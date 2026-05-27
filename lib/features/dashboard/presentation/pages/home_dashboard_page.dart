import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme.dart';

import '../widgets/social_chaos_marquee.dart';
import '../widgets/trip_summary_card.dart';
import '../widgets/friend_presence_panel.dart';
import '../widgets/quick_actions_panel.dart';
import '../widgets/squad_mood_widget.dart';
import '../widgets/emergency_sos_widget.dart';
import '../widgets/daily_recap_widget.dart';
import '../../../discovery/presentation/pages/explore_discoveries_screen.dart';

import '../../../moments/presentation/pages/memory_wall_screen.dart';

class HomeDashboardPage extends StatelessWidget {
  final VoidCallback onNavigateToLiveMode;
  final VoidCallback onNavigateToActivityHub;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeDashboardPage({
    super.key,
    required this.onNavigateToLiveMode,
    required this.onNavigateToActivityHub,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant customized header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "dashboard.title".tr(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      "dashboard.social_ticker".tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Live mode shortcut and notification badge
                Row(
                  children: [
                    GestureDetector(
                      onTap: onNavigateToLiveMode,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.secondary, colorScheme.secondary.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.secondary.withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.bolt, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              "LIVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                				fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onNavigateToActivityHub,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? TripMateTheme.darkSurface : const Color(0xFFE2E8F0),
                            ),
                            child: Icon(
                              Icons.notifications_none_outlined,
                              color: colorScheme.onSurface,
                              size: 22,
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ticker notification feed
          const SocialChaosMarquee(),
          const SizedBox(height: 16),

          // Search Trigger Bar pointing to ExploreDiscoveriesScreen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExploreDiscoveriesScreen(
                      isDarkMode: isDarkMode,
                      onThemeToggle: onThemeToggle,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? TripMateTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'general.search_placeholder'.tr(),
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.tune,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Main contents column
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dalat Chill Trip summary card
                const TripSummaryCard(),
                const SizedBox(height: 24),

                // Squad Online Panel
                FriendPresencePanel(
                  isDarkMode: isDarkMode,
                  onThemeToggle: onThemeToggle,
                ),
                const SizedBox(height: 24),

                // Quick Actions Modular Panel
                QuickActionsPanel(
                  isDarkMode: isDarkMode,
                  onThemeToggle: onThemeToggle,
                ),
                const SizedBox(height: 24),

                // The Roast & Mood Widgets combined
                const SquadMoodWidget(),
                const SizedBox(height: 24),

                // Emergency SOS card
                const EmergencySosWidget(),
                const SizedBox(height: 24),

                // Daily Recap Widget
                const DailyRecapWidget(),
                const SizedBox(height: 24),

                // Scrapbook polaroid elements
                Text(
                  "dashboard.scrapbook".tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                // Polaroid Grid Row
                Row(
                  children: [
                    Expanded(
                      child: Transform.rotate(
                        angle: -0.06,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemoryWallScreen(
                                  isDarkMode: isDarkMode,
                                  onThemeToggle: onThemeToggle,
                                ),
                              ),
                            );
                          },
                          child: _buildPolaroidCard(
                            context: context,
                            title: "Chợ Đêm Vibe 🍢",
                            author: "- Phú Khang -",
                            location: "📍 Da Lat Night Market",
                            gradient: const [Color(0xFFE29587), Color(0xFFD66D75)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Transform.rotate(
                        angle: 0.05,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemoryWallScreen(
                                  isDarkMode: isDarkMode,
                                  onThemeToggle: onThemeToggle,
                                ),
                              ),
                            );
                          },
                          child: _buildPolaroidCard(
                            context: context,
                            title: "Chạy booooo! 🛵💨",
                            author: "- Thảo Ly -",
                            location: "📍 Đồi Đa Phú",
                            gradient: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidCard({
    required BuildContext context,
    required String title,
    required String author,
    required String location,
    required List<Color> gradient,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? TripMateTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo image mockup
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.white54,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.caveat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            author,
            style: GoogleFonts.caveat(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 10, color: Colors.redAccent),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 8,
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
