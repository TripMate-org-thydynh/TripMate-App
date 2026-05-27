import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';

class RequestPermissionsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const RequestPermissionsScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<RequestPermissionsScreen> createState() => _RequestPermissionsScreenState();
}

class _RequestPermissionsScreenState extends State<RequestPermissionsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Theme responsive color assignments
    final Color bg = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final Color surface = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final Color primary = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final Color secondary = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final Color textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final Color textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Ambient Background Glows ──────────────────────────────────────────
          if (isDark) ...[
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary.withValues(alpha: 0.1),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ],

          // ── Main Content Layout ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header with back button & theme toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      if (widget.onThemeToggle != null)
                        GestureDetector(
                          onTap: widget.onThemeToggle,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                            ),
                            child: Icon(
                              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              size: 20,
                              color: textSecondary,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 42),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // ── Pulsating GPS Radar Visualizer Card ──────────────────────
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsating Radar Ring 1
                              AnimatedBuilder(
                                animation: _radarController,
                                builder: (context, child) {
                                  final progress = _radarController.value;
                                  return Container(
                                    width: 100 + (progress * 100),
                                    height: 100 + (progress * 100),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primary.withValues(alpha: (1.0 - progress) * 0.4),
                                        width: 2.0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Pulsating Radar Ring 2
                              AnimatedBuilder(
                                animation: _radarController,
                                builder: (context, child) {
                                  final progress = (_radarController.value + 0.5) % 1.0;
                                  return Container(
                                    width: 100 + (progress * 100),
                                    height: 100 + (progress * 100),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primary.withValues(alpha: (1.0 - progress) * 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Glassmorphic Center Pin
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
                                      border: Border.all(
                                        color: primary.withValues(alpha: 0.35),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.2),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        size: 44,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Title Text block
                        Text(
                          "don't lose the squad😭",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: textPrimary,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Core Paragraph
                        Text(
                          "location access helps us find hidden gems and track your travel idiots in realtime.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            color: textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const Spacer(flex: 3),

                        // ── Button: Allow Location ─────────────────────────────────
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🗺️ Squad location synchronization granted! Finding travel idiots...',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              gradient: LinearGradient(
                                colors: [primary, primary.withValues(alpha: 0.85)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Allow Location',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Button: Maybe Later ────────────────────────────────────
                        GestureDetector(
                          onTap: () {
                            Navigator.maybePop(context);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: surface.withValues(alpha: isDark ? 0.2 : 0.5),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: textSecondary.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'maybe later.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
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
}
