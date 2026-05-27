import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialMentionNotificationsScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SocialMentionNotificationsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bgGradStart = isDarkMode ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDarkMode ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : Colors.black87;
    final textSecondary = isDarkMode ? Colors.white60 : Colors.black54;

    final primaryColor = isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);

    final List<Map<String, dynamic>> notifications = [
      {
        'user': '@kai_travels',
        'avatar': '🦖',
        'type': 'mention',
        'content': 'mentioned you: "@alex_escapes did you check the Ryokan dinner menu yet? It looks crazy good!"',
        'time': '5 mins ago',
        'trip': 'Kyoto Drift Squad 🛵',
        'unread': true,
      },
      {
        'user': '@sarah_wander',
        'avatar': '🦊',
        'type': 'poll',
        'content': 'added a option to your poll: "Tenryu-ji Garden Coffee Stop 🍵"',
        'time': '1 hour ago',
        'trip': 'Kyoto Drift Squad 🛵',
        'unread': true,
      },
      {
        'user': '@minh_nhat',
        'avatar': '🐱',
        'type': 'mention',
        'content': 'tagged the crew: "@squad we need to split the Grab booking fee of ¥3500 immediately!"',
        'time': '2 hours ago',
        'trip': 'Phú Quốc Escape 🌴',
        'unread': false,
      },
      {
        'user': '@thao_ly',
        'avatar': '🦄',
        'type': 'status',
        'content': 'sent a location ping: "I am literally lost in Gion. Help 😭"',
        'time': '5 hours ago',
        'trip': 'Kyoto Drift Squad 🛵',
        'unread': false,
      }
    ];

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
                          '@ Mentions',
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
                        isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: textPrimary,
                      ),
                      onPressed: onThemeToggle,
                    ),
                  ],
                ),
              ),

              // Sub-info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  'Keep track of your squad callouts & chaos mentions.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notifications List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notify = notifications[index];
                    final isMention = notify['type'] == 'mention';
                    final isPoll = notify['type'] == 'poll';
                    final isUnread = notify['unread'] as bool;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnread 
                            ? primaryColor.withValues(alpha: 0.08) 
                            : cardBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isUnread
                              ? primaryColor.withValues(alpha: 0.3)
                              : (isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                          width: isUnread ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    notify['avatar'] as String,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    notify['user'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isMention 
                                          ? neonPink.withValues(alpha: 0.15) 
                                          : isPoll ? neonCyan.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isMention 
                                          ? 'mention' 
                                          : isPoll ? 'poll' : 'ping',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isMention 
                                            ? neonPink 
                                            : isPoll ? neonCyan : Colors.green,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                notify['time'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notify['content'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '💬 ${notify['trip']}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Jumping to conversation thread in ${notify['trip']}... 🚀'),
                                      backgroundColor: primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Jump to chat',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10,
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
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
}
