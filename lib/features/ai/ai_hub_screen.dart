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
  final bool? isDarkMode;

  const AiHubScreen({super.key, this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = isDarkMode ?? (theme.brightness == Brightness.dark);

    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = theme.colorScheme.primary;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: bg,
            scrolledUnderElevation: 0,
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
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  letterSpacing: -0.2,
                  color: ink,
                ),
              ),
              background: Container(
                color: bg,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            GenZTokens.radiusCard,
                          ),
                          color: accentSoft,
                          border: Border.all(
                            color: line,
                            width: GenZTokens.borderWidthThin,
                          ),
                        ),
                        child: Icon(
                          PhosphorIcons.robot(PhosphorIconsStyle.fill),
                          size: 36,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: GenZTokens.space4,
              vertical: 20,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.all(GenZTokens.space4),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusCard,
                      ),
                      border: Border.all(
                        color: line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PillTag(
                              text: 'ai.companion_mode'.tr(),
                              selected: true,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PulseDot(color: success),
                                const SizedBox(width: 6),
                                Text(
                                  'ai.online'.tr(),
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ai.hub_welcome'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            letterSpacing: -0.2,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ai.hub_intro'.tr(),
                          style: AppFonts.body(
                            color: inkSoft,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
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
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MateyAiEmotionalChaosScreen(isDarkMode: isDark),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'ai.vibe_matcher_title'.tr(),
                  subtitle: 'ai.vibe_match_sub'.tr(),
                  icon: PhosphorIcons.heart(PhosphorIconsStyle.bold),
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
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiBudgetAssistantScreen(isDarkMode: isDark),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'ai.personality_title'.tr(),
                  subtitle: 'ai.personality_sub'.tr(),
                  icon: PhosphorIcons.brain(PhosphorIconsStyle.bold),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiPersonalityAnalysisScreen(isDarkMode: isDark),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'ai.mood_title'.tr(),
                  subtitle: 'ai.drama_sub'.tr(),
                  icon: PhosphorIcons.smileyMeh(PhosphorIconsStyle.bold),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiMoodDetectionScreen(isDarkMode: isDark),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'ai.timeline_title'.tr(),
                  subtitle: 'ai.hub_route_sub'.tr(),
                  icon: PhosphorIcons.path(PhosphorIconsStyle.bold),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiRecommendationTimelineScreen(isDarkMode: isDark),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'ai.wrapped_title'.tr(),
                  subtitle: 'ai.hub_recap_sub'.tr(),
                  icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
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
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiGenerationQueueScreen(isDarkMode: isDark),
                    ),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'ai.prompts_title'.tr(),
                  subtitle: 'ai.hub_prompts_sub'.tr(),
                  icon: PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiSavedPromptsScreen(isDarkMode: isDark),
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
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: -0.2,
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
    required bool isDark,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PressableCard(
        onTap: onTap,
        color: surfaceColor,
        radius: GenZTokens.radiusCard,
        padding: const EdgeInsets.all(GenZTokens.space4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                color: fill,
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Icon(icon, color: ink, size: 20),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: inkSoft,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              color: inkSoft,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
