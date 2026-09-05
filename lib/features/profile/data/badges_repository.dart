import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Một danh hiệu và tiến độ đạt được của user.
class TripBadge {
  final String id;
  final String title;
  final String desc;
  final int current;
  final int target;
  final bool unlocked;

  const TripBadge({
    required this.id,
    required this.title,
    required this.desc,
    required this.current,
    required this.target,
    required this.unlocked,
  });

  int get percent =>
      target <= 0 ? 0 : ((current / target) * 100).clamp(0, 100).round();

  factory TripBadge.fromJson(Map<String, dynamic> j) {
    final p = j['progress'];
    return TripBadge(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      desc: j['desc'] as String? ?? '',
      current: (p is Map ? (p['current'] as num?)?.toInt() : 0) ?? 0,
      target: (p is Map ? (p['target'] as num?)?.toInt() : 1) ?? 1,
      unlocked: j['unlocked'] as bool? ?? false,
    );
  }
}

final badgesProvider = FutureProvider<List<TripBadge>>((ref) async {
  final data = await ref.watch(apiClientProvider).getData('/users/me/badges');
  if (data is! List) return const [];
  return data
      .whereType<Map>()
      .map((e) => TripBadge.fromJson(e.cast<String, dynamic>()))
      .toList();
});
