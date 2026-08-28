import 'dart:math' as math;
import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
class AiBudgetAssistantScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AiBudgetAssistantScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<AiBudgetAssistantScreen> createState() =>
      _AiBudgetAssistantScreenState();
}

class _AiBudgetAssistantScreenState extends State<AiBudgetAssistantScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _marqueeController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _marqueeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF1A1712) : const Color(0xFFF1EDE6);
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final surfaceHigh = isDark
        ? const Color(0xFF222A3D)
        : const Color(0xFFEDE7F6);
    final primary = isDark ? const Color(0xFFC9B8FF) : const Color(0xFF6D3BD7);
    final secondary = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFF00BD85);
    final textPrimary = isDark
        ? const Color(0xFFDAE2FD)
        : const Color(0xFF141210);
    final textMuted = isDark
        ? const Color(0xFFCBC3D7)
        : const Color(0xFF4A453E);
    final errorColor = isDark
        ? const Color(0xFFFFB4AB)
        : const Color(0xFFE53935);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Aurora background
          Positioned.fill(
            child: CustomPaint(
              painter: _AuroraPainter(
                isDark: isDark,
                primary: primary,
                secondary: secondary,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(textPrimary, primary, secondary, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        // Hero: Matey orb + total damage
                        _buildHeroSection(
                          primary,
                          secondary,
                          textPrimary,
                          textMuted,
                          errorColor,
                          isDark,
                        ),
                        const SizedBox(height: 24),
                        // Marquee ticker
                        _buildMarquee(secondary, textMuted, surface, isDark),
                        const SizedBox(height: 24),
                        // Insights grid
                        _buildInsightsGrid(
                          primary,
                          secondary,
                          textPrimary,
                          textMuted,
                          errorColor,
                          surface,
                          surfaceHigh,
                          isDark,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating bottom nav
          _buildBottomNav(surface, primary, secondary, textMuted, isDark),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    Color textPrimary,
    Color primary,
    Color secondary,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF262019) : Colors.white,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.group_rounded, color: primary, size: 18),
          ),
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [primary, primary]).createShader(bounds),
            child: Text(
              'trip.mate',
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: textPrimary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF262019) : Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.bolt_rounded, color: primary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    Color errorColor,
    bool isDark,
  ) {
    return Column(
      children: [
        // Pulsing AI Orb
        ScaleTransition(
          scale: _pulseAnim,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA078FF),
                  border: Border.all(color: const Color(0xFFE9DDFF), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.4),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              Positioned(
                top: -8,
                right: -16,
                child: Transform.rotate(
                  angle: 12 * math.pi / 180,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF93000A),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: errorColor, width: 2),
                    ),
                    child: Text(
                      'judging u',
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFDAD6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Total Financial Damage',
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$',
              style: AppFonts.heading(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE9DDFF),
              ),
            ),
            Text(
              '1,420.69',
              style: AppFonts.heading(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
                color: Colors.white,
                shadows: [
                  Shadow(color: primary.withValues(alpha: 0.6), blurRadius: 0),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarquee(
    Color secondary,
    Color textMuted,
    Color surface,
    bool isDark,
  ) {
    const tickerText =
        'maybe skip the 4th coffee today ☕  •  squad dinner was literally 40% of the budget 😭  •  someone stop sarah from buying more souvenirs 🛍️  •  ';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1FA85C).withValues(alpha: 0.05)
                : secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: secondary, width: 2),
          ),
          child: Row(
            children: [
              // Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? const Color(0xFF1A1712) : Colors.white,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign_rounded, color: secondary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'MATEY SAYS',
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _marqueeController,
                  builder: (ctx, child) {
                    return ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionalTranslation(
                          translation: Offset(
                            1.0 - _marqueeController.value * 2.0,
                            0,
                          ),
                          child: Text(
                            tickerText + tickerText,
                            maxLines: 1,
                            style: AppFonts.body(
                              fontSize: 13,
                              color: textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsGrid(
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    Color errorColor,
    Color surface,
    Color surfaceHigh,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Critical Insight card
        Expanded(
          child: _glassCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'CRITICAL INSIGHT',
                        style: AppFonts.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'you spent '),
                      TextSpan(
                        text: '62%',
                        style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: errorColor,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' of your budget on cafes 😭 financial damage accelerating.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF222A3D)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Cafe Receipts',
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Vibe Check / Budget meter card
        Expanded(
          child: _glassCard(
            isDark: isDark,
            glowColor: primary,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'VIBE CHECK',
                    style: AppFonts.body(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Circular progress
                SizedBox(
                  width: 120,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (ctx, child) {
                      return CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: _progressController.value * 0.75,
                          trackColor: isDark
                              ? const Color(0xFF2D3449)
                              : Colors.grey.shade200,
                          progressColor: const Color(0xFF68FCBF),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '75%',
                                style: AppFonts.heading(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Chaos Incurred',
                                style: AppFonts.body(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF68FCBF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Remaining',
                          style: AppFonts.body(
                            fontSize: 10,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$579.31',
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Pace',
                          style: AppFonts.body(
                            fontSize: 10,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              size: 14,
                              color: const Color(0xFFFFB4AB),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Fast',
                              style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFB4AB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    Color? glowColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
              left: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.04),
                width: 1,
              ),
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
            boxShadow: glowColor != null
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.15),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBottomNav(
    Color surface,
    Color primary,
    Color secondary,
    Color textMuted,
    bool isDark,
  ) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: isDark ? 0.8 : 0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navIcon(Icons.explore_outlined, false, textMuted, secondary),
                _navIcon(Icons.group_outlined, false, textMuted, secondary),
                _navIcon(Icons.add_circle_rounded, false, textMuted, secondary),
                _navIcon(Icons.map_rounded, true, textMuted, secondary),
                _navIcon(
                  Icons.account_circle_outlined,
                  false,
                  textMuted,
                  secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon(
    IconData icon,
    bool active,
    Color textMuted,
    Color secondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: active
          ? BoxDecoration(
              color: secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(icon, color: active ? secondary : textMuted, size: 24),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final bool isDark;
  final Color primary;
  final Color secondary;

  _AuroraPainter({
    required this.isDark,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..shader =
          RadialGradient(
            colors: [primary.withValues(alpha: 0.15), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.15, size.height * 0.3),
              radius: size.width * 0.6,
            ),
          );
    canvas.drawRect(Offset.zero & size, p1);

    final p2 = Paint()
      ..shader =
          RadialGradient(
            colors: [secondary.withValues(alpha: 0.1), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.85, size.height * 0.7),
              radius: size.width * 0.6,
            ),
          );
    canvas.drawRect(Offset.zero & size, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 10.0;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) =>
      old.progress != progress;
}
