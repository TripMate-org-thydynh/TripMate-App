import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Số liệu tổng kết một chuyến (Trip Wrapped).
///
/// Trước đây màn Wrapped in cứng "7 địa điểm / 142 khoảnh khắc / 186 km", MVP
/// "Thảo Ly" và tổng chi 6.020.000đ — giống hệt nhau ở mọi chuyến. Nay lấy từ
/// `/trips/:id/recap`, đếm thật trong DB.
class TripRecap {
  final String tripName;
  final String? destination;
  final String? coverImage;
  final int days;
  final int memberCount;
  final int placeCount;
  final int momentCount;
  final int expenseCount;
  final double totalSpent;
  final String currency;
  final String? mvpName;
  final String? mvpAvatarUrl;
  final List<TripRecapMember> members;
  final List<TripRecapMoment> moments;

  /// `false` khi chuyến chưa có điểm lịch trình, khoảnh khắc lẫn khoản chi.
  final bool hasData;

  const TripRecap({
    required this.tripName,
    this.destination,
    this.coverImage,
    required this.days,
    required this.memberCount,
    required this.placeCount,
    required this.momentCount,
    required this.expenseCount,
    required this.totalSpent,
    required this.currency,
    required this.hasData,
    this.mvpName,
    this.mvpAvatarUrl,
    this.members = const [],
    this.moments = const [],
  });

  /// Chi bình quân đầu người — 0 khi chuyến chưa có thành viên nào.
  double get perHead => memberCount == 0 ? 0 : totalSpent / memberCount;

  factory TripRecap.fromJson(Map<String, dynamic> json) {
    final mvp = json['mvp'];
    final members = json['members'];
    final moments = json['moments'];
    return TripRecap(
      tripName: json['tripName'] as String? ?? '',
      destination: json['destination'] as String?,
      coverImage: json['coverImage'] as String?,
      days: (json['days'] as num?)?.toInt() ?? 0,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      placeCount: (json['placeCount'] as num?)?.toInt() ?? 0,
      momentCount: (json['momentCount'] as num?)?.toInt() ?? 0,
      expenseCount: (json['expenseCount'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'VND',
      hasData: json['hasData'] as bool? ?? false,
      mvpName: mvp is Map ? mvp['name'] as String? : null,
      mvpAvatarUrl: mvp is Map ? mvp['avatarUrl'] as String? : null,
      members: members is List
          ? members
                .whereType<Map>()
                .map((e) => TripRecapMember.fromJson(e.cast<String, dynamic>()))
                .toList()
          : const [],
      moments: moments is List
          ? moments
                .whereType<Map>()
                .map((e) => TripRecapMoment.fromJson(e.cast<String, dynamic>()))
                .toList()
          : const [],
    );
  }
}

class TripRecapMember {
  final String id;
  final String name;
  final String? avatarUrl;

  const TripRecapMember({required this.id, required this.name, this.avatarUrl});

  factory TripRecapMember.fromJson(Map<String, dynamic> json) =>
      TripRecapMember(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class TripRecapMoment {
  final String id;
  final String mediaUrl;
  final String posterUrl;
  final String type;
  final String? caption;
  final String authorName;
  final String? authorAvatarUrl;
  final int reactionCount;
  final int commentCount;

  const TripRecapMoment({
    required this.id,
    required this.mediaUrl,
    required this.posterUrl,
    required this.type,
    this.caption,
    required this.authorName,
    this.authorAvatarUrl,
    this.reactionCount = 0,
    this.commentCount = 0,
  });

  factory TripRecapMoment.fromJson(Map<String, dynamic> json) =>
      TripRecapMoment(
        id: json['id'] as String? ?? '',
        mediaUrl: json['mediaUrl'] as String? ?? '',
        posterUrl:
            json['posterUrl'] as String? ?? json['mediaUrl'] as String? ?? '',
        type: json['type'] as String? ?? 'PHOTO',
        caption: json['caption'] as String?,
        authorName: json['authorName'] as String? ?? '',
        authorAvatarUrl: json['authorAvatarUrl'] as String?,
        reactionCount: (json['reactionCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      );
}

final tripRecapProvider = FutureProvider.family<TripRecap, String>((
  ref,
  tripId,
) async {
  final data = await ref
      .watch(apiClientProvider)
      .getData('/trips/$tripId/recap');
  return TripRecap.fromJson((data as Map).cast<String, dynamic>());
});
