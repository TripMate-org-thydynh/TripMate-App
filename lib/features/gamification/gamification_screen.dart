import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../core/theme/gen_z_tokens.dart';
import 'pages/achievement_unlock_screen.dart';
import 'pages/chaos_challenges_screen.dart';
import 'pages/daily_squad_missions_screen.dart';
import 'pages/end_trip_awards_screen.dart';
import 'pages/random_dare_generator_screen.dart';
import 'pages/seasonal_events_screen.dart';
import 'pages/squad_leaderboard_screen.dart';
import 'pages/squad_xp_system_screen.dart';
import 'pages/trip_bingo_screen.dart';
import 'pages/weekly_challenges_screen.dart';
import 'pages/who_pays_wheel_screen.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final accentSoft = isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'gamification.hub_title'.tr(),
          style: AppFonts.heading(
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: GenZTokens.space4,
          vertical: GenZTokens.space4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner visual game
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GenZTokens.space5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                color: paper,
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GenZTokens.space3,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                    ),
                    child: Text(
                      'games.hub_kicker'.tr(),
                      style: AppFonts.heading(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: GenZTokens.space3),
                  Text(
                    'gamification.hub_desc'.tr(),
                    style: AppFonts.body(
                      color: inkSoft,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: GenZTokens.space5),

            Text(
              'gamification.hub_title'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space3),

            Builder(
              builder: (context) {
                final textScaler = MediaQuery.textScalerOf(context);
                final tileExtent = max(152.0, textScaler.scale(50) + 102);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: GenZTokens.space3,
                    mainAxisSpacing: GenZTokens.space3,
                    mainAxisExtent: tileExtent,
                  ),
                  children: [
                    _buildGameCard(
                      context,
                      'games.who_pays_title'.tr(),
                      'gamification.chaotic_wheel'.tr(),
                      PhosphorIcons.diceFive(PhosphorIconsStyle.fill),
                      const WhoPaysWheelScreen(),
                      isDark,
                    ),
                    _buildGameCard(
                      context,
                      'games.dare_title'.tr(),
                      'gamification.random_challenge'.tr(),
                      PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                      const RandomDareGeneratorScreen(),
                      isDark,
                    ),
                    _buildGameCard(
                      context,
                      'games.trip_bingo_title'.tr(),
                      'gamification.bingo_board'.tr(),
                      PhosphorIcons.gridFour(PhosphorIconsStyle.fill),
                      const TripBingoScreen(),
                      isDark,
                    ),
                    _buildGameCard(
                      context,
                      'games.chaos_title'.tr(),
                      'gamification.crazy_challenges'.tr(),
                      PhosphorIcons.fire(PhosphorIconsStyle.fill),
                      const ChaosChallengesScreen(),
                      isDark,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: GenZTokens.space5),

            Text(
              'gamification.xp_ranks'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space3),

            _buildListAction(
              context,
              PhosphorIcons.ranking(PhosphorIconsStyle.fill),
              'gamification.squad_rankings'.tr(),
              'gamification.squad_rankings_desc'.tr(),
              const SquadLeaderboardScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill),
              'gamification.xp_system'.tr(),
              'gamification.xp_system_desc'.tr(),
              const SquadXpSystemScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              PhosphorIcons.trophy(PhosphorIconsStyle.fill),
              'games.badges_title'.tr(),
              'gamification.achievements_accumulated'.tr(),
              const AchievementUnlockScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              PhosphorIcons.gift(PhosphorIconsStyle.fill),
              'games.awards_title'.tr(),
              'gamification.end_awards'.tr(),
              const EndTripAwardsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
              'gamification.daily_missions'.tr(),
              'gamification.daily_missions_desc'.tr(),
              const DailySquadMissionsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              PhosphorIcons.plant(PhosphorIconsStyle.fill),
              'gamification.season_events'.tr(),
              'gamification.season_events_desc'.tr(),
              const SeasonalEventsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              PhosphorIcons.lightning(PhosphorIconsStyle.fill),
              'gamification.weekly_challenges'.tr(),
              'gamification.weekly_challenges_desc'.tr(),
              const WeeklyChallengesScreen(),
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Widget target,
    bool isDark,
  ) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => target),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(GenZTokens.space4),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: line,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(GenZTokens.space2),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Icon(
                icon,
                color: ink,
                size: 24,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    color: inkSoft,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListAction(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    Widget target,
    bool isDark,
  ) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    return Padding(
      padding: const EdgeInsets.only(bottom: GenZTokens.space3),
      child: Container(
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: line,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => target),
            );
          },
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              border: Border.all(
                color: line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(icon, color: ink, size: 20),
          ),
          title: Text(
            title,
            style: AppFonts.heading(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: ink,
            ),
          ),
          subtitle: Text(
            desc,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: inkSoft,
            ),
          ),
          trailing: Icon(
            PhosphorIcons.caretRight(),
            size: 16,
            color: inkSoft,
          ),
        ),
      ),
    );
  }
}
