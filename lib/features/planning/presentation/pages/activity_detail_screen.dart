import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityDetailScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final String? title;
  final String? time;
  final String? location;
  final String? description;
  final Color? themeColor;

  const ActivityDetailScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
    this.title,
    this.time,
    this.location,
    this.description,
    this.themeColor,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Colour tokens ─────────────────────────────────────────────────────────
  static const _darkBg = Color(0xFF0B1326);
  static const _darkSurface = Color(0xFF171F33);
  static const _primaryDark = Color(0xFFD0BCFF);
  static const _secondaryDark = Color(0xFF45DFA4);
  static const _tertiaryDark = Color(0xFFFFB783);
  static const _errorDark = Color(0xFFFFB4AB);

  static const _lightBg = Color(0xFFFCFAF6);
  static const _primaryLight = Color(0xFF6D3BD7);
  static const _secondaryLight = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final bg = isDark ? _darkBg : _lightBg;
    final surface = isDark ? _darkSurface : Colors.white;
    final primary = widget.themeColor ?? (isDark ? _primaryDark : _primaryLight);
    final secondary = isDark ? _secondaryDark : _secondaryLight;
    final tertiary = isDark ? _tertiaryDark : const Color(0xFFE07B39);
    final error = isDark ? _errorDark : const Color(0xFFB00020);

    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [primary, secondary],
          ).createShader(bounds),
          child: Text(
            'Up Next',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'View Itinerary →',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondary,
              ),
            ),
          ),
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textMuted,
                size: 20,
              ),
              onPressed: widget.onThemeToggle,
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // ── Main Glass Card ───────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: isDark ? 0.55 : 0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Timeline Column ───────────────────────────────
                      _TimelineColumn(
                        pulseAnimation: _pulseAnimation,
                        secondary: secondary,
                      ),
                      const SizedBox(width: 16),
                      // ── Content Column ────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              widget.title ?? 'Night Market Chaos',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Location chip
                            Row(
                              children: [
                                Text(
                                  '📍',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.location ?? 'Shilin District',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.description != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                widget.description!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Countdown badge
                            Align(
                              alignment: Alignment.centerRight,
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (_, child) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: secondary.withValues(
                                          alpha: _pulseAnimation.value),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: secondary.withValues(
                                            alpha: 0.25 *
                                                _pulseAnimation.value),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer_rounded,
                                          size: 14, color: secondary),
                                      const SizedBox(width: 5),
                                      Text(
                                        '18 MINS',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: secondary,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Transport chip
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: surface.withValues(
                                        alpha: isDark ? 0.4 : 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: tertiary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.local_taxi_rounded,
                                              color: tertiary, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Uber XL arriving soon',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '🚕 Leaving in 18 mins',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Divider(
                              color: primary.withValues(alpha: 0.15),
                              height: 1,
                            ),
                            const SizedBox(height: 14),
                            // Squad row
                            Row(
                              children: [
                                // Overlapping avatars
                                SizedBox(
                                  width: 72,
                                  height: 28,
                                  child: Stack(
                                    children: [
                                      _Avatar(
                                        color: secondary,
                                        left: 0,
                                        surface: surface,
                                      ),
                                      _Avatar(
                                        color: primary,
                                        left: 22,
                                        surface: surface,
                                      ),
                                      _Avatar(
                                        color: Colors.grey,
                                        left: 44,
                                        surface: surface,
                                        opacity: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '3/4 Ready',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Breathing "not ready" badge
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (_, child) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Pulsing red dot
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: error.withValues(
                                            alpha: _pulseAnimation.value),
                                        boxShadow: [
                                          BoxShadow(
                                            color: error.withValues(
                                                alpha: 0.4 *
                                                    _pulseAnimation.value),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Nam Trung is still not ready 😭',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Future Slot Card (60% opacity) ────────────────────────────
            Opacity(
              opacity: 0.6,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Empty timeline dot
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: surface.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3:00 PM',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: textMuted,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cafe hopping starts',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.local_cafe_rounded,
                              color: tertiary.withValues(alpha: 0.7),
                              size: 22),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper: Timeline column with pulsing dot + gradient line ─────────────────
class _TimelineColumn extends StatelessWidget {
  const _TimelineColumn({
    required this.pulseAnimation,
    required this.secondary,
  });

  final Animation<double> pulseAnimation;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          // Pulsing dot with ping ring
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (_, child) => SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ping ring
                  Container(
                    width: 24 * pulseAnimation.value,
                    height: 24 * pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondary.withValues(
                          alpha: 0.25 * (1 - pulseAnimation.value) + 0.05),
                    ),
                  ),
                  // Core dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondary,
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Gradient line
          Container(
            width: 2,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  secondary.withValues(alpha: 0.7),
                  secondary.withValues(alpha: 0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper: Overlapping avatar circle ────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.color,
    required this.left,
    required this.surface,
    this.opacity = 1.0,
  });

  final Color color;
  final double left;
  final Color surface;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          border: Border.all(color: surface, width: 2),
        ),
      ),
    );
  }
}
