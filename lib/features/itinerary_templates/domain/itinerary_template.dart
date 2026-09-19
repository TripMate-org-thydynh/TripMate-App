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
    this.tags = const [],
    this.isFeatured = false,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
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
  final List<String> tags;
  final bool isFeatured;
  final double ratingAvg;
  final int ratingCount;

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
      tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isFeatured: j['isFeatured'] as bool? ?? false,
      ratingAvg: (j['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (j['ratingCount'] as num?)?.toInt() ?? 0,
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

/// Trạng thái của user hiện tại với mẫu (`GET /itinerary-templates/:id/me`).
class TemplateMyState {
  const TemplateMyState({
    required this.used,
    this.myStars,
  });

  final bool used;
  final int? myStars;

  factory TemplateMyState.fromJson(Map<String, dynamic> j) {
    return TemplateMyState(
      used: j['used'] as bool? ?? false,
      myStars: (j['myStars'] as num?)?.toInt(),
    );
  }
}

/// Người nhận xét đánh giá mẫu.
class TemplateRatingUser {
  const TemplateRatingUser({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  factory TemplateRatingUser.fromJson(Map<String, dynamic> j) {
    return TemplateRatingUser(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      avatarUrl: j['avatarUrl'] as String?,
    );
  }
}

/// Một lượt nhận xét đánh giá (`GET /itinerary-templates/:id/ratings`).
class TemplateRating {
  const TemplateRating({
    required this.stars,
    this.comment,
    this.updatedAt,
    required this.user,
  });

  final int stars;
  final String? comment;
  final DateTime? updatedAt;
  final TemplateRatingUser user;

  factory TemplateRating.fromJson(Map<String, dynamic> j) {
    return TemplateRating(
      stars: (j['stars'] as num?)?.toInt() ?? 5,
      comment: j['comment'] as String?,
      updatedAt: j['updatedAt'] != null
          ? DateTime.tryParse(j['updatedAt'].toString())
          : null,
      user: TemplateRatingUser.fromJson(
        (j['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

/// Bộ thẻ cố định cho lịch trình mẫu.
class TemplateTags {
  static const chill = 'CHILL';
  static const adventure = 'ADVENTURE';
  static const foodie = 'FOODIE';
  static const party = 'PARTY';
  static const culture = 'CULTURE';
  static const nature = 'NATURE';
  static const budgetLow = 'BUDGET_LOW';
  static const budgetMid = 'BUDGET_MID';
  static const budgetHigh = 'BUDGET_HIGH';

  static const all = [
    chill,
    adventure,
    foodie,
    party,
    culture,
    nature,
    budgetLow,
    budgetMid,
    budgetHigh,
  ];

  static const budget = [
    budgetLow,
    budgetMid,
    budgetHigh,
  ];

  static bool isBudget(String tag) => budget.contains(tag);
}
