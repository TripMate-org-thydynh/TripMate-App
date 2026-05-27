import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../trip_planner/presentation/itinerary_screen.dart';
import '../../trip_planner/presentation/create_trip_screen.dart';
import '../../profile/profile_screen.dart';
import 'pages/home_dashboard_page.dart';
import 'pages/live_trip_page.dart';
import '../../../../core/theme/theme.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const DashboardScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primaryColor = widget.isDarkMode ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = widget.isDarkMode ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final tertiaryColor = widget.isDarkMode ? TripMateTheme.darkTertiary : TripMateTheme.lightSecondary;

    // Body pages representing Home flow, Itinerary map, Create trip, Live crew tracking, and Profile
    final List<Widget> pages = [
      HomeDashboardPage(
        onNavigateToLiveMode: () {
          setState(() {
            _selectedIndex = 3; // Navigate to LiveTripPage (Crew/Group tab)
          });
        },
        onNavigateToActivityHub: () {
          setState(() {
            _selectedIndex = 2; // Navigate to CreateTripScreen (Create tab)
          });
        },
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      ItineraryScreen(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      CreateTripScreen(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      LiveTripPage(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6),
      body: Stack(
        children: [
          // Dynamic Ambient Aurora background layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: DashboardMeshBackgroundPainter(
                    progress: _bgAnimationController.value,
                    isDarkMode: widget.isDarkMode,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    tertiaryColor: tertiaryColor,
                  ),
                );
              },
            ),
          ),
          // Backdrop blur for premium frosted glass feel
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Main Body content with SafeArea
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode 
                  ? Colors.black.withValues(alpha: 0.35) 
                  : Colors.grey.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: widget.isDarkMode
                  ? const Color(0x9E171F33) // Translucent surface-container dark
                  : const Color(0xB5FFFFFF), // Translucent white light
              selectedItemColor: secondaryColor,
              unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.4),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.explore_outlined),
                  activeIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.explore),
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: secondaryColor.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  label: 'general.explore'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.map_outlined),
                  activeIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map),
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: secondaryColor.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  label: 'general.itinerary'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.add_circle_outline),
                  activeIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle),
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: secondaryColor.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  label: 'trips.create_trip'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.group_outlined),
                  activeIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group),
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: secondaryColor.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  label: 'live_trip.live_mode'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: secondaryColor.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  label: 'general.settings'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardMeshBackgroundPainter extends CustomPainter {
  final double progress;
  final bool isDarkMode;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  DashboardMeshBackgroundPainter({
    required this.progress,
    required this.isDarkMode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Center 1 - primaryColor (Stitch Purple in Dark, Coral in Light)
    final center1 = Offset(
      size.width * 0.8 + math.sin(progress * math.pi * 2) * 40,
      size.height * 0.1 + math.cos(progress * math.pi * 2) * 50,
    );
    final radius1 = size.width * 0.9;
    paint.shader = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: isDarkMode ? 0.15 : 0.08),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint);

    // Center 2 - secondaryColor (Stitch Mint in Dark, Amber in Light)
    final center2 = Offset(
      size.width * 0.15 - math.cos(progress * math.pi * 2) * 30,
      size.height * 0.5 + math.sin(progress * math.pi * 2) * 60,
    );
    final radius2 = size.width * 0.8;
    paint.shader = RadialGradient(
      colors: [
        secondaryColor.withValues(alpha: isDarkMode ? 0.12 : 0.06),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint);

    // Center 3 - tertiaryColor (Coral Orange in Dark, Lavender in Light)
    final center3 = Offset(
      size.width * 0.6 + math.sin(progress * math.pi * 2 + 1) * 50,
      size.height * 0.85 - math.cos(progress * math.pi * 2) * 40,
    );
    final radius3 = size.width * 0.85;
    paint.shader = RadialGradient(
      colors: [
        tertiaryColor.withValues(alpha: isDarkMode ? 0.12 : 0.06),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center3, radius: radius3));
    canvas.drawCircle(center3, radius3, paint);
  }

  @override
  bool shouldRepaint(covariant DashboardMeshBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDarkMode != isDarkMode;
}
