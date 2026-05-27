import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryTimelineScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MemoryTimelineScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MemoryTimelineScreen> createState() => _MemoryTimelineScreenState();
}

class _MemoryTimelineScreenState extends State<MemoryTimelineScreen> {
  final List<Map<String, dynamic>> _timelineItems = [
    {
      'day': 'Day 1',
      'title': 'Koto Ryokan Arrival 🍵',
      'time': '02:15 PM',
      'tag': 'Check-In Vibe',
      'desc': 'Alex fell asleep on the tatami mats within 4 minutes. True slacker energy.',
      'url': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500',
      'likes': 12,
      'emoji': '😴',
    },
    {
      'day': 'Day 1',
      'title': 'Kyoto Night Walk 🏮',
      'time': '08:30 PM',
      'tag': 'City Glow',
      'desc': 'Discovered a hidden alley with red paper lanterns and a tiny ramen shop.',
      'url': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=500',
      'likes': 19,
      'emoji': '🏮',
    },
    {
      'day': 'Day 2',
      'title': 'Golden Temple Beat Crowds ⛩️',
      'time': '06:45 AM',
      'tag': 'Early Bird',
      'desc': 'Woke up the squad by playing heavy metal on the Bluetooth speaker. Cruel but gold reflections.',
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=500',
      'likes': 24,
      'emoji': '🌅',
    },
    {
      'day': 'Day 2',
      'title': 'Lost in Nishiki Market 🍢',
      'time': '01:00 PM',
      'tag': 'Food Craze',
      'desc': 'Khang spent 300k VND on octopus skewers and got lost looking for bubble tea.',
      'url': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=500',
      'likes': 15,
      'emoji': '🐙',
    }
  ];

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
                          'Memory Timeline 📅',
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Chronological stream of your travel squad chaos.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Timeline List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _timelineItems.length,
                  itemBuilder: (context, index) {
                    final item = _timelineItems[index];
                    final isLast = index == _timelineItems.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Time dots and cascading line columns
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    item['emoji'] as String,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Content card details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image top cover
                                      Image.network(
                                        item['url'] as String,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const SizedBox(height: 100, child: Center(child: Icon(Icons.broken_image)));
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: neonCyan.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${item['day']} • ${item['time']}',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: neonCyan,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  item['tag'] as String,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item['title'] as String,
                                              style: GoogleFonts.outfit(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['desc'] as String,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Reactions and comments count
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Liked this timeline entry! ❤️✨'),
                                                        duration: Duration(milliseconds: 600),
                                                        behavior: SnackBarBehavior.floating,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.favorite, color: neonPink, size: 16),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${item['likes']}',
                                                        style: GoogleFonts.outfit(
                                                          color: textPrimary,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                const Icon(Icons.mode_comment_outlined, color: Colors.grey, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '3 comments',
                                                  style: GoogleFonts.outfit(color: textSecondary, fontSize: 11),
                                                ),
                                              ],
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
