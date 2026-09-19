import 'package:flutter_map/flutter_map.dart';

/// Nguồn tile bản đồ dùng chung cho mọi màn — một chỗ để đổi nhà cung cấp.
///
/// Esri Canvas (xám nhạt / xám đậm): tông trung tính, hợp bộ màu kem–graphite,
/// không cần API key. Nền không có chữ nên phủ thêm lớp nhãn (Reference).
///
/// Đã bỏ: `tile.openstreetmap.org` (bị chặn ở một số mạng, chính sách OSM cấm
/// app dùng tải nặng) và CARTO `basemaps.cartocdn.com` (nay in watermark
/// "API KEY REQUIRED" lên tile).
List<TileLayer> mapTileLayers({required bool dark}) {
  final tone = dark ? 'Dark' : 'Light';
  const base = 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas';
  return [
    TileLayer(
      urlTemplate: '$base/World_${tone}_Gray_Base/MapServer/tile/{z}/{y}/{x}',
      userAgentPackageName: 'com.tripmate.app',
      maxNativeZoom: 16,
    ),
    TileLayer(
      urlTemplate:
          '$base/World_${tone}_Gray_Reference/MapServer/tile/{z}/{y}/{x}',
      userAgentPackageName: 'com.tripmate.app',
      maxNativeZoom: 16,
    ),
  ];
}

/// Dòng ghi nguồn bắt buộc theo điều khoản Esri.
const String kMapAttribution = 'Esri, HERE, Garmin, © OpenStreetMap';
