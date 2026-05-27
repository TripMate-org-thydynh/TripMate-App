import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiExploreSearchScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AiExploreSearchScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<AiExploreSearchScreen> createState() => _AiExploreSearchScreenState();
}

class _AiExploreSearchScreenState extends State<AiExploreSearchScreen> {
  String _selectedFilter = '🔥 Chaos Mode';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    '🔥 Chaos Mode',
    '☕ Chill',
    '💎 Hidden Gem',
    '💸 Budget',
  ];

  final List<String> _hashtags = [
    '#DaLatVibes',
    '#NightMarket',
    '#HiddenGem',
    '#SquadGoals',
    '#ChaosMode',
  ];

  final List<Map<String, dynamic>> _results = [
    {
      'name': 'Hill Station',
      'location': 'Da Lat',
      'match': 95,
      'gradientA': const Color(0xFFD0BCFF),
      'gradientB': const Color(0xFF45DFA4),
    },
    {
      'name': 'Night Market Chaos',
      'location': 'Shilin',
      'match': 88,
      'gradientA': const Color(0xFFFFB783),
      'gradientB': const Color(0xFFFFB4AB),
    },
    {
      'name': 'Hidden Gem Cafe',
      'location': 'Hoi An',
      'match': 76,
      'gradientA': const Color(0xFF45DFA4),
      'gradientB': const Color(0xFFD0BCFF),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final surfaceVariant = isDark
        ? const Color(0xFF171F33)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(isDark, primaryColor, textPrimary),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 1. AI Search Bar
                    _buildAiSearchBar(isDark, primaryColor, textMuted),
                    const SizedBox(height: 14),

                    // 2. Filter chips
                    _buildFilterChips(
                        isDark, primaryColor, secondaryColor, textPrimary),
                    const SizedBox(height: 16),

                    // 3. Trending hashtags
                    _buildHashtags(
                        isDark, primaryColor, surfaceVariant, textMuted),
                    const SizedBox(height: 22),

                    // 4. AI Results header
                    Text(
                      'AI Vibe Matches ⚡',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. Result cards
                    ..._results.map(
                      (result) => _buildResultCard(
                        result,
                        isDark,
                        primaryColor,
                        secondaryColor,
                        textPrimary,
                        textMuted,
                      ),
                    ),

                    // 6. Discover More button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Loading more vibes... 🌍'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          'Discover More →',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color primaryColor, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Explore ✨',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.auto_awesome, color: primaryColor, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI vibe matching activated ✨'),
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

  Widget _buildAiSearchBar(bool isDark, Color primaryColor, Color textMuted) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.stars_outlined, color: primaryColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'find your vibe...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: textMuted,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _searchController.text.isEmpty
                            ? 'Type something first! 💡'
                            : 'Searching for "${_searchController.text}"... ⚡',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: primaryColor,
                    size: 18,
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
                    ? primaryColor.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
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
                  color: isSelected ? primaryColor : textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHashtags(
    bool isDark,
    Color primaryColor,
    Color surfaceVariant,
    Color textMuted,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _hashtags.map((tag) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultCard(
    Map<String, dynamic> result,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textMuted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
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
            child: Row(
              children: [
                // Gradient image box
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        (result['gradientA'] as Color)
                            .withValues(alpha: 0.5),
                        (result['gradientB'] as Color)
                            .withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.landscape,
                    color: (result['gradientA'] as Color)
                        .withValues(alpha: 0.8),
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${result['location']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Vibe Match badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⚡ ${result['match']}% Vibe Match',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
