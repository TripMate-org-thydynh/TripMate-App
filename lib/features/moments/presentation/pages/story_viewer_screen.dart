import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryViewerScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const StoryViewerScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  int _storyIndex = 0;
  double _storyProgress = 0.0;
  Timer? _progressTimer;

  final List<Map<String, String>> _stories = [
    {
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=800',
      'user': '@alex_escapes',
      'caption': 'Peak sunrise reflect at Kinkaku-ji temple! Beats crowds 🌅✨',
      'location': 'Kinkaku-ji Golden Pavilion',
    },
    {
      'url': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
      'user': '@minh_nhat',
      'caption': 'Towering bamboo paths. Major green energy 🌲🎋',
      'location': 'Arashiyama Bamboo Forest',
    },
    {
      'url': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=800',
      'user': '@thao_ly',
      'caption': 'Kyoto ramen crawl! Best noodles I have ever tasted! 🍜🔥',
      'location': 'Nishiki Market, Nakagyo',
    }
  ];

  @override
  void initState() {
    super.initState();
    _startStoryTimer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startStoryTimer() {
    _storyProgress = 0.0;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_storyProgress < 1.0) {
          _storyProgress += 0.01;
        } else {
          _progressTimer?.cancel();
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    if (_storyIndex < _stories.length - 1) {
      setState(() {
        _storyIndex++;
        _startStoryTimer();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (_storyIndex > 0) {
      setState(() {
        _storyIndex--;
        _startStoryTimer();
      });
    } else {
      _startStoryTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_storyIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Immersive Image
            Image.network(
              story['url']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                );
              },
            ),

            // Soft dark gradient top and bottom for readability
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Progress Indicators Layer
            Positioned(
              top: 15,
              left: 12,
              right: 12,
              child: Row(
                children: List.generate(_stories.length, (idx) {
                  double val = 0.0;
                  if (idx < _storyIndex) val = 1.0;
                  if (idx == _storyIndex) val = _storyProgress;

                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: val,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Top Header: User Profile
            Positioned(
              top: 32,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('📸', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['user']!,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            story['location']!,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Left/Right Touch Controllers
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _prevStory,
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextStory,
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),

            // Bottom Caption & Interactive panel
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['caption']!,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Kyoto squad romanticized this moment.',
                    style: GoogleFonts.caveat(
                      color: Colors.orangeAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Reaction actions row
                  Row(
                    children: [
                      _buildQuickReaction('🔥'),
                      _buildQuickReaction('❤️'),
                      _buildQuickReaction('😂'),
                      _buildQuickReaction('🙌'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.mode_comment_outlined, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening comment thread overlay... 💬'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saving the Moment and preparing export link! 🚀'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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
  }

  Widget _buildQuickReaction(String emoji) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent reaction: $emoji to story!'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
