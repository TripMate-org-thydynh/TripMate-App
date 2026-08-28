import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_messenger.dart';
class ChaosChallengesScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ChaosChallengesScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<ChaosChallengesScreen> createState() => _ChaosChallengesScreenState();
}

class _ChaosChallengesScreenState extends State<ChaosChallengesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Count-down timer state
  late Timer _countdownTimer;
  Duration _remainingTime = const Duration(hours: 4, minutes: 20, seconds: 0);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Start ticking countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          } else {
            _remainingTime = const Duration(
              hours: 24,
              minutes: 0,
              seconds: 0,
            ); // loop
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String hours = d.inHours.toString().padLeft(2, '0');
    String minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Design System colors
    final bgStart = isDark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final primary = isDark ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
    final secondary = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D);
    final textPrimary = isDark
        ? const Color(0xFFDAE2FD)
        : const Color(0xFF141210);
    final textMuted = isDark
        ? const Color(0xFFCBC3D7)
        : const Color(0xFF4A453E);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgStart),
        child: Stack(
          children: [
            // Ambient glow backdrops
            if (isDark) ...[
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ],

            SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Top App Bar
                    _buildTopAppBar(textPrimary),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),

                            // Header Text Blocks
                            _buildHeaderSection(textPrimary, textMuted),

                            const SizedBox(height: 24),

                            // Highlighted Daily Chaos Card
                            _buildDailyChaosCard(
                              surface,
                              primary,
                              secondary,
                              textPrimary,
                              textMuted,
                              isDark,
                            ),

                            const SizedBox(height: 28),

                            // Viral Challenges Feed list
                            _buildViralChallenges(
                              surface,
                              primary,
                              secondary,
                              textPrimary,
                              textMuted,
                              isDark,
                            ),

                            const SizedBox(height: 28),

                            // Chaos Rewards Bento Grid
                            _buildRewardsSection(
                              surface,
                              primary,
                              secondary,
                              textPrimary,
                              textMuted,
                              isDark,
                            ),

                            const SizedBox(
                              height: 160,
                            ), // Spacing for bottom navbar
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Custom Navbar
            _buildFloatingNavbar(surface, primary, secondary, textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(Color textPrimary) {
    final isDark = widget.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
          Text(
            'trip.mate',
            style: AppFonts.heading(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textPrimary.withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: widget.onThemeToggle,
              tooltip: 'Toggle Theme',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Color textPrimary, Color textMuted) {
    return Center(
      child: Column(
        children: [
          Text(
            'embrace the chaos',
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'bad decisions make good memories.',
            style: AppFonts.body(
              fontSize: 14,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChaosCard(
    Color surface,
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primary, width: 2),
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.05), blurRadius: 0),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🎲', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'DAILY CHAOS',
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active',
                        style: AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Take a random bus',
                style: AppFonts.heading(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Timer countdown display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining',
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                  Text(
                    _formatDuration(_remainingTime),
                    style: AppFonts.heading(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Accept Challenge button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Challenge Accepted! Time to hop on a random bus! 🚌✨',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.3),
                        blurRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Accept Challenge',
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViralChallenges(
    Color surface,
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Viral Challenges',
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal list / vertical items representing trending dares
        // Item 1: Order mystery food
        _buildViralChallengeCard(
          isDark: isDark,
          surface: surface,
          primaryColor: primary,
          secondaryColor: secondary,
          textPrimary: textPrimary,
          textMuted: textMuted,
          avatarText: '🍜',
          title: 'Order mystery food',
          sub: 'Voted by Minh Nhật',
          buttonLabel: 'Join',
          buttonColor: secondary,
          onTap: () => showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
        ),

        const SizedBox(height: 12),

        // Item 2: Recreate a movie scene
        _buildViralChallengeCard(
          isDark: isDark,
          surface: surface,
          primaryColor: primary,
          secondaryColor: secondary,
          textPrimary: textPrimary,
          textMuted: textMuted,
          avatarText: '📸',
          title: 'Recreate a movie scene',
          sub: '1 member ready',
          buttonLabel: 'Join',
          buttonColor: primary,
          onTap: () => showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
        ),
      ],
    );
  }

  Widget _buildViralChallengeCard({
    required bool isDark,
    required Color surface,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textMuted,
    required String avatarText,
    required String title,
    required String sub,
    required String buttonLabel,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.05,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(avatarText, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: AppFonts.body(
                    fontSize: 12,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Join Button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: buttonColor),
                color: buttonColor.withValues(alpha: 0.1),
              ),
              child: Text(
                buttonLabel,
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(
    Color surface,
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    bool isDark,
  ) {
    final List<Map<String, String>> rewards = [
      {'emoji': '👑', 'label': 'Chaos King'},
      {'emoji': '🎵', 'label': 'Vibe Savior'},
      {'emoji': '🍕', 'label': 'Mystery Gourmet'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Chaos Rewards',
          style: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal list of Bento rewards
        Row(
          children: rewards.map((rew) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(rew['emoji']!, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 10),
                    Text(
                      rew['label']!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFloatingNavbar(
    Color surface,
    Color primary,
    Color secondary,
    Color textMuted,
  ) {
    final isDark = widget.isDarkMode;
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: surface.withValues(alpha: isDark ? 0.65 : 0.8),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                    blurRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavbarItem(
                    Icons.home_rounded,
                    false,
                    textMuted,
                    secondary,
                  ),
                  _buildNavbarItem(
                    Icons.payments_outlined,
                    false,
                    textMuted,
                    secondary,
                  ),
                  _buildNavbarItem(
                    Icons.explore_rounded,
                    true,
                    textMuted,
                    secondary,
                  ),
                  _buildNavbarItem(
                    Icons.auto_awesome_rounded,
                    false,
                    textMuted,
                    secondary,
                  ),
                  _buildNavbarItem(
                    Icons.person_outline_rounded,
                    false,
                    textMuted,
                    secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavbarItem(
    IconData icon,
    bool isActive,
    Color textMuted,
    Color secondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isActive
          ? BoxDecoration(
              color: secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.25),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: Icon(icon, color: isActive ? secondary : textMuted, size: 24),
    );
  }
}
