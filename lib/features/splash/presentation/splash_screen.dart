import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _popController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOutCubic),
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
    final isDark = widget.isDarkMode;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final cardColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final textColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Logo card ở giữa
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: HardShadowBox(
                  color: cardColor,
                  borderColor: line,
                  shadowColor: textColor,
                  radius: GenZTokens.radiusCard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 28,
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
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(height: GenZTokens.space2),
                      Text(
                        'trip.mate',
                        style: AppFonts.heading(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                          height: 1.1,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: GenZTokens.space2),
                      // Gạch chân accent đơn sắc
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(
                            GenZTokens.radiusPill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tagline pill dưới cùng
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
                    PillTag(text: 'splash.tag_plan'.tr(), color: fill),
                    PillTag(text: 'splash.tag_split'.tr(), color: fill),
                    PillTag(text: 'splash.tag_moments'.tr(), color: fill),
                  ],
                ),
              ),
            ),
          ),

          // Nút đổi sáng/tối
          Positioned(
            top: 54,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                  boxShadow: GenZTokens.hardShadow(textColor, isDark),
                ),
                child: IconButton(
                  tooltip: 'theme.toggle'.tr(),
                  icon: Icon(
                    widget.isDarkMode
                        ? PhosphorIcons.sun(PhosphorIconsStyle.fill)
                        : PhosphorIcons.moon(PhosphorIconsStyle.fill),
                    color: textColor,
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
