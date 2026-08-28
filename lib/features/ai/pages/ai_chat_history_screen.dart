import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../core/app_messenger.dart';
class AiChatHistoryScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AiChatHistoryScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<AiChatHistoryScreen> createState() => _AiChatHistoryScreenState();
}

class _AiChatHistoryScreenState extends State<AiChatHistoryScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primary = isDark ? const Color(0xFFC9B8FF) : const Color(0xFF6D3BD7);
    final secondary = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFF00BD85);
    final tertiary = isDark ? const Color(0xFFFFB783) : const Color(0xFFF5822B);
    final error = isDark ? const Color(0xFFFFB4AB) : const Color(0xFFD32F2F);

    final bg = isDark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark
        ? const Color(0xFFDAE2FD)
        : const Color(0xFF262019);
    final textSecondary = isDark
        ? const Color(0xFFCBC3D7)
        : const Color(0xFF4A453E);
    final glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background soft aurora glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cardBg,
                            border: Border.all(color: glassBorder),
                          ),
                          child: Icon(Icons.menu, color: textPrimary, size: 20),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primary, primary],
                        ).createShader(bounds),
                        child: Text(
                          'trip.mate',
                          style: AppFonts.heading(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.onThemeToggle != null)
                            IconButton(
                              icon: Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: textPrimary.withValues(alpha: 0.7),
                              ),
                              onPressed: widget.onThemeToggle,
                            ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cardBg,
                              border: Border.all(color: glassBorder),
                            ),
                            child: Icon(
                              Icons.search,
                              color: textPrimary,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'your squad\'s chaos archive.',
                          style: AppFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The Chaos Archive',
                          style: AppFonts.heading(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -1.0,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'AI remembers the emotional damage.',
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Search Bar block
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 52,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: AppFonts.body(
                                    fontSize: 14,
                                    color: textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search emotional damage...',
                                    hintStyle: AppFonts.body(
                                      color: textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.filter_list_rounded,
                                color: primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Bento Category scroll tags
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildCategoryTag(
                                'All',
                                Icons.all_inclusive_rounded,
                                primary,
                              ),
                              _buildCategoryTag(
                                'Itineraries',
                                Icons.folder_special,
                                primary,
                              ),
                              _buildCategoryTag(
                                'Recommendations',
                                Icons.star,
                                tertiary,
                              ),
                              _buildCategoryTag(
                                'Squad Advice',
                                Icons.forum,
                                secondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Pinned Gold
                        Row(
                          children: [
                            Icon(
                              Icons.push_pin_rounded,
                              color: tertiary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pinned Gold',
                              style: AppFonts.heading(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPinnedCard(
                          icon: Icons.umbrella_rounded,
                          iconColor: error,
                          badgeText: 'Critical',
                          title: 'Rain backup plan for Đà Lạt',
                          desc:
                              '"If it floods again, go to Maze Bar, don\'t try to scooter to the waterfall."',
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 12),
                        _buildPinnedCard(
                          icon: Icons.restaurant_rounded,
                          iconColor: secondary,
                          badgeText: 'Saved',
                          title: 'Best late-night food spots',
                          desc:
                              '"That street food lady near the hostel stays open until 3AM. Legendary."',
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 28),

                        // Recent Processing (history)
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Recent Processing',
                              style: AppFonts.heading(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildHistoryCard(
                          title: 'The Spicy Noodle Incident',
                          timeAgo: '2d ago',
                          desc:
                              'AI Summary: Squad heavily debated spice levels. Mark cried. 10/10 would not recommend level 5 again.',
                          hashtag: '#FoodDamage',
                          location: 'Bangkok',
                          icon: Icons.local_fire_department_rounded,
                          iconColor: tertiary,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          primaryColor: primary,
                        ),
                        const SizedBox(height: 12),
                        _buildHistoryCard(
                          title: 'Lost in Shibuya',
                          timeAgo: '1w ago',
                          desc:
                              'AI Summary: 45 minutes spent trying to find the specific matcha place. Resulted in accidental karaoke.',
                          hashtag: '#RouteChaos',
                          location: 'Tokyo',
                          icon: Icons.navigation_rounded,
                          iconColor: secondary,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          primaryColor: primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Bottom Navigation
          _buildBottomNav(cardBg, primary, secondary, textSecondary, isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(String label, IconData icon, Color color) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.heading(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedCard({
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required String title,
    required String desc,
    required Color cardBg,
    required Color glassBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText.toUpperCase(),
                        style: AppFonts.heading(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppFonts.body(
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String timeAgo,
    required String desc,
    required String hashtag,
    required String location,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color glassBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: AppFonts.body(
                  fontSize: 11,
                  color: textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: AppFonts.body(
              fontSize: 12,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hashtag,
                  style: AppFonts.body(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  location,
                  style: AppFonts.body(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
    Color surface,
    Color primary,
    Color secondary,
    Color textMuted,
    bool isDark,
  ) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.explore_rounded,
                  'explore',
                  false,
                  textMuted,
                  primary,
                ),
                GestureDetector(
                  onTap: () =>
                      showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondary.withValues(alpha: 0.15),
                      border: Border.all(color: secondary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.group_rounded,
                      color: secondary,
                      size: 24,
                    ),
                  ),
                ),
                _buildNavItem(
                  Icons.map_rounded,
                  'map',
                  false,
                  textMuted,
                  primary,
                ),
                _buildNavItem(
                  Icons.person_rounded,
                  'person',
                  false,
                  textMuted,
                  primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color textMuted,
    Color primary,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? primary : textMuted.withValues(alpha: 0.6),
          size: 24,
        ),
      ],
    );
  }
}
