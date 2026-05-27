import 'dart:async';
import 'dart:ui';
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

class _StoryViewerScreenState extends State<StoryViewerScreen> with TickerProviderStateMixin {
  int _storyIndex = 0;
  double _storyProgress = 0.0;
  Timer? _progressTimer;
  bool _showComments = true;

  late AnimationController _likeController;

  final List<Map<String, String>> _stories = [
    {
      'url': 'https://images.unsplash.com/photo-1585079542156-2755d9c8a094?w=800',
      'user': '@alex_travels',
      'caption': 'Midnight cravings led us here. Best Bahn Mi ever! 🍜✨#VietnamSquad',
      'location': 'Hội An, VN',
      'time': '02:45 AM · Aug 14',
    },
    {
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=800',
      'user': '@minh_nhat',
      'caption': 'Peak sunrise reflect at Kinkaku-ji temple! Beats crowds 🌅✨',
      'location': 'Kyoto, Japan',
      'time': '06:12 AM · Aug 13',
    },
    {
      'url': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
      'user': '@thao_ly',
      'caption': 'Towering bamboo paths. Major green energy 🌲🎋',
      'location': 'Arashiyama',
      'time': '03:30 PM · Aug 12',
    },
  ];

  final List<Map<String, dynamic>> _comments = [
    {
      'user': '@sarah_w',
      'text': 'I can still taste that spicy sauce! Take me back 😭',
      'time': '2h',
      'likes': 12,
      'liked': false,
    },
    {
      'user': '@joshua_v',
      'text': 'The fact that we almost got lost trying to find this stall makes it 10x better.',
      'time': '5h',
      'likes': 45,
      'liked': false,
    },
    {
      'user': '@mike_d',
      'text': '🔥🔥🔥',
      'time': '6h',
      'likes': 2,
      'liked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startStoryTimer();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _likeController.dispose();
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
      body: Stack(
        children: [
          // FULLSCREEN IMMERSIVE IMAGE
          Positioned.fill(
            child: Image.network(
              story['url']!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, st) => Container(color: const Color(0xFF0B0F19)),
            ),
          ),

          // SOFT DARK GRADIENT
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

          // MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                // TOP: Progress bars + header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
                const SizedBox(height: 12),

                // TOP: Header bar with user + close
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Avatar bubble
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
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 11, color: Colors.white60),
                                  const SizedBox(width: 3),
                                  Text(
                                    story['location']!,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    story['time']!,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Close button with glassmorphism
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // CAPTION (middle of screen)
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      story['caption']!,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // BOTTOM SECTION: side interactions + comment drawer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // LEFT: gestures to navigate
                    Expanded(
                      child: GestureDetector(
                        onTap: _prevStory,
                        behavior: HitTestBehavior.translucent,
                        child: const SizedBox(height: 200),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: _nextStory,
                        behavior: HitTestBehavior.translucent,
                        child: const SizedBox(height: 200),
                      ),
                    ),

                    // RIGHT: Side interactions bar
                    Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 20),
                      child: Column(
                        children: [
                          // LIKE
                          _buildSideAction(
                            icon: Icons.favorite,
                            label: '3.2k',
                            color: const Color(0xFFFF2D55),
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                          // COMMENTS
                          _buildSideAction(
                            icon: Icons.chat_bubble,
                            label: '128',
                            color: Colors.white,
                            onTap: () {
                              setState(() => _showComments = !_showComments);
                            },
                          ),
                          const SizedBox(height: 20),
                          // SHARE
                          _buildSideAction(
                            icon: Icons.send,
                            label: 'Share',
                            color: Colors.white,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sharing story... ✨'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BOTTOM SLIDE DRAWER: Comments panel
          if (_showComments)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCommentsDrawer(),
            ),
        ],
      ),
    );
  }

  Widget _buildSideAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsDrawer() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 440),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Comments',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: ' 128',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showComments = false),
                      child: const Icon(Icons.tune, color: Colors.white60, size: 22),
                    ),
                  ],
                ),
              ),

              // Comments list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            child: Center(
                              child: Text(
                                comment['user'].toString().substring(1, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment['user'] as String,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      comment['time'] as String,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment['text'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Replied to comment'),
                                            duration: Duration(seconds: 1),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Reply',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _comments[index]['liked'] = !(_comments[index]['liked'] as bool);
                                          if (_comments[index]['liked'] as bool) {
                                            _comments[index]['likes'] = (_comments[index]['likes'] as int) + 1;
                                          } else {
                                            _comments[index]['likes'] = (_comments[index]['likes'] as int) - 1;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            size: 14,
                                            color: (comment['liked'] as bool) ? const Color(0xFFFF2D55) : Colors.white60,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${comment['likes']}',
                                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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

              // Input field
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comment posted! ✨'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_upward, color: Color(0xFFD0BCFF), size: 20),
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
  }
}
