/// Nhập địa điểm từ link bản đồ.
///
/// **Trước đây toàn bộ file này là mock** (BUG-016): dán bất kỳ link Google Maps
/// nào cũng trả về "Bãi Sao Phú Quốc", link TripAdvisor bất kỳ trả về
/// "InterContinental Phú Quốc", còn nhánh mặc định thì sinh
/// `TripAdvisor Featured Attraction ${Random().nextInt(100)}` với **toạ độ ngẫu
/// nhiên**. Kết quả đó không dừng ở màn hình — nó được `trip_map_screen.dart`
/// ghi thẳng vào database qua `itineraryRepository.create()`. Người dùng dán
/// link một quán ở Hà Nội và lịch trình của họ có thêm một quán ở Phú Quốc.
///
/// Nay chỉ đọc **toạ độ có thật nằm trong chính URL**. Link nào không mang toạ
/// độ thì trả `null` để tầng UI nói thẳng là không nhập được — thà không có
/// tính năng còn hơn ghi dữ liệu sai vào chuyến của người dùng.
library;

class ImportedPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String category;

  const ImportedPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.category,
  });
}

class PlaceImportService {
  PlaceImportService._();

  /// Các dạng URL Google Maps có mang toạ độ:
  ///   - `/@10.7769,106.7009,17z`      → tâm bản đồ
  ///   - `!3d10.7769!4d106.7009`       → toạ độ của địa điểm được ghim
  ///   - `?q=10.7769,106.7009`         → truy vấn theo toạ độ
  ///   - `?ll=10.7769,106.7009`
  static final _patterns = <RegExp>[
    RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)'),
    RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)'),
    RegExp(r'[?&](?:q|ll|daddr|center)=(-?\d+\.\d+),\s*(-?\d+\.\d+)'),
  ];

  /// Lấy tên địa điểm từ đoạn `/place/<Ten+Dia+Diem>/` nếu có.
  static final _namePattern = RegExp(r'/place/([^/@?]+)');

  /// Đọc địa điểm từ link. Trả `null` nếu link không chứa toạ độ.
  static ImportedPlace? parseExternalLink(String url) {
    final raw = url.trim();
    if (raw.isEmpty) return null;

    // Chỉ chấp nhận link bản đồ; link rút gọn (goo.gl/maps) không mang toạ độ
    // nên cũng rơi vào nhánh trả null bên dưới.
    final lower = raw.toLowerCase();
    final isMapLink =
        lower.contains('google.com/maps') ||
        lower.contains('maps.google') ||
        lower.contains('maps.app.goo.gl') ||
        lower.contains('goo.gl/maps') ||
        lower.contains('openstreetmap.org');
    if (!isMapLink) return null;

    for (final p in _patterns) {
      final m = p.firstMatch(raw);
      if (m == null) continue;
      final lat = double.tryParse(m.group(1)!);
      final lng = double.tryParse(m.group(2)!);
      if (lat == null || lng == null) continue;
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;

      return ImportedPlace(
        name: _nameFrom(raw) ?? _coordLabel(lat, lng),
        address: _coordLabel(lat, lng),
        latitude: lat,
        longitude: lng,
        // Link không cho biết loại địa điểm; không đoán bừa.
        category: 'OTHER',
      );
    }
    return null;
  }

  static String? _nameFrom(String url) {
    final m = _namePattern.firstMatch(url);
    if (m == null) return null;
    final decoded = Uri.decodeComponent(m.group(1)!).replaceAll('+', ' ').trim();
    return decoded.isEmpty ? null : decoded;
  }

  static String _coordLabel(double lat, double lng) =>
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}
