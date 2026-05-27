import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentThreadOverlay extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const CommentThreadOverlay({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<CommentThreadOverlay> createState() => _CommentThreadOverlayState();
}

class _CommentThreadOverlayState extends State<CommentThreadOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Dynamic comments list
  final List<Map<String, String>> _comments = [
    {
      'author': 'Maya',
      'avatar': 'MY',
      'avatarColor': '0xFFF43F5E',
      'time': '2m ago during the rain',
      'text': '😭 bro why are we running at 2AM',
    },
    {
      'author': 'Leo',
      'avatar': 'LE',
      'avatarColor': '0xFF0EA5E9',
      'time': 'just now',
      'text': '🔥 main character energy',
    },
    {
      'author': 'Chloe',
      'avatar': 'CH',
      'avatarColor': '0xFF10B981',
      'time': 'at the peak ⛰️',
      'text': '☕ this cafe healed me.',
    },
  ];

  // Typing status indicator
  bool _isNamTrungTyping = true;
  Timer? _typingTimer;
  late AnimationController _pulseController;

  static const _darkSurface = Color(0xFF131C2E);
  static const _darkCard = Color(0xFF1E293B);
  static const _primaryDark = Color(0xFFD0BCFF);
  static const _secondaryDark = Color(0xFF45DFA4);

  static const _lightSurface = Color(0xFFFCFAF6);
  static const _lightCard = Colors.white;
  static const _primaryLight = Color(0xFF6D3BD7);
  static const _secondaryLight = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    // Simulate typing dots / state
    _typingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _isNamTrungTyping = !_isNamTrungTyping;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add({
        'author': 'Nam Trung',
        'avatar': 'NT',
        'avatarColor': '0xFF6D3BD7',
        'time': 'just now',
        'text': text,
      });
      _commentController.clear();
    });

    // Scroll to bottom
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final surfaceColor = isDark ? _darkSurface : _lightSurface;
    final cardColor = isDark ? _darkCard : _lightCard;
    final primary = isDark ? _primaryDark : _primaryLight;
    final secondary = isDark ? _secondaryDark : _secondaryLight;

    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: isDark ? 0.75 : 0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Drag Handle Indicator
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),

              // Header Section
              _buildHeader(isDark, textPrimary, primary),

              // Comments Thread List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final item = _comments[index];
                    final colorVal = int.tryParse(item['avatarColor']!) ?? 0xFF6D3BD7;
                    final avatarColor = Color(colorVal);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: isDark ? 0.4 : 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar Bubble
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [avatarColor, avatarColor.withValues(alpha: 0.6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                item['avatar']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['author']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      item['time']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['text']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: textPrimary,
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

              // Bottom status bar ("Nam Trung is typing...")
              if (_isNamTrungTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nam Trung is typing...',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _pulseController.value,
                            child: Text(
                              '✍️',
                              style: TextStyle(fontSize: 12, color: secondary),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              // Bottom Interactive Chat Input Box
              _buildBottomChatDock(isDark, cardColor, primary, secondary, textPrimary, textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color textPrimary, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title: the squad remembers everything
          Expanded(
            child: Text(
              'the squad remembers everything.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ),
          // Action Buttons: Theme Toggle & [Interactive] Text: "close"
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              // Close Button
              IconButton(
                icon: Icon(Icons.close_rounded, color: textPrimary, size: 20),
                onPressed: () => Navigator.maybePop(context),
                tooltip: 'close',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomChatDock(
      bool isDark, Color cardColor, Color primary, Color secondary, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: isDark ? 0.3 : 0.6),
        border: Border(
          top: BorderSide(
            color: primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Input Card Box
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: isDark ? 0.5 : 0.8),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _commentController,
                    style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                    decoration: InputDecoration(
                      hintText: 'type a memory to lock in...',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.sentiment_satisfied_alt_rounded),
                        color: textMuted,
                        iconSize: 22,
                        tooltip: 'sentiment_satisfied',
                        onPressed: () {
                          // Simulation: append a cute emoji
                          _commentController.text += ' 🔥';
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send / Voice Recording overlay microphone: [Interactive] Text: "mic"
          GestureDetector(
            onTap: _addComment,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
