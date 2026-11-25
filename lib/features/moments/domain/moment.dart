import 'package:easy_localization/easy_localization.dart';

class MomentComment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;

  const MomentComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
  });

  factory MomentComment.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    return MomentComment(
      id: j['id'] as String? ?? '',
      content: j['content'] as String? ?? '',
      authorId: user is Map ? (user['id'] as String? ?? '') : '',
      authorName: user is Map
          ? (user['name'] as String? ?? 'common.anonymous'.tr())
          : 'common.anonymous'.tr(),
      authorAvatar: user is Map ? user['avatarUrl'] as String? : null,
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

class MomentReaction {
  final String id;
  final String emoji;
  final String userId;
  final String userName;

  const MomentReaction({
    required this.id,
    required this.emoji,
    required this.userId,
    required this.userName,
  });

  factory MomentReaction.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    return MomentReaction(
      id: j['id'] as String? ?? '',
      emoji: j['emoji'] as String? ?? '❤️',
      userId: user is Map
          ? (user['id'] as String? ?? '')
          : (j['userId'] as String? ?? ''),
      userName: user is Map ? (user['name'] as String? ?? '') : '',
    );
  }
}

/// Model Moment — khớp BE `moments` module + Shared Memory Photo Board fields.
class Moment {
  final String id;
  final String mediaUrl;
  final String type;
  final bool isGhost;

  /// Ghost Cam: ảnh của chính mình còn đang "tráng" — server chỉ trả cờ này
  /// cho người chụp; người khác chưa thấy ảnh cho tới [revealAt].
  final bool developing;
  final DateTime? revealAt;
  final String? caption;
  final String authorName;

  /// Id người đăng — để biết ảnh nào của mình (không tự báo cáo).
  final String? authorId;
  final String? authorAvatar;
  final int commentCount;
  final int reactionCount;
  final DateTime createdAt;
  final DateTime? takenAt;
  final double? latitude;
  final double? longitude;
  final String? placeName;

  // Shared Memory Photo Board persistent layout & styling fields
  final double? boardX;
  final double? boardY;
  final double? boardRotation;
  final double boardScale;
  final String boardFilter;
  final String? noteColor;
  final bool isPinned;
  final bool isFavorite;

  final List<MomentComment> comments;
  final List<MomentReaction> reactions;

  const Moment({
    required this.id,
    required this.mediaUrl,
    required this.type,
    this.isGhost = false,
    this.developing = false,
    this.revealAt,
    this.caption,
    required this.authorName,
    this.authorId,
    this.authorAvatar,
    this.commentCount = 0,
    this.reactionCount = 0,
    required this.createdAt,
    this.takenAt,
    this.latitude,
    this.longitude,
    this.placeName,
    this.boardX,
    this.boardY,
    this.boardRotation,
    this.boardScale = 1.0,
    this.boardFilter = 'CLASSIC',
    this.noteColor,
    this.isPinned = false,
    this.isFavorite = false,
    this.comments = const [],
    this.reactions = const [],
  });

  bool get isNoteOnly => mediaUrl.trim().isEmpty || type == 'NOTE';

  factory Moment.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    final count = j['_count'];
    final rawComments = j['comments'];
    final rawReactions = j['reactions'];
    final parsedComments = rawComments is List
        ? rawComments
              .whereType<Map>()
              .map((c) => MomentComment.fromJson(c.cast<String, dynamic>()))
              .toList()
        : const <MomentComment>[];
    final parsedReactions = rawReactions is List
        ? rawReactions
              .whereType<Map>()
              .map((r) => MomentReaction.fromJson(r.cast<String, dynamic>()))
              .toList()
        : const <MomentReaction>[];

    return Moment(
      id: j['id'] as String? ?? '',
      mediaUrl: j['mediaUrl'] as String? ?? '',
      type: j['type'] as String? ?? 'PHOTO',
      isGhost: j['isGhost'] as bool? ?? false,
      developing: j['developing'] as bool? ?? false,
      revealAt: DateTime.tryParse(j['revealAt']?.toString() ?? '')?.toLocal(),
      caption: j['caption'] as String?,
      authorName: user is Map
          ? (user['name'] as String? ?? 'common.anonymous'.tr())
          : (j['authorName'] as String? ?? 'common.anonymous'.tr()),
      authorAvatar: user is Map
          ? user['avatarUrl'] as String?
          : j['authorAvatar'] as String?,
      authorId: user is Map
          ? user['id'] as String?
          : j['userId'] as String?,
      commentCount: count is Map
          ? (count['comments'] as int? ?? parsedComments.length)
          : parsedComments.length,
      reactionCount: count is Map
          ? (count['reactions'] as int? ?? parsedReactions.length)
          : parsedReactions.length,
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      takenAt: DateTime.tryParse(j['takenAt']?.toString() ?? '')?.toLocal(),
      latitude: j['latitude'] != null
          ? (j['latitude'] as num).toDouble()
          : null,
      longitude: j['longitude'] != null
          ? (j['longitude'] as num).toDouble()
          : null,
      placeName: j['placeName'] as String?,
      boardX: j['boardX'] != null ? (j['boardX'] as num).toDouble() : null,
      boardY: j['boardY'] != null ? (j['boardY'] as num).toDouble() : null,
      boardRotation: j['boardRotation'] != null
          ? (j['boardRotation'] as num).toDouble()
          : null,
      boardScale: j['boardScale'] != null
          ? (j['boardScale'] as num).toDouble()
          : 1.0,
      boardFilter: (j['boardFilter'] as String?)?.toUpperCase() ?? 'CLASSIC',
      noteColor: j['noteColor'] as String?,
      isPinned: j['isPinned'] as bool? ?? false,
      isFavorite: j['isFavorite'] as bool? ?? false,
      comments: parsedComments,
      reactions: parsedReactions,
    );
  }

  /// Deterministic board coordinates `(x, y, rotationRad)` supporting both:
  /// 1. **Vertical Journey Mode (`isHorizontalRopeMode: false`)**: Winding top-to-bottom trail.
  /// 2. **Horizontal Stage Mode (`isHorizontalRopeMode: true`)**: Sweeping horizontal rope rows per day/stage.
  ({double x, double y, double rotation}) resolveBoardPosition(
    int indexInGroup,
    int groupRowIndex, {
    bool isHorizontalRopeMode = false,
    bool forceAlgorithmic = false,
  }) {
    final seed = id.codeUnits.fold<int>(
      0,
      (acc, c) => (acc * 31 + c) & 0x7fffffff,
    );

    if (isHorizontalRopeMode) {
      const slotOffsetsX = <double>[95.0, 370.0, 665.0, 960.0, 1255.0];
      final slot = indexInGroup % slotOffsetsX.length;
      final subStrand = indexInGroup ~/ slotOffsetsX.length;
      final strandIndex = groupRowIndex + subStrand;

      final isReverseSlope = strandIndex.isOdd;
      final normalizedSlot = slot / (slotOffsetsX.length - 1);
      final slopeDeltaY = isReverseSlope
          ? (1.0 - normalizedSlot) * 118.0 - 34.0
          : normalizedSlot * 118.0 - 34.0;
      final centerDip = (1.0 - ((normalizedSlot - 0.5).abs() * 2.0)) * 46.0;
      final staggerY = (slot.isOdd ? 38.0 : -14.0) + (((seed ~/ 17) % 55) - 27);
      final jitterX = ((seed % 75) - 37).toDouble();

      final defaultX = (slotOffsetsX[slot] + jitterX).clamp(56.0, 1480.0);
      final defaultY =
          136.0 + strandIndex * 348.0 + slopeDeltaY + centerDip + staggerY;
      final rawRot = (((seed % 23) - 11) * 0.0135);
      final defaultRot = rawRot.abs() < 0.025
          ? (strandIndex.isEven ? -0.045 : 0.045)
          : rawRot;

      return (
        x: forceAlgorithmic ? defaultX : (boardX ?? defaultX),
        y: forceAlgorithmic ? defaultY : (boardY ?? defaultY),
        rotation: boardRotation ?? defaultRot,
      );
    }

    // Default: Vertical Winding Journey Trail (from TOP to BOTTOM)
    const journeyWaypointsX = <double>[76.0, 332.0, 118.0, 308.0];
    final seqIndex = groupRowIndex * 2 + indexInGroup;
    final waypoint = seqIndex % journeyWaypointsX.length;

    final jitterX = ((seed % 36) - 18).toDouble();
    final jitterY = (((seed ~/ 17) % 28) - 14).toDouble();

    final defaultX = (journeyWaypointsX[waypoint] + jitterX).clamp(52.0, 420.0);
    final defaultY = 128.0 + seqIndex * 246.0 + jitterY;
    final rawRot = (((seed % 19) - 9) * 0.012);
    final defaultRot = rawRot.abs() < 0.02
        ? (seqIndex.isEven ? -0.038 : 0.038)
        : rawRot;

    return (
      x: forceAlgorithmic ? defaultX : (boardX ?? defaultX),
      y: forceAlgorithmic ? defaultY : (boardY ?? defaultY),
      rotation: boardRotation ?? defaultRot,
    );
  }

  Moment copyWith({
    String? caption,
    int? commentCount,
    int? reactionCount,
    double? latitude,
    double? longitude,
    String? placeName,
    double? boardX,
    double? boardY,
    double? boardRotation,
    double? boardScale,
    String? boardFilter,
    String? noteColor,
    bool? isPinned,
    bool? isFavorite,
    List<MomentComment>? comments,
    List<MomentReaction>? reactions,
  }) => Moment(
    id: id,
    mediaUrl: mediaUrl,
    type: type,
    isGhost: isGhost,
    developing: developing,
    revealAt: revealAt,
    caption: caption ?? this.caption,
    authorName: authorName,
    authorId: authorId,
    authorAvatar: authorAvatar,
    commentCount: commentCount ?? this.commentCount,
    reactionCount: reactionCount ?? this.reactionCount,
    createdAt: createdAt,
    takenAt: takenAt,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    placeName: placeName ?? this.placeName,
    boardX: boardX ?? this.boardX,
    boardY: boardY ?? this.boardY,
    boardRotation: boardRotation ?? this.boardRotation,
    boardScale: boardScale ?? this.boardScale,
    boardFilter: boardFilter ?? this.boardFilter,
    noteColor: noteColor ?? this.noteColor,
    isPinned: isPinned ?? this.isPinned,
    isFavorite: isFavorite ?? this.isFavorite,
    comments: comments ?? this.comments,
    reactions: reactions ?? this.reactions,
  );
}
