import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FullscreenVideoViewerScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const FullscreenVideoViewerScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<FullscreenVideoViewerScreen> createState() => _FullscreenVideoViewerScreenState();
}

class _FullscreenVideoViewerScreenState extends State<FullscreenVideoViewerScreen> with TickerProviderStateMixin {
  late AnimationController _kenBurnsController;
  late AnimationController _soundwaveController;
  late AnimationController _musicTickerController;
  
  bool _isPlaying = true;
  bool _isLiked = false;
  int _likesCount = 14200;
  bool _showComments = false;
  double _videoProgress = 0.35; // 0.0 to 1.0
  Timer? _progressTimer;
  int _elapsedSeconds = 14;
  final int _totalSeconds = 40;

  // Soundwave heights
  final List<double> _baseHeights = [15, 28, 40, 22, 35, 48, 25, 30, 18, 38, 45, 20, 32, 14, 26];
  
  // Custom comments list for Screen 70 overlay
  final List<Map<String, String>> _comments = [
    {
      'name': 'Maya',
      'time': '2m ago during the rain',
      'text': '😭 bro why are we running at 2AM',
      'avatar': 'M',
    },
    {
      'name': 'Leo',
      'time': 'just now',
      'text': '🔥 main character energy',
      'avatar': 'L',
    },
    {
      'name': 'Chloe',
      'time': 'at the peak ⛰️',
      'text': '☕ this cafe healed me.',
      'avatar': 'C',
    }
  ];

  final List<Offset> _tapHearts = [];

  @override
  void initState() {
    super.initState();
    
    // Looping image zoom (Ken Burns)
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    // Bouncing music soundwave visualizer
    _soundwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    // Continuous music text ticker scrolling
    _musicTickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Timer to simulate video playback progress
    _startPlaybackTimer();
  }

  void _startPlaybackTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        setState(() {
          _elapsedSeconds++;
          if (_elapsedSeconds > _totalSeconds) {
            _elapsedSeconds = 0;
          }
          _videoProgress = _elapsedSeconds / _totalSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _kenBurnsController.dispose();
    _soundwaveController.dispose();
    _musicTickerController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _handleScreenDoubleTap(TapDownDetails details) {
    setState(() {
      _tapHearts.add(details.localPosition);
      if (!_isLiked) {
        _isLiked = true;
        _likesCount++;
      }
    });

    // Remove heart after animation completes
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          if (_tapHearts.isNotEmpty) _tapHearts.removeAt(0);
        });
      }
    });
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final textPrimary = isDark ? Colors.white : const Color(0xFF16152B);
    final textSecondary = isDark ? Colors.white70 : Colors.black87;
    final glassBorder = isDark 
      ? Colors.white.withValues(alpha: 0.1) 
      : Colors.black.withValues(alpha: 0.1);

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFAF7FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // IMMERSIVE VIDEO SCREEN LAYER (With subtle Ken Burns moving scale)
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            onDoubleTapDown: _handleScreenDoubleTap,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                CurvedAnimation(parent: _kenBurnsController, curve: Curves.easeInOut),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=1080',
                fit: BoxFit.cover,
                errorBuilder: (context, err, stack) => Container(
                  color: isDark ? const Color(0xFF141226) : Colors.deepPurple[100],
                  child: Center(
                    child: Icon(Icons.videocam, size: 80, color: textSecondary),
                  ),
                ),
              ),
            ),
          ),

          // Vignette gradient overlay for cinematic readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // TOP STATUS BAR (Core Memory Tag, Close, Theme Toggle)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Core Memory Tag
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: neonCyan, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Core Memory Unlocked',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: neonCyan.withValues(alpha: 0.6), blurRadius: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top right control buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white,
                      ),
                      onPressed: widget.onThemeToggle,
                    ),
                    const SizedBox(width: 8),
                    // Immersive Close button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Center(
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LIVE INDICATOR PILL
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LIVE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // RIGHT SIDE INTERACTIONS PANEL (Likes, Comments, Share, Add Memory)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                // Favorite Button
                _buildInteractionItem(
                  icon: Icons.favorite,
                  label: '${(_likesCount / 1000).toStringAsFixed(1)}k',
                  color: _isLiked ? neonPink : Colors.white,
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                      _likesCount += _isLiked ? 1 : -1;
                    });
                  },
                ),
                const SizedBox(height: 18),

                // Chat bubble button
                _buildInteractionItem(
                  icon: Icons.chat_bubble,
                  label: '842',
                  color: Colors.white,
                  onTap: () {
                    setState(() {
                      _showComments = true;
                    });
                  },
                ),
                const SizedBox(height: 18),

                // Share Button
                _buildInteractionItem(
                  icon: Icons.send,
                  label: 'Share',
                  color: Colors.white,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sharing Memory to squad feed! 🔗',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: neonCyan,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Add to memories button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Saved to Highlights album! 📁✨',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: neonPink,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: neonPink.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: neonPink.withValues(alpha: 0.4), blurRadius: 10),
                      ],
                    ),
                    child: const Icon(Icons.add_circle, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM METADATA CARD (Location, Captions, Scrolling Music Ticker, Soundwave)
          Positioned(
            left: 20,
            right: 80,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location tag
                Row(
                  children: [
                    Icon(Icons.location_on, color: neonCyan, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Shibuya Crossing, Tokyo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bold Cinematic Caption
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.25,
                    ),
                    children: [
                      const TextSpan(text: 'financially unstable. '),
                      TextSpan(
                        text: 'cinematically unforgettable.',
                        style: TextStyle(
                          color: neonCyan,
                          shadows: [
                            Shadow(color: neonCyan.withValues(alpha: 0.8), blurRadius: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle Description
                Text(
                  'Lost the group chat but found the best ramen in existence. Take me back. 🍜🌃 #TokyoDrift #SquadGoals',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Scrolling Ticker + Animated Soundwave
                Row(
                  children: [
                    // Scrolling audio ticker
                    Expanded(
                      child: ClipRect(
                        child: SizedBox(
                          height: 20,
                          child: Stack(
                            children: [
                              AnimatedBuilder(
                                animation: _musicTickerController,
                                builder: (context, child) {
                                  return Positioned(
                                    left: (1.0 - _musicTickerController.value) * -180,
                                    child: Row(
                                      children: [
                                        Text(
                                          '♫ Fred again.. - leavemealone (feat. Baby Keem) • Original Audio     ♫ Fred again.. - leavemealone (feat. Baby Keem) • Original Audio',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Immersive Soundwave visualizer
                    SizedBox(
                      height: 30,
                      width: 90,
                      child: AnimatedBuilder(
                        animation: _soundwaveController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(_baseHeights.length, (idx) {
                              final waveHeight = _baseHeights[idx] * (0.4 + 0.6 * _soundwaveController.value);
                              return Container(
                                width: 2.5,
                                height: waveHeight,
                                decoration: BoxDecoration(
                                  color: neonPink,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PLAYBACK PROGRESS TRACKER AT VERY BOTTOM
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elapsed / Total Timer Label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(_elapsedSeconds),
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTime(_totalSeconds),
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Premium Neon progress slider track
                Container(
                  height: 4,
                  width: double.infinity,
                  color: Colors.white24,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _videoProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: neonCyan,
                          boxShadow: [
                            BoxShadow(color: neonCyan, blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SCREEN PAUSED SHADE OVERLAY
          if (!_isPlaying)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                  ),
                ),
              ),
            ),

          // FLOATING DOUBLE-TAP HEART ANIMATIONS OVERLAY
          ..._tapHearts.map((pos) => Positioned(
                left: pos.dx - 40,
                top: pos.dy - 40,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    final scale = 1.0 + (value * 0.4);
                    final opacity = (1.0 - value).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Icon(
                          Icons.favorite,
                          color: neonPink,
                          size: 80,
                          shadows: [
                            Shadow(color: neonPink.withValues(alpha: 0.5), blurRadius: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),

          // SCREEN 70 SLIDE-UP COMMENT THREAD OVERLAY
          if (_showComments)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showComments = false;
                  });
                },
                child: Container(
                  color: Colors.black54,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {}, // Prevent click-through closing
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: MediaQuery.of(context).size.height * 0.6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark 
                                ? const Color(0xFF130E26).withValues(alpha: 0.9) 
                                : Colors.white.withValues(alpha: 0.9),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              border: Border.all(color: glassBorder, width: 2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Drag handle & close top bar
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'the squad remembers everything.',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Nam Trung is typing...',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: neonCyan,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _showComments = false;
                                          });
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white10 : Colors.black12,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.close, color: textPrimary, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Divider(color: glassBorder, height: 1),

                                // Scrollable Comments List
                                Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(20),
                                    itemCount: _comments.length,
                                    itemBuilder: (context, index) {
                                      final comment = _comments[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Avatar
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: index == 0 
                                                ? neonPink 
                                                : (index == 1 ? neonCyan : neonGreenColor(index)),
                                              child: Text(
                                                comment['avatar']!,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        comment['name']!,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                          color: textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        comment['time']!,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 9,
                                                          color: textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    comment['text']!,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: textSecondary,
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

                                // Custom bottom reply textbox
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: glassBorder),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  style: GoogleFonts.inter(color: textPrimary, fontSize: 13),
                                                  decoration: InputDecoration(
                                                    hintText: 'Add to squad chaos memories...',
                                                    hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 12),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                              Icon(Icons.sentiment_satisfied, color: textSecondary, size: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Megaphone mic voice memo button (Screen 70 specification!)
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [neonPink, Colors.deepPurple],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: neonPink.withValues(alpha: 0.3),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.mic, color: Colors.white, size: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color neonGreenColor(int index) {
    return const Color(0xFF45FFA4);
  }

  Widget _buildInteractionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
