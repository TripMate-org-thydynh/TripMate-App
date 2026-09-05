import 'package:easy_localization/easy_localization.dart';
// Model Moment — khớp BE `moments` module.
class Moment {
  final String id;
  final String mediaUrl;
  final String type;
  final bool isGhost;
  final String? caption;
  final String authorName;
  final String? authorAvatar;
  final int commentCount;
  final int reactionCount;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? placeName;

  const Moment({
    required this.id,
    required this.mediaUrl,
    required this.type,
    this.isGhost = false,
    this.caption,
    required this.authorName,
    this.authorAvatar,
    this.commentCount = 0,
    this.reactionCount = 0,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.placeName,
  });

  factory Moment.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    final count = j['_count'];
    return Moment(
      id: j['id'] as String,
      mediaUrl: j['mediaUrl'] as String? ?? '',
      type: j['type'] as String? ?? 'PHOTO',
      isGhost: j['isGhost'] as bool? ?? false,
      caption: j['caption'] as String?,
      authorName: user is Map
          ? (user['name'] as String? ?? 'common.anonymous'.tr())
          : 'common.anonymous'.tr(),
      authorAvatar: user is Map ? user['avatarUrl'] as String? : null,
      commentCount: count is Map ? (count['comments'] as int? ?? 0) : 0,
      reactionCount: count is Map ? (count['reactions'] as int? ?? 0) : 0,
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      latitude: j['latitude'] != null
          ? (j['latitude'] as num).toDouble()
          : null,
      longitude: j['longitude'] != null
          ? (j['longitude'] as num).toDouble()
          : null,
      placeName: j['placeName'] as String?,
    );
  }

  Moment copyWith({
    int? reactionCount,
    double? latitude,
    double? longitude,
    String? placeName,
  }) => Moment(
    id: id,
    mediaUrl: mediaUrl,
    type: type,
    isGhost: isGhost,
    caption: caption,
    authorName: authorName,
    authorAvatar: authorAvatar,
    commentCount: commentCount,
    reactionCount: reactionCount ?? this.reactionCount,
    createdAt: createdAt,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    placeName: placeName ?? this.placeName,
  );
}
