import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedPlacesScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SavedPlacesScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _squadWants = [
    {
      'name': 'Hill Station',
      'location': 'Da Lat',
      'match': 95,
      'gradientStart': const Color(0xFFD0BCFF),
      'gradientEnd': const Color(0xFF45DFA4),
    },
    {
      'name': 'Night Market Chaos',
      'location': 'Shilin',
      'match': 88,
      'gradientStart': const Color(0xFFFFB783),
      'gradientEnd': const Color(0xFFFFB4AB),
    },
    {
      'name': 'Hidden Beach',
      'location': 'Phu Quoc',
      'match': 76,
      'gradientStart': const Color(0xFF45DFA4),
      'gradientEnd': const Color(0xFFD0BCFF),
    },
    {
      'name': 'Rooftop Cafe',
      'location': 'HCM',
      'match': 71,
      'gradientStart': const Color(0xFFFFB783),
      'gradientEnd': const Color(0xFF45DFA4),
    },
  ];

  final List<Map<String, dynamic>> _soloDreams = [
    {
      'name': 'Secret Forest Cafe',
      'location': 'Da Lat',
      'match': 92,
      'gradientStart': const Color(0xFF45DFA4),
      'gradientEnd': const Color(0xFFD0BCFF),
    },
    {
      'name': 'Lan Ha Bay',
      'location': 'Quang Ninh',
      'match': 87,
      'gradientStart': const Color(0xFFD0BCFF),
      'gradientEnd': const Color(0xFFFFB783),
    },
    {
      'name': 'Ancient Town',
      'location': 'Hoi An',
      'match': 83,
      'gradientStart': const Color(0xFFFFB783),
      'gradientEnd': const Color(0xFF45DFA4),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final bgColor =
        isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;
    final primaryColor =
        isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6D3BD7);
    final secondaryColor =
        isDark ? const Color(0xFF45DFA4) : const Color(0xFF059669);
    final errorColor = const Color(0xFFFFB4AB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textMuted =
        isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add a new place to your list! 📍'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: secondaryColor,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: Text(
          'Add Place',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(isDark, primaryColor, textPrimary),

            // TabBar
            _buildTabBar(isDark, primaryColor, secondaryColor, textMuted),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGrid(
                    _squadWants,
                    isDark,
                    surfaceColor,
                    primaryColor,
                    secondaryColor,
                    errorColor,
                    textPrimary,
                    textMuted,
                  ),
                  _buildGrid(
                    _soloDreams,
                    isDark,
                    surfaceColor,
                    primaryColor,
                    secondaryColor,
                    errorColor,
                    textPrimary,
                    textMuted,
                  ),
                ],
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
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isDark
                    ? [const Color(0xFFD0BCFF), const Color(0xFF45DFA4)]
                    : [const Color(0xFF6D3BD7), const Color(0xFF059669)],
              ).createShader(bounds),
              child: Text(
                'Saved Places ❤️',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: primaryColor, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing your wishlist! 🔗'),
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

  Widget _buildTabBar(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color textMuted,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: secondaryColor,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        labelColor: secondaryColor,
        unselectedLabelColor: textMuted,
        tabs: const [
          Tab(text: 'Squad Wants'),
          Tab(text: 'Solo Dreams'),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<Map<String, dynamic>> places,
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color secondaryColor,
    Color errorColor,
    Color textPrimary,
    Color textMuted,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: places.map((place) {
        return _buildPlaceCard(
          place,
          isDark,
          surfaceColor,
          primaryColor,
          secondaryColor,
          errorColor,
          textPrimary,
          textMuted,
        );
      }).toList(),
    );
  }

  Widget _buildPlaceCard(
    Map<String, dynamic> place,
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color secondaryColor,
    Color errorColor,
    Color textPrimary,
    Color textMuted,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area with heart button
              Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          (place['gradientStart'] as Color)
                              .withValues(alpha: 0.3),
                          (place['gradientEnd'] as Color)
                              .withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.landscape_outlined,
                        color: (place['gradientStart'] as Color)
                            .withValues(alpha: 0.6),
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${place['name']} removed ❌'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: errorColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: errorColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: errorColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom info section
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '📍 ${place['location']}',
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
                        '⚡ ${place['match']}% Vibe Match',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
