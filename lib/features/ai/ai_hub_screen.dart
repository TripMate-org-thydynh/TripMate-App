import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'pages/matey_ai_emotional_chaos_screen.dart';
import 'pages/ai_budget_assistant_screen.dart';
import 'pages/ai_trip_summary_screen.dart';
import 'pages/ai_chat_history_screen.dart';
import 'pages/ai_suggestion_feed_screen.dart';
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

    // Brand design system tokens
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);
    final backgroundColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;

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
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Matey AI Space 🔮',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF312E81), // Indigo 900
                            const Color(0xFF581C87), // Purple 900
                            backgroundColor, // Obsidian
                          ]
                        : [
                            const Color(0xFFEEF2FF), // Indigo 50
                            const Color(0xFFF3E8FF), // Purple 50
                            backgroundColor, // Warm Ivory
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow background bubble
                    Positioned(
                      right: -30,
                      top: 40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Premium mascot icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Text(
                            '🧠',
                            style: TextStyle(fontSize: 42),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? primaryColor.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Companion Mode',
                              style: GoogleFonts.plusJakartaSans(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chào mừng cưng đến với Matey AI! ⚡',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hệ thống AI phân tích tính cách, đo lường sự hỗn loạn và hỗ trợ tính toán ngân sách du lịch đang hoạt động hết công suất. Hãy chạm để khám phá!',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? Colors.grey[350] : Colors.black54,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                // SECTION 1: TRẢI NGHIỆM TƯƠNG TÁC
                _buildSectionHeader('Tương Tác Companion 🎭', isDark),
                const SizedBox(height: 12),
                _buildHubCard(
                  context: context,
                  title: 'Matey AI — Emotional Chaos',
                  subtitle: 'Trò chuyện cực kỳ hỗn loạn và đầy tính giải trí với Matey AI 🔮',
                  icon: Icons.chat_bubble_outline,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MateyAiEmotionalChaosScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Vibe Matcher — Squad Energy',
                  subtitle: 'Đo lường mức độ hợp cạ và rung động tâm hồn của cả hội bạn 🗺️',
                  icon: Icons.favorite_border,
                  color: const Color(0xFFEC4899),
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
                  subtitle: 'Tạo và tối ưu hóa lịch trình Kyoto / Dalat siêu tốc bằng AI 🛫',
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
                _buildSectionHeader('Hỗ Trợ & Phân Tích Squad 🧠', isDark),
                const SizedBox(height: 12),
                _buildHubCard(
                  context: context,
                  title: 'AI Budget Assistant',
                  subtitle: 'Trợ lý tối ưu hóa ngân sách và roast chi tiêu cực phũ 💸🔥',
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiBudgetAssistantScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Personality Analysis',
                  subtitle: 'Roast và xếp hạng tính cách lười biếng / ham chơi của từng đứa 👹',
                  icon: Icons.psychology_outlined,
                  color: Colors.orangeAccent,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiPersonalityAnalysisScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Mood Detection',
                  subtitle: 'Đo lường chỉ số căng thẳng và drama trong squad thời gian thực 🎭',
                  icon: Icons.mood_bad_outlined,
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiMoodDetectionScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Recommendation Timeline',
                  subtitle: 'Lộ trình gợi ý hoạt động độc lạ theo múi giờ ⏰',
                  icon: Icons.timeline_outlined,
                  color: const Color(0xFF06B6D4),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiRecommendationTimelineScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Suggestion Feed',
                  subtitle: 'Cập nhật giao thông, thời tiết thông minh kèm giải pháp 🌦️',
                  icon: Icons.rss_feed,
                  color: const Color(0xFF14B8A6),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiSuggestionFeedScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Trip Summary Recap',
                  subtitle: 'Ghép video kỷ niệm hành trình tự động cực cháy 🎞️',
                  icon: Icons.video_library_outlined,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiTripSummaryScreen()),
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 3: QUẢN LÝ TÁC VỤ
                _buildSectionHeader('Không Gian Làm Việc AI 🖥️', isDark),
                const SizedBox(height: 12),
                _buildHubCard(
                  context: context,
                  title: 'AI Generation Queue',
                  subtitle: 'Hàng đợi render video recap & bóc tách hóa đơn nền 🔄',
                  icon: Icons.queue_play_next,
                  color: const Color(0xFFEC4899),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiGenerationQueueScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Saved Prompts',
                  subtitle: 'Danh sách các câu lệnh mẫu siêu tốc cực kỳ xịn sò 📌',
                  icon: Icons.bookmark_outline,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiSavedPromptsScreen()),
                  ),
                ),
                _buildHubCard(
                  context: context,
                  title: 'AI Chat History',
                  subtitle: 'Lịch sử tra cứu các thông tin cũ từ Matey AI 📂',
                  icon: Icons.history_edu,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiChatHistoryScreen()),
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
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
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
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon container with neon circle design
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow forward
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
