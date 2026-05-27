import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chat_search_screen.dart';
import 'squad_group_settings_screen.dart';
import 'shared_media_gallery_screen.dart';
import 'friend_online_status_screen.dart';
import 'social_mention_notifications_screen.dart';
import 'squad_activity_feed_screen.dart';

class SquadChatScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SquadChatScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SquadChatScreen> createState() => _SquadChatScreenState();
}

class _SquadChatScreenState extends State<SquadChatScreen> {
  int _activeConversation = 0; // 0: Kyoto Drift Squad, 1: Social Chaos Mode
  bool _voiceOverlayVisible = false;
  bool _stickerTrayVisible = false;
  bool _showTypingIndicator = true;
  String _selectedMessageForSticker = '';

  final TextEditingController _msgController = TextEditingController();

  // Kyoto Drift messages
  final List<Map<String, dynamic>> _kyotoMessages = [
    {
      'id': 'm1',
      'user': '@alex_escapes',
      'avatar': '🦊',
      'content': 'Welcome to Kyoto Drift Squad crew space! Get ready for chaotic temples and matcha overload! 🍵',
      'time': '10:02 AM',
      'reactions': ['🔥', '👾'],
    },
    {
      'id': 'm2',
      'user': '@minh_nhat',
      'avatar': '🐱',
      'content': 'LOCATION_PING: Sharing location! Meet me at Gion Walk.',
      'type': 'ping',
      'location': 'Shijodori Gion-machi, Kyoto',
      'time': '10:15 AM',
      'reactions': ['👀'],
    },
    {
      'id': 'm3',
      'user': '@sarah_wander',
      'avatar': '🦊',
      'content': 'POLL: Kyoto Squad Dinner Democracy 🗳️',
      'type': 'poll',
      'pollQuestion': 'What Ryokan Kyoto dining style fits our vibe?',
      'pollOptions': [
        {'text': 'Kaiseki Dinner (Traditional) 🍱', 'votes': 3, 'voted': true},
        {'text': 'Ramen Crawl & Sake 🍜', 'votes': 1, 'voted': false},
      ],
      'time': '10:45 AM',
      'reactions': [],
    },
    {
      'id': 'm4',
      'user': '@thao_ly',
      'avatar': '🦄',
      'content': 'Wait, did someone check if we need Grab bike bookings or rental scooters?',
      'time': '11:02 AM',
      'reactions': ['🛵'],
    }
  ];

  // Social Chaos messages
  final List<Map<String, dynamic>> _chaosMessages = [
    {
      'id': 'c1',
      'user': '@nam_trung',
      'avatar': '🦖',
      'content': 'This channel is absolute social chaos edit. Post your wildest travel roasts here!',
      'time': '09:00 AM',
      'reactions': ['🔥', '😂'],
    },
    {
      'id': 'c2',
      'user': '@thao_ly',
      'avatar': '🦄',
      'content': 'I spent ¥8000 on matcha cookies and I am already broke student tier 💸😭',
      'time': '09:30 AM',
      'reactions': ['💀', '💸'],
    }
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    
    setState(() {
      final newMsg = {
        'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
        'user': '@alex_escapes',
        'avatar': '🦊',
        'content': _msgController.text.trim(),
        'time': 'Just now',
        'reactions': <String>[],
      };
      
      if (_activeConversation == 0) {
        _kyotoMessages.add(newMsg);
      } else {
        _chaosMessages.add(newMsg);
      }
      _msgController.clear();
      _showTypingIndicator = false;
    });

    // Simulate typing indicator reappearing later
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showTypingIndicator = true;
        });
      }
    });
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);

    final messages = _activeConversation == 0 ? _kyotoMessages : _chaosMessages;
    final activeTitle = _activeConversation == 0 ? 'Kyoto Drift Squad 🛵' : 'Social Chaos Mode 🔥';

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
          child: Stack(
            children: [
              Column(
                children: [
                  // Upper Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left conversation togglers
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeConversation = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _activeConversation == 0 ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '🛵 Kyoto',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _activeConversation == 0 ? Colors.white : textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeConversation = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _activeConversation == 1 ? neonPink : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '🔥 Chaos',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _activeConversation == 1 ? Colors.white : textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Right icons (Mentions & Search)
                        Row(
                          children: [
                            // Mentions tag badge trigger
                            GestureDetector(
                              onTap: () => _navigateToPage(
                                SocialMentionNotificationsScreen(
                                  isDarkMode: isDark,
                                  onThemeToggle: widget.onThemeToggle,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.alternate_email, color: textPrimary),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search, color: textPrimary),
                              onPressed: () => _navigateToPage(
                                ChatSearchScreen(
                                  isDarkMode: isDark,
                                  onThemeToggle: widget.onThemeToggle,
                                ),
                              ),
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
                      ],
                    ),
                  ),

                  // Chat Info Bar (Tappable header -> Group Settings)
                  GestureDetector(
                    onTap: () => _navigateToPage(
                      SquadGroupSettingsScreen(
                        isDarkMode: isDark,
                        onThemeToggle: widget.onThemeToggle,
                        crewName: activeTitle,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _navigateToPage(
                                  FriendOnlineStatusScreen(
                                    isDarkMode: isDark,
                                    onThemeToggle: widget.onThemeToggle,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('👥', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeTitle,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '4 members active online • Tap for Settings',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(Icons.settings, color: textSecondary.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                  ),

                  // Sub-trigger quick activities alert bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: GestureDetector(
                      onTap: () => _navigateToPage(
                        SquadActivityFeedScreen(
                          isDarkMode: isDark,
                          onThemeToggle: widget.onThemeToggle,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  '@minh_nhat checked off a task in Packing Checklist!',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.keyboard_double_arrow_right, size: 12, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Messages list
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isSelf = msg['user'] == '@alex_escapes';
                        final type = msg['type'] ?? 'text';

                        return Column(
                          crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // User tag header
                            if (!isSelf)
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: Text(
                                  '${msg['avatar']} ${msg['user']}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondary,
                                  ),
                                ),
                              ),

                            // Main Bubble content card
                            Row(
                              mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Long press triggers sticker reaction tray overlay
                                GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      _selectedMessageForSticker = msg['id'] as String;
                                      _stickerTrayVisible = true;
                                    });
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelf
                                          ? primaryColor
                                          : cardBg.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(20),
                                        topRight: const Radius.circular(20),
                                        bottomLeft: isSelf ? const Radius.circular(20) : const Radius.circular(0),
                                        bottomRight: isSelf ? const Radius.circular(0) : const Radius.circular(20),
                                      ),
                                      border: Border.all(
                                        color: isSelf
                                            ? Colors.transparent
                                            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                                      ),
                                    ),
                                    child: _buildBubbleContent(type, msg, isSelf, textPrimary, textSecondary),
                                  ),
                                ),
                              ],
                            ),

                            // Reactions list below bubble
                            if ((msg['reactions'] as List).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 10),
                                child: Wrap(
                                  spacing: 4,
                                  children: (msg['reactions'] as List).map<Widget>((emoji) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                                      ),
                                      child: Text(
                                        emoji as String,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            else
                              const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  ),

                  // Realtime Typing Indicator
                  if (_showTypingIndicator)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: neonPink, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '@minh_nhat is typing... 💬',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message Input Tray
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Media Gallery trigger
                        IconButton(
                          icon: Icon(Icons.photo_library_outlined, color: neonCyan),
                          onPressed: () => _navigateToPage(
                            SharedMediaGalleryScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                        ),
                        // Voice Chat Overlay trigger
                        IconButton(
                          icon: Icon(Icons.mic_none, color: neonPink),
                          onPressed: () {
                            setState(() {
                              _voiceOverlayVisible = true;
                            });
                          },
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: cardBg.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: TextField(
                              controller: _msgController,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Message active squad...',
                                hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              // Glassmorphic Voice Chat Overlay (Supports simulated active voice)
              if (_voiceOverlayVisible)
                _buildVoiceOverlay(isDark, cardBg, textPrimary, textSecondary, primaryColor, neonPink, neonCyan),

              // Sticker Reaction Tray Overlay
              if (_stickerTrayVisible)
                _buildStickerTray(isDark, cardBg, textPrimary, textSecondary, primaryColor, neonPink, neonCyan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleContent(
    String type,
    Map<String, dynamic> msg,
    bool isSelf,
    Color textPrimary,
    Color textSecondary,
  ) {
    final textColor = isSelf ? Colors.white : textPrimary;
    final subColor = isSelf ? Colors.white70 : textSecondary;

    if (type == 'ping') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Shared Location Ping',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            msg['location'] as String,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subColor),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Location coordinates on live map... 🗺️')),
              );
            },
            child: const Text('Track Mates'),
          ),
        ],
      );
    } else if (type == 'poll') {
      final question = msg['pollQuestion'] as String;
      final options = msg['pollOptions'] as List;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗳️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Squad Democracy Poll',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          ...options.map((opt) {
            final isVoted = opt['voted'] as bool;
            final text = opt['text'] as String;
            final votes = opt['votes'] as int;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isVoted 
                    ? Colors.blueAccent.withValues(alpha: 0.2) 
                    : Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isVoted ? Colors.blueAccent : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: isVoted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '$votes votes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    } else {
      return Text(
        msg['content'] as String,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: textColor,
          height: 1.4,
        ),
      );
    }
  }

  // SQUAD VOICE OVERLAY
  Widget _buildVoiceOverlay(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
    Color neonPink,
    Color neonCyan,
  ) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.15),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎙️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Voice Chat Active',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _voiceOverlayVisible = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Active voice waves showing who is talking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActiveVoiceSpeaker('🐱', '@minh_nhat', true, themeColor),
                _buildActiveVoiceSpeaker('🦖', '@nam_trung', true, neonCyan),
                _buildActiveVoiceSpeaker('🦄', '@thao_ly', false, Colors.grey),
                _buildActiveVoiceSpeaker('🦊', 'You', false, Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _voiceOverlayVisible = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disconnected from Squad Voice Chat.')),
                );
              },
              icon: const Icon(Icons.call_end, color: Colors.white),
              label: const Text('Disconnect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveVoiceSpeaker(String emoji, String tag, bool isTalking, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isTalking)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          tag,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: isTalking ? color : Colors.grey,
            fontWeight: isTalking ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // STICKER REACTION TRAY
  Widget _buildStickerTray(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
    Color neonPink,
    Color neonCyan,
  ) {
    final stickers = ['🔥', '😂', '💀', '💸', '👾', '👀', '👍', '❤️'];
    return Positioned(
      bottom: 90,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Express the Chaos! Add Sticker Reaction:',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() {
                      _stickerTrayVisible = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stickers.map((sticker) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Find message and add reaction
                      if (_activeConversation == 0) {
                        final idx = _kyotoMessages.indexWhere((m) => m['id'] == _selectedMessageForSticker);
                        if (idx != -1) {
                          if (!(_kyotoMessages[idx]['reactions'] as List).contains(sticker)) {
                            (_kyotoMessages[idx]['reactions'] as List).add(sticker);
                          }
                        }
                      } else {
                        final idx = _chaosMessages.indexWhere((m) => m['id'] == _selectedMessageForSticker);
                        if (idx != -1) {
                          if (!(_chaosMessages[idx]['reactions'] as List).contains(sticker)) {
                            (_chaosMessages[idx]['reactions'] as List).add(sticker);
                          }
                        }
                      }
                      _stickerTrayVisible = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      sticker,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
