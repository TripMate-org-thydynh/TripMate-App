import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedLocationPingScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SharedLocationPingScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SharedLocationPingScreen> createState() => _SharedLocationPingScreenState();
}

class _SharedLocationPingScreenState extends State<SharedLocationPingScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _floatController;
  late AnimationController _pulseController;

  // Selected squad member to show details
  String? _selectedMember;

  // Mock locations for members relative to screen center
  final List<Map<String, dynamic>> _squadMembers = [
    {
      'name': 'Minh Nhật',
      'status': '2 mins away',
      'avatar': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=150',
      'dx': -100.0,
      'dy': -150.0,
      'border': const Color(0xFF34D399),
    },
    {
      'name': 'Thảo Ly',
      'status': 'still in the Grab 🚕',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
      'dx': 120.0,
      'dy': 100.0,
      'border': const Color(0xFFFB923C),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Radar rotation animation
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Floating translation animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Pulsing circle animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Theme tokens
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
            // ── Cyber Grid Background ───────────────────────────────────────
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.08 : 0.04,
                child: CustomPaint(
                  painter: GridPainter(primaryColor: primary),
                ),
              ),
            ),

            // ── Radar Sweeper Visualizer ─────────────────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadarPainter(
                      angle: _radarController.value * 2 * math.pi,
                      color: primary.withValues(alpha: 0.15),
                    ),
                  );
                },
              ),
            ),

            // ── Top Header App Bar ──────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _buildTopBar(textPrimary, primary),
              ),
            ),

            // ── Center Title Floating Section ────────────────────────────────
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    "where's the squad?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "chaos is finding its way.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Intersections & Squad Pins Layer ─────────────────────────────
            _buildInteractiveMapArea(primary, secondary, textPrimary, textMuted, surface),

            // ── Bottom Panel Cluster ─────────────────────────────────────────
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Info Card
                  _buildStatusCard(surface, secondary, textPrimary, textMuted, isDark),

                  const SizedBox(height: 12),

                  // Actions row
                  Row(
                    children: [
                      // "where are you 😭" primary CTA
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ping signal broadcasted to all active members! 📡',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: primary,
                              ),
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primary, primary.withRed(150)],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cell_tower_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'where are you 😭',
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
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Emergency SOS CTA
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('SOS signal broadcasted! Emergency services notified.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildInteractiveMapArea(
      Color primary, Color secondary, Color textPrimary, Color textMuted, Color surface) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final isDark = widget.isDarkMode;

    return Positioned.fill(
      child: Stack(
        children: [
          // ── Connection lines ──────────────────────────────────────────────
          CustomPaint(
            size: size,
            painter: ConnectionLinePainter(
              centerX: centerX,
              centerY: centerY,
              members: _squadMembers,
              lineColor: secondary.withValues(alpha: 0.4),
            ),
          ),

          // ── Central User ("You") Pin ──────────────────────────────────────
          Positioned(
            left: centerX - 24,
            top: centerY - 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 80 * _pulseController.value,
                      height: 80 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: 0.2 * (1 - _pulseController.value)),
                      ),
                    );
                  },
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary,
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'You',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Confused/Lost Emoji Marker (Floating) ────────────────────────
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final translationY = 8.0 * math.sin(_floatController.value * 2 * math.pi);
              return Positioned(
                left: centerX + 50,
                top: centerY - 80 + translationY,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMember = _selectedMember == 'lost_friend' ? null : 'lost_friend';
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: surface.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '😭',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      if (_selectedMember == 'lost_friend')
                        Positioned(
                          top: -45,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: surface.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  'bro where are you?',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Render Squad Members ──────────────────────────────────────────
          ..._squadMembers.map((member) {
            final x = centerX + member['dx'];
            final y = centerY + member['dy'];
            final isSelected = _selectedMember == member['name'];
            final avatarColor = member['border'] as Color;

            return AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                // Unique phase shift for floating effect
                final indexOffset = _squadMembers.indexOf(member) * 1.5;
                final translationY = 8.0 * math.sin((_floatController.value * 2 * math.pi) + indexOffset);

                return Positioned(
                  left: x - 28,
                  top: y - 28 + translationY,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMember = isSelected ? null : member['name'];
                      });
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Glow behind active pins
                        if (isSelected)
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avatarColor.withValues(alpha: 0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: avatarColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),

                        // Main circular avatar
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: avatarColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(member['avatar']!),
                          ),
                        ),

                        // Hover info tooltip
                        if (isSelected)
                          Positioned(
                            top: -64,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: surface.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        member['name']!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        member['status']!,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: avatarColor,
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
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Color surface, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.6 : 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: secondary.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.radar_rounded, color: secondary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATUS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '2/4 Squad nearby',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Avatars overlay
                  SizedBox(
                    width: 72,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: const NetworkImage(
                              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=150',
                            ),
                            backgroundColor: surface,
                          ),
                        ),
                        Positioned(
                          left: 20,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: const NetworkImage(
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
                            ),
                            backgroundColor: surface,
                          ),
                        ),
                        Positioned(
                          left: 40,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: surface.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: textMuted.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Icon(Icons.more_horiz_rounded, size: 16, color: textMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CUSTOM PAINTERS FOR CYBERPUNK RADAR & GRID ─────────────────────────────

class GridPainter extends CustomPainter {
  final Color primaryColor;

  GridPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    const step = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarPainter extends CustomPainter {
  final double angle;
  final Color color;

  RadarPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw reference rings
    canvas.drawCircle(center, maxRadius * 0.33, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.66, ringPaint);
    canvas.drawCircle(center, maxRadius, ringPaint);

    // Draw the radar sweep gradient segment
    final radarPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: angle - 0.5,
        endAngle: angle,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawCircle(Offset.zero, maxRadius, radarPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color;
}

class ConnectionLinePainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final List<Map<String, dynamic>> members;
  final Color lineColor;

  ConnectionLinePainter({
    required this.centerX,
    required this.centerY,
    required this.members,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final dashLength = 6.0;
    final dashSpace = 4.0;

    for (final member in members) {
      final targetX = centerX + member['dx'];
      final targetY = centerY + member['dy'];

      final start = Offset(centerX, centerY);
      final end = Offset(targetX, targetY);

      // Simple Bezier control point for aesthetic curves
      final control = Offset(
        (start.dx + end.dx) / 2 + 30,
        (start.dy + end.dy) / 2 - 20,
      );

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      // Dash path effect
      final pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        double distance = 0.0;
        while (distance < metric.length) {
          final dashStart = distance;
          final dashEnd = math.min(distance + dashLength, metric.length);
          canvas.drawPath(
            metric.extractPath(dashStart, dashEnd),
            paint,
          );
          distance += dashLength + dashSpace;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionLinePainter oldDelegate) =>
      oldDelegate.members != members || oldDelegate.lineColor != lineColor;
}
