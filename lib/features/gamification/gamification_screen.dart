import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'gamification.hub_title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
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
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.pinkAccent, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SQUAD CHAOS PLAYGROUND 🎮',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'gamification.hub_desc'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'gamification.hub_title'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
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
                  'Who Pays Wheel 🎡',
                  'gamification.chaotic_wheel'.tr(),
                  const WhoPaysWheelScreen(),
                  isDark,
                  Colors.redAccent,
                ),
                _buildGameCard(
                  context,
                  'Random Dare 🎲',
                  'gamification.random_challenge'.tr(),
                  const RandomDareGeneratorScreen(),
                  isDark,
                  Colors.orangeAccent,
                ),
                _buildGameCard(
                  context,
                  'Trip Bingo 🎯',
                  'gamification.bingo_board'.tr(),
                  const TripBingoScreen(),
                  isDark,
                  Colors.teal,
                ),
                _buildGameCard(
                  context,
                  'Chaos Challenges ⚡',
                  'gamification.crazy_challenges'.tr(),
                  const ChaosChallengesScreen(),
                  isDark,
                  Colors.purpleAccent,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'gamification.xp_ranks'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
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
              'Achievement Unlocked 🏆',
              'gamification.achievements_accumulated'.tr(),
              const AchievementUnlockScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.card_giftcard_outlined,
              'End Trip Awards 🎭',
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => target));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.sports_esports, color: accentColor, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
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
      child: Card(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => target));
          },
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.purpleAccent),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(desc, style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        ),
      ),
    );
  }
}
