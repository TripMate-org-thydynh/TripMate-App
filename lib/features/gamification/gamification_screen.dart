import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
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

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'gamification.hub_title'.tr(),
          style: AppFonts.heading(
            color: ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner visual game
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                color: GenZTokens.magenta,
                border: Border.all(color: ink, width: GenZTokens.borderWidth),
                boxShadow: GenZTokens.hardShadow(ink),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SQUAD CHAOS PLAYGROUND',
                    style: AppFonts.heading(
                      color: GenZTokens.paper,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'gamification.hub_desc'.tr(),
                    style: AppFonts.body(
                      color: GenZTokens.paper,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'gamification.hub_title'.tr(),
              style: AppFonts.heading(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGameCard(
                  context,
                  'Who Pays Wheel',
                  'gamification.chaotic_wheel'.tr(),
                  const WhoPaysWheelScreen(),
                  isDark,
                  GenZTokens.red,
                ),
                _buildGameCard(
                  context,
                  'Random Dare',
                  'gamification.random_challenge'.tr(),
                  const RandomDareGeneratorScreen(),
                  isDark,
                  GenZTokens.orange,
                ),
                _buildGameCard(
                  context,
                  'Trip Bingo',
                  'gamification.bingo_board'.tr(),
                  const TripBingoScreen(),
                  isDark,
                  GenZTokens.green,
                ),
                _buildGameCard(
                  context,
                  'Chaos Challenges',
                  'gamification.crazy_challenges'.tr(),
                  const ChaosChallengesScreen(),
                  isDark,
                  GenZTokens.purple,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'gamification.xp_ranks'.tr(),
              style: AppFonts.heading(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),

            _buildListAction(
              context,
              Icons.leaderboard_outlined,
              'gamification.squad_rankings'.tr(),
              'gamification.squad_rankings_desc'.tr(),
              const SquadLeaderboardScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.bolt_outlined,
              'gamification.xp_system'.tr(),
              'gamification.xp_system_desc'.tr(),
              const SquadXpSystemScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.emoji_events_outlined,
              'Achievement Unlocked',
              'gamification.achievements_accumulated'.tr(),
              const AchievementUnlockScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.card_giftcard_outlined,
              'End Trip Awards',
              'gamification.end_awards'.tr(),
              const EndTripAwardsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.task_alt_outlined,
              'gamification.daily_missions'.tr(),
              'gamification.daily_missions_desc'.tr(),
              const DailySquadMissionsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.calendar_month_outlined,
              'gamification.season_events'.tr(),
              'gamification.season_events_desc'.tr(),
              const SeasonalEventsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.workspace_premium_outlined,
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
    Widget target,
    bool isDark,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => target),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
            width: GenZTokens.borderWidth,
          ),
          boxShadow: GenZTokens.hardShadow(
            isDark ? GenZTokens.inkDark : GenZTokens.ink,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: GenZTokens.paper,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: GenZTokens.ink,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: const Icon(
                Icons.sports_esports,
                color: GenZTokens.ink,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: GenZTokens.paper,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    color: GenZTokens.paper,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
            width: GenZTokens.borderWidthThin,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
              offset: const Offset(0, 3),
            ),
          ],
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
              color: GenZTokens.lilac,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GenZTokens.ink,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(icon, color: GenZTokens.ink),
          ),
          title: Text(
            title,
            style: AppFonts.heading(
              fontWeight: FontWeight.w700,
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
            ),
          ),
          subtitle: Text(
            desc,
            style: AppFonts.body(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward,
            size: 16,
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
          ),
        ),
      ),
    );
  }
}
