import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../core/widgets/gen_z_widgets.dart';
import '../discovery/presentation/pages/ai_vibe_match_screen.dart';
import '../gamification/data/games_repository.dart';
import '../moments/presentation/pages/trip_recap_reel_screen.dart';
import '../planning/presentation/pages/ai_planning_matey_screen.dart';
import 'pages/ai_budget_assistant_screen.dart';
import 'pages/ai_caption_generator_screen.dart';
import 'pages/ai_chat_history_screen.dart';
import 'pages/ai_generation_queue_screen.dart';
import 'pages/ai_mood_detection_screen.dart';
import 'pages/ai_personality_analysis_screen.dart';
import 'pages/ai_recommendation_timeline_screen.dart';
import 'pages/ai_saved_prompts_screen.dart';
import 'pages/matey_ai_emotional_chaos_screen.dart';

class AiHubScreen extends StatelessWidget {
  const AiHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                color: ink,
              ),
              onPressed: () => Navigator.pop(context),
              tooltip: 'common.back'.tr(),
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

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: HardShadowBox(
                    color: surfaceColor,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PillTag(
                              text: 'ai.companion_mode'.tr(),
                              color: GenZTokens.lilac,
                            ),
                            const Spacer(),
                            PillTag(
                              text: 'ai.online'.tr(),
                              color: GenZTokens.green,
                            ),
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
                  title: 'ai.matey_title'.tr(),
                  subtitle: 'ai.chat_sub'.tr(),
                  icon: PhosphorIcons.chatCircleDots(PhosphorIconsStyle.bold),
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
                  title: 'ai.vibe_matcher_title'.tr(),
                  subtitle: 'ai.vibe_match_sub'.tr(),
                  icon: PhosphorIcons.heart(PhosphorIconsStyle.bold),
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
                  title: 'ai.planner_title'.tr(),
                  subtitle: 'ai.planner_sub'.tr(),
                  icon: PhosphorIcons.sparkle(PhosphorIconsStyle.bold),
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
                _buildHubCard(
                  context: context,
                  title: 'ai.generate_captions'.tr(),
                  subtitle: 'ai.caption_tagline'.tr(),
                  icon: PhosphorIcons.textT(PhosphorIconsStyle.bold),
                  color: GenZTokens.lilac,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AICaptionGeneratorScreen(
                        isDarkMode: isDark,
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
                  title: 'ai.budget_title'.tr(),
                  subtitle: 'ai.budget_sub'.tr(),
                  icon: PhosphorIcons.currencyCircleDollar(
                    PhosphorIconsStyle.bold,
                  ),
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
                  title: 'ai.personality_title'.tr(),
                  subtitle: 'ai.personality_sub'.tr(),
                  icon: PhosphorIcons.brain(PhosphorIconsStyle.bold),
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
                  title: 'ai.mood_title'.tr(),
                  subtitle: 'ai.drama_sub'.tr(),
                  icon: PhosphorIcons.smileyMeh(PhosphorIconsStyle.bold),
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
                  title: 'ai.timeline_title'.tr(),
                  subtitle: 'ai.hub_route_sub'.tr(),
                  icon: PhosphorIcons.path(PhosphorIconsStyle.bold),
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
                _buildHubCard(
                  context: context,
                  title: 'ai.wrapped_title'.tr(),
                  subtitle: 'ai.hub_recap_sub'.tr(),
                  icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
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
                  title: 'ai.queue_title'.tr(),
                  subtitle: 'ai.workspace_sub'.tr(),
                  icon: PhosphorIcons.queue(PhosphorIconsStyle.bold),
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
                  title: 'ai.prompts_title'.tr(),
                  subtitle: 'ai.hub_prompts_sub'.tr(),
                  icon: PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
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
                  title: 'ai.history_title'.tr(),
                  subtitle: 'ai.hub_history_sub'.tr(),
                  icon: PhosphorIcons.clockCounterClockwise(
                    PhosphorIconsStyle.bold,
                  ),
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

            Icon(
              PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
