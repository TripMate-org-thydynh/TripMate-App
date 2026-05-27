import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadLeaderboardScreen extends StatefulWidget {
  const SquadLeaderboardScreen({super.key});

  @override
  State<SquadLeaderboardScreen> createState() => _SquadLeaderboardScreenState();
}

class _SquadLeaderboardScreenState extends State<SquadLeaderboardScreen> {
  int _selectedTab = 0; // 0: Chaos Score, 1: Funny Moments, 2: Most Reliable

  final List<String> _tabs = [
    '👑 Chaos Score',
    '😂 Funny Moments',
    '🛡️ Most Reliable'
  ];

  final Map<int, List<Map<String, dynamic>>> _rankingsData = {
    0: [
      {
        'name': 'Sam',
        'badge': 'Main Character',
        'points': 1240,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sam',
      },
      {
        'name': 'Alex',
        'badge': 'Sidekick Energy',
        'points': 850,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
      },
      {
        'name': 'Jordan',
        'badge': 'NPC Vibes',
        'points': 720,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jordan',
      },
      {
        'name': 'Taylor',
        'badge': 'Slept through it all',
        'points': 450,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Taylor',
      },
      {
        'name': 'Casey',
        'badge': 'Who invited them?',
        'points': 120,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Casey',
      },
    ],
    1: [
      {
        'name': 'Alex',
        'badge': 'Sidekick Energy',
        'points': 1120,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
      },
      {
        'name': 'Sam',
        'badge': 'Main Character',
        'points': 980,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sam',
      },
      {
        'name': 'Taylor',
        'badge': 'Slept through it all',
        'points': 850,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Taylor',
      },
      {
        'name': 'Jordan',
        'badge': 'NPC Vibes',
        'points': 690,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jordan',
      },
      {
        'name': 'Casey',
        'badge': 'Who invited them?',
        'points': 150,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Casey',
      },
    ],
    2: [
      {
        'name': 'Jordan',
        'badge': 'NPC Vibes',
        'points': 1310,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jordan',
      },
      {
        'name': 'Casey',
        'badge': 'Who invited them?',
        'points': 980,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Casey',
      },
      {
        'name': 'Sam',
        'badge': 'Main Character',
        'points': 890,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sam',
      },
      {
        'name': 'Alex',
        'badge': 'Sidekick Energy',
        'points': 620,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
      },
      {
        'name': 'Taylor',
        'badge': 'Slept through it all',
        'points': 250,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Taylor',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define adaptive color palette (TripMate color palette)
    final Color bgColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final Color primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final Color surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;
    final Color textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
    final Color textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76);

    final currentList = _rankingsData[_selectedTab] ?? [];

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B1326),
                    Color(0xFF131B2E),
                    Color(0xFF060E20),
                  ],
                ),
              )
            : null,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: textPrimary),
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor.withValues(alpha: isDark ? 0.3 : 0.8),
                          shape: const CircleBorder(),
                        ),
                      ),
                      Text(
                        'trip.mate',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add_reaction_outlined, color: primaryColor),
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor.withValues(alpha: isDark ? 0.3 : 0.8),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Squad Leaderboard',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal switcher tags
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        final label = _tabs[index];
                        final isSelected = _selectedTab == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : surfaceColor.withValues(alpha: isDark ? 0.4 : 0.7),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.08)),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isSelected
                                      ? Colors.white
                                      : textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Elevated Podium Visualizer
                  if (currentList.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 2nd Place
                        if (currentList.length > 1)
                          Expanded(
                            child: _buildPodiumSpot(
                              player: currentList[1],
                              rank: 2,
                              height: 110,
                              color: const Color(0xFFC0C0C0), // Silver
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                        const SizedBox(width: 12),
                        // 1st Place (Elevated/Center)
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -18),
                            child: _buildPodiumSpot(
                              player: currentList[0],
                              rank: 1,
                              height: 145,
                              color: const Color(0xFFFFD700), // Gold
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 3rd Place
                        if (currentList.length > 2)
                          Expanded(
                            child: _buildPodiumSpot(
                              player: currentList[2],
                              rank: 3,
                              height: 90,
                              color: const Color(0xFFCD7F32), // Bronze
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 28),

                  // Remaining Squad Title
                  Text(
                    'The Rest of the Squad',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Remaining list items (4th Taylor, 5th Casey)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentList.length > 3 ? currentList.length - 3 : 0,
                    itemBuilder: (context, index) {
                      final actualIndex = index + 3;
                      final player = currentList[actualIndex];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: surfaceColor.withValues(alpha: isDark ? 0.5 : 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '#${actualIndex + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: primaryColor.withValues(alpha: 0.1),
                              backgroundImage: NetworkImage(player['avatar'] as String),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player['name'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    player['badge'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${player['points']}pts',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSpot({
    required Map<String, dynamic> player,
    required int rank,
    required double height,
    required Color color,
    required bool isDark,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final emoji = rank == 1 ? '👑' : '';
    final medal = rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉');

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Floating Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: rank == 1 ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 38 : 30,
                backgroundColor: surfaceColor,
                backgroundImage: NetworkImage(player['avatar'] as String),
              ),
            ),
            // Floating Crown
            if (rank == 1)
              Positioned(
                top: -18,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            // Floating Medal Badge
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Text(
                  medal,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 3D Glass Podium Container
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                surfaceColor.withValues(alpha: isDark ? 0.35 : 0.8),
                surfaceColor.withValues(alpha: isDark ? 0.1 : 0.4),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: color, width: 4),
              left: BorderSide(color: color.withValues(alpha: 0.2), width: 1.5),
              right: BorderSide(color: color.withValues(alpha: 0.2), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: rank == 1 ? 16 : 14,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    player['badge'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: rank == 1 ? 10 : 9,
                      fontWeight: FontWeight.w600,
                      color: isDark ? color : color.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${player['points']}pts',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: rank == 1 ? 15 : 13,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

