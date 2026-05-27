import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HighlightCollectionsScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HighlightCollectionsScreen({
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
    final neonAmber = const Color(0xFFFFB300);

    final List<Map<String, dynamic>> highlights = [
      {
        'title': 'Day 1 Peak Sunset Reflection 🌅',
        'desc': 'Curated Kyoto skyline with glowing vermilion shrine highlights.',
        'cover': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=500',
        'energy': '98% Chill Energy',
        'color': neonPink,
        'count': 12,
      },
      {
        'title': 'Arashiyama Bamboo Early Walk 🎋',
        'desc': 'Group photo walks through towering deep bamboo pathways.',
        'cover': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500',
        'energy': '92% Nature Vibe',
        'color': Colors.greenAccent,
        'count': 8,
      },
      {
        'title': 'Ramen Crawl & Nishiki Street 🍜',
        'desc': 'Octopus skewers, mochi dumps, and high spice level soups.',
        'cover': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=500',
        'energy': '95% Foodie Chaos',
        'color': neonAmber,
        'count': 15,
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
              // Header
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
                          'Highlight Collections',
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
                  'Automated collections of peak squad experience memories.',
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
                  itemCount: highlights.length,
                  itemBuilder: (context, index) {
                    final hl = highlights[index];
                    final accentColor = hl['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: cardBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Immersive cover height
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(hl['cover'] as String),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.black54, Colors.transparent],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: accentColor),
                                      ),
                                      child: Text(
                                        hl['energy'] as String,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '📸 ${hl['count']} items',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Caption fields
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hl['title'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hl['desc'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Playing high-fidelity AI Trip Recap video preview... 📺✨'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.play_arrow, size: 16),
                                        label: const Text('Play Recap'),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Preparing highlight bundle files for export! 📤'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.ios_share, size: 14, color: primaryColor),
                                        label: Text(
                                          'Export Chaos',
                                          style: TextStyle(color: primaryColor),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
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
          ),
        ),
      ),
    );
  }
}
