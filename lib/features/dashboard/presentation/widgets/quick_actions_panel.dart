import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../discovery/presentation/pages/ai_vibe_match_screen.dart';
import '../../../moments/presentation/pages/ghost_cam_screen.dart';
import '../../../gamification/gamification_screen.dart';
import '../../../profile/profile_screen.dart';
import '../../../ai/ai_hub_screen.dart';
import '../../../premium/premium_hub_screen.dart';
import '../../../system_states/system_states_hub_screen.dart';
import '../../../marketing/marketing_hub_screen.dart';

class QuickActionsPanel extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const QuickActionsPanel({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final List<Map<String, dynamic>> _actions = const [
    {
      "icon": Icons.payments_outlined,
      "title": "dashboard.split_money",
      "gradient": [Color(0xFF10B981), Color(0xFF059669)],
      "emoji": "💸",
    },
    {
      "icon": Icons.photo_camera_outlined,
      "title": "dashboard.ghost_cam",
      "gradient": [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      "emoji": "📸",
    },
    {
      "icon": Icons.sports_esports_outlined,
      "title": "dashboard.gamification",
      "gradient": [Color(0xFFEC4899), Color(0xFFDB2777)],
      "emoji": "🕹️",
    },
    {
      "icon": Icons.person_outline,
      "title": "dashboard.profile",
      "gradient": [Color(0xFFEBA83A), Color(0xFFD97706)],
      "emoji": "🛡️",
    },
    {
      "icon": Icons.explore_outlined,
      "title": "dashboard.vibe_match",
      "gradient": [Color(0xFF3B82F6), Color(0xFF2563EB)],
      "emoji": "🗺",
    },
    {
      "icon": Icons.psychology_outlined,
      "title": "dashboard.ai_hub",
      "gradient": [Color(0xFFA855F7), Color(0xFF7C3AED)],
      "emoji": "🔮",
    },
    {
      "icon": Icons.workspace_premium_outlined,
      "title": "dashboard.premium_hub",
      "gradient": [Color(0xFFF59E0B), Color(0xFFD97706)],
      "emoji": "💎",
    },
    {
      "icon": Icons.warning_amber_outlined,
      "title": "dashboard.system_hub",
      "gradient": [Color(0xFFEF4444), Color(0xFFB91C1C)],
      "emoji": "⚙️",
    },
    {
      "icon": Icons.campaign_outlined,
      "title": "dashboard.marketing_hub",
      "gradient": [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      "emoji": "📢",
    }
  ];

  String _getActionTitle(String key) {
    if (key == "dashboard.gamification") return "Trò Chơi 🕹️";
    if (key == "dashboard.profile") return "Cá Nhân 🛡️";
    if (key == "dashboard.ai_hub") return "Matey AI Hub 🔮";
    if (key == "dashboard.premium_hub") return "Premium Space 💎";
    if (key == "dashboard.system_hub") return "Hệ Thống ⚙️";
    if (key == "dashboard.marketing_hub") return "Core Showcase 📢";
    return key.tr();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "dashboard.quick_actions".tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: _actions.length,
          itemBuilder: (context, index) {
            final action = _actions[index];
            final gradient = action["gradient"] as List<Color>;

            return GestureDetector(
              onTap: () {
                if (action["title"] == "dashboard.vibe_match") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIVibeMatchScreen(
                        isDarkMode: isDarkMode,
                        onThemeToggle: onThemeToggle,
                      ),
                    ),
                  );
                } else if (action["title"] == "dashboard.ai_hub") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiHubScreen(),
                    ),
                  );
                } else if (action["title"] == "dashboard.premium_hub") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumHubScreen(),
                    ),
                  );
                } else if (action["title"] == "dashboard.system_hub") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SystemStatesHubScreen(),
                    ),
                  );
                } else if (action["title"] == "dashboard.marketing_hub") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketingHubScreen(),
                    ),
                  );
                } else if (action["title"] == "dashboard.ghost_cam") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GhostCamScreen(
                        isDarkMode: isDarkMode,
                        onThemeToggle: onThemeToggle,
                      ),
                    ),
                  );
                } else if (action["title"] == "dashboard.gamification") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamificationScreen(),
                    ),
                  );
                } else if (action["title"] == "dashboard.profile") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Opened ${_getActionTitle(action['title'] as String)}!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            gradient[0].withValues(alpha: 0.15),
                            gradient[1].withValues(alpha: 0.05),
                          ]
                        : [
                            gradient[0].withValues(alpha: 0.12),
                            gradient[1].withValues(alpha: 0.06),
                          ],
                  ),
                  border: Border.all(
                    color: gradient[0].withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Text(
                          action["emoji"] as String,
                          style: TextStyle(
                            fontSize: 48,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: gradient[0].withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                action["icon"] as IconData,
                                color: gradient[0],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getActionTitle(action["title"] as String),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
