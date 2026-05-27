import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyAnalyticsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const MonthlyAnalyticsScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<MonthlyAnalyticsScreen> createState() => _MonthlyAnalyticsScreenState();
}

class _MonthlyAnalyticsScreenState extends State<MonthlyAnalyticsScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  int _currentPageIndex = 0;
  Timer? _storyTimer;

  // Wrapped Data Slides
  final List<Map<String, dynamic>> _wrappedSlides = [
    {
      'title': 'your odyssey\nin numbers.',
      'subtitle': 'friendship survived another year of financial chaos.',
      'type': 'hero_stats',
      'stats': [
        {'emoji': '📸', 'value': '1,248', 'label': 'memories created'},
        {'emoji': '🌍', 'value': '12', 'label': 'destinations explored'},
        {'emoji': '💸', 'value': '42M', 'label': 'emotionally spent'},
      ],
    },
    {
      'title': 'the vibe check.',
      'subtitle': 'our AI ran the numbers on your personality.',
      'type': 'ai_insights',
      'insights': [
        '“You romanticized cafes more than anyone else this year.” ☕',
        '“Your squad peaks emotionally after midnight.” 🌙',
      ],
    },
    {
      'title': 'the cafe addiction.',
      'subtitle': 'caffeine vs. financial stability',
      'type': 'cafe_meter',
    },
    {
      'title': 'squad energy.',
      'subtitle': 'real-time social battery tracking across months',
      'type': 'social_energy',
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    // Auto-advance Wrapped Stories
    _startStoryTimer();
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _storyTimer?.cancel();
    _progressController.reset();
    _progressController.forward();

    _storyTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        if (_currentPageIndex < _wrappedSlides.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        } else {
          // loop back to start
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _startStoryTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Theme Tokens
    final bgStart = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final bgEnd = isDark ? const Color(0xFF060E20) : const Color(0xFFF1EDE6);
    final surface = isDark ? const Color(0xFF171F33) : Colors.white;
    final primary = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondary = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
    final textMuted = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: Stack(
          children: [
            // ── Dynamic Background Mesh Glow ────────────────────────────────
            if (isDark) ...[
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -100,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ],

            SafeArea(
              child: Column(
                children: [
                  // ── Spotify Wrapped Stories Progress Bar Indicators ────────
                  _buildProgressIndicators(primary),

                  // ── Top Header App Bar ────────────────────────────────────
                  _buildTopBar(textPrimary, primary),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _wrappedSlides.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final slide = _wrappedSlides[index];
                        return _buildStorySlide(
                          slide: slide,
                          surface: surface,
                          primaryColor: primary,
                          secondaryColor: secondary,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),

                  // ── CTA "Share the damage" Action Pill ─────────────────────
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildShareButton(primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicators(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: List.generate(_wrappedSlides.length, (index) {
          final isCompleted = index < _currentPageIndex;
          final isCurrent = index == _currentPageIndex;

          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  if (isCompleted)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  if (isCurrent)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(Color textPrimary, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
          Text(
            'trip.mate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: textPrimary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                  tooltip: 'Toggle Theme',
                ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: textPrimary, size: 24),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorySlide({
    required Map<String, dynamic> slide,
    required Color surface,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    final title = slide['title'] as String;
    final subtitle = slide['subtitle'] as String;
    final type = slide['type'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Slide Title
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Slide Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),

          const SizedBox(height: 32),

          // Content body based on type
          Expanded(
            child: _buildSlideContent(
              type: type,
              slide: slide,
              surface: surface,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              textPrimary: textPrimary,
              textMuted: textMuted,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent({
    required String type,
    required Map<String, dynamic> slide,
    required Color surface,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    switch (type) {
      case 'hero_stats':
        final stats = slide['stats'] as List<Map<String, String>>;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: stats.map((stat) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: (isDark ? Colors.white10 : Colors.black12)),
              ),
              child: Row(
                children: [
                  Text(stat['emoji']!, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat['value']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        stat['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'ai_insights':
        final insights = slide['insights'] as List<String>;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: insights.map((insight) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.05),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                insight,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  color: textPrimary,
                ),
              ),
            );
          }).toList(),
        );

      case 'cafe_meter':
        // Render Cafe comparative donut/meter visualizer
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: CafeMeterPainter(
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendIndicator('Cafes ☕', primaryColor),
                  const SizedBox(width: 20),
                  _buildLegendIndicator('Everything else 🍕', secondaryColor),
                ],
              ),
            ],
          ),
        );

      case 'social_energy':
        // Render Squad Activity Line Chart CustomPainter
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: SocialEnergyPainter(
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Social Energy Spike Points (Jan - Dec)',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildShareButton(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Damage Report ready for Instagram & TikTok! 📸✨'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withRed(150)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'share the damage',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── COMPARATIVE DONUT CUSTOM PAINTER ────────────────────────────────────────

class CafeMeterPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  CafeMeterPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    final paintBase = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;

    final paintPrimary = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final paintSecondary = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(center, radius, paintBase);

    // Comparative values: Cafes take up 65%, rest takes 35%
    const startAngle = -math.pi / 2;
    const sweepPrimary = 2 * math.pi * 0.65;
    const sweepSecondary = 2 * math.pi * 0.30; // Small space left for styling spacing

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepPrimary,
      false,
      paintPrimary,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepPrimary + 0.1,
      sweepSecondary,
      false,
      paintSecondary,
    );

    // Core typography details
    final textPainter = TextPainter(
      text: TextSpan(
        text: '65%',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: primaryColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CafeMeterPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor;
}

// ── SPLINE GRAPH CUSTOM PAINTER ─────────────────────────────────────────────

class SocialEnergyPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  SocialEnergyPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paintDots = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Monthly data coordinates (Normalized values 0.0 - 1.0)
    final points = [0.15, 0.45, 0.30, 0.75, 0.90, 0.50, 0.65, 0.85, 0.40, 0.60, 0.95, 0.80];

    final widthStep = size.width / (points.length - 1);

    final path = Path();
    final fillPath = Path();

    // Start coordinates
    path.moveTo(0, size.height * (1.0 - points[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * (1.0 - points[0]));

    for (int i = 1; i < points.length; i++) {
      final x = i * widthStep;
      final y = size.height * (1.0 - points[i]);

      // Cubic Bezier curve algorithm
      final prevX = (i - 1) * widthStep;
      final prevY = size.height * (1.0 - points[i - 1]);
      final controlX1 = prevX + widthStep / 2;
      final controlY1 = prevY;
      final controlX2 = x - widthStep / 2;
      final controlY2 = y;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Render area fill
    canvas.drawPath(fillPath, paintFill);

    // Render continuous line
    canvas.drawPath(path, paintLine);

    // Draw secondary highlight nodes
    for (int i = 0; i < points.length; i++) {
      if (i % 2 == 0) {
        final x = i * widthStep;
        final y = size.height * (1.0 - points[i]);
        canvas.drawCircle(Offset(x, y), 5.0, paintDots);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SocialEnergyPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor;
}
