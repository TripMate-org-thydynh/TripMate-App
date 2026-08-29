import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/data/badges_repository.dart';

/// Danh hiệu đã mở khoá và tiến độ tới các danh hiệu còn lại.
///
/// Trước đây màn này là một màn hình ăn mừng in cứng: "Level 4 Reached",
/// "RARITY: MYTHIC", "1,200 / 2,000 to Lvl 5" — không đọc dữ liệu nào và có
/// nút chỉ hiện "Tính năng đang được hoàn thiện 🚧". Nay lấy danh hiệu thật từ
/// `/users/me/badges`, tiến độ đếm từ số chuyến, khoản chi đã trả và check-in.
class AchievementUnlockScreen extends ConsumerWidget {
  const AchievementUnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'games.badges_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ink),
            onPressed: () => ref.invalidate(badgesProvider),
          ),
        ],
      ),
      body: ref
          .watch(badgesProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(badgesProvider),
            ),
            data: (badges) {
              if (badges.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.emoji_events_outlined,
                  title: 'games.badges_title'.tr(),
                  body: 'games.badges_empty'.tr(),
                );
              }
              final unlocked = badges.where((b) => b.unlocked).length;
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(badgesProvider),
                child: ListView(
                  padding: const EdgeInsets.all(GenZTokens.space5),
                  children: [
                    _summary(isDark, unlocked, badges.length),
                    const SizedBox(height: GenZTokens.space5),
                    for (final b in badges) ...[
                      _card(isDark, b),
                      const SizedBox(height: GenZTokens.space4),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _summary(bool isDark, int unlocked, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: GenZTokens.yellow,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: GenZTokens.ink,
          width: GenZTokens.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$unlocked / $total',
            style: AppFonts.heading(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: GenZTokens.ink,
            ),
          ),
          Text(
            'games.badges_unlocked'.tr(),
            style: AppFonts.body(fontSize: 13, color: GenZTokens.ink),
          ),
        ],
      ),
    );
  }

  Widget _card(bool isDark, TripBadge b) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: b.unlocked ? GenZTokens.green.withValues(alpha: 0.18) : surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: ink,
          width: b.unlocked
              ? GenZTokens.borderWidth
              : GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                b.unlocked ? Icons.emoji_events : Icons.lock_outline,
                size: 20,
                color: b.unlocked ? GenZTokens.success : inkSoft,
              ),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: Text(
                  b.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            b.desc,
            style: AppFonts.body(fontSize: 12.5, color: inkSoft, height: 1.4),
          ),
          const SizedBox(height: GenZTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: b.percent / 100,
              minHeight: 8,
              backgroundColor: inkSoft.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                b.unlocked ? GenZTokens.success : GenZTokens.orange,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${b.current} / ${b.target}',
            style: AppFonts.body(fontSize: 12, color: inkSoft),
          ),
        ],
      ),
    );
  }
}
