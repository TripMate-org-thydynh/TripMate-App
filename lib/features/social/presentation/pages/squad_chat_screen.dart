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
  int _activeConversation = 0; // 0: Phú Quốc Escape 🌴, 1: Social Chaos Mode 🔥
  bool _voiceOverlayVisible = false;
  bool _stickerTrayVisible = false;
  bool _showTypingIndicator = true;
  String _selectedMessageForSticker = '';
  bool _pinnedLocationVisible = true;

  final TextEditingController _msgController = TextEditingController();

  // Poll state for Bún Quậy vs Seafood
  int _bunQuayVotes = 8;
  int _seafoodVotes = 5;
  String? _myPollVote; // null, 'bun', 'seafood'

  // Phú Quốc messages
  late final List<Map<String, dynamic>> _phuQuocMessages = [
    {
      'id': 'pq1',
      'user': '@phuc_travels',
      'avatar': '🚗',
      'content': 'Guys, I just arrived at the resort! Phú Quốc is absolutely gorgeous today. 🌊',
      'time': '10:02 AM',
      'reactions': ['🔥', '💯'],
    },
    {
      'id': 'pq2',
      'user': '@lan_music',
      'avatar': '🎵',
      'content': 'Sao Beach Club is the move for tonight! Already hear the bass calling. 🔊',
      'time': '10:15 AM',
      'reactions': ['🔥', '💀'],
    },
    {
      'id': 'pq_poll',
      'user': '@minh_nomad',
      'avatar': '👑',
      'type': 'poll',
      'pollQuestion': 'Dinner Democracy: Bún Quậy 🍜 vs Seafood 🦐?',
      'time': '10:20 AM',
      'reactions': [],
    },
    {
      'id': 'pq3',
      'user': '@thao_ly',
      'avatar': '🦄',
      'content': 'Are we renting bikes or taking a taxi to the beach club? It says 15m drive on the map.',
      'time': '10:25 AM',
      'reactions': ['👀'],
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
        _phuQuocMessages.add(newMsg);
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

  Widget _buildCrewStatusChip(String name, String status, Color accent, Color textCol, Color subTextCol) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: textCol,
            ),
            children: [
              TextSpan(text: '$name: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text: status,
                style: TextStyle(color: subTextCol),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReactionChip(String label, Color accent, Color textCol, Color cardBg) {
    return GestureDetector(
      onTap: () {
        setState(() {
          final newMsg = {
            'id': 'reaction_${DateTime.now().millisecondsSinceEpoch}',
            'user': '@alex_escapes',
            'avatar': '🦊',
            'content': 'reacted: $label',
            'time': 'Just now',
            'reactions': <String>[],
          };
          if (_activeConversation == 0) {
            _phuQuocMessages.add(newMsg);
          } else {
            _chaosMessages.add(newMsg);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Squad reacted with $label! 🙌'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Standard palette matching instructions
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final tertiaryColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFEBA83A);
    final backgroundColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);

    final messages = _activeConversation == 0 ? _phuQuocMessages : _chaosMessages;
    final activeTitle = _activeConversation == 0 ? 'Phú Quốc Escape 🌴' : 'Social Chaos Mode 🔥';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
                ? [const Color(0xFF0B1326), const Color(0xFF171F33)] 
                : [const Color(0xFFFCFAF6), const Color(0xFFF0EAE1)],
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _activeConversation == 0 ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: _activeConversation == 0 && isDark
                                      ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8)]
                                      : null,
                                ),
                                child: Text(
                                  '🌴 Phú Quốc',
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _activeConversation == 1 ? neonPink : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: _activeConversation == 1 && isDark
                                      ? [BoxShadow(color: neonPink.withValues(alpha: 0.3), blurRadius: 8)]
                                      : null,
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
                        color: surfaceColor.withValues(alpha: 0.7),
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

                  // Crew status sub-header
                  if (_activeConversation == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: surfaceColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCrewStatusChip('🚗 Phúc', 'traveling', primaryColor, textPrimary, textSecondary),
                            _buildCrewStatusChip('🎵 Lan', 'listening', secondaryColor, textPrimary, textSecondary),
                            _buildCrewStatusChip('Minh', 'away', textSecondary, textPrimary, textSecondary),
                          ],
                        ),
                      ),
                    ),

                  // Pinned location card for Sao Beach Club
                  if (_activeConversation == 0 && _pinnedLocationVisible)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [const Color(0xFF1E293B).withValues(alpha: 0.9), const Color(0xFF0F172A).withValues(alpha: 0.9)]
                                : [Colors.white.withValues(alpha: 0.9), const Color(0xFFF3EFE9).withValues(alpha: 0.9)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('🏖️', style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'PINNED',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Sao Beach Club',
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '15m drive • Tap for direction details',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Routing to Sao Beach Club... 🚙💨'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Text(
                                'Directions',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 16, color: textSecondary),
                              onPressed: () {
                                setState(() {
                                  _pinnedLocationVisible = false;
                                });
                              },
                            ),
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
                                  '@phuc_travels verified Packing List checklist items!',
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
                                          : surfaceColor.withValues(alpha: 0.8),
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
                                    child: _buildBubbleContent(type, msg, isSelf, textPrimary, textSecondary, surfaceColor, primaryColor, secondaryColor, isDark),
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
                                        color: surfaceColor,
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: surfaceColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '3 people typing... 💬',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Gen Z Quick Reactions Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickReactionChip('🔥 LIT', primaryColor, textPrimary, surfaceColor),
                        _buildQuickReactionChip('😂 DEAD', secondaryColor, textPrimary, surfaceColor),
                        _buildQuickReactionChip('💀 CHAOS', tertiaryColor, textPrimary, surfaceColor),
                        _buildQuickReactionChip('💯 YASSS', primaryColor, textPrimary, surfaceColor),
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
                              color: surfaceColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
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
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                )
                              ],
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
                _buildVoiceOverlay(isDark, surfaceColor, textPrimary, textSecondary, primaryColor, neonPink, neonCyan),

              // Sticker Reaction Tray Overlay
              if (_stickerTrayVisible)
                _buildStickerTray(isDark, surfaceColor, textPrimary, textSecondary, primaryColor, neonPink, neonCyan),
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
    Color surfaceColor,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final textColor = isSelf ? Colors.white : textPrimary;
    final subColor = isSelf ? Colors.white70 : textSecondary;

    if (type == 'poll') {
      final double totalVotes = (_bunQuayVotes + _seafoodVotes).toDouble();
      final double bunQuayPercent = totalVotes > 0 ? (_bunQuayVotes / totalVotes) * 100 : 50.0;
      final double seafoodPercent = totalVotes > 0 ? (_seafoodVotes / totalVotes) * 100 : 50.0;

      final bool votedBun = _myPollVote == 'bun';
      final bool votedSeafood = _myPollVote == 'seafood';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗳️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dinner Democracy',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            msg['pollQuestion'] as String,
            style: GoogleFonts.outfit(fontSize: 13, color: textColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          
          // Bun Quay option card
          GestureDetector(
            onTap: () {
              setState(() {
                if (_myPollVote == 'bun') {
                  _bunQuayVotes--;
                  _myPollVote = null;
                } else {
                  if (_myPollVote == 'seafood') {
                    _seafoodVotes--;
                  }
                  _bunQuayVotes++;
                  _myPollVote = 'bun';
                }
              });
            },
            child: Stack(
              children: [
                // Live voting progress bar behind
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 48,
                  width: (MediaQuery.of(context).size.width * 0.6) * (bunQuayPercent / 100),
                  decoration: BoxDecoration(
                    color: votedBun 
                        ? primaryColor.withValues(alpha: 0.35) 
                        : primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: votedBun ? primaryColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bún Quậy 🍜',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: votedBun ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        '$_bunQuayVotes (${bunQuayPercent.toStringAsFixed(0)}%)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: subColor,
                          fontWeight: votedBun ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // Seafood option card
          GestureDetector(
            onTap: () {
              setState(() {
                if (_myPollVote == 'seafood') {
                  _seafoodVotes--;
                  _myPollVote = null;
                } else {
                  if (_myPollVote == 'bun') {
                    _bunQuayVotes--;
                  }
                  _seafoodVotes++;
                  _myPollVote = 'seafood';
                }
              });
            },
            child: Stack(
              children: [
                // Live voting progress bar behind
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 48,
                  width: (MediaQuery.of(context).size.width * 0.6) * (seafoodPercent / 100),
                  decoration: BoxDecoration(
                    color: votedSeafood 
                        ? secondaryColor.withValues(alpha: 0.35) 
                        : secondaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: votedSeafood ? secondaryColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seafood 🦐',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: votedSeafood ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        '$_seafoodVotes (${seafoodPercent.toStringAsFixed(0)}%)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: subColor,
                          fontWeight: votedSeafood ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    Color surfaceColor,
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
          color: surfaceColor.withValues(alpha: 0.95),
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
    Color surfaceColor,
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
          color: surfaceColor.withValues(alpha: 0.95),
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
                        final idx = _phuQuocMessages.indexWhere((m) => m['id'] == _selectedMessageForSticker);
                        if (idx != -1) {
                          if (!(_phuQuocMessages[idx]['reactions'] as List).contains(sticker)) {
                            (_phuQuocMessages[idx]['reactions'] as List).add(sticker);
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
