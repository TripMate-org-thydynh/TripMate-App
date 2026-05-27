import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadActivityFeedScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SquadActivityFeedScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bgGradStart = isDarkMode ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDarkMode ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : Colors.black87;
    final textSecondary = isDarkMode ? Colors.white60 : Colors.black54;

    final primaryColor = isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final neonAmber = const Color(0xFFFFB300);

    final List<Map<String, dynamic>> activities = [
      {
        'user': '@minh_nhat',
        'avatar': '🐱',
        'action': 'checked off a task in Packing Checklist',
        'detail': 'Checked: "Travel adapters & extension cables" 🔌',
        'time': 'Just now',
        'icon': Icons.checklist_rtl_outlined,
        'color': Colors.green,
      },
      {
        'user': '@nam_trung',
        'avatar': '🦖',
        'action': 'split a Grab transport booking',
        'detail': 'Fares split: ¥3,500 total (¥875 per head)',
        'time': '12 mins ago',
        'icon': Icons.hail_outlined,
        'color': neonCyan,
      },
      {
        'user': '@alex_escapes',
        'avatar': '🦊',
        'action': 'swapped outdoor timeline spots (Rain Mode)',
        'detail': 'Swapped: "Raohe Night Market" ➡️ Cozy "Cloud Nine Cafe" ☕',
        'time': '45 mins ago',
        'icon': Icons.cloud_sync,
        'color': neonAmber,
      },
      {
        'user': '@thao_ly',
        'avatar': '🦄',
        'action': 'voted in Squad Dinner Democracy Poll',
        'detail': 'Voted: "Traditional Kaiseki Room Dining" 🍱',
        'time': '2 hours ago',
        'icon': Icons.how_to_vote_outlined,
        'color': neonPink,
      },
      {
        'user': '@sarah_wander',
        'avatar': '🦊',
        'action': 'uploaded a new trip Moment',
        'detail': 'Added "Aesthetic Matcha Pour" photos at Still Cafe 📸',
        'time': '3 hours ago',
        'icon': Icons.photo_library_outlined,
        'color': primaryColor,
      }
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradStart, bgGradEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Settings Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Squad Activity Feed',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: textPrimary,
                      ),
                      onPressed: onThemeToggle,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  'Real-time operations stream. Keep tab on who is doing what in your squad.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final act = activities[index];
                    final itemColor = act['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: itemColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              act['icon'] as IconData,
                              color: itemColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          act['avatar'] as String,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          act['user'] as String,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      act['time'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  act['action'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  act['detail'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
