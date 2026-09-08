import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/gen_z_widgets.dart';

/// Splash Neo-Brutalist: khối màu accent full-bleed, logo trong khối paper
/// viền ink + hard shadow, tagline pill mono, sticker sparkle lắc nhẹ.
class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const SplashScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();

    // Pop-in: scale 0.96→1 + fade (Design DNA micro-motion)
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _popController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOutBack),
    );

    _popController.forward();

    // Navigate to Onboarding Auth Flow after 1.2 seconds
    _splashTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Khối màu full-bleed theo accent đã chọn; thích ứng Dark/Light theme
    final accent = ref.watch(accentProvider);
    final isDark = widget.isDarkMode;
    final blockColor = isDark ? const Color(0xFF141210) : accent.accent;
    final cardColor = isDark ? const Color(0xFF1E1B18) : GenZTokens.paper;
    final cardBorder = isDark ? GenZTokens.yellow : GenZTokens.ink;
    final cardShadow = isDark ? const Color(0x80000000) : GenZTokens.ink;
    final textColor = isDark ? GenZTokens.paper : GenZTokens.ink;

    return Scaffold(
      backgroundColor: blockColor,
      body: Stack(
        children: [
          // Doodle sparkle rải nền, opacity thấp
          const Positioned.fill(
            child: CustomPaint(painter: _SplashDoodlePainter()),
          ),

          // Logo card brutalist ở giữa
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _WiggleSticker(
                  child: HardShadowBox(
                    color: cardColor,
                    borderColor: cardBorder,
                    shadowColor: cardShadow,
                    radius: GenZTokens.radiusCard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Official TripMate Logo Mark
                        Image.asset(
                          isDark
                              ? 'assets/images/symbol_dark.png'
                              : 'assets/images/symbol_light.png',
                          width: screenWidth > 360 ? 84 : 70,
                          height: screenWidth > 360 ? 72 : 60,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: GenZTokens.space2),
                        Text(
                          'trip.mate',
                          style: AppFonts.heading(
                            fontSize: screenWidth > 360 ? 40 : 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            height: 1.05,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: GenZTokens.space2),
                        // Gạch chân accent viền ink
                        Container(
                          width: 52,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark ? GenZTokens.yellow : accent.pair,
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusPill,
                            ),
                            border: Border.all(
                              color: isDark ? GenZTokens.yellow : GenZTokens.ink,
                              width: GenZTokens.borderWidthThin,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tagline pill mono dưới cùng
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: GenZTokens.space2,
                  runSpacing: GenZTokens.space2,
                  children: [
                    PillTag(
                      text: 'plan chill',
                      color: isDark ? const Color(0xFF1E1B18) : GenZTokens.paper,
                    ),
                    PillTag(text: 'splash.tag_split'.tr(), color: GenZTokens.lilac),
                    PillTag(text: 'splash.tag_moments'.tr(), color: GenZTokens.pink),
                  ],
                ),
              ),
            ),
          ),

          // Nút đổi sáng/tối — viên tròn paper viền ink
          Positioned(
            top: 54,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1B18) : GenZTokens.paper,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? GenZTokens.yellow : GenZTokens.ink,
                    width: GenZTokens.borderWidthThin,
                  ),
                  boxShadow: GenZTokens.hardShadow(),
                ),
                child: IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? GenZTokens.yellow : GenZTokens.ink,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lắc nhẹ ±1.5° một nhịp khi xuất hiện (không loop gây rối).
class _WiggleSticker extends StatefulWidget {
  final Widget child;
  const _WiggleSticker({required this.child});

  @override
  State<_WiggleSticker> createState() => _WiggleStickerState();
}

class _WiggleStickerState extends State<_WiggleSticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Dao động tắt dần: sin nhanh × (1 - t)
        final t = _c.value;
        final angle = math.sin(t * math.pi * 4) * (1 - t) * 0.03;
        return Transform.rotate(angle: angle, child: child);
      },
      child: widget.child,
    );
  }
}

/// Sparkle ✦ + dấu + rải trên khối màu, dùng ink opacity thấp.
class _SplashDoodlePainter extends CustomPainter {
  const _SplashDoodlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GenZTokens.ink.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rng = math.Random(11); // seed cố định
    for (var i = 0; i < 16; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = 6 + rng.nextDouble() * 8;
      if (i % 3 == 0) {
        canvas.drawCircle(Offset(cx, cy), r * 0.4, paint);
      } else {
        canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), paint);
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashDoodlePainter oldDelegate) => false;
}
