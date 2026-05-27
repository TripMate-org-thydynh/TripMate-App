import 'dart:math';
import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryWallEmptyScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const MemoryWallEmptyScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<MemoryWallEmptyScreen> createState() => _MemoryWallEmptyScreenState();
}

class _MemoryWallEmptyScreenState extends State<MemoryWallEmptyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 4.0, end: 20.0).animate(
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

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final bgColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Glowing backdrop nodes (Gems & Highlights placeholders)
          Positioned(
            top: 150,
            left: 40,
            child: _buildFloatingPlaceholder('🍽️', 'restaurant', 30, primaryColor.withValues(alpha: 0.08), borderCol),
          ),
          Positioned(
            top: 220,
            right: 40,
            child: _buildFloatingPlaceholder('🏞️', 'landscape', 20, secondaryColor.withValues(alpha: 0.08), borderCol),
          ),
          Positioned(
            bottom: 300,
            left: 60,
            child: _buildFloatingPlaceholder('👥', 'groups', -15, primaryColor.withValues(alpha: 0.08), borderCol),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu, color: textPrimary),
                        onPressed: () {},
                      ),
                      Text(
                        'trip.mate',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: -1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          color: primaryColor,
                        ),
                        onPressed: widget.onThemeToggle,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glass Scrapbook Frame Mockup
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: surfaceColor.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: borderCol),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 20,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              // Empty state icon
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor.withValues(alpha: 0.12),
                                ),
                                child: Icon(Icons.photo_library_outlined, color: primaryColor, size: 40),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                'your camera roll deserves\nbetter stories.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: textPrimary,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'the scrapbook is waiting.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'time to make core memories ✨',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Action Button with Pulsing Shadow Glow
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: secondaryColor.withValues(alpha: 0.25),
                                    blurRadius: _glowAnimation.value,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '📸 Bật máy ảnh Ghost Cam! Chuẩn bị dìm hàng lũ bạn nào.',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: secondaryColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('Capture a Memory'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: secondaryColor,
                              side: BorderSide(color: secondaryColor.withValues(alpha: 0.5), width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Mock Bottom Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(top: BorderSide(color: borderCol)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBottomNavItem(Icons.explore_outlined, 'explore', false, textSecondary, primaryColor),
                      _buildBottomNavItem(Icons.groups_outlined, 'group', false, textSecondary, primaryColor),
                      
                      // Accent center add action
                      Transform.translate(
                        offset: const Offset(0, -16),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: surfaceColor,
                            border: Border.all(color: borderCol),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withValues(alpha: 0.35),
                                blurRadius: 12,
                              )
                            ],
                          ),
                          child: Icon(Icons.add_circle, color: secondaryColor, size: 40),
                        ),
                      ),
                      
                      _buildBottomNavItem(Icons.map_outlined, 'map', false, textSecondary, primaryColor),
                      _buildBottomNavItem(Icons.person_outline, 'profile', false, textSecondary, primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, Color inactiveColor, Color activeColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? activeColor : inactiveColor.withValues(alpha: 0.6),
          size: 24,
        ),
      ],
    );
  }

  Widget _buildFloatingPlaceholder(String emoji, String tag, double angle, Color color, Color borderCol) {
    return Transform.rotate(
      angle: angle * pi / 180,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
