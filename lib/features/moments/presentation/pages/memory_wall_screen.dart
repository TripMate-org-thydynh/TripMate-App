import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'story_viewer_screen.dart';
import 'memory_archive_screen.dart';
import 'highlight_collections_screen.dart';
import 'ai_memory_sorting_screen.dart';
import 'favorite_memories_screen.dart';
import 'ghost_cam_screen.dart';
import 'shared_album_screen.dart';
import 'share_chaos_export_screen.dart';
import 'collaborative_scrapbook_editor_screen.dart';
import 'memory_timeline_screen.dart';
import 'ai_caption_generator_screen.dart';

class MemoryWallScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MemoryWallScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final textPrimary = isDark ? Colors.white : Colors.black87;

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final neonAmber = const Color(0xFFFFB300);
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          'Memory Wall Hub 🔮',
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
                      onPressed: onThemeToggle,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cinematic Landscape Story Loop Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'Squad Moments Live Stories',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                      ),
                      Container(
                        height: 90,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            _buildStoryCircle(context, '🙋‍♂️ Alex', '🔥', neonPink),
                            _buildStoryCircle(context, '👩‍💼 Ly', '💅', neonCyan),
                            _buildStoryCircle(context, '👨‍💻 Nhật', '🍵', neonAmber),
                            _buildStoryCircle(context, '👻 Ghost', '📸', Colors.purpleAccent),
                          ],
                        ),
                      ),

                      // Feature Navigation Panels Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.9,
                          children: [
                            _buildFeatureTile(
                              context,
                              icon: Icons.photo_library_outlined,
                              title: 'Shared Album',
                              desc: 'Curated group rolls',
                              color: neonCyan,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SharedAlbumScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                            _buildFeatureTile(
                              context,
                              icon: Icons.edit_note_outlined,
                              title: 'Scrapbook Canvas',
                              desc: 'Layered polaroids',
                              color: neonPink,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => CollaborativeScrapbookEditorScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                            _buildFeatureTile(
                              context,
                              icon: Icons.auto_awesome_outlined,
                              title: 'AI Caption Studio',
                              desc: 'Witty quote roasts',
                              color: neonAmber,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AICaptionGeneratorScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                            _buildFeatureTile(
                              context,
                              icon: Icons.share_outlined,
                              title: 'Export Chaos',
                              desc: 'TikTok / Reels clips',
                              color: Colors.lightGreenAccent,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ShareChaosExportScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                            _buildFeatureTile(
                              context,
                              icon: Icons.timeline_outlined,
                              title: 'Timeline Story',
                              desc: 'Chronological Dot cascade',
                              color: primaryColor,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MemoryTimelineScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                            _buildFeatureTile(
                              context,
                              icon: Icons.favorite_border,
                              title: 'Favorite Feeds',
                              desc: 'Highly aesthetic pins',
                              color: Colors.redAccent,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => FavoriteMemoriesScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                            _buildFeatureTile(
                              context,
                              icon: Icons.archive_outlined,
                              title: 'Memory Archive',
                              desc: 'Sort media history',
                              color: Colors.blueAccent,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MemoryArchiveScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                            _buildFeatureTile(
                              context,
                              icon: Icons.auto_mode_outlined,
                              title: 'AI Auto-Sorter',
                              desc: 'Tag & organize chaos',
                              color: Colors.tealAccent,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AIMemorySortingScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle))),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Highlights Collections Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Squad Highlights Reels',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => HighlightCollectionsScreen(isDarkMode: isDark, onThemeToggle: onThemeToggle)));
                              },
                              child: Text('View Collections', style: GoogleFonts.outfit(color: neonCyan, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),

                      // Two Beautiful Highlight Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildHighlightCard(
                                context,
                                title: 'Kyoto Golden Hour 🌅',
                                desc: 'Day 2 peaks',
                                likes: '42 ❤️',
                                url: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
                                color: neonAmber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildHighlightCard(
                                context,
                                title: 'Kyoto Coffee Run ☕',
                                desc: 'Nishiki crawl',
                                likes: '29 ❤️',
                                url: 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=400',
                                color: neonPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCircle(BuildContext context, String name, String emoji, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => name == '👻 Ghost'
                ? GhostCamScreen(
                    isDarkMode: isDarkMode,
                    onThemeToggle: onThemeToggle,
                  )
                : StoryViewerScreen(
                    isDarkMode: isDarkMode,
                    onThemeToggle: onThemeToggle,
                  ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 18,
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.plusJakartaSans(fontSize: 9, color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String likes,
    required String url,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(url, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(desc, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 9)),
                      Text(likes, style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
