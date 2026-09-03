import 'package:easy_localization/easy_localization.dart';
/// Model Trip — khớp response BE (`trips` module).
class Trip {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? coverImage;
  final String inviteCode;
  final String currency;
  final String? theme;
  final bool isPublic;
  final String? destination;
  final double? budget;
  final String? vibe;
  final int memberCount;
  final List<TripMemberLite> members;

  const Trip({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.coverImage,
    required this.inviteCode,
    this.currency = 'VND',
    this.theme,
    this.isPublic = false,
    this.destination,
    this.budget,
    this.vibe,
    this.memberCount = 0,
    this.members = const [],
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];
    final rawMembers = json['members'];
    return Trip(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      startDate:
          DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.now(),
      coverImage: json['coverImage'] as String?,
      inviteCode: json['inviteCode'] as String? ?? '',
      currency: json['currency'] as String? ?? 'VND',
      theme: json['theme'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      destination: json['destination'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      vibe: json['vibe'] as String?,
      memberCount:
          (count is Map ? count['members'] as int? : null) ??
          (rawMembers is List ? rawMembers.length : 0),
      members: rawMembers is List
          ? rawMembers
                .whereType<Map>()
                .map((m) => TripMemberLite.fromJson(m.cast<String, dynamic>()))
                .toList()
          : const [],
    );
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;
}

/// Thành viên rút gọn (id/name/avatar) như BE trả trong `include.members.user`.
class TripMemberLite {
  final String id;
  final String name;
  final String? avatarUrl;
  final String role;

  const TripMemberLite({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.role = 'MEMBER',
  });

  factory TripMemberLite.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final u = user is Map ? user.cast<String, dynamic>() : json;
    return TripMemberLite(
      id: u['id'] as String? ?? '',
      name: u['name'] as String? ?? 'common.anonymous'.tr(),
      avatarUrl: u['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'MEMBER',
    );
  }
}
