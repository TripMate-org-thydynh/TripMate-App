import 'dart:ui';
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
import '../../../expense_tracker/presentation/pages/expense_splitter_social_screen.dart';

class QuickActionsPanel extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const QuickActionsPanel({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  // Primary 4 actions shown as large pill grid (Stitch spec)
  static const List<Map<String, dynamic>> _primaryActions = [
    {
      'emoji': '💸',
      'label': 'chia tiền',
      'type': 'expense',
      'glowColor': Color(0xFF34D399),
      'borderColor': Color(0xFF10B981),
    },
    {
      'emoji': '📸',
      'label': 'ghost cam',
      'type': 'ghost_cam',
      'glowColor': Color(0xFF8B5CF6),
      'borderColor': Color(0xFF7C3AED),
    },
    {
      'emoji': '🎲',
      'label': 'bingo',
      'type': 'bingo',
      'glowColor': Color(0xFFF472B6),
      'borderColor': Color(0xFFDB2777),
    },
    {
      'emoji': '🗺',
      'label': 'vibe match',
      'type': 'vibe_match',
      'glowColor': Color(0xFF60A5FA),
      'borderColor': Color(0xFF3B82F6),
    },
  ];

  // Secondary actions shown in compact list row
  static const List<Map<String, dynamic>> _secondaryActions = [
    {
      'icon': Icons.person_outline,
      'label': 'Cá Nhân',
      'type': 'profile',
      'color': Color(0xFFEBA83A),
    },
    {
      'icon': Icons.psychology_outlined,
      'label': 'Matey AI',
      'type': 'ai_hub',
      'color': Color(0xFFA855F7),
    },
    {
      'icon': Icons.workspace_premium_outlined,
      'label': 'Premium',
      'type': 'premium',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Icons.warning_amber_outlined,
      'label': 'System',
      'type': 'system',
      'color': Color(0xFFEF4444),
    },
    {
      'icon': Icons.campaign_outlined,
      'label': 'Showcase',
      'type': 'marketing',
      'color': Color(0xFF3B82F6),
    },
  ];

  void _handleTap(BuildContext context, String type) {
    switch (type) {
      case 'expense':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ExpenseSplitterSocialScreen(),
          ),
        );
      case 'ghost_cam':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GhostCamScreen(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
        );
      case 'bingo':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GamificationScreen()),
        );
      case 'vibe_match':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AIVibeMatchScreen(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
        );
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      case 'ai_hub':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiHubScreen()),
        );
      case 'premium':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumHubScreen()),
        );
      case 'system':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SystemStatesHubScreen()),
        );
      case 'marketing':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MarketingHubScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'dashboard.quick_actions'.tr(),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1E2022),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⚡ quick',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Primary 2x2 Stitch-style pill grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.9,
          ),
          itemCount: _primaryActions.length,
          itemBuilder: (context, index) {
            final action = _primaryActions[index];
            final glowColor = action['glowColor'] as Color;
            final borderColor = action['borderColor'] as Color;

            return GestureDetector(
              onTap: () => _handleTap(context, action['type'] as String),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                glowColor.withValues(alpha: 0.12),
                                glowColor.withValues(alpha: 0.04),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.9),
                                glowColor.withValues(alpha: 0.06),
                              ],
                      ),
                      border: Border.all(
                        color: borderColor.withValues(alpha: isDark ? 0.4 : 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Text(
                            action['emoji'] as String,
                            style: const TextStyle(fontSize: 26),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              action['label'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1E2022),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Secondary actions horizontal scrollable row
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _secondaryActions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final action = _secondaryActions[index];
              final color = action['color'] as Color;

              return GestureDetector(
                onTap: () => _handleTap(context, action['type'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isDark
                        ? color.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.8),
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(action['icon'] as IconData, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        action['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF1E2022),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
