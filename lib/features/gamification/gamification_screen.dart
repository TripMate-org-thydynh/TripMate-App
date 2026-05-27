import 'package:flutter/material.dart';
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
          'Mini Game Lobby 🕹️',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SQUAD CHAOS PLAYGROUND 🎮',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Trạm giải trí độc quyền cho cả nhóm du lịch. Hãy quẩy hết nấc để tích điểm thăng hạng phượt thủ!',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Trò Chơi Hỗn Loạn 🎡',
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
                  'Vòng quay hỗn loạn',
                  const WhoPaysWheelScreen(),
                  isDark,
                  Colors.redAccent,
                ),
                _buildGameCard(
                  context,
                  'Random Dare 🎲',
                  'Bốc thử thách ngẫu nhiên',
                  const RandomDareGeneratorScreen(),
                  isDark,
                  Colors.orangeAccent,
                ),
                _buildGameCard(
                  context,
                  'Trip Bingo 🎯',
                  'Bảng tích lũy Bingo',
                  const TripBingoScreen(),
                  isDark,
                  Colors.teal,
                ),
                _buildGameCard(
                  context,
                  'Chaos Challenges ⚡',
                  'Các thử thách điên rồ',
                  const ChaosChallengesScreen(),
                  isDark,
                  Colors.purpleAccent,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'Hành Trình XP & Danh Hiệu 🏆',
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
              'Bảng Xếp Hạng Squad • Rankings 🏆',
              'Xem xếp hạng lầy lội của cả hội bạn',
              const SquadLeaderboardScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.bolt_outlined,
              'Hệ Thống Squad XP 🚀',
              'Mở khóa đặc quyền du lịch cực chất',
              const SquadXpSystemScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.emoji_events_outlined,
              'Achievement Unlocked 🏆',
              'Xem các cúp danh hiệu đã tích lũy',
              const AchievementUnlockScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.card_giftcard_outlined,
              'End Trip Awards 🎭',
              'Lễ trao giải vui nhộn cuối hành trình',
              const EndTripAwardsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.task_alt_outlined,
              'Nhiệm Vụ Hằng Ngày 📆',
              'Cùng cả nhóm làm nhiệm vụ nhận thưởng',
              const DailySquadMissionsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.calendar_month_outlined,
              'Sự Kiện Mùa Giải 🎏',
              'Nhận các thử thách giới hạn thời gian',
              const SeasonalEventsScreen(),
              isDark,
            ),
            _buildListAction(
              context,
              Icons.workspace_premium_outlined,
              'Thử Thách Tuần 📆',
              'Thử thách tuần mới thách thức kỹ năng',
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
