import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrendingDiscoveryScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const TrendingDiscoveryScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<TrendingDiscoveryScreen> createState() =>
      _TrendingDiscoveryScreenState();
}

class _TrendingDiscoveryScreenState extends State<TrendingDiscoveryScreen> {
  String _selectedFilter = '🔥 Chaos Mode';

  final List<String> _filters = [
    '🔥 Chaos Mode',
    '☕ Chill',
    '💎 Hidden Gem',
    '💸 Budget',
    '🌿 Nature',
  ];

  final List<Map<String, dynamic>> _trendingCards = [
    {
      'name': 'Night Market Chaos',
      'location': 'Shilin',
      'vibing': '2.3k',
      'badge': '🔥 VIRAL',
      'badgeColor': const Color(0xFFFFB783),
      'gradientA': const Color(0xFFFFB783),
      'gradientB': const Color(0xFFFFB4AB),
    },
    {
      'name': 'Hill Station',
      'location': 'Da Lat',
      'vibing': '1.8k',
      'badge': '💎 HIDDEN GEM',
      'badgeColor': const Color(0xFFD0BCFF),
      'gradientA': const Color(0xFFD0BCFF),
      'gradientB': const Color(0xFF45DFA4),
    },
    {
      'name': 'Hidden Beach',
      'location': 'Phu Quoc',
      'vibing': '987',
      'badge': '🌿 NATURE',
      'badgeColor': const Color(0xFF45DFA4),
      'gradientA': const Color(0xFF45DFA4),
      'gradientB': const Color(0xFFD0BCFF),
    },
    {
      'name': 'Rooftop Chaos',
      'location': 'HCM',
      'vibing': '756',
      'badge': '🔥 VIRAL',
      'badgeColor': const Color(0xFFFFB783),
      'gradientA': const Color(0xFFFFB4AB),
      'gradientB': const Color(0xFFFFB783),
    },
  ];

  final List<bool> _isBookmarked = [false, false, false, false];
  final List<bool> _isLiked = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final bgColor =
        isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final primaryColor =
        isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6D3BD7);
    final secondaryColor =
        isDark ? const Color(0xFF45DFA4) : const Color(0xFF059669);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textMuted =
        isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(isDark, primaryColor, textPrimary, textMuted),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Text(
                      '🔥 what\'s going viral',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Search bar
                    _buildSearchBar(isDark, textMuted),
                    const SizedBox(height: 14),

                    // Filter chips
                    _buildFilterChips(
                        isDark, primaryColor, secondaryColor, textPrimary),
                    const SizedBox(height: 20),

                    // Trending cards
                    ...List.generate(_trendingCards.length, (i) {
                      return _buildTrendingCard(
                        _trendingCards[i],
                        i,
                        isDark,
                        primaryColor,
                        secondaryColor,
                        textPrimary,
                        textMuted,
                      );
                    }),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textMuted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Profile avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD0BCFF), Color(0xFF45DFA4)],
              ),
            ),
            child: const Center(
              child: Text(
                '🧑',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // trip.mate gradient title
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFD0BCFF),
                  Color(0xFF45DFA4),
                  Color(0xFFFFB783),
                ],
              ).createShader(bounds),
              child: Text(
                'trip.mate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Bell icon
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: textPrimary,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications 🔔'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          if (widget.onThemeToggle != null)
            GestureDetector(
              onTap: widget.onThemeToggle,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color textMuted) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: textMuted, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'search for your next core memory...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? secondaryColor.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? secondaryColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1)),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                filter,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? secondaryColor : textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingCard(
    Map<String, dynamic> card,
    int index,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textMuted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image area
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            (card['gradientA'] as Color)
                                .withValues(alpha: 0.4),
                            (card['gradientB'] as Color)
                                .withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.landscape,
                          color: (card['gradientA'] as Color)
                              .withValues(alpha: 0.7),
                          size: 64,
                        ),
                      ),
                    ),

                    // VIRAL badge top-left
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (card['badgeColor'] as Color)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (card['badgeColor'] as Color)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          card['badge'],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: card['badgeColor'],
                          ),
                        ),
                      ),
                    ),

                    // Heart + Bookmark buttons top-right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _buildIconBtn(
                            icon: _isLiked[index]
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isLiked[index]
                                ? const Color(0xFFFFB4AB)
                                : Colors.white,
                            onTap: () => setState(
                                () => _isLiked[index] = !_isLiked[index]),
                          ),
                          const SizedBox(width: 8),
                          _buildIconBtn(
                            icon: _isBookmarked[index]
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _isBookmarked[index]
                                ? primaryColor
                                : Colors.white,
                            onTap: () => setState(() =>
                                _isBookmarked[index] = !_isBookmarked[index]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: textMuted, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            card['location'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${card['vibing']} people vibing',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
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
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
