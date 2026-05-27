import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _LiveTripPageState extends State<LiveTripPage> with TickerProviderStateMixin {
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
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
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
    // Shake animation
    _shakeController.forward(from: 0.0);
    
    // Increment energy slightly
    setState(() {
      _energyLevel = min(1.0, _energyLevel + 0.05);
    });

    // Generate colorful particles
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(
        Particle(
          x: 150 + _random.nextDouble() * 50 - 25,
          y: 150 + _random.nextDouble() * 50 - 25,
          vx: (_random.nextDouble() - 0.5) * 8,
          vy: (_random.nextDouble() - 0.5) * 8 - 4,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
          size: _random.nextDouble() * 8 + 4,
        ),
      );
    }
    _particlesController.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("live_trip.boosted_vibe".tr()),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Simulate active particles movement
    if (_particlesController.isAnimating) {
      for (var p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.15; // Gravity
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "live_trip.live_mode".tr(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      "live_trip.active_mates".tr(namedArgs: {"count": "6"}),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "LIVE MAP",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map schematic mockup
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
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Abstract decorative map lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MapGridPainter(isDark: isDark, colorScheme: colorScheme),
                      ),
                    ),
                    // Pinned squad overlays
                    _buildMapPin(top: 40, left: 60, name: "Nam Trung", emoji: "☕", color: Colors.greenAccent),
                    _buildMapPin(top: 130, left: 160, name: "Thảo Ly (Me)", emoji: "📸", color: colorScheme.primary, isMe: true),
                    _buildMapPin(top: 80, left: 220, name: "Minh Nhật", emoji: "🚶‍♀️", color: Colors.greenAccent),
                    _buildMapPin(top: 170, left: 80, name: "Phú Khang", emoji: "😴", color: Colors.amberAccent),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Vibe Meter & Particle Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Circular Vibe Energy Meter
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(120, 120),
                          painter: EnergyGaugePainter(
                            progress: _energyLevel,
                            color: colorScheme.secondary,
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${(_energyLevel * 100).toInt()}%",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.secondary,
                              ),
                            ),
                            Text(
                              "vibe energy".tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Custom animated particles on boost
                        if (_particlesController.isAnimating)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: ParticlePainter(particles: _particles),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Shake booster button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _triggerVibeBoost,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.vibration, size: 42, color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              "live_trip.shake_to_boost".tr(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
          ),
          const SizedBox(height: 24),

          // Live Activity Feed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "live_trip.live_updates".tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActivityFeedItem(
                  theme: theme,
                  isDark: isDark,
                  emoji: "☕",
                  title: "Minh Nhật is at The Hill Station",
                  time: "Just now",
                ),
                _buildActivityFeedItem(
                  theme: theme,
                  isDark: isDark,
                  emoji: "📸",
                  title: "Thảo Ly uploaded 3 moments",
                  time: "5m ago",
                ),
                _buildActivityFeedItem(
                  theme: theme,
                  isDark: isDark,
                  emoji: "🛵",
                  title: "Nam Trung is cruising Dalat Night Market",
                  time: "15m ago",
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin({
    required double top,
    required double left,
    required String name,
    required String emoji,
    required Color color,
    bool isMe = false,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF8B5CF6) : Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 2),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(color: color, width: 2),
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeedItem({
    required ThemeData theme,
    required bool isDark,
    required String emoji,
    required String title,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
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

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter({required this.particles});

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

class EnergyGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  EnergyGaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = 10.0;
    
    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(strokeWidth/2, strokeWidth/2, size.width - strokeWidth, size.height - strokeWidth),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Progress arc
    final fgPaint = Paint()
      ..shader = SweepGradient(
        colors: [color, color.withValues(alpha: 0.5)],
        startAngle: 0.0,
        endAngle: pi * 2,
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(strokeWidth/2, strokeWidth/2, size.width - strokeWidth, size.height - strokeWidth),
      pi * 0.75,
      pi * 1.5 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MapGridPainter extends CustomPainter {
  final bool isDark;
  final ColorScheme colorScheme;

  MapGridPainter({required this.isDark, required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    // Draw coordinate lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // Abstract roads
    final roadPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 40);
    path.quadraticBezierTo(100, 50, 160, 130);
    path.quadraticBezierTo(200, 200, size.width, 170);

    path.moveTo(80, 0);
    path.lineTo(60, size.height);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
