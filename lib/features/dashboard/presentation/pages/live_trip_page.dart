import 'dart:math';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../discovery/presentation/pages/live_map_squad_tracking_screen.dart';

class LiveTripPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const LiveTripPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<LiveTripPage> createState() => _LiveTripPageState();
}

class _LiveTripPageState extends State<LiveTripPage>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _particlesController;
  final List<Particle> _particles = [];
  final Random _random = Random();
  double _energyLevel = 0.85;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _particlesController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _triggerVibeBoost() {
    _shakeController.forward(from: 0.0);
    setState(() {
      _energyLevel = min(1.0, _energyLevel + 0.05);
    });

    // Generate falling color particle sparks
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(
        Particle(
          x: 100 + _random.nextDouble() * 80,
          y: 80 + _random.nextDouble() * 50,
          vx: (_random.nextDouble() - 0.5) * 10,
          vy: (_random.nextDouble() - 0.5) * 8 - 4,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
          size: _random.nextDouble() * 6 + 3,
        ),
      );
    }
    _particlesController.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('VIBE BOOST ACTIVE! Squad energy is skyrocketing! 🚀⚡'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B);
    final secondaryColor = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D);

    final bgColor = isDark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    final textSecondary = isDark
        ? const Color(0xFFB8AE9C)
        : const Color(0xFF4A453E);
    final glassBorder = textPrimary; // viền ink brutalist

    if (_particlesController.isAnimating) {
      for (var p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.2; // Gravity effect
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Live Mode header block
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [textPrimary, textPrimary],
                            ).createShader(bounds),
                            child: Text(
                              'Đà Lạt Chill 🌲',
                              style: AppFonts.body(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                          Text(
                            'Active squad members: 6 idiots',
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LiveMapSquadTrackingScreen(
                                isDarkMode: widget.isDarkMode,
                                onThemeToggle: widget.onThemeToggle,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8422B),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: glassBorder, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.gps_fixed,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE MAP',
                                style: AppFonts.mono(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mini Map Schematic panel card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiveMapSquadTrackingScreen(
                            isDarkMode: widget.isDarkMode,
                            onThemeToggle: widget.onThemeToggle,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: cardBg,
                        border: Border.all(color: glassBorder, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: glassBorder,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: MiniMapGridPainter(
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                ),
                              ),
                            ),
                            // Small simplified pin bubbles overlay
                            _buildMiniMapPin(
                              top: 30,
                              left: 50,
                              name: 'Nam Trung',
                              color: Colors.greenAccent,
                            ),
                            _buildMiniMapPin(
                              top: 100,
                              left: 140,
                              name: 'Ly (Me)',
                              color: primaryColor,
                              isMe: true,
                            ),
                            _buildMiniMapPin(
                              top: 60,
                              left: 240,
                              name: 'Nhật',
                              color: secondaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Circular Vibe energy meter gauge & Shake booster panel (2 columns)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: glassBorder, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: glassBorder,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(110, 110),
                                painter: EnergyCirclePainter(
                                  progress: _energyLevel,
                                  color: secondaryColor,
                                  backgroundColor: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(_energyLevel * 100).toInt()}%',
                                    style: AppFonts.heading(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  Text(
                                    'vibe energy',
                                    style: AppFonts.body(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              // Spans floating particles when boosted
                              if (_particlesController.isAnimating)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: FallingParticlesPainter(
                                        particles: _particles,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _triggerVibeBoost,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.vibration,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Shake to Vibe Boost',
                                    textAlign: TextAlign.center,
                                    style: AppFonts.heading(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Real-time Live Updates timeline list section
                  Text(
                    'Live Updates',
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildLiveFeedItem(
                    '☕',
                    'Minh Nhật is at The Hill Station',
                    'Just now',
                    cardBg,
                    glassBorder,
                    textPrimary,
                    textSecondary,
                  ),
                  _buildLiveFeedItem(
                    '📸',
                    'Thảo Ly uploaded 3 moments',
                    '5m ago',
                    cardBg,
                    glassBorder,
                    textPrimary,
                    textSecondary,
                  ),
                  _buildLiveFeedItem(
                    '🛵',
                    'Nam Trung is cruising Dalat Night Market',
                    '15m ago',
                    cardBg,
                    glassBorder,
                    textPrimary,
                    textSecondary,
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMapPin({
    required double top,
    required double left,
    required String name,
    required Color color,
    bool isMe = false,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFF5822B) : Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveFeedItem(
    String emoji,
    String title,
    String time,
    Color cardBg,
    Color glassBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder, width: 2),
        boxShadow: [BoxShadow(color: glassBorder, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppFonts.body(fontSize: 10, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x, y;
  double vx, vy;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class FallingParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  FallingParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      paint.color = p.color;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EnergyCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  EnergyCirclePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 8.0;

    // Background complete ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Front progress ring
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      pi * 0.75,
      pi * 1.5 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MiniMapGridPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;

  MiniMapGridPainter({required this.isDark, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.black.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    final roadPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(100, 40, 160, 100);
    path.quadraticBezierTo(200, 160, size.width, 140);

    path.moveTo(80, 0);
    path.lineTo(60, size.height);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
