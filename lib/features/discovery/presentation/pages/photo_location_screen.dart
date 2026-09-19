import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:tripmate/core/theme/app_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/api_service.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/map/map_tiles.dart';

/// Phân tích ảnh → check vị trí trên bản đồ.
/// Gửi ảnh (base64) lên BE: EXIF GPS trước, không có thì Gemini vision đoán.
/// Hiển thị kết quả trên OpenStreetMap (flutter_map, free).
class PhotoLocationScreen extends StatefulWidget {
  final bool isDarkMode;
  const PhotoLocationScreen({super.key, this.isDarkMode = false});

  @override
  State<PhotoLocationScreen> createState() => _PhotoLocationScreenState();
}

class _PhotoLocationScreenState extends State<PhotoLocationScreen> {
  final _picker = ImagePicker();
  final _map = MapController();

  bool _loading = false;
  String? _error;
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
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 88,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
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
                  ),
                  children: [
                    ...mapTileLayers(
                      dark: Theme.of(context).brightness == Brightness.dark,
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
                  const SizedBox(height: GenZTokens.space3),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: GenZTokens.space3),
                    child: Text(
                      'photo.where_sub'.tr(),
                      style: AppFonts.body(color: _sub, fontSize: 13),
                    ),
                  ),
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
            isExif ? 'photo.src_gps'.tr() : 'photo.src_ai'.tr(),
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
