import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:tripmate/core/theme/theme.dart';
import '../../../core/app_messenger.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../planning/presentation/pages/ai_planning_matey_screen.dart';
import '../../planning/presentation/pages/ai_weather_replanning_screen.dart';
import '../../planning/presentation/pages/squad_voting_democracy_screen.dart';
import '../../planning/presentation/pages/ai_route_optimization_screen.dart';
import '../../planning/presentation/pages/transport_planning_screen.dart';
import '../../planning/presentation/pages/squad_checklist_packing_screen.dart';
import '../../planning/presentation/pages/flight_hotel_info_screen.dart';
import '../../planning/presentation/pages/activity_detail_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const ItineraryScreen({
    super.key,
    this.isDarkMode = false,
    required this.onThemeToggle,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen>
    with SingleTickerProviderStateMixin {
  int _activeDayIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool _isNightMarketSwapped = false;

  // Custom colors based on TripMate color palette instructions
  // Dark: bg=#0B1326, primary=#8B5CF6, secondary=#34D399, tertiary=#FB923C, surface=#171F33
  // Light: bg=#FCFAF6, primary=#E0533C, secondary=#EBA83A, surface=white, text=#1E2022
  late Color bgGradStart;
  late Color bgGradEnd;
  late Color cardBg;
  late Color textPrimaryColor;
  late Color textSecondaryColor;
  late Color primaryColor;
  late Color secondaryColor;
  late Color tertiaryColor;
  late Color surfaceColor;

  void _initThemeColors(bool isDark) {
    if (isDark) {
      bgGradStart = const Color(0xFF1A1712);
      bgGradEnd = const Color(0xFF1A1712);
      cardBg = const Color(0xFF262019);
      textPrimaryColor = const Color(0xFFFDF6D3);
      textSecondaryColor = const Color(0xFFB8AE9C);
      primaryColor = TripMateTheme.darkPrimary;
      secondaryColor = TripMateTheme.darkSecondary;
      tertiaryColor = TripMateTheme.darkTertiary;
      surfaceColor = const Color(0xFF262019);
    } else {
      bgGradStart = const Color(0xFFFDF6D3);
      bgGradEnd = const Color(0xFFFDF6D3);
      cardBg = const Color(0xFFFFFDF5); // paper
      textPrimaryColor = const Color(0xFF141210);
      textSecondaryColor = const Color(0xFF4A453E);
      primaryColor = TripMateTheme.lightPrimary;
      secondaryColor = TripMateTheme.lightSecondary;
      tertiaryColor = TripMateTheme.lightTertiary;
      surfaceColor = const Color(0xFFFFFDF5);
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // overlapping avatar row in header with live edit indicator
  Widget _buildCrewAvatars(bool isDark) {
    final borderCol = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _avatarCircle('A', const Color(0xFFF5822B), borderCol),
        Positioned(
          left: 16,
          child: _avatarCircle('S', const Color(0xFF1FA85C), borderCol),
        ),
        Positioned(
          left: 32,
          child: _avatarCircle('T', const Color(0xFFFB923C), borderCol),
        ),
        Positioned(
          left: 48,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF262019) : Colors.grey[200]!,
              border: Border.all(color: borderCol, width: 2),
            ),
            child: Center(
              child: Text(
                '+1',
                style: AppFonts.body(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -10,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF1FA85C), // Live edit green dot
              shape: BoxShape.circle,
              border: Border.all(color: borderCol, width: 1.5),
            ),
            child: Icon(
              Icons.visibility,
              size: 8,
              color: isDark ? const Color(0xFF1A1712) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarCircle(String initial, Color color, Color borderCol) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderCol, width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Rerouting Warning Alert Banner
  Widget _buildReroutingWarning(bool isDark) {
    final warningColor = isDark
        ? const Color(0xFFFB923C)
        : const Color(0xFFD8422B);
    final warningBg = isDark
        ? const Color(0xFFFF9800).withValues(alpha: 0.1)
        : const Color(0xFFD8422B).withValues(alpha: 0.08);
    final warningBorder = isDark
        ? const Color(0xFFFF9800).withValues(alpha: 0.3)
        : const Color(0xFFD8422B).withValues(alpha: 0.25);

    return GestureDetector(
      onTap: () => _navigateToScreen(
        AIWeatherReplanningScreen(
          isDarkMode: isDark,
          onThemeToggle: widget.onThemeToggle,
        ),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: warningBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: warningBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFFFF9800).withValues(alpha: 0.2)
                    : const Color(0xFFD8422B).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'itinerary.rerouting_warning'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: warningColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'itinerary.rerouting_desc'.tr(),
                    style: AppFonts.heading(
                      fontSize: 11,
                      color: textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 14,
              color: warningColor,
            ),
          ],
        ),
      ),
    );
  }

  // AI "Magic Build" Planner Card with Violet Neon Glow
  Widget _buildMagicBuildCard(bool isDark, ThemeData theme) {
    return GestureDetector(
      onTap: () => _navigateToScreen(
        AIPlanningMateyScreen(
          isDarkMode: isDark,
          onThemeToggle: widget.onThemeToggle,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textPrimaryColor, width: 2.5),
          boxShadow: [
            BoxShadow(color: textPrimaryColor, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Magic Build Header Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF141210),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFFDF5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'itinerary.magic_build'.tr(),
                              style: AppFonts.body(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textPrimaryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: secondaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'itinerary.ai_active'.tr(),
                                style: AppFonts.body(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'itinerary.magic_build_desc'.tr(),
                          style: AppFonts.heading(
                            fontSize: 11,
                            color: textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Double Column Info Grid inside the card
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  // Column 1: View Route
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: secondaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.map,
                              color: secondaryColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'itinerary.view_route'.tr(),
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  'itinerary.spots_mapped'.tr(args: ['3']),
                                  style: AppFonts.heading(
                                    fontSize: 10,
                                    color: textSecondaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Column 2: Weather info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tertiaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud,
                              color: tertiaryColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '18°C, Cloudy',
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  'itinerary.perfect_for_coffee'.tr(),
                                  style: AppFonts.heading(
                                    fontSize: 10,
                                    color: textSecondaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
    );
  }

  // AI Alternative Speakeasy Léon Bar card overlay
  Widget _buildAiAlternativeCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262019) : const Color(0xFFC9B8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textPrimaryColor, width: 2),
        boxShadow: [
          BoxShadow(color: textPrimaryColor, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert AI Alternative Header
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Color(0xFFF5822B),
              ),
              const SizedBox(width: 8),
              Text(
                'itinerary.ai_alternative'.tr(),
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF5822B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'itinerary.alternative_desc'.tr(),
            style: AppFonts.heading(
              fontSize: 12,
              color: textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Spot name & Swap In button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Léon Bar',
                style: AppFonts.body(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textPrimaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isNightMarketSwapped = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5822B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF5822B),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'itinerary.swap_in'.tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF5822B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tags & undicided squad emoji reactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.nightlife, size: 14, color: textSecondaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'itinerary.explore_speakeasy'.tr(),
                    style: AppFonts.heading(
                      fontSize: 11,
                      color: textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withValues(alpha: 0.2),
                          border: Border.all(color: cardBg, width: 1),
                        ),
                        child: const Center(
                          child: Text('🤔', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.2),
                            border: Border.all(color: cardBg, width: 1),
                          ),
                          child: const Center(
                            child: Text('🤔', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom single node renderer for timeline activities
  Widget _buildActivityNode({
    required bool isDark,
    required String time,
    required String title,
    required String location,
    required String description,
    required Color themeColor,
    required IconData icon,
    required bool isFirst,
    required bool isLast,
    String? badge,
    IconData? badgeIcon,
    String? tag,
    IconData? tagIcon,
    String? tag2,
    IconData? tag2Icon,
    List<dynamic>? crewAvatars,
    bool hasAiAlternative = false,
    Widget? alternativeCard,
    bool isAiSwapped = false,
    VoidCallback? onUndoSwap,
    VoidCallback? onTap,
  }) {
    return Stack(
      children: [
        // Timeline line (positioned)
        if (!isLast)
          Positioned(
            left: 15,
            top: 32,
            bottom: 0,
            child: Container(
              width: 2.5,
              color: themeColor.withValues(alpha: 0.2),
            ),
          ),

        // Timeline circle indicator (positioned)
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: themeColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: isDark ? 0.4 : 0.15),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: themeColor, size: 14),
          ),
        ),

        // Clickable Activity Card
        Padding(
          padding: const EdgeInsets.only(left: 48, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isAiSwapped
                          ? const Color(0xFFF5822B).withValues(alpha: 0.4)
                          : isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      width: isAiSwapped ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (isAiSwapped)
                        BoxShadow(
                          color: const Color(
                            0xFFF5822B,
                          ).withValues(alpha: isDark ? 0.25 : 0.1),
                          blurRadius: 0,
                          spreadRadius: 1,
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.15 : 0.03,
                          ),
                          blurRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Time, drag indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: themeColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                time,
                                style: AppFonts.body(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.drag_indicator,
                            size: 16,
                            color: textSecondaryColor.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Activity Title & Swapped indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppFonts.body(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                            ),
                          ),
                          if (isAiSwapped)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF5822B,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 10,
                                    color: Color(0xFFF5822B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI Swapped',
                                    style: AppFonts.body(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF5822B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Description text
                      Text(
                        description,
                        style: AppFonts.heading(
                          fontSize: 12,
                          color: textSecondaryColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Badges & Tag capsules
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (badge != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: themeColor,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (badgeIcon != null) ...[
                                      Icon(
                                        badgeIcon,
                                        size: 11,
                                        color: themeColor,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      badge,
                                      style: AppFonts.heading(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: themeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (tag != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (tagIcon != null) ...[
                                      Icon(
                                        tagIcon,
                                        size: 11,
                                        color: textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      tag,
                                      style: AppFonts.heading(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (tag2 != null) const SizedBox(width: 8),
                            ],
                            if (tag2 != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (tag2Icon != null) ...[
                                      Icon(
                                        tag2Icon,
                                        size: 11,
                                        color: textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      tag2,
                                      style: AppFonts.heading(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Overlapping crew avatars
                      if (crewAvatars != null &&
                          crewAvatars.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Squad Vibe 🔥',
                                  style: AppFonts.body(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: List.generate(crewAvatars.length, (
                                idx,
                              ) {
                                final initials = crewAvatars[idx] as String;
                                final borderCol = isDark
                                    ? const Color(0xFF262019)
                                    : Colors.white;
                                final bgCol = [
                                  const Color(0xFFF5822B),
                                  const Color(0xFF1FA85C),
                                  const Color(0xFFFB923C),
                                  const Color(0xFFF5822B),
                                ][idx % 4];

                                return Container(
                                  transform: Matrix4.translationValues(
                                    idx * -6.0,
                                    0,
                                    0,
                                  ),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: borderCol,
                                      width: 1.5,
                                    ),
                                    color: bgCol,
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: AppFonts.body(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Swapped Alert and Undo Row
              if (isAiSwapped) ...[
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Color(0xFFF5822B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'itinerary.avoided_rain_alert'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 11,
                                  color: textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onUndoSwap,
                        child: Text(
                          'itinerary.undo'.tr(),
                          style: AppFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF5822B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (hasAiAlternative && alternativeCard != null)
                alternativeCard,
            ],
          ),
        ),
      ],
    );
  }

  // Quick action shortcut horizontal panel
  Widget _buildQuickActionItem({
    required String emoji,
    required String label,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () => _navigateToScreen(screen),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;
    _initThemeColors(isDark);

    // List of dynamic days matching specifications
    final List<Map<String, dynamic>> itineraryDays = [
      {'day': 'Day 1', 'title': 'Saturday, Oct 12', 'date': 'Oct 12, 2026'},
      {'day': 'Day 2', 'title': 'Sunday, Oct 13', 'date': 'Oct 13, 2026'},
      {'day': 'Day 3', 'title': 'Monday, Oct 14', 'date': 'Oct 14, 2026'},
    ];

    return Scaffold(
      backgroundColor: bgGradStart,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER BAR: Screen Title, Collaborators overlapping avatars, theme toggler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button + Trip Title & info
                  Expanded(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: textPrimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đà Lạt Chill',
                                style: AppFonts.body(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimaryColor,
                                ),
                              ),
                              Text(
                                'Oct 12 - 15 • 3 Collaborators',
                                style: AppFonts.heading(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Overlapping crew avatars + theme toggler
                  Row(
                    children: [
                      _buildCrewAvatars(isDark),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: widget.onThemeToggle,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            size: 18,
                            color: textPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Toàn bộ nội dung dưới header cuộn CHUNG một mạch — fix bug timeline
            // trước đây bị các section fixed che, chỉ còn khung nhỏ để lướt.
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rerouting Warning Alert Banner
                    _buildReroutingWarning(isDark),

                    // Magic Build AI planner card with Neon Purple/Coral glow
                    _buildMagicBuildCard(isDark, theme),

                    // FLOATING SHORCUTS PANEL (Squad actions)
                    Container(
                      height: 52,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildQuickActionItem(
                            emoji: '🗳️',
                            label: 'Squad Voting',
                            color: secondaryColor,
                            screen: SquadVotingDemocracyScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                          _buildQuickActionItem(
                            emoji: '🚀',
                            label: 'Optimize Route',
                            color: primaryColor,
                            screen: AIRouteOptimizationScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                          _buildQuickActionItem(
                            emoji: '🛵',
                            label: 'Transport Split',
                            color: tertiaryColor,
                            screen: TransportPlanningScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                          _buildQuickActionItem(
                            emoji: '📦',
                            label: 'Gear Packing',
                            color: Colors.greenAccent,
                            screen: SquadChecklistPackingScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                          _buildQuickActionItem(
                            emoji: '🎫',
                            label: 'Boarding Passes',
                            color: Colors.purpleAccent,
                            screen: FlightHotelInfoScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Horizontal Day Navigation Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: SizedBox(
                        height: 54,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: itineraryDays.length,
                          itemBuilder: (context, index) {
                            final dayData = itineraryDays[index];
                            final isSelected = _activeDayIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activeDayIndex = index;
                                    _animController.reset();
                                    _animController.forward();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: primaryColor.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 0,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          dayData['day'] as String,
                                          style: AppFonts.body(
                                            color: isSelected
                                                ? Colors.white
                                                : textPrimaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          dayData['title'] as String,
                                          style: AppFonts.heading(
                                            color: isSelected
                                                ? Colors.white.withValues(
                                                    alpha: 0.8,
                                                  )
                                                : textSecondaryColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Header for Day details (Date and Title)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itineraryDays[_activeDayIndex]['title'] as String,
                            style: AppFonts.body(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                          ),
                          Text(
                            itineraryDays[_activeDayIndex]['date'] as String,
                            style: AppFonts.heading(
                              fontSize: 12,
                              color: textSecondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Timeline Items — Column cuộn cùng cả trang (không còn Expanded bó nhỏ)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildTimelineForActiveDay(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add Place capsule — phần tử thường ở cuối danh sách
                    Center(
                      child: GestureDetector(
                        onTap: () => showGlobalSnack(
                          'Tính năng đang được hoàn thiện 🚧',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: textPrimaryColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: textPrimaryColor,
                                blurRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 18,
                                color: textPrimaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Place',
                                style: AppFonts.body(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ], // đóng Column trong SingleChildScrollView
                ),
              ),
            ), // đóng Expanded bọc SingleChildScrollView
          ],
        ),
      ),
    );
  }

  // Builds the timeline activity items for the active day
  List<Widget> _buildTimelineForActiveDay(bool isDark) {
    if (_activeDayIndex == 0) {
      // Day 1 - Saturday, Oct 12 items as specified in the instruction
      return [
        _buildActivityNode(
          isDark: isDark,
          time: '08:00 AM - 09:30 AM',
          title: 'itinerary.bamboo_breakfast'.tr(),
          location: 'Bún bò Huế Minh Trí',
          description:
              'itinerary.minh_tri_desc'.tr(),
          themeColor: primaryColor,
          icon: Icons.restaurant,
          isFirst: true,
          isLast: false,
          badge: 'itinerary.badge_energy_balanced'.tr(),
          badgeIcon: Icons.bolt,
          tag: 'itinerary.tag_food'.tr(),
          tagIcon: Icons.restaurant,
          crewAvatars: ['A', 'S'],
          onTap: () => _navigateToScreen(
            ActivityDetailScreen(
              isDarkMode: isDark,
              onThemeToggle: widget.onThemeToggle,
              title: 'itinerary.bamboo_breakfast'.tr(),
              time: '08:00 AM - 09:30 AM',
              location: 'Bún bò Huế Minh Trí',
              description:
                  'itinerary.minh_tri_desc'.tr(),
              themeColor: primaryColor,
            ),
          ),
        ),
        _buildActivityNode(
          isDark: isDark,
          time: '10:00 AM - 12:00 PM',
          title: 'itinerary.hill_station_title'.tr(),
          location: 'itinerary.hill_station_loc'.tr(),
          description:
              'itinerary.hill_station_desc'.tr(),
          themeColor: secondaryColor,
          icon: Icons.local_cafe,
          isFirst: false,
          isLast: false,
          badge: 'itinerary.badge_crowd_low'.tr(),
          badgeIcon: Icons.groups,
          tag: 'itinerary.tag_cafe'.tr(),
          tagIcon: Icons.local_cafe,
          tag2: 'itinerary.tag_aesthetic'.tr(),
          tag2Icon: Icons.photo_camera,
          crewAvatars: ['A', 'S', 'T', '+1'],
          onTap: () => _navigateToScreen(
            ActivityDetailScreen(
              isDarkMode: isDark,
              onThemeToggle: widget.onThemeToggle,
              title: 'itinerary.hill_station_title'.tr(),
              time: '10:00 AM - 12:00 PM',
              location: 'itinerary.hill_station_loc'.tr(),
              description:
                  'itinerary.hill_station_desc'.tr(),
              themeColor: secondaryColor,
            ),
          ),
        ),

        // Swappable activity 3 based on state
        if (!_isNightMarketSwapped)
          _buildActivityNode(
            isDark: isDark,
            time: '07:00 PM - Late',
            title: 'itinerary.night_market_title'.tr(),
            location: 'itinerary.night_market_loc'.tr(),
            description:
                'itinerary.night_market_desc'.tr(),
            themeColor: primaryColor,
            icon: Icons.shopping_bag,
            isFirst: false,
            isLast: true,
            badge: 'itinerary.badge_high_chaos'.tr(),
            badgeIcon: Icons.local_activity,
            tag: 'itinerary.tag_shopping'.tr(),
            tagIcon: Icons.shopping_bag,
            crewAvatars: ['A', 'S'],
            hasAiAlternative: true,
            alternativeCard: _buildAiAlternativeCard(isDark),
            onTap: () => _navigateToScreen(
              ActivityDetailScreen(
                isDarkMode: isDark,
                onThemeToggle: widget.onThemeToggle,
                title: 'itinerary.night_market_title'.tr(),
                time: '07:00 PM - Late',
                location: 'itinerary.night_market_loc'.tr(),
                description:
                    'itinerary.night_market_desc'.tr(),
                themeColor: primaryColor,
              ),
            ),
          )
        else
          _buildActivityNode(
            isDark: isDark,
            time: '07:30 PM - 10:30 PM',
            title: 'itinerary.leon_bar_title'.tr(),
            location: 'itinerary.leon_bar_loc'.tr(),
            description:
                'itinerary.leon_bar_desc'.tr(),
            themeColor: primaryColor,
            icon: Icons.nightlife,
            isFirst: false,
            isLast: true,
            isAiSwapped: true,
            onUndoSwap: () {
              setState(() {
                _isNightMarketSwapped = false;
              });
            },
            badge: 'itinerary.badge_rain_safe'.tr(),
            badgeIcon: Icons.beach_access,
            tag: 'itinerary.tag_speakeasy'.tr(),
            tagIcon: Icons.wine_bar,
            crewAvatars: ['A', 'S', 'T'],
            onTap: () => _navigateToScreen(
              ActivityDetailScreen(
                isDarkMode: isDark,
                onThemeToggle: widget.onThemeToggle,
                title: 'itinerary.leon_bar_title'.tr(),
                time: '07:30 PM - 10:30 PM',
                location: 'itinerary.leon_bar_loc'.tr(),
                description:
                    'itinerary.leon_bar_desc'.tr(),
                themeColor: primaryColor,
              ),
            ),
          ),
      ];
    } else if (_activeDayIndex == 1) {
      // Day 2 Items
      return [
        _buildActivityNode(
          isDark: isDark,
          time: '08:00 AM - 01:00 PM',
          title: 'itinerary.langbiang_title'.tr(),
          location: 'itinerary.langbiang_loc'.tr(),
          description:
              'itinerary.langbiang_desc'.tr(),
          themeColor: const Color(0xFF1FA85C),
          icon: Icons.terrain,
          isFirst: true,
          isLast: false,
          badge: 'itinerary.badge_scenic_view'.tr(),
          badgeIcon: Icons.landscape,
          tag: 'itinerary.tag_adventure'.tr(),
          tagIcon: Icons.directions_run,
          crewAvatars: ['A', 'S', 'T'],
          onTap: () => _navigateToScreen(
            ActivityDetailScreen(
              isDarkMode: isDark,
              onThemeToggle: widget.onThemeToggle,
              title: 'itinerary.langbiang_title'.tr(),
              time: '08:00 AM - 01:00 PM',
              location: 'itinerary.langbiang_loc'.tr(),
              description:
                  'itinerary.langbiang_desc'.tr(),
              themeColor: const Color(0xFF1FA85C),
            ),
          ),
        ),
        _buildActivityNode(
          isDark: isDark,
          time: '02:30 PM - 05:00 PM',
          title: 'itinerary.clay_tunnel_title'.tr(),
          location: 'itinerary.clay_tunnel_loc'.tr(),
          description:
              'itinerary.clay_tunnel_desc'.tr(),
          themeColor: tertiaryColor,
          icon: Icons.photo_album,
          isFirst: false,
          isLast: true,
          badge: 'itinerary.badge_crowd_medium'.tr(),
          badgeIcon: Icons.groups,
          tag: 'itinerary.tag_sightseeing'.tr(),
          tagIcon: Icons.camera_alt,
          crewAvatars: ['A', 'S'],
          onTap: () => _navigateToScreen(
            ActivityDetailScreen(
              isDarkMode: isDark,
              onThemeToggle: widget.onThemeToggle,
              title: 'itinerary.clay_tunnel_title'.tr(),
              time: '02:30 PM - 05:00 PM',
              location: 'itinerary.clay_tunnel_loc'.tr(),
              description:
                  'itinerary.clay_tunnel_desc'.tr(),
              themeColor: tertiaryColor,
            ),
          ),
        ),
      ];
    } else {
      // Day 3 Items
      return [
        _buildActivityNode(
          isDark: isDark,
          time: '09:00 AM - 12:00 PM',
          title: 'itinerary.datanla_title'.tr(),
          location: 'itinerary.datanla_loc'.tr(),
          description:
              'itinerary.datanla_desc'.tr(),
          themeColor: primaryColor,
          icon: Icons.rocket_launch,
          isFirst: true,
          isLast: false,
          badge: 'itinerary.badge_thrilling'.tr(),
          badgeIcon: Icons.speed,
          tag: 'itinerary.tag_activity'.tr(),
          tagIcon: Icons.park,
          crewAvatars: ['A', 'S', 'T', '+1'],
          onTap: () => _navigateToScreen(
            ActivityDetailScreen(
              isDarkMode: isDark,
              onThemeToggle: widget.onThemeToggle,
              title: 'itinerary.datanla_title'.tr(),
              time: '09:00 AM - 12:00 PM',
              location: 'itinerary.datanla_loc'.tr(),
              description:
                  'itinerary.datanla_desc'.tr(),
              themeColor: primaryColor,
            ),
          ),
        ),
        _buildActivityNode(
          isDark: isDark,
          time: '04:00 PM - 07:00 PM',
          title: 'itinerary.tuyen_lam_sunset_title'.tr(),
          location: 'itinerary.tuyen_lam_sunset_loc'.tr(),
          description:
              'itinerary.tuyen_lam_sunset_desc'.tr(),
          themeColor: primaryColor,
          icon: Icons.filter_hdr,
          isFirst: false,
          isLast: true,
          badge: 'itinerary.badge_romantic_vibes'.tr(),
          badgeIcon: Icons.favorite,
          tag: 'itinerary.tag_relaxing'.tr(),
          tagIcon: Icons.spa,
          crewAvatars: ['A', 'S'],
          onTap: () => _navigateToScreen(
            ActivityDetailScreen(
              isDarkMode: isDark,
              onThemeToggle: widget.onThemeToggle,
              title: 'itinerary.tuyen_lam_sunset_title'.tr(),
              time: '04:00 PM - 07:00 PM',
              location: 'itinerary.tuyen_lam_sunset_loc'.tr(),
              description:
                  'itinerary.tuyen_lam_sunset_desc'.tr(),
              themeColor: primaryColor,
            ),
          ),
        ),
      ];
    }
  }
}
