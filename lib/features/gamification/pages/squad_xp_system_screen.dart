import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/games_repository.dart';
import '../widgets/game_state_views.dart';

/// Hệ thống XP của squad.
///
/// XP do backend tính từ hoạt động THẬT của chuyến (lịch trình, chi tiêu,
/// khoảnh khắc, mini game, bình chọn, thành viên). Trước đây màn này hiện cứng
/// level 4 / 1420 XP và 3 "đặc quyền" không tồn tại, giống hệt nhau cho mọi
/// tài khoản.
class SquadXpSystemScreen extends ConsumerWidget {
  const SquadXpSystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
        ),
        title: Text(
          'games.xp_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
          ),
        ),
      ),
      body: tripId == null
          ? GameEmptyState(
              isDark: isDark,
              icon: Icons.rocket_launch_outlined,
              title: 'games.need_trip_title'.tr(),
              body: 'games.need_trip_body'.tr(),
            )
          : ref
                .watch(squadXpProvider(tripId))
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => GameErrorState(
                    isDark: isDark,
                    onRetry: () => ref.invalidate(squadXpProvider(tripId)),
                  ),
                  data: (xp) => _content(context, isDark, xp),
                ),
    );
  }

  Widget _content(BuildContext context, bool isDark, SquadXp xp) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return ListView(
      padding: const EdgeInsets.all(GenZTokens.space5),
      children: [
        // ── Vòng tiến độ level ──
        Container(
          padding: const EdgeInsets.all(GenZTokens.space5),
          decoration: BoxDecoration(
            color: GenZTokens.purple,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(color: ink, width: GenZTokens.borderWidth),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: xp.levelProgress,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation(
                          GenZTokens.yellow,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'games.level_short'.tr(),
                          style: AppFonts.mono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          '${xp.squadLevel}',
                          style: AppFonts.heading(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GenZTokens.space4),
              Text(
                '${xp.currentXP} / ${xp.nextLevelXP} XP',
                style: AppFonts.mono(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                xp.xpToNextLevel == 0
                    ? 'games.level_ready'.tr()
                    : 'games.xp_to_next'.tr(
                        namedArgs: {'xp': '${xp.xpToNextLevel}'},
                      ),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: GenZTokens.space5),

        // ── XP đến từ đâu ──
        Text(
          'games.xp_breakdown'.tr(),
          style: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: GenZTokens.space3),
        if (xp.currentXP == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(GenZTokens.space5),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: ink.withValues(alpha: 0.25),
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Text(
              'games.xp_zero'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 13, color: inkSoft),
            ),
          )
        else
          ...xp.breakdown.where((b) => b.count > 0).map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: GenZTokens.space2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GenZTokens.space4,
                  vertical: GenZTokens.space3,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                  border: Border.all(
                    color: ink,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        b.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                    ),
                    Text(
                      '×${b.count}',
                      style: AppFonts.mono(fontSize: 12, color: inkSoft),
                    ),
                    const SizedBox(width: GenZTokens.space3),
                    Text(
                      '+${b.xp}',
                      style: AppFonts.mono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: GenZTokens.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
