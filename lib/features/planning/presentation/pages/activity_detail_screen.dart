import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityDetailScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final String title;
  final String time;
  final String location;
  final String description;
  final Color themeColor;

  const ActivityDetailScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.title,
    required this.time,
    required this.location,
    required this.description,
    required this.themeColor,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  int _activeTab = 0; // 0: Intel & Crowd, 1: Food & Menu, 2: Squad Vibe
  bool _joinedWaitlist = false;

  final List<Map<String, String>> _menuItems = [
    {
      'name': 'Matcha Shaved Ice 🍧',
      'price': '¥850',
      'desc': 'Uji matcha syrup, sweet red bean paste, and hand-pounded mochi.',
      'tag': 'Best Seller'
    },
    {
      'name': 'Dango Kyoto Style 🍡',
      'price': '¥450',
      'desc': 'Sweet soy glaze sweet rice dumplings, grilled over white charcoal.',
      'tag': 'Local'
    },
    {
      'name': 'Cold Brew Hojicha 🍵',
      'price': '¥600',
      'desc': 'Roasted green tea brewed cold for 12 hours. Super nutty flavor.',
      'tag': 'Vegan'
    },
  ];

  final List<Map<String, dynamic>> _squadIntel = [
    {
      'user': '@sarah_wander',
      'avatar': '🦊',
      'vibe': 'Total aesthetic dream, crowd is 8/10 busy, go around sunset for peak neon shadows!'
    },
    {
      'user': '@kai_travels',
      'avatar': '🦖',
      'vibe': 'Food menu is a bit pricey but the matcha shaved ice is 10/10 worth it. Super chill staff!'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = widget.themeColor;
    final secondaryColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFFEBA83A);

    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF1E1E2F) : const Color(0xFFF0EAE1);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

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
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Beautiful Custom Glassmorphic Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Activity Details',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
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
                ),
              ),

              // Image & Key Info Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              widget.time,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '🟢 Open Now',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: primaryColor, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.location,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Selection (Glassmorphic Segmented Control)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cardBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, '📊 Intel'),
                      _buildTabItem(1, '🍱 Menu'),
                      _buildTabItem(2, '💬 Squad Vibe'),
                    ],
                  ),
                ),
              ),

              // Dynamic Tab Contents
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _activeTab == 0
                    ? _buildIntelTab(isDark, cardBg, textPrimary, textSecondary, primaryColor)
                    : _activeTab == 1
                        ? _buildMenuTab(isDark, cardBg, textPrimary, textSecondary, primaryColor)
                        : _buildSquadVibeTab(isDark, cardBg, textPrimary, textSecondary, primaryColor),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _joinedWaitlist = !_joinedWaitlist;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _joinedWaitlist
                      ? '🎟️ Squad successfully registered on waitlist!'
                      : '🎟️ Canceled waitlist registration.',
                ),
                backgroundColor: primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _joinedWaitlist
                    ? [Colors.grey, Colors.blueGrey]
                    : [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _joinedWaitlist ? Icons.check_circle : Icons.confirmation_number,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  _joinedWaitlist ? 'You\'re on the list!' : 'Book Squad Pass / Join Waitlist',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _activeTab == index;
    final isDark = widget.isDarkMode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.themeColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // INTEL & CROWD TAB
  Widget _buildIntelTab(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Text(
          '⚡ Live Crowd Heatmap',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Crowd gauge
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: Semi-Busy 👾',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    'Wait Time: ~15 mins',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Simulated heatmap bars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final listHeight = [20, 35, 60, 85, 90, 45, 15][index];
                  final isCurrentHour = index == 4;
                  return Column(
                    children: [
                      Container(
                        height: 90,
                        width: 25,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          height: listHeight.toDouble(),
                          width: 25,
                          decoration: BoxDecoration(
                            color: isCurrentHour
                                ? themeColor
                                : themeColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ['12p', '2p', '4p', '6p', '8p', '10p', '12a'][index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: isCurrentHour ? themeColor : textSecondary,
                          fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                        ),
                      )
                    ],
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          '📍 Quick Address Card',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.map_outlined, color: themeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shijodori Gion-machi, Kyoto',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3-minute walk from Gion-Shijo Subway exit 4.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // FOOD & MENU TAB
  Widget _buildMenuTab(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _menuItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name']!,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            item['price']!,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['desc']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['tag']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        childCount: _menuItems.length,
      ),
    );
  }

  // SQUAD VIBE INTEL
  Widget _buildSquadVibeTab(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color themeColor,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Text(
          '✨ Live Matey AI Vibe Roasted Comments',
          style: GoogleFonts.caveat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Text(
                '🤖',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '"Oh honey, this place is so cute it almost makes me forget you all argued for 40 minutes about which route has the cheapest train tickets. Go grab that matcha!"',
                  style: GoogleFonts.caveat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                    height: 1.3,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '💬 Active Squad Member Intel',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._squadIntel.map((intel) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intel['avatar'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intel['user'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intel['vibe'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ]),
    );
  }
}
