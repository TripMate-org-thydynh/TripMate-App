import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/data/badges_repository.dart';

/// Danh hiệu đã mở khoá và tiến độ tới các danh hiệu còn lại.
///
/// Trước đây màn này là một màn hình ăn mừng in cứng: "Level 4 Reached",
/// "RARITY: MYTHIC", "1,200 / 2,000 to Lvl 5" — không đọc dữ liệu nào và có
/// nút chỉ hiện "Tính năng đang được hoàn thiện". Nay lấy danh hiệu thật từ
/// `/users/me/badges`, tiến độ đếm từ số chuyến, khoản chi đã trả và check-in.
class AchievementUnlockScreen extends ConsumerWidget {
  const AchievementUnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'games.badges_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: ink),
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
                  icon: PhosphorIcons.trophy(),
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
                    _summary(context, isDark, unlocked, badges.length),
                    const SizedBox(height: GenZTokens.space5),
                    for (final b in badges) ...[
                      _card(context, isDark, b),
                      const SizedBox(height: GenZTokens.space4),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _summary(BuildContext context, bool isDark, int unlocked, int total) {
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$unlocked / $total',
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'games.badges_unlocked'.tr(),
            style: AppFonts.body(fontSize: 13, color: inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, bool isDark, TripBadge b) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: b.unlocked ? success : line,
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
                b.unlocked
                    ? PhosphorIcons.trophy(PhosphorIconsStyle.fill)
                    : PhosphorIcons.lockKey(),
                size: 20,
                color: b.unlocked ? success : inkSoft,
              ),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: Text(
                  b.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            b.desc,
            style: AppFonts.body(fontSize: 13, color: inkSoft, height: 1.4),
          ),
          const SizedBox(height: GenZTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            child: LinearProgressIndicator(
              value: b.percent / 100,
              minHeight: 8,
              backgroundColor: fill,
              valueColor: AlwaysStoppedAnimation<Color>(
                b.unlocked ? success : accent,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${b.current} / ${b.target}',
            style: AppFonts.mono(fontSize: 12, color: inkSoft),
          ),
        ],
      ),
    );
  }
}
