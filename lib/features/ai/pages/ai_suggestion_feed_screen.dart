import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../core/app_messenger.dart';
class AiSuggestionFeedScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AiSuggestionFeedScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<AiSuggestionFeedScreen> createState() => _AiSuggestionFeedScreenState();
}

class _AiSuggestionFeedScreenState extends State<AiSuggestionFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primary = isDark ? const Color(0xFFC9B8FF) : const Color(0xFF6D3BD7);
    final secondary = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFF00BD85);
    final tertiary = isDark ? const Color(0xFFFFB783) : const Color(0xFFF5822B);

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
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: textPrimary,
                            size: 16,
                          ),
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
                              Icons.notifications,
                              color: primary,
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
                        const SizedBox(height: 16),
                        // Squad vibe pill
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: tertiary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: tertiary, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_cafe_rounded,
                                    color: tertiary,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  RichText(
                                    text: TextSpan(
                                      style: AppFonts.heading(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Squad Vibe: '),
                                        TextSpan(
                                          text: 'Caffeine-Deprived',
                                          style: TextStyle(
                                            color: tertiary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Squad Suggestion Feed',
                          style: AppFonts.heading(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'AI-powered updates keeping your squad synced in real-time.',
                          style: AppFonts.body(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Card 1: Rain switcher
                        _buildFeedCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          tagText: 'Matey AI Insight',
                          tagColor: primary,
                          headline:
                              '☔ rain starts in 30 mins— switching to cafe mode.',
                          description:
                              'the AI knows your chaos too well. Found a highly-rated spot 5 mins away.',
                          actions: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: primary,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => showGlobalSnack(
                                      'Tính năng đang được hoàn thiện 🚧',
                                    ),
                                    icon: const Icon(
                                      Icons.route,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Route Me',
                                      style: AppFonts.heading(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: glassBorder),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => showGlobalSnack(
                                    'Tính năng đang được hoàn thiện 🚧',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card 2: BBQ Place
                        _buildFeedCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          tagText: 'Matey AI Insight',
                          tagColor: secondary,
                          headline:
                              '🍜 your squad would destroy this BBQ place.',
                          description:
                              'Matches 4/4 squad dietary preferences. High energy vibe.',
                          actions: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: secondary,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => showGlobalSnack(
                                      'Tính năng đang được hoàn thiện 🚧',
                                    ),
                                    icon: const Icon(
                                      Icons.done_all_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Vibe Check',
                                      style: AppFonts.heading(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: glassBorder),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => showGlobalSnack(
                                    'Tính năng đang được hoàn thiện 🚧',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          extraInfo: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: secondary,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+1 ready to eat',
                                style: AppFonts.body(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card 3: Golden hour countdown
                        _buildFeedCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          tagText: 'Time Sensitive',
                          tagColor: tertiary,
                          headline: '📸 golden hour starts in 18 mins',
                          description:
                              'Head to the rooftop for peak lighting. It\'s giving main character energy.',
                          actions: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: tertiary,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => showGlobalSnack(
                                      'Tính năng đang được hoàn thiện 🚧',
                                    ),
                                    icon: const Icon(
                                      Icons.directions_walk_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Let\'s Go',
                                      style: AppFonts.heading(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
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
              ],
            ),
          ),

          // Floating Bottom Navigation
          _buildBottomNav(cardBg, primary, secondary, textSecondary, isDark),
        ],
      ),
    );
  }

  Widget _buildFeedCard({
    required bool isDark,
    required Color cardBg,
    required Color glassBorder,
    required Color textPrimary,
    required Color textSecondary,
    required String tagText,
    required Color tagColor,
    required String headline,
    required String description,
    required Widget actions,
    Widget? extraInfo,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
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
                  Icon(Icons.smart_toy_rounded, color: tagColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    tagText,
                    style: AppFonts.heading(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: tagColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              ?extraInfo,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            style: AppFonts.heading(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppFonts.body(
              fontSize: 13,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          actions,
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
                      Icons.explore_rounded,
                      color: secondary,
                      size: 24,
                    ),
                  ),
                ),
                _buildNavItem(
                  Icons.group_rounded,
                  'group',
                  false,
                  textMuted,
                  primary,
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
