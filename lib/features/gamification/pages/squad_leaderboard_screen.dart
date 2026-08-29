import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/games_repository.dart';
import '../../../core/widgets/state_views.dart';

/// Bảng xếp hạng đóng góp của squad trong chuyến.
///
/// Trước đây màn này liệt kê 5 người chơi bịa (Sam / Alex / Jordan / Taylor /
/// Casey) với điểm số cứng. Nay xếp hạng thành viên THẬT theo số khoảnh khắc
/// đã đăng, khoản chi đã trả, điểm lịch trình đã thêm và ghi chú đã viết.
class SquadLeaderboardScreen extends ConsumerWidget {
  const SquadLeaderboardScreen({super.key});

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'games.leaderboard_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          if (tripId != null)
            IconButton(
              icon: Icon(Icons.refresh, color: ink),
              onPressed: () => ref.invalidate(leaderboardProvider(tripId)),
            ),
        ],
      ),
      body: tripId == null
          ? AppEmptyState(
              isDark: isDark,
              icon: Icons.emoji_events_outlined,
              title: 'games.need_trip_title'.tr(),
              body: 'games.need_trip_body'.tr(),
            )
          : ref
                .watch(leaderboardProvider(tripId))
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => AppErrorState(
                    isDark: isDark,
                    error: e,
                    onRetry: () => ref.invalidate(leaderboardProvider(tripId)),
                  ),
                  data: (rows) {
                    if (rows.isEmpty || rows.every((r) => r.xp == 0)) {
                      return AppEmptyState(
                        isDark: isDark,
                        icon: Icons.emoji_events_outlined,
                        title: 'games.leaderboard_title'.tr(),
                        body: 'games.leaderboard_empty'.tr(),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(leaderboardProvider(tripId)),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(GenZTokens.space5),
                        itemCount: rows.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: GenZTokens.space3),
                        itemBuilder: (context, i) =>
                            _row(context, isDark, rows[i]),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _row(BuildContext context, bool isDark, LeaderboardRow r) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final isPodium = r.rank <= 3;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: isPodium ? GenZTokens.yellow : surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: ink,
          width: isPodium
              ? GenZTokens.borderWidth
              : GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              isPodium ? _medals[r.rank - 1] : '#${r.rank}',
              style: AppFonts.mono(
                fontSize: isPodium ? 22 : 14,
                fontWeight: FontWeight.w700,
                color: isPodium ? GenZTokens.ink : inkSoft,
              ),
            ),
          ),
          const SizedBox(width: GenZTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isPodium ? GenZTokens.ink : ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '📸 ${r.moments}   💸 ${r.expenses}   🗺️ ${r.plans}   📝 ${r.notes}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.mono(
                    fontSize: 11,
                    color: isPodium
                        ? GenZTokens.ink.withValues(alpha: 0.7)
                        : inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: GenZTokens.space3),
          Text(
            '${r.xp} XP',
            style: AppFonts.mono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isPodium ? GenZTokens.ink : GenZTokens.green,
            ),
          ),
        ],
      ),
    );
  }
}
