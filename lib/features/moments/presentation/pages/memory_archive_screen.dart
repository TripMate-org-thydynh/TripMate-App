import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryArchiveScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MemoryArchiveScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MemoryArchiveScreen> createState() => _MemoryArchiveScreenState();
}

class _MemoryArchiveScreenState extends State<MemoryArchiveScreen> {
  int _activeCategory = 0; // 0: All, 1: Photos, 2: Videos, 3: AI Recaps
  String _searchQuery = '';

  final List<Map<String, String>> _archiveItems = [
    {
      'title': 'KIX Express Train Haruka',
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
      'type': 'photo',
      'tag': 'Day 1 Arrival',
      'date': 'June 12, 2026',
    },
    {
      'title': 'Ryokan Tatami Room Setup',
      'url': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
      'type': 'photo',
      'tag': 'Hotel Check-In',
      'date': 'June 12, 2026',
    },
    {
      'title': 'Golden Pavilion Beating Crowds',
      'url': 'https://images.unsplash.com/photo-1528164344705-47542687000d?w=400',
      'type': 'video',
      'tag': 'Golden Temple',
      'date': 'June 13, 2026',
    },
    {
      'title': 'Bamboo Paths Early Walk',
      'url': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=400',
      'type': 'photo',
      'tag': 'Arashiyama Vibe',
      'date': 'June 13, 2026',
    },
    {
      'title': 'Nishiki Market Ramen Stop',
      'url': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=400',
      'type': 'video',
      'tag': 'Food Crawl',
      'date': 'June 14, 2026',
    },
    {
      'title': 'AI Trip Recap - Kyoto Drift',
      'url': 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400',
      'type': 'recap',
      'tag': 'AI Recap Video',
      'date': 'June 15, 2026',
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

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);

    // Filter list
    final filtered = _archiveItems.where((item) {
      final matchesQuery = item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['tag']!.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (!matchesQuery) return false;

      if (_activeCategory == 1) return item['type'] == 'photo';
      if (_activeCategory == 2) return item['type'] == 'video';
      if (_activeCategory == 3) return item['type'] == 'recap';
      return true;
    }).toList();

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
                          'Memory Archive',
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

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardBg.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search archive memories by tags...',
                      hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: primaryColor),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
              ),

              // Category Horizontal List
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 14),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildCategoryItem(0, '🎒 All Chaos'),
                    _buildCategoryItem(1, '📸 Photos'),
                    _buildCategoryItem(2, '📹 Videos'),
                    _buildCategoryItem(3, '🤖 AI Recaps'),
                  ],
                ),
              ),

              // Items Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: filtered.isEmpty
                      ? _buildEmptyState(textPrimary, textSecondary)
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final isVideo = item['type'] == 'video';
                            final isRecap = item['type'] == 'recap';

                            return GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening immersive viewer for: ${item['title']}... 🖼️'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              item['url']!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(child: Icon(Icons.broken_image));
                                              },
                                            ),
                                            if (isVideo || isRecap)
                                              Center(
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.black45,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    isRecap ? Icons.auto_awesome : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title']!,
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  item['tag']!,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    color: secondaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  item['date']!,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 9,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                              ],
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index, String label) {
    final isSelected = _activeCategory == index;
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategory = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
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
          const Text('📂🤷‍♂️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No matching moments in archive',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try filtering with a different category pill.',
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
