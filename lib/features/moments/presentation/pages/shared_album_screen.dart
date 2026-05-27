import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedAlbumScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SharedAlbumScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SharedAlbumScreen> createState() => _SharedAlbumScreenState();
}

class _SharedAlbumScreenState extends State<SharedAlbumScreen> {
  int _selectedTab = 0; // 0: All, 1: Sunset, 2: Food, 3: Fails
  String? _fullscreenVideoUrl;
  String? _fullscreenVideoTitle;
  bool _isPlaying = true;
  bool _showComments = false;
  final List<String> _comments = [
    'Alex: Who let Khang drive the scooter? 😭🏍️',
    'Thảo Ly: Absolute peak vibe at the peak sunset!',
    'Minh Nhật: Ramen place was goated 🍜',
    'Phú Khang: Next time let me cook!'
  ];
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, String>> _albumMedia = [
    {
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=500',
      'tag': 'Sunset',
      'title': 'Kinkaku-ji reflection',
      'isVideo': 'false',
    },
    {
      'url': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500',
      'tag': 'Sunset',
      'title': 'Golden Bamboo shadows',
      'isVideo': 'false',
    },
    {
      'url': 'https://images.unsplash.com/photo-1528164344705-47542687000d?w=500',
      'tag': 'Sunset',
      'title': 'Torii gate sunset drift',
      'isVideo': 'true',
    },
    {
      'url': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=500',
      'tag': 'Food',
      'title': 'Glistening tonkotsu bowl',
      'isVideo': 'false',
    },
    {
      'url': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=500',
      'tag': 'Fails',
      'title': 'Lost in Kyoto station again',
      'isVideo': 'true',
    },
    {
      'url': 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500',
      'tag': 'Fails',
      'title': 'Scooter crash in heavy rain',
      'isVideo': 'false',
    }
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

    final filteredMedia = _albumMedia.where((media) {
      if (_selectedTab == 0) return true;
      if (_selectedTab == 1) return media['tag'] == 'Sunset';
      if (_selectedTab == 2) return media['tag'] == 'Food';
      if (_selectedTab == 3) return media['tag'] == 'Fails';
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
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
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
                              'Shared Album 📸',
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

                  // Tag description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Curated high-vibe memories of Kyoto Adventure.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Pills
                  Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildTab(0, '🍿 All Moments', primaryColor),
                        _buildTab(1, '🌅 Sunset Vibe', primaryColor),
                        _buildTab(2, '🍜 Food Crawl', primaryColor),
                        _buildTab(3, '🤪 Fails & Chaos', primaryColor),
                      ],
                    ),
                  ),

                  // Media Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: filteredMedia.length,
                        itemBuilder: (context, index) {
                          final item = filteredMedia[index];
                          final isVideo = item['isVideo'] == 'true';

                          return GestureDetector(
                            onTap: () {
                              if (isVideo) {
                                setState(() {
                                  _fullscreenVideoUrl = item['url'];
                                  _fullscreenVideoTitle = item['title'];
                                  _isPlaying = true;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Double tap to drop ❤️ on "${item['title']}"!'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: neonPink,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.black12,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
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
                                    // Soft dark bottom overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.transparent, Colors.black54],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Info
                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      right: 12,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']!,
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isVideo ? neonCyan.withValues(alpha: 0.2) : neonPink.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isVideo ? neonCyan.withValues(alpha: 0.4) : neonPink.withValues(alpha: 0.4),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              isVideo ? '📹 VIDEO' : '📸 PHOTO',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: isVideo ? neonCyan : neonPink,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isVideo)
                                      const Center(
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black54,
                                          radius: 20,
                                          child: Icon(Icons.play_arrow, color: Colors.white),
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

            // Immersive Video Viewer overlay (simulates TikTok)
            if (_fullscreenVideoUrl != null)
              _buildFullscreenVideoPlayer(neonPink, neonCyan),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, Color selectedColor) {
    final isSelected = _selectedTab == index;
    final isDark = widget.isDarkMode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor
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

  Widget _buildFullscreenVideoPlayer(Color neonPink, Color neonCyan) {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Mock Video Content
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              onDoubleTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Dropped a viral heart to this squad video! ❤️💥'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: neonPink,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _fullscreenVideoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image, color: Colors.white));
                        },
                      ),
                      // Soft shadows
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Pause indicator icon
                      if (!_isPlaying)
                        const Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 36,
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 48),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 48,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () {
                  setState(() {
                    _fullscreenVideoUrl = null;
                  });
                },
              ),
            ),

            // Video Title / Owner description
            Positioned(
              bottom: 80,
              left: 20,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: neonCyan.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: neonCyan, width: 1),
                        ),
                        child: const Center(child: Text('🤪', style: TextStyle(fontSize: 14))),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '@matey_bot • Squad Clip',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fullscreenVideoTitle ?? 'Kyoto Roadtrip Highlights',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recorded live using candidate Ghost Cam! ⚡👻',
                    style: GoogleFonts.caveat(
                      color: Colors.amberAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Sidebar actions (Hearts, Comments)
            Positioned(
              bottom: 120,
              right: 16,
              child: Column(
                children: [
                  _buildSidebarAction(Icons.favorite, '142', neonPink, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Dropped a viral heart to this squad video! ❤️💥'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: neonPink,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildSidebarAction(Icons.mode_comment, '18', Colors.white, () {
                    setState(() {
                      _showComments = true;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildSidebarAction(Icons.share, 'Share', neonCyan, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied share link to dashboard! 🚀🔗'),
                        backgroundColor: neonCyan,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Video Seek bar mock
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  const Text('0:12', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Expanded(
                    child: Slider(
                      value: 0.4,
                      onChanged: (val) {},
                      activeColor: neonPink,
                      inactiveColor: Colors.white30,
                    ),
                  ),
                  const Text('0:30', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),

            // Animated Comments drawer overlay (bottom sheet style)
            if (_showComments)
              _buildCommentsDrawer(neonPink),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarAction(IconData icon, String count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white12,
            radius: 24,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsDrawer(Color accentColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 400,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comment Thread Overlay 💬',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      _showComments = false;
                    });
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _comments[index],
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Send bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add to the chaos...',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: accentColor),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      setState(() {
                        _comments.add('You: ${_commentController.text.trim()}');
                        _commentController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
