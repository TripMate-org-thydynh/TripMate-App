import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../core/app_messenger.dart';
class DailySquadMissionsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const DailySquadMissionsScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<DailySquadMissionsScreen> createState() =>
      _DailySquadMissionsScreenState();
}

class _DailySquadMissionsScreenState extends State<DailySquadMissionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _missions = [
    {
      'emoji': '📸',
      'title': 'Upload 5 memories',
      'progress': 3,
      'total': 5,
      'xp': '+250 XP',
      'tag': null,
      'locked': false,
    },
    {
      'emoji': '☕',
      'title': 'Visit 3 cafes',
      'progress': 1,
      'total': 3,
      'xp': '+150 XP',
      'tag': 'High Vibe Mission',
      'tagIcon': Icons.local_cafe,
      'locked': false,
    },
    {
      'emoji': '🔥',
      'title': 'Everyone reacts once',
      'progress': 4,
      'total': 5,
      'xp': '+300 XP',
      'tag': null,
      'locked': false,
    },
    {
      'emoji': '🚕',
      'title': 'Take a random route',
      'progress': 0,
      'total': 1,
      'xp': '??? XP',
      'tag': null,
      'locked': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF0F0FF);
    final surface = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.75);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.6);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'trip.mate',
                        style: AppFonts.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFC9B8FF),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onThemeToggle,
                        child: _buildNavIcon(
                          icon: Icons.wb_sunny_outlined,
                          isDark: isDark,
                          isActive: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildNavIcon(
                        icon: Icons.notifications_outlined,
                        isDark: isDark,
                        isActive: true,
                        activeColor: const Color(0xFFC9B8FF),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Squad Energy Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1FA85C,
                                ).withValues(alpha: isDark ? 0.15 : 0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF1FA85C),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Squad Energy',
                                          style: AppFonts.heading(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '84%',
                                              style: AppFonts.heading(
                                                fontSize: 38,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF1FA85C),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'collective chaos achieved ✨',
                                          style: AppFonts.body(
                                            fontSize: 12,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Circular energy ring
                                  AnimatedBuilder(
                                    animation: _pulseAnim,
                                    builder: (context, child) =>
                                        Transform.scale(
                                          scale: _pulseAnim.value,
                                          child: child,
                                        ),
                                    child: SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: CircularProgressIndicator(
                                        value: 0.84,
                                        strokeWidth: 6,
                                        backgroundColor: const Color(
                                          0xFF1FA85C,
                                        ).withValues(alpha: 0.15),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Color(0xFF1FA85C),
                                            ),
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Countdown
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: const Color(0xFFC9B8FF),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '14:22:05 left',
                                    style: AppFonts.heading(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFC9B8FF),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'daily reset',
                                    style: AppFonts.body(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Daily Missions',
                          style: AppFonts.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Mission cards
                        ...List.generate(_missions.length, (i) {
                          final m = _missions[i];
                          final locked = m['locked'] as bool;
                          final prog = m['progress'] as int;
                          final total = m['total'] as int;
                          final pct = prog / total;
                          final complete = pct >= 1.0;

                          return _buildMissionCard(
                            mission: m,
                            isDark: isDark,
                            surface: surface,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            locked: locked,
                            pct: pct,
                            complete: complete,
                          );
                        }),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Bottom Nav
                _buildBottomNav(isDark: isDark, surface: surface),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required Map<String, dynamic> mission,
    required bool isDark,
    required Color surface,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool locked,
    required double pct,
    required bool complete,
  }) {
    final xp = mission['xp'] as String;
    final Color progressColor = complete
        ? const Color(0xFF1FA85C)
        : locked
        ? Colors.grey
        : const Color(0xFFC9B8FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: locked
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.03))
                  : surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: complete
                    ? const Color(0xFF1FA85C).withValues(alpha: 0.3)
                    : borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mission['emoji'] as String,
                      style: TextStyle(
                        fontSize: 22,
                        color: locked
                            ? Colors.white.withValues(alpha: 0.3)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mission['tag'] != null)
                            Row(
                              children: [
                                Icon(
                                  mission['tagIcon'] as IconData? ?? Icons.star,
                                  size: 12,
                                  color: const Color(0xFF1FA85C),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mission['tag'] as String,
                                  style: AppFonts.body(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1FA85C),
                                  ),
                                ),
                              ],
                            ),
                          Text(
                            mission['title'] as String,
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: locked ? textSecondary : textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (locked)
                      Icon(Icons.lock, size: 16, color: textSecondary)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: progressColor.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          xp,
                          style: AppFonts.heading(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: progressColor,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!locked) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: progressColor.withValues(
                              alpha: 0.12,
                            ),
                            valueColor: AlwaysStoppedAnimation(progressColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Progress: ${mission['progress']}/${mission['total']}',
                        style: AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (locked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Mystery Mission',
                      style: AppFonts.body(
                        fontSize: 12,
                        color: textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required bool isDark,
    required bool isActive,
    Color? activeColor,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive && activeColor != null
            ? activeColor.withValues(alpha: 0.15)
            : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: 22,
        color: isActive && activeColor != null
            ? activeColor
            : isDark
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildBottomNav({required bool isDark, required Color surface}) {
    final icons = [
      Icons.explore_outlined,
      Icons.group_outlined,
      Icons.add_circle,
      Icons.map_outlined,
      Icons.person_outlined,
    ];
    final activeIdx = 1;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (i) {
              final isActive = i == activeIdx;
              return GestureDetector(
                onTap: () =>
                    showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? const Color(0xFF1FA85C).withValues(alpha: 0.2)
                        : Colors.transparent,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF1FA85C,
                              ).withValues(alpha: 0.3),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icons[i],
                    size: 24,
                    color: isActive
                        ? const Color(0xFF1FA85C)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.35),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
