import 'dart:ui';
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

class _TimelineMemory {
  final String day;
  final String time;
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final String energy;
  final String imageUrl;
  final double angle;
  int likes;
  bool isLiked = false;
  final String music;
  final List<String> hashtags;

  _TimelineMemory({
    required this.day,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.energy,
    required this.imageUrl,
    required this.angle,
    required this.likes,
    required this.music,
    required this.hashtags,
  });
}

class _MemoryTimelineScreenState extends State<MemoryTimelineScreen> {
  final List<_TimelineMemory> _timelineItems = [
    _TimelineMemory(
      day: 'Day 1',
      time: '08:00 AM',
      title: 'soft launch chaos.',
      subtitle: 'literally died here 😭',
      description: 'The squad arrived in Hà Giang. Phu fell off his motorbike within 10 minutes. 92% squad battery remaining but emotional stability at an all-time low.',
      location: 'Hà Giang Loop',
      energy: '92% energy',
      imageUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=500',
      angle: -0.02,
      likes: 42,
      music: '♫ Fred again.. - leavemealone',
      hashtags: ['#HaGiangLoop', '#SoftLaunch', '#Broke'],
    ),
    _TimelineMemory(
      day: 'Day 1',
      time: '02:30 PM',
      title: 'tatami sleep crisis 🍵',
      subtitle: 'Alex is out of service.',
      description: 'Checked into Koto Ryokan. Alex fell asleep on the tatami floor in broad daylight while Sam was complaining about the lack of iced matcha.',
      location: 'Koto Ryokan, Kyoto',
      energy: '48% energy',
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500',
      angle: 0.03,
      likes: 56,
      music: '♫ Pink + White - Frank Ocean',
      hashtags: ['#RyokanSleeps', '#MatchaCrisis', '#KyotoVibes'],
    ),
    _TimelineMemory(
      day: 'Day 2',
      time: '07:15 AM',
      title: 'early bird mental damage 🌅',
      subtitle: 'Cruel but golden reflections.',
      description: 'Woke up the group with a heavy metal solo on the portable JBL speaker to beat the crowd at the Golden Temple. Cruel? Yes. Worth it? Absolutely.',
      location: 'Golden Temple, Kyoto',
      energy: '99% energy',
      imageUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=500',
      angle: -0.04,
      likes: 124,
      music: '♫ Bring Me The Horizon - LosT',
      hashtags: ['#GoldenHour', '#JBLAlarm', '#RiseAndGrind'],
    ),
    _TimelineMemory(
      day: 'Day 2',
      time: '01:00 PM',
      title: ' Nishiki Market bankruptcies 🍢',
      subtitle: 'financial ruin is imminent.',
      description: 'Khang spent half his food budget on custom octopus skewers and sweet potato mochi. Now seeking sponsors for dinner.',
      location: 'Nishiki Market, Tokyo',
      energy: '68% energy',
      imageUrl: 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=500',
      angle: 0.02,
      likes: 83,
      music: '♫ Money - LISA',
      hashtags: ['#StreetFood', '#BrokeInTokyo', '#Octopus🍢'],
    )
  ];

  int _selectedTab = 1; // 0: Explore, 1: Trips (Friends & Profile)
  bool _isStatsPanelOpen = false;

  void _addNewTimelineItem() {
    setState(() {
      _timelineItems.insert(
        0,
        _TimelineMemory(
          day: 'Day 3',
          time: 'Just Now',
          title: 'late night arcade raid 🕹️',
          subtitle: 'main character unlocked.',
          description: 'Cleared three claw machines in Shibuya and bought a giant neon pink teddy bear. The squad is officially out of funds.',
          location: 'Akihabara Arcade',
          energy: '100% energy',
          imageUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=500',
          angle: -0.03,
          likes: 1,
          music: '♫ Tokyo Drift - Teriyaki Boyz',
          hashtags: ['#ArcadeRaid', '#Akihabara', '#TokyoGlow'],
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added arcade memory to squad odyssey timeline!',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF2E93),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgStart = isDark ? const Color(0xFF0C091A) : const Color(0xFFFAF7FF);
    final bgEnd = isDark ? const Color(0xFF04040A) : const Color(0xFFEDE9F5);
    
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E1533);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF16152B) : Colors.white;
    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final neonAmber = const Color(0xFFFFB300);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PREMIUM TIMELINE HEADER (Matching Screen 68 spec)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Interactive menu button (Screen 68 specification)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isStatsPanelOpen = !_isStatsPanelOpen;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.menu, color: textPrimary, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'trip.mate',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  "the squad's odyssey",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Top icons and Toggle theme
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: neonPink),
                              onPressed: _addNewTimelineItem,
                            ),
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                color: textPrimary,
                              ),
                              onPressed: widget.onThemeToggle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Mini Stats Ticker Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: neonPink.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: neonPink.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome, color: neonPink, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'Day 1 to 3',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  4 memories pinned  •  12.4k views',
                          style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // SCROLLABLE TIMELINE LIST (Vintage Cinematic Scrapbook layout)
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                      itemCount: _timelineItems.length,
                      itemBuilder: (context, index) {
                        final item = _timelineItems[index];
                        final isLast = index == _timelineItems.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // TIMELINE CONNECTOR TRACK COLUMN
                              Column(
                                children: [
                                  // Glowing Node icon with indicator emoji
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF22153B) : const Color(0xFFF3EDF7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: item.isLiked ? neonPink : neonCyan,
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (item.isLiked ? neonPink : neonCyan).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        index == 0 ? '✨' : (index == 1 ? '😴' : '🏮'),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  // Cascading connecting line
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 3,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              item.isLiked ? neonPink : neonCyan,
                                              isLast ? Colors.transparent : (index % 2 == 0 ? neonAmber : neonPink),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // CINEMATIC SCRAPBOOK CARD
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Transform.rotate(
                                    angle: item.angle,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Card body
                                        Container(
                                          decoration: BoxDecoration(
                                            color: cardBg,
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: glassBorder, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(22),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // High-Quality image overlay
                                                Image.network(
                                                  item.imageUrl,
                                                  height: 140,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, err, stack) => Container(
                                                    height: 120,
                                                    color: isDark ? Colors.white10 : Colors.black12,
                                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Tag / Time Row
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  color: neonCyan.withValues(alpha: 0.15),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Text(
                                                                  '${item.day}  •  ${item.time}',
                                                                  style: GoogleFonts.plusJakartaSans(
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w800,
                                                                    color: neonCyan,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 6),
                                                              // Bolt energy rating tag (Screen 68 requirement)
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  color: neonAmber.withValues(alpha: 0.15),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(Icons.bolt, color: neonAmber, size: 10),
                                                                    Text(
                                                                      item.energy,
                                                                      style: GoogleFonts.inter(
                                                                        fontSize: 9,
                                                                        color: neonAmber,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          // Location Tag
                                                          Row(
                                                            children: [
                                                              Icon(Icons.location_on, color: neonPink, size: 11),
                                                              const SizedBox(width: 2),
                                                              Text(
                                                                item.location,
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 9,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: textSecondary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),

                                                      // Main Header and "literally died here" subtitle
                                                      Text(
                                                        item.title,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: textPrimary,
                                                        ),
                                                      ),
                                                      Text(
                                                        item.subtitle,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 11,
                                                          color: neonPink,
                                                          fontWeight: FontWeight.bold,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),

                                                      // Body Narrative text
                                                      Text(
                                                        item.description,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          color: textSecondary,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),

                                                      // Music played ticker label
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.music_note, size: 11, color: Colors.grey),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            item.music,
                                                            style: GoogleFonts.inter(
                                                              fontSize: 10,
                                                              color: Colors.grey,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 12),

                                                      // Hashtags
                                                      Wrap(
                                                        spacing: 6,
                                                        children: item.hashtags.map((tag) => Text(
                                                          tag,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            color: neonCyan,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )).toList(),
                                                      ),
                                                      const SizedBox(height: 12),

                                                      // Interactions: Likes & comments
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                item.isLiked = !item.isLiked;
                                                                item.likes += item.isLiked ? 1 : -1;
                                                              });
                                                            },
                                                            child: AnimatedContainer(
                                                              duration: const Duration(milliseconds: 200),
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                              decoration: BoxDecoration(
                                                                color: item.isLiked 
                                                                  ? neonPink.withValues(alpha: 0.15) 
                                                                  : Colors.transparent,
                                                                borderRadius: BorderRadius.circular(12),
                                                                border: Border.all(
                                                                  color: item.isLiked ? neonPink : Colors.transparent,
                                                                ),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    item.isLiked ? Icons.favorite : Icons.favorite_border,
                                                                    color: item.isLiked ? neonPink : Colors.grey,
                                                                    size: 14,
                                                                  ),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    '${item.likes}',
                                                                    style: GoogleFonts.plusJakartaSans(
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: item.isLiked ? neonPink : textSecondary,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 14),
                                                          const Icon(Icons.mode_comment_outlined, size: 14, color: Colors.grey),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '4 replies',
                                                            style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
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

                                        // Tape Sticker Overlay (Cinematic polaroid feel!)
                                        Positioned(
                                          top: -12,
                                          left: 40,
                                          child: Transform.rotate(
                                            angle: -0.1,
                                            child: Container(
                                              width: 60,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.35),
                                                boxShadow: const [
                                                  BoxShadow(color: Colors.black12, blurRadius: 4),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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

              // STATS SIDE-DRAWER SHEET
              if (_isStatsPanelOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isStatsPanelOpen = false;
                      });
                    },
                    child: Container(
                      color: Colors.black54,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: GestureDetector(
                              onTap: () {}, // Prevent tap close-through
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  border: Border(right: BorderSide(color: glassBorder, width: 2)),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      'Trip Analytics 📈',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kyoto Drift Squad Live Vibes',
                                      style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildStatRow('Total Pinned Memories', '24 Pockets', neonCyan),
                                    _buildStatRow('Squad Active Hours', '168 hours', neonPink),
                                    _buildStatRow('Financial Toll (Est)', '\$1,420 spent', neonAmber),
                                    _buildStatRow('Energy levels', '68% Avg', const Color(0xFF45FFA4)),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _isStatsPanelOpen = false;
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                      label: const Text('Back to Odyssey'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: neonPink,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // BOTTOM DOCK NAV BAR (Screen 56/68 specification!)
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? const Color(0xFF141226).withValues(alpha: 0.8) 
                          : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: glassBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, Icons.explore, 'Explore'),
                          // Megatrip highlighted trips tab with neon glow (Screen 68 specification)
                          _buildTripsNavItem(Icons.travel_explore, 'Trips'),
                          _buildNavItem(2, Icons.group, 'Friends'),
                          _buildNavItem(3, Icons.person, 'Profile'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    final isDark = widget.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int idx, IconData icon, String label) {
    final isSel = _selectedTab == idx;
    final activeCol = widget.isDarkMode ? Colors.white : Colors.black87;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = idx;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSel ? activeCol : Colors.grey,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isSel ? activeCol : Colors.grey,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsNavItem(IconData icon, String label) {
    final neonGreen = const Color(0xFF45FFA4);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: neonGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: neonGreen.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: neonGreen.withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: neonGreen,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
