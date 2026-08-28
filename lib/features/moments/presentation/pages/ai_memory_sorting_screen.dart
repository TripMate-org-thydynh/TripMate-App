import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class AIMemorySortingScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIMemorySortingScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AIMemorySortingScreen> createState() => _AIMemorySortingScreenState();
}

class _AIMemorySortingScreenState extends State<AIMemorySortingScreen> {
  final List<Map<String, dynamic>> _sortingTasks = [
    {
      'id': '1',
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
      'aiCategory': '🌿 Deep Chill Vibe',
      'aiCaption':
          '"Kyoto temples look gorgeous when you guys aren\'t arguing about train passes." 🍵',
      'tags': ['Kyoto', 'Chill', 'Temple'],
      'isSorted': false,
    },
    {
      'id': '2',
      'url':
          'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=400',
      'aiCategory': '🍜 Foodie Chaos',
      'aiCaption':
          '"Eating 4 bowls of ramen and crying about the credit card bills later is our squad signature." 💸🍲',
      'tags': ['Ramen', 'Market', 'BrokeStudent'],
      'isSorted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark
        ? const Color(0xFF1A1712)
        : const Color(0xFFFDF6D3);
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B);
    final secondaryColor = isDark
        ? const Color(0xFF3D8BFF)
        : const Color(0xFFFFD84D);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgGradStart),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Memory Sorting',
                          style: AppFonts.body(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: textPrimary,
                      ),
                      onPressed: widget.onThemeToggle,
                    ),
                  ],
                ),
              ),

              // Title advice from Matey
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Text('🤖', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          '"Let me sort out your trip moments. I will tag them according to your crew vibe!"',
                          style: GoogleFonts.caveat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Task List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _sortingTasks.length,
                  itemBuilder: (context, index) {
                    final task = _sortingTasks[index];
                    final isSorted = task['isSorted'] as bool;

                    if (isSorted) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main moment preview
                            Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(task['url'] as String),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'AI Category Suggestion:',
                                        style: AppFonts.body(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: secondaryColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          task['aiCategory'] as String,
                                          style: AppFonts.body(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    task['aiCaption'] as String,
                                    style: GoogleFonts.caveat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Tags rows
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (task['tags'] as List)
                                        .map<Widget>((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: cardBg,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: textSecondary,
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              '#$tag',
                                              style: AppFonts.heading(
                                                fontSize: 11,
                                                color: textSecondary,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                  const SizedBox(height: 20),
                                  // Actions
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _sortingTasks[index]['isSorted'] =
                                                  true;
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Approved AI categorization & sorting tags! 📂✨',
                                                ),
                                                backgroundColor: secondaryColor,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: secondaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const Text(
                                            'Approve Sorting',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Skipped current suggestion.',
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Skip'),
                                      ),
                                    ],
                                  ),
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
