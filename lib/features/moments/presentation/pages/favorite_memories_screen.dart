import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteMemoriesScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const FavoriteMemoriesScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<FavoriteMemoriesScreen> createState() => _FavoriteMemoriesScreenState();
}

class _FavoriteMemoriesScreenState extends State<FavoriteMemoriesScreen> {
  final List<Map<String, String>> _favorites = [
    {
      'title': 'Sunset at Fushimi Inari 🌅',
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=500',
      'user': '@alex_escapes',
      'likes': '24',
    },
    {
      'title': 'Ryokan Hot Springs Garden ♨️',
      'url': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500',
      'user': '@sarah_wander',
      'likes': '18',
    },
    {
      'title': 'Kyoto Matcha Tea Masterclass 🍵',
      'url': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=500',
      'user': '@thao_ly',
      'likes': '32',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);

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
                          'Favorite Memories',
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
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: textPrimary,
                      ),
                      onPressed: widget.onThemeToggle,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  'Your highly rated and starred trip memories.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _favorites.isEmpty
                    ? _buildEmptyState(textPrimary, textSecondary)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final fav = _favorites[index];

                          return Dismissible(
                            key: Key(fav['title']!),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (dir) {
                              setState(() {
                                _favorites.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed ${fav['title']} from favorites.')),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      fav['url']!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fav['title']!,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Added by ${fav['user']}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.favorite, color: neonPink, size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${fav['likes']} reactions',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share, color: neonCyan),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sharing favorite memory to squad chat... 🚀')),
                                      );
                                    },
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

  Widget _buildEmptyState(Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐🤷‍♂️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No starred favorites yet',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Swipe or star memory moments to see them here.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
