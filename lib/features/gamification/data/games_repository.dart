import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../trips/application/trips_providers.dart';

/// Tiến độ XP của cả nhóm trong một chuyến.
///
/// XP do backend tính từ hoạt động thật (lịch trình, chi tiêu, khoảnh khắc,
/// mini game, bình chọn, thành viên) — không còn là con số cứng.
class SquadXp {
  final int squadLevel;
  final int currentXP;
  final int levelStartXP;
  final int nextLevelXP;
  final List<XpBreakdown> breakdown;

  const SquadXp({
    required this.squadLevel,
    required this.currentXP,
    required this.levelStartXP,
    required this.nextLevelXP,
    required this.breakdown,
  });

  /// Tiến độ trong level hiện tại, 0..1 (không phải trên tổng XP).
  double get levelProgress {
    final span = nextLevelXP - levelStartXP;
    if (span <= 0) return 0;
    return ((currentXP - levelStartXP) / span).clamp(0.0, 1.0);
  }

  int get xpToNextLevel => (nextLevelXP - currentXP).clamp(0, 1 << 30);

  factory SquadXp.fromJson(Map<String, dynamic> j) => SquadXp(
    squadLevel: (j['squadLevel'] as num?)?.toInt() ?? 1,
    currentXP: (j['currentXP'] as num?)?.toInt() ?? 0,
    levelStartXP: (j['levelStartXP'] as num?)?.toInt() ?? 0,
    nextLevelXP: (j['nextLevelXP'] as num?)?.toInt() ?? 500,
    breakdown: (j['breakdown'] as List? ?? [])
        .whereType<Map>()
        .map((e) => XpBreakdown.fromJson(e.cast<String, dynamic>()))
        .toList(),
  );
}

class XpBreakdown {
  final String key;
  final int count;
  final int xp;

  const XpBreakdown({
    required this.key,
    required this.count,
    required this.xp,
  });

  /// Nhãn đã dịch. BE chỉ trả `key` để app hiển thị đúng ngôn ngữ đang chọn.
  String get label => 'games.xp_source_$key'.tr();

  factory XpBreakdown.fromJson(Map<String, dynamic> j) => XpBreakdown(
    key: j['key'] as String? ?? '',
    count: (j['count'] as num?)?.toInt() ?? 0,
    xp: (j['xp'] as num?)?.toInt() ?? 0,
  );
}

/// Một dòng trong bảng xếp hạng đóng góp của chuyến.
class LeaderboardRow {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int rank;
  final int xp;
  final int moments;
  final int expenses;
  final int plans;
  final int notes;

  const LeaderboardRow({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.rank,
    required this.xp,
    required this.moments,
    required this.expenses,
    required this.plans,
    required this.notes,
  });

  factory LeaderboardRow.fromJson(Map<String, dynamic> j) => LeaderboardRow(
    userId: j['userId'] as String? ?? '',
    name: j['name'] as String? ?? '',
    avatarUrl: j['avatarUrl'] as String?,
    rank: (j['rank'] as num?)?.toInt() ?? 0,
    xp: (j['xp'] as num?)?.toInt() ?? 0,
    moments: (j['moments'] as num?)?.toInt() ?? 0,
    expenses: (j['expenses'] as num?)?.toInt() ?? 0,
    plans: (j['plans'] as num?)?.toInt() ?? 0,
    notes: (j['notes'] as num?)?.toInt() ?? 0,
  );
}

/// Nhiệm vụ (tuần hoặc theo mùa) — mục tiêu cố định, tiến độ tính từ dữ liệu thật.
class GameChallenge {
  final String id;
  final String title;
  final String desc;
  final int current;
  final int target;
  final int rewardXP;
  final bool completed;
  final int percent;

  const GameChallenge({
    required this.id,
    required this.title,
    required this.desc,
    required this.current,
    required this.target,
    required this.rewardXP,
    required this.completed,
    required this.percent,
  });

  /// BE chỉ trả `id`; nhãn lấy từ file dịch để khớp ngôn ngữ đang chọn.
  /// Id lạ (BE thêm nhiệm vụ mới) rơi về nhãn chung thay vì hiện key thô.
  static String _label(String id, String suffix) {
    const known = {
      'week-moments', 'week-expenses', 'week-plan', 'week-notes',
      'season-winter', 'season-spring', 'season-summer', 'season-autumn',
    };
    final key = known.contains(id) ? id.replaceAll('-', '_') : 'unknown';
    return 'games.challenge_${key}_$suffix'.tr();
  }

  factory GameChallenge.fromJson(Map<String, dynamic> j) => GameChallenge(
    id: j['id'] as String? ?? '',
    title: _label(j['id'] as String? ?? '', 'title'),
    desc: _label(j['id'] as String? ?? '', 'desc'),
    current: (j['current'] as num?)?.toInt() ?? 0,
    target: (j['target'] as num?)?.toInt() ?? 1,
    rewardXP: (j['rewardXP'] as num?)?.toInt() ?? 0,
    completed: j['completed'] as bool? ?? false,
    percent: (j['percent'] as num?)?.toInt() ?? 0,
  );
}

class GamesRepository {
  final ApiClient _client;
  GamesRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/games';

  Future<SquadXp> fetchXp(String tripId) async {
    final data = await _client.getData('${_base(tripId)}/xp');
    return SquadXp.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<List<LeaderboardRow>> fetchLeaderboard(String tripId) async {
    final data = await _client.getData('${_base(tripId)}/leaderboard');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => LeaderboardRow.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<List<GameChallenge>> fetchWeekly(String tripId) =>
      _fetchChallenges('${_base(tripId)}/weekly');

  Future<List<GameChallenge>> fetchSeasonal(String tripId) =>
      _fetchChallenges('${_base(tripId)}/seasonal');

  Future<List<GameChallenge>> _fetchChallenges(String path) async {
    final data = await _client.getData(path);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => GameChallenge.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }
}

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(ref.watch(apiClientProvider));
});

final squadXpProvider = FutureProvider.family<SquadXp, String>((ref, tripId) {
  return ref.watch(gamesRepositoryProvider).fetchXp(tripId);
});

final leaderboardProvider =
    FutureProvider.family<List<LeaderboardRow>, String>((ref, tripId) {
      return ref.watch(gamesRepositoryProvider).fetchLeaderboard(tripId);
    });

final weeklyChallengesProvider =
    FutureProvider.family<List<GameChallenge>, String>((ref, tripId) {
      return ref.watch(gamesRepositoryProvider).fetchWeekly(tripId);
    });

final seasonalEventsProvider =
    FutureProvider.family<List<GameChallenge>, String>((ref, tripId) {
      return ref.watch(gamesRepositoryProvider).fetchSeasonal(tripId);
    });

/// Chuyến đang dùng làm bối cảnh cho các màn game.
///
/// Các màn game không nhận `tripId` qua constructor (mở từ Quick Actions),
/// nên lấy chuyến gần nhất của user. `null` = chưa có chuyến nào → màn game
/// hiển thị empty state thay vì số liệu bịa.
final activeTripIdProvider = Provider<String?>((ref) {
  return ref.watch(tripsProvider).maybeWhen(
    data: (trips) => trips.isEmpty ? null : trips.first.id,
    orElse: () => null,
  );
});
