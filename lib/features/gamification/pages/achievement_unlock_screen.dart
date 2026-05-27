import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementUnlockScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AchievementUnlockScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<AchievementUnlockScreen> createState() =>
      _AchievementUnlockScreenState();
}

class _AchievementUnlockScreenState extends State<AchievementUnlockScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _entranceController;
  late AnimationController _particleController;
  late Animation<double> _glowAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _particleAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _entranceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF080818) : const Color(0xFFF0EEFF);
    final surface = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.75);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.55);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Purple ambient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 0.8,
                  colors: [
                    const Color(0xFF7B2FF7).withValues(alpha: isDark ? 0.25 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Particle-like dots
          AnimatedBuilder(
            animation: _particleAnim,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildParticle(0.15, 0.12, _particleAnim.value, 0.0),
                  _buildParticle(0.75, 0.08, _particleAnim.value, 0.3),
                  _buildParticle(0.85, 0.25, _particleAnim.value, 0.6),
                  _buildParticle(0.1, 0.35, _particleAnim.value, 0.15),
                  _buildParticle(0.65, 0.18, _particleAnim.value, 0.45),
                  _buildParticle(0.45, 0.05, _particleAnim.value, 0.7),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                        isDark: isDark,
                      ),
                      const Spacer(),
                      // Achievement Unlocked badge
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (context, child) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFD0BCFF)
                                  .withValues(alpha: 0.5 * _glowAnim.value),
                            ),
                            color: const Color(0xFF7B2FF7)
                                .withValues(alpha: 0.15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD0BCFF)
                                    .withValues(alpha: 0.2 * _glowAnim.value),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              Text(
                                'Achievement Unlocked',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD0BCFF),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildGlassButton(
                        icon: isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        onTap: widget.onThemeToggle ?? () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _slideAnim.value),
                        child: Opacity(
                          opacity: _entranceController.value,
                          child: child,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            'new personality trait unlocked✨',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'your chaos is evolving.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Main badge
                          AnimatedBuilder(
                            animation: _glowAnim,
                            builder: (context, child) => AnimatedBuilder(
                              animation: _scaleAnim,
                              builder: (ctx, c) => Transform.scale(
                                scale: _scaleAnim.value,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7B2FF7),
                                        Color(0xFFD0BCFF),
                                        Color(0xFF45DFA4),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7B2FF7)
                                            .withValues(
                                                alpha: 0.5 * _glowAnim.value),
                                        blurRadius: 40,
                                        spreadRadius: 8,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFD0BCFF)
                                            .withValues(
                                                alpha: 0.3 * _glowAnim.value),
                                        blurRadius: 60,
                                        spreadRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 0, sigmaY: 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white
                                                  .withValues(alpha: 0.15),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // RARITY badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white
                                                    .withValues(alpha: 0.2),
                                              ),
                                              child: Text(
                                                'RARITY: MYTHIC',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            const Icon(
                                              Icons.local_fire_department,
                                              color: Colors.white,
                                              size: 56,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Chaos King',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Level 4 Reached',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // XP gained
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFD0BCFF)
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF7B2FF7),
                                                Color(0xFFD0BCFF),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF7B2FF7)
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 16,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '+500 XP',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // XP Progress bar
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Level 4',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: textSecondary,
                                              ),
                                            ),
                                            Text(
                                              'Level 5',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: LinearProgressIndicator(
                                            value: 1200 / 2000,
                                            minHeight: 8,
                                            backgroundColor:
                                                const Color(0xFFD0BCFF)
                                                    .withValues(alpha: 0.15),
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                    Color(0xFFD0BCFF)),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Center(
                                          child: Text(
                                            '1,200 / 2,000 to Lvl 5',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Share button
                          AnimatedBuilder(
                            animation: _glowAnim,
                            builder: (context, child) => Container(
                              width: double.infinity,
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7B2FF7),
                                    Color(0xFFD0BCFF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7B2FF7).withValues(
                                        alpha: 0.4 * _glowAnim.value),
                                    blurRadius: 24,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  onTap: () {},
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.share,
                                            color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Share the Chaos',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Collect button
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFFD0BCFF)
                                      .withValues(alpha: 0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                'Collect Reward',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD0BCFF),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(
      double xFactor, double yFactor, double t, double offset) {
    final size = MediaQuery.of(context).size;
    final phase = (t + offset) % 1.0;
    final opacity = (phase < 0.5 ? phase : 1 - phase) * 0.6;
    return Positioned(
      left: xFactor * size.width,
      top: (yFactor + phase * 0.2) * size.height,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD0BCFF),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
    );
  }
}
