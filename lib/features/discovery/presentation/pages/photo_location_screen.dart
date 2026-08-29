import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:tripmate/core/theme/app_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/api_service.dart';
import '../../../../core/theme/gen_z_tokens.dart';

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
  Map<String, dynamic>? _result; // {source, latitude, longitude, placeName, ...}

  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _sub =>
      widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _surface =>
      widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

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

      final mime = file.mimeType ??
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
          _error = (res is Map ? res['message'] as String? : null) ??
              'Không xác định được vị trí từ ảnh này.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không đọc được ảnh. Thử ảnh khác nhé.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    final hasLoc = r != null && r['latitude'] != null;
    final center = hasLoc
        ? LatLng((r['latitude'] as num).toDouble(),
            (r['longitude'] as num).toDouble())
        : const LatLng(16.047, 108.206); // Đà Nẵng default

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'Ảnh này ở đâu? 📍',
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: _ink,
            letterSpacing: -0.5,
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
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tripmate.app',
                    ),
                    if (hasLoc)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 54,
                            height: 54,
                            child: Icon(
                              Icons.location_on,
                              size: 54,
                              color: GenZTokens.red,
                              shadows: const [
                                Shadow(color: Colors.black45, blurRadius: 4),
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
                          CircularProgressIndicator(color: _ink),
                          const SizedBox(height: 14),
                          Text(
                            'Đang soi ảnh...',
                            style: AppFonts.body(
                              color: _ink,
                              fontWeight: FontWeight.w700,
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
                top: BorderSide(color: _ink, width: GenZTokens.borderWidth),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_preview != null) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _preview!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _resultBody()),
                    ],
                  ),
                  const SizedBox(height: 14),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Chọn 1 tấm ảnh, mình đoán nó chụp ở đâu và ghim lên bản đồ 🗺️',
                      style: AppFonts.body(color: _sub, fontSize: 14),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _pickBtn(
                        icon: Icons.photo_library_rounded,
                        label: 'Thư viện',
                        color: GenZTokens.yellow,
                        onTap: () => _pick(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pickBtn(
                        icon: Icons.camera_alt_rounded,
                        label: 'general.capture'.tr(),
                        color: GenZTokens.lilac,
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
          color: GenZTokens.red,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    }
    final r = _result;
    if (r == null) {
      return Text(
        'Đang phân tích...',
        style: AppFonts.body(color: _sub),
      );
    }
    final isExif = r['source'] == 'exif';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          r['placeName']?.toString() ?? 'general.place'.tr(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isExif ? GenZTokens.green : GenZTokens.orange,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _ink, width: 1.5),
          ),
          child: Text(
            isExif ? 'GPS trong ảnh · chính xác' : 'AI đoán từ hình ảnh',
            style: AppFonts.mono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: GenZTokens.ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pickBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          border: Border.all(color: _ink, width: GenZTokens.borderWidth),
          boxShadow: GenZTokens.hardShadow(_ink),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: GenZTokens.ink, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: GenZTokens.ink,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
