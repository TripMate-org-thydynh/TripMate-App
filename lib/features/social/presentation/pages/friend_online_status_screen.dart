import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendOnlineStatusScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const FriendOnlineStatusScreen({
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

    final neonCyan = const Color(0xFF00F5FF);

    final List<Map<String, String>> friends = [
      {
        'name': 'Nam Trung 🦖',
        'username': '@nam_trung',
        'status': '🟢 Online Now',
        'distance': '120m away • heading to Still Cafe',
        'lastSeen': 'Just now',
        'avatar': '🦖',
      },
      {
        'name': 'Minh Nhật 🐱',
        'username': '@minh_nhat',
        'status': '🟢 Online Now',
        'distance': '450m away • at Ryokan Koto',
        'lastSeen': '1 min ago',
        'avatar': '🐱',
      },
      {
        'name': 'Thảo Ly 🦄',
        'username': '@thao_ly',
        'status': '🟡 In Trip • Away',
        'distance': '1.2km away • exploring Gion shops',
        'lastSeen': '15 mins ago',
        'avatar': '🦄',
      },
      {
        'name': 'Sarah Phú 🦊',
        'username': '@sarah_wander',
        'status': '🔴 Offline',
        'distance': 'Not sharing location',
        'lastSeen': '3 hours ago',
        'avatar': '🦊',
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
              // Header Settings Bar
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
                          'Friend Presence',
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  'Real-time distance tracking and status of your active squad mates.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isOnline = friend['status']!.contains('🟢');
                    final isAway = friend['status']!.contains('🟡');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            friend['avatar']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      friend['name']!,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isOnline 
                                            ? Colors.green.withValues(alpha: 0.15) 
                                            : isAway ? Colors.amber.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isOnline 
                                            ? 'online' 
                                            : isAway ? 'away' : 'offline',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: isOnline 
                                              ? Colors.green 
                                              : isAway ? Colors.amber : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  friend['distance']!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Last seen: ${friend['lastSeen']}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: textSecondary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.near_me_outlined, color: neonCyan),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Pinging location for ${friend['name']} on live map... 🗺️')),
                                  );
                                },
                              ),
                              Text(
                                'Ping',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: neonCyan,
                                ),
                              ),
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
