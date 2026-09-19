import '../../trip_planner/domain/itinerary_item.dart';

/// Lịch trình mẫu do người dùng đăng — khớp BE `itinerary-templates`.
///
/// Là bản chụp tại lúc đăng; nhân bản xong người dùng sửa thoải mái trên bản
/// của mình, không ảnh hưởng mẫu.
class ItineraryTemplate {
  const ItineraryTemplate({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.title,
    this.description,
    this.destination,
    this.coverImage,
    this.vibe,
    required this.dayCount,
    required this.stopCount,
    required this.isPublic,
    required this.useCount,
    this.items = const [],
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String? description;
  final String? destination;
  final String? coverImage;
  final String? vibe;
  final int dayCount;
  final int stopCount;
  final bool isPublic;
  final int useCount;

  /// Chỉ có khi lấy chi tiết (`GET /itinerary-templates/:id`).
  final List<ItineraryItem> items;

  /// Điểm dừng gom theo ngày, đúng thứ tự giờ.
  Map<int, List<ItineraryItem>> get byDay {
    final m = <int, List<ItineraryItem>>{};
    for (final i in items) {
      m.putIfAbsent(i.day, () => []).add(i);
    }
    return m;
  }

  factory ItineraryTemplate.fromJson(Map<String, dynamic> j) {
    final author = (j['author'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ItineraryTemplate(
      id: j['id'] as String,
      authorId: j['authorId'] as String? ?? '',
      authorName: author['name'] as String? ?? '',
      authorAvatar: author['avatarUrl'] as String?,
      title: j['title'] as String? ?? '',
      description: j['description'] as String?,
      destination: j['destination'] as String?,
      coverImage: j['coverImage'] as String?,
      vibe: j['vibe'] as String?,
      dayCount: (j['dayCount'] as num?)?.toInt() ?? 1,
      stopCount: (j['stopCount'] as num?)?.toInt() ?? 0,
      isPublic: j['isPublic'] as bool? ?? true,
      useCount: (j['useCount'] as num?)?.toInt() ?? 0,
      items: (j['items'] as List? ?? const []).whereType<Map>().map((e) {
        final m = e.cast<String, dynamic>();
        // Decimal của Prisma có thể về dạng chuỗi.
        double? toD(dynamic v) =>
            v is num ? v.toDouble() : double.tryParse('$v');
        return ItineraryItem.fromJson({
          ...m,
          'latitude': m['latitude'] == null ? null : toD(m['latitude']),
          'longitude': m['longitude'] == null ? null : toD(m['longitude']),
        });
      }).toList(),
    );
  }
}
