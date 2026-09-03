import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/widgets/gen_z_widgets.dart';

// Pages
import 'pages/matey_ai_emotional_chaos_screen.dart';
import 'pages/ai_budget_assistant_screen.dart';
import '../gamification/data/games_repository.dart';
import '../moments/presentation/pages/trip_recap_reel_screen.dart';
import 'pages/ai_chat_history_screen.dart';
import 'pages/ai_personality_analysis_screen.dart';
import 'pages/ai_mood_detection_screen.dart';
import 'pages/ai_recommendation_timeline_screen.dart';
import 'pages/ai_saved_prompts_screen.dart';
import 'pages/ai_generation_queue_screen.dart';

// External cross-links
import '../discovery/presentation/pages/ai_vibe_match_screen.dart';
import '../planning/presentation/pages/ai_planning_matey_screen.dart';

class AiHubScreen extends StatelessWidget {
  const AiHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Token Gen Z Neo-Brutalist
    const primaryColor = GenZTokens.purple;
    const secondaryColor = GenZTokens.yellow;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Glowing AI Header
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ink),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'ai.hub_title'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: ink,
                ),
              ),
              background: Container(
                color: backgroundColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Khối sticker màu đặc trang trí
                    Positioned(
                      right: -20,
                      top: 20,
                      child: Transform.rotate(
                        angle: 0.15,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: secondaryColor,
                            border: Border.all(
                              color: ink,
                              width: GenZTokens.borderWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: 10,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GenZTokens.lilac,
                          border: Border.all(
                            color: ink,
                            width: GenZTokens.borderWidth,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Icon robot — khối tím viền ink hard shadow
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusCard,
                            ),
                            color: primaryColor,
                            border: Border.all(
                              color: ink,
                              width: GenZTokens.borderWidth,
                            ),
                            boxShadow: GenZTokens.hardShadow(ink),
                          ),
                          child: Icon(
                            PhosphorIcons.robot(PhosphorIconsStyle.fill),
                            size: 40,
                            color: GenZTokens.paper,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main body content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Matey AI companion intro card
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: HardShadowBox(
                    color: surfaceColor,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            PillTag(
                              text: 'Companion Mode',
                              color: GenZTokens.lilac,
                            ),
                            Spacer(),
                            PillTag(text: 'Online', color: GenZTokens.green),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ai.hub_welcome'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.5,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ai.hub_intro'.tr(),
                          style: AppFonts.body(
                            color: isDark
                                ? GenZTokens.inkSoftDark
                                : GenZTokens.inkSoft,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SECTION 1: TRẢI NGHIỆM TƯƠNG TÁC
                _buildSectionHeader('ai.section_companion'.tr(), isDark),
                const SizedBox(height: 12),
                _buildHubCard(
                  context: context,
                  title: 'Matey AI — Emotional Chaos',
                  subtitle:
                      'ai.chat_sub'.tr(),
                  icon: Icons.chat_bubble_outline,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MateyAiEmotionalChaosScreen(),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Vibe Matcher — Squad Energy',
                  subtitle:
                      'ai.vibe_match_sub'.tr(),
                  icon: Icons.favorite_border,
                  color: GenZTokens.magenta,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIVibeMatchScreen(
                        isDarkMode: isDark,
                        onThemeToggle: () {},
                      ),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Itinerary Planner — Matey Plans',
                  subtitle:
                      'ai.planner_sub'.tr(),
                  icon: Icons.auto_awesome_motion,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIPlanningMateyScreen(
                        isDarkMode: isDark,
                        onThemeToggle: () {},
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 2: HỖ TRỢ CHUYẾN ĐI
                _buildSectionHeader('ai.section_analysis'.tr(), isDark),
                const SizedBox(height: 12),
                _buildHubCard(
                  context: context,
                  title: 'AI Budget Assistant',
                  subtitle:
                      'ai.budget_sub'.tr(),
                  icon: Icons.monetization_on_outlined,
                  color: GenZTokens.green,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiBudgetAssistantScreen(),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Personality Analysis',
                  subtitle:
                      'ai.personality_sub'.tr(),
                  icon: Icons.psychology_outlined,
                  color: GenZTokens.orange,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiPersonalityAnalysisScreen(),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Mood Detection',
                  subtitle:
                      'ai.drama_sub'.tr(),
                  icon: Icons.mood_bad_outlined,
                  color: GenZTokens.red,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiMoodDetectionScreen(),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Recommendation Timeline',
                  subtitle: 'ai.hub_route_sub'.tr(),
                  icon: Icons.timeline_outlined,
                  color: GenZTokens.blue,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AiRecommendationTimelineScreen(),
                    ),
                  ),
                ),
                // Trước đây tile này mở AiTripSummaryScreen — một màn 925 dòng
                // in cứng "842 khoảnh khắc", nhân vật "Alex"/"Thảo Ly" và ảnh
                // Unsplash, không gọi API nào. Trip Wrapped làm đúng việc đó
                // trên số liệu thật nên trỏ thẳng sang đấy.
                _buildHubCard(
                  context: context,
                  title: 'Trip Wrapped',
                  subtitle: 'ai.hub_recap_sub'.tr(),
                  icon: Icons.auto_awesome,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () {
                    final tripId = ProviderScope.containerOf(
                      context,
                      listen: false,
                    ).read(activeTripIdProvider);
                    if (tripId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('games.need_trip_body'.tr())),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripRecapReelScreen(
                          isDarkMode: isDark,
                          tripId: tripId,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // SECTION 3: QUẢN LÝ TÁC VỤ
                _buildSectionHeader('ai.section_workspace'.tr(), isDark),
                const SizedBox(height: 12),
                _buildHubCard(
                  context: context,
                  title: 'AI Generation Queue',
                  subtitle:
                      'ai.workspace_sub'.tr(),
                  icon: Icons.queue_play_next,
                  color: GenZTokens.magenta,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiGenerationQueueScreen(),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Saved Prompts',
                  subtitle: 'ai.hub_prompts_sub'.tr(),
                  icon: Icons.bookmark_outline,
                  color: GenZTokens.green,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiSavedPromptsScreen(),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Chat History',
                  subtitle: 'ai.hub_history_sub'.tr(),
                  icon: Icons.history_edu,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiChatHistoryScreen(isDarkMode: isDark),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: AppFonts.heading(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.5,
          color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
        ),
      ),
    );
  }

  Widget _buildHubCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: PressableCard(
        onTap: onTap,
        color: surfaceColor,
        radius: 18,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ô icon vuông màu accent đặc, viền ink
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                color: color,
                border: Border.all(
                  color: GenZTokens.ink,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Icon(icon, color: GenZTokens.ink, size: 22),
            ),
            const SizedBox(width: 16),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? GenZTokens.inkSoftDark
                          : GenZTokens.inkSoft,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow forward
            Icon(
              Icons.arrow_forward,
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
