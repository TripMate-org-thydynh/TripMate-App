import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api_service.dart';
import '../../../../core/theme/theme.dart';

class TripSummaryCard extends StatefulWidget {
  const TripSummaryCard({super.key});

  @override
  State<TripSummaryCard> createState() => _TripSummaryCardState();
}

class _TripSummaryCardState extends State<TripSummaryCard> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _tripData;
  bool _isLoading = true;
  late AnimationController _borderGlowController;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    _borderGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _borderGlowController.dispose();
    super.dispose();
  }

  Future<void> _fetchSummary() async {
    final data = await ApiService.get('/dashboard/summary');
    if (mounted) {
      setState(() {
        _tripData = data?['activeTrip'] as Map<String, dynamic>?;
        _isLoading = false;
      });
    }
  }

  String _getDaysLeft() {
    if (_tripData == null) return '?';
    try {
      final endDate = DateTime.parse(_tripData!['endDate'] as String);
      final now = DateTime.now();
      final diff = endDate.difference(now).inDays;
      return diff >= 0 ? diff.toString() : '0';
    } catch (_) {
      return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;

    // Fallback display data
    final tripName = _tripData?['name'] as String? ?? 'Phượt Đà Lạt Chill Chill 🌲';
    final activeEditors = _tripData?['activeEditors'] as int? ?? 3;
    final progressPercent = (_tripData?['progressPercent'] as int? ?? 80) / 100.0;
    final daysLeft = _getDaysLeft();

    return AnimatedBuilder(
      animation: _borderGlowController,
      builder: (context, child) {
        return CustomPaint(
          painter: GradientBorderPainter(
            progress: _borderGlowController.value,
            colors: [
              primaryColor,
              secondaryColor,
              const Color(0xFFFB923C), // Stitch Orange / Coral
              primaryColor, // Loop back
            ],
            strokeWidth: 2.0,
            borderRadius: 24.0,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        TripMateTheme.darkSurface.withValues(alpha: 0.9),
                        TripMateTheme.darkBackground.withValues(alpha: 0.8),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.95),
                        TripMateTheme.lightBackground.withValues(alpha: 0.8),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : primaryColor.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Mesh decorative blur background gradients - brand colors
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -50,
                    bottom: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryColor.withValues(alpha: isDark ? 0.12 : 0.1),
                      ),
                    ),
                  ),
                  // Loading shimmer
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Days left chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "dashboard.days_left".tr(namedArgs: {"days": daysLeft}),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Weather chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: secondaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thermostat,
                                    size: 14,
                                    color: secondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "22°C Clear",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tripName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Active glow dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00C853),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C853).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$activeEditors editing active right now",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Progress indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "dashboard.group_progress".tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "dashboard.paid_percentage".tr(namedArgs: {
                                "percent": "${(progressPercent * 100).toInt()}"
                              }),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 8,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;
  final double borderRadius;

  GradientBorderPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Create a rotating SweepGradient centered inside the card
    final shaderGradient = SweepGradient(
      center: Alignment.center,
      colors: colors,
      transform: GradientRotation(progress * math.pi * 2),
    );

    paint.shader = shaderGradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GradientBorderPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors;
}
