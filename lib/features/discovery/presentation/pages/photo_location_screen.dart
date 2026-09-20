import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:tripmate/core/theme/app_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../trip_planner/data/itinerary_repository.dart';
import '../../../trips/presentation/pick_trip_sheet.dart';
import '../../../../core/api_service.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/map/map_tiles.dart';

/// Phân tích ảnh → check vị trí trên bản đồ.
/// Gửi ảnh (base64) lên BE: EXIF GPS trước, không có thì Gemini vision đoán.
/// Hiển thị kết quả trên OpenStreetMap (flutter_map, free).
class PhotoLocationScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  /// Chuyến đang mở (nếu có) — điểm đến của chuyến là gợi ý cho AI.
  final String? tripId;
  const PhotoLocationScreen({super.key, this.isDarkMode = false, this.tripId});

  @override
  ConsumerState<PhotoLocationScreen> createState() =>
      _PhotoLocationScreenState();
}

class _PhotoLocationScreenState extends ConsumerState<PhotoLocationScreen> {
  final _picker = ImagePicker();
  final _map = MapController();

  bool _loading = false;
  String? _error;

  /// Vị trí người dùng tự ghim trên bản đồ — luôn thắng phỏng đoán của AI.
  LatLng? _pinned;
  bool _saving = false;
  Uint8List? _preview;
  Map<String, dynamic>?
  _result; // {source, latitude, longitude, placeName, ...}

  Color get _bg => widget.isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _sub =>
      widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _surface =>
      widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _line => widget.isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => widget.isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _accent =>
      widget.isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      widget.isDarkMode ? GenZTokens.onAccentDark : GenZTokens.onAccent;

  Future<void> _pick(ImageSource source) async {
    try {
      // KHÔNG đặt maxWidth/imageQuality: image_picker nén lại ảnh và XOÁ EXIF,
      // mất luôn GPS — bước xác định vị trí chính xác nhất. Chỉ nén khi ảnh
      // vượt giới hạn 16MB của API (hiếm), lúc đó đành chịu mất GPS.
      var file = await _picker.pickImage(
        source: source,
        requestFullMetadata: true,
      );
      if (file == null) return;
      var bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 16 * 1024 * 1024) {
        final small = await _picker.pickImage(
          source: source,
          maxWidth: 2048,
          imageQuality: 90,
        );
        if (small == null) return;
        file = small;
        bytes = await small.readAsBytes();
      }
      setState(() {
        _preview = bytes;
        _loading = true;
        _error = null;
        _result = null;
      });
      HapticFeedback.mediumImpact();

      final mime =
          file.mimeType ??
          (file.path.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');
      final res = await ApiService.post('/ai/photo-location', {
        'imageBase64': base64Encode(bytes),
        'mimeType': mime,
        'tripId': ?widget.tripId,
      });

      if (!mounted) return;
      if (res is Map && res['found'] == true) {
        setState(() {
          _result = res.cast<String, dynamic>();
          _loading = false;
        });
        final lat = (res['latitude'] as num).toDouble();
        final lng = (res['longitude'] as num).toDouble();
        _map.move(LatLng(lat, lng), 13);
      } else if (res is Map &&
          (res['candidates'] as List? ?? const []).isNotEmpty) {
        // Không chốt được toạ độ nhưng có phương án + manh mối → vẫn hiện.
        setState(() {
          _result = res.cast<String, dynamic>();
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error =
              (res is Map ? res['message'] as String? : null) ??
              'photo.no_location'.tr();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'reservations.photo_failed'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    final hasLoc = r != null && r['latitude'] != null;
    final center = hasLoc
        ? LatLng(
            (r['latitude'] as num).toDouble(),
            (r['longitude'] as num).toDouble(),
          )
        : const LatLng(16.047, 108.206); // Đà Nẵng default

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'photo.where_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _ink,
          ),
        ),
      ),
      body: Column(
        children: [
          // Bản đồ OSM
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: hasLoc ? 13 : 5,
                    // Chạm bản đồ để tự ghim đúng chỗ khi AI đoán sai hoặc
                    // không ra toạ độ — người chụp mới là người biết.
                    onTap: (_, p) => setState(() => _pinned = p),
                  ),
                  children: [
                    ...mapTileLayers(
                      dark: Theme.of(context).brightness == Brightness.dark,
                    ),
                    if (_pinned != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pinned!,
                            width: 44,
                            height: 44,
                            child: Icon(
                              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                              color: _accent,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    if (hasLoc)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 48,
                            height: 48,
                            child: Icon(
                              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                              size: 48,
                              color: _accent,
                              shadows: [
                                Shadow(
                                  color: _ink.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_loading)
                  Container(
                    color: _bg.withValues(alpha: 0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(_accent),
                          ),
                          const SizedBox(height: GenZTokens.space3),
                          Text(
                            'photo.scanning'.tr(),
                            style: AppFonts.body(
                              color: _ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Kết quả + nút chọn ảnh
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _surface,
              border: Border(
                top: BorderSide(
                  color: _line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              GenZTokens.space4,
              GenZTokens.space4,
              GenZTokens.space4,
              GenZTokens.space4 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_preview != null) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                        child: Image.memory(
                          _preview!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: GenZTokens.space3),
                      Expanded(child: _resultBody()),
                    ],
                  ),
                  _note(),
                  _details(),
                  const SizedBox(height: GenZTokens.space3),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: GenZTokens.space3),
                    child: Text(
                      'photo.where_sub'.tr(),
                      style: AppFonts.body(color: _sub, fontSize: 13),
                    ),
                  ),
                _pinPanel(),
                Row(
                  children: [
                    Expanded(
                      child: _pickBtn(
                        icon: PhosphorIcons.image(),
                        label: 'common.gallery'.tr(),
                        isPrimary: true,
                        onTap: () => _pick(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: GenZTokens.space3),
                    Expanded(
                      child: _pickBtn(
                        icon: PhosphorIcons.camera(),
                        label: 'general.capture'.tr(),
                        isPrimary: false,
                        onTap: () => _pick(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultBody() {
    if (_error != null) {
      return Text(
        _error!,
        style: AppFonts.body(
          color: widget.isDarkMode ? GenZTokens.dangerDark : GenZTokens.danger,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    }
    final r = _result;
    if (r == null) {
      return Text('common.analyzing'.tr(), style: AppFonts.body(color: _sub));
    }
    final isExif = r['source'] == 'exif';
    final srcColor = isExif
        ? (widget.isDarkMode ? GenZTokens.successDark : GenZTokens.success)
        : (widget.isDarkMode ? GenZTokens.infoDark : GenZTokens.info);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          r['placeName']?.toString() ?? 'general.place'.tr(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _ink,
          ),
        ),
        const SizedBox(height: GenZTokens.space1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: srcColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            border: Border.all(
              color: srcColor.withValues(alpha: 0.3),
              width: GenZTokens.borderWidthThin,
            ),
          ),
          child: Text(
            isExif
                ? 'photo.src_gps'.tr()
                : r['coordSource'] == 'ai_estimate'
                ? 'photo.src_ai_estimate'.tr()
                : r['coordSource'] == 'none'
                ? 'photo.src_ai_no_coord'.tr()
                : 'photo.src_ai'.tr(),
            style: AppFonts.mono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: srcColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Khối vị trí tự ghim: toạ độ + nút lưu vào lịch trình một chuyến.
  Widget _pinPanel() {
    final p = _pinned;
    if (p == null) {
      if (_result == null && _error == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: GenZTokens.space2),
        child: Text(
          'photo.pin_hint'.tr(),
          style: AppFonts.body(fontSize: 12, color: _sub),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: GenZTokens.space3),
      padding: const EdgeInsets.all(GenZTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'photo.pinned'.tr(),
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                Text(
                  '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}',
                  style: AppFonts.mono(fontSize: 12, color: _sub),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _pinned = null),
            child: Text('general.cancel'.tr()),
          ),
          FilledButton(
            onPressed: _saving ? null : _savePinned,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('photo.pin_save'.tr()),
          ),
        ],
      ),
    );
  }

  /// Lưu vị trí đã ghim thành một điểm dừng trong lịch trình chuyến người dùng chọn.
  Future<void> _savePinned() async {
    final p = _pinned;
    if (p == null) return;
    final trip = await PickTripSheet.show(
      context,
      widget.isDarkMode,
      title: 'photo.pin_pick_trip'.tr(),
    );
    if (trip == null || !mounted) return;

    final nameCtrl = TextEditingController(
      text: _result?['placeName']?.toString() ?? '',
    );
    final dayCtrl = TextEditingController(text: '1');
    final timeCtrl = TextEditingController(text: '09:00');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: Text(
          'photo.pin_save_title'.tr(),
          style: AppFonts.heading(fontSize: 17, color: _ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: AppFonts.body(fontSize: 15, color: _ink),
              decoration: InputDecoration(
                labelText: 'itinerary.place_name'.tr(),
                labelStyle: AppFonts.body(fontSize: 13, color: _sub),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dayCtrl,
                    keyboardType: TextInputType.number,
                    style: AppFonts.body(fontSize: 15, color: _ink),
                    decoration: InputDecoration(
                      labelText: 'itinerary.day_label'.tr(),
                      labelStyle: AppFonts.body(fontSize: 13, color: _sub),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: timeCtrl,
                    style: AppFonts.body(fontSize: 15, color: _ink),
                    decoration: InputDecoration(
                      labelText: 'itinerary.time_hint'.tr(),
                      labelStyle: AppFonts.body(fontSize: 13, color: _sub),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('general.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('general.save'.tr()),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(itineraryRepositoryProvider)
          .create(
            trip.id,
            day: int.tryParse(dayCtrl.text.trim()) ?? 1,
            startTime: timeCtrl.text.trim().isEmpty
                ? '09:00'
                : timeCtrl.text.trim(),
            placeName: nameCtrl.text.trim().isEmpty
                ? 'photo.pinned'.tr()
                : nameCtrl.text.trim(),
            latitude: p.latitude,
            longitude: p.longitude,
          );
      ref.invalidate(tripItineraryProvider(trip.id));
      showGlobalSnack('photo.pin_saved'.tr(namedArgs: {'trip': trip.name}));
      if (mounted) setState(() => _pinned = null);
    } catch (e) {
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Lời nhắn của server khi chỉ đoán được tên, chưa có toạ độ.
  Widget _note() {
    final msg = _result?['message'];
    if (msg is! String || msg.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: GenZTokens.space2),
      child: Text(msg, style: AppFonts.body(fontSize: 12, color: _sub)),
    );
  }

  /// Các phương án khác + manh mối AI đọc được trong ảnh.
  Widget _details() {
    final r = _result;
    if (r == null || r['source'] == 'exif') return const SizedBox.shrink();
    final cands = (r['candidates'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    final clues = (r['clues'] as List? ?? const []).map((e) => '$e').toList();
    if (cands.length < 2 && clues.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: GenZTokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cands.length > 1) ...[
              Text(
                'photo.candidates'.tr(),
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in cands)
                    ChoiceChip(
                      label: Text(
                        '${c['placeName']} · ${((c['confidence'] as num? ?? 0) * 100).round()}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: c['placeName'] == r['placeName'],
                      showCheckmark: false,
                      labelStyle: AppFonts.body(
                        fontSize: 12,
                        color: c['placeName'] == r['placeName']
                            ? _onAccent
                            : _ink,
                      ),
                      selectedColor: _accent,
                      backgroundColor: _fill,
                      side: BorderSide(color: _line),
                      onSelected: (_) {
                        // Phương án chưa tra được toạ độ: chỉ hiện tên, không
                        // di chuyển bản đồ (không có chỗ nào để ghim).
                        if (c['latitude'] == null) {
                          setState(() {
                            _result = {
                              ...r,
                              'placeName': c['placeName'],
                              'confidence': c['confidence'],
                              'precision': c['precision'],
                              'coordSource': 'none',
                            };
                          });
                          return;
                        }
                        setState(() {
                          _result = {
                            ...r,
                            'placeName': c['placeName'],
                            'latitude': c['latitude'],
                            'longitude': c['longitude'],
                            'confidence': c['confidence'],
                            'precision': c['precision'],
                            'coordSource': c['coordSource'],
                          };
                        });
                        _map.move(
                          LatLng(
                            (c['latitude'] as num).toDouble(),
                            (c['longitude'] as num).toDouble(),
                          ),
                          c['precision'] == 'exact' ? 15 : 11,
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: GenZTokens.space3),
            ],
            if (clues.isNotEmpty) ...[
              Text(
                'photo.clues'.tr(),
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              for (final c in clues)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Icon(
                          PhosphorIcons.magnifyingGlass(),
                          size: 12,
                          color: _sub,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c,
                          style: AppFonts.body(fontSize: 12, color: _sub),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pickBtn({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final bg = isPrimary ? _accent : _fill;
    final fg = isPrimary ? _onAccent : _ink;
    final border = isPrimary
        ? BorderSide.none
        : BorderSide(color: _line, width: GenZTokens.borderWidthThin);

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: GenZTokens.space2),
            Text(
              label,
              style: AppFonts.heading(
                fontWeight: FontWeight.w600,
                color: fg,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
