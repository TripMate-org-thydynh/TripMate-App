import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/filters_modal.dart';
import 'place_detail_screen.dart';
import 'ai_vibe_match_screen.dart';

class ExploreDiscoveriesScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const ExploreDiscoveriesScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<ExploreDiscoveriesScreen> createState() => _ExploreDiscoveriesScreenState();
}

class _ExploreDiscoveriesScreenState extends State<ExploreDiscoveriesScreen> {
  final TextEditingController _searchController = TextEditingController(text: 'best chill cafes in Đà Lạt');
  String _activeCategory = '🌿 Chill Cafes';
  bool _isSearching = false;

  final List<String> _categories = [
    '🌿 Chill Cafes',
    '🔥 Nightlife',
    '📸 Hidden Gems',
    '🍜 Foodie',
    '🏕 Adventure',
  ];

  // Curated list mockup
  final List<Map<String, dynamic>> _curatedSquadList = [
    {
      'title': 'Secret Đà Lạt Viewpoint',
      'match': '98%',
      'description': '"This cafe matches your squad\'s chaotic energy perfectly."',
      'saves': 'Minh Nhật and 3 others loved this',
      'emoji': '🌲',
      'gradient': [Color(0xFF8B5CF6), Color(0xFF0D9488)],
    },
    {
      'title': 'Hanoi Street Food Run',
      'match': '95%',
      'description': '"Perfect for late-night bún bò runs with main character energy."',
      'saves': '127 squads visited this week',
      'emoji': '🍜',
      'gradient': [Color(0xFFE0533C), Color(0xFFEBA83A)],
    }
  ];

  // Trending list mockup
  final List<Map<String, dynamic>> _trendingList = [
    {
      'title': 'Pù Luông Hidden Terraces',
      'match': '98%',
      'location': 'Pù Luông',
      'description': 'Escape the crowds. Trek through infinite green valleys and sleep above the clouds. Perfect for the nature squad.',
      'likes': '12k',
      'comments': '342',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=60',
    },
    {
      'title': 'Misty Pine Forests',
      'match': '94%',
      'location': 'Măng Đen',
      'description': 'The \'Da Lat\' without the crowds. Chill vibes, winding forest roads, and cozy cafes.',
      'likes': '8.4k',
      'comments': '156',
      'image': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&auto=format&fit=crop&q=60',
    },
    {
      'title': 'Phú Quốc Night Market',
      'match': '92%',
      'location': 'Phú Quốc',
      'description': 'Seafood, chaotic vibes, and ocean breeze. The ultimate foodie adventure.',
      'likes': '10.5k',
      'comments': '289',
      'image': 'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?w=800&auto=format&fit=crop&q=60',
    }
  ];

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FiltersModal(
        isDarkMode: widget.isDarkMode,
        onApply: (filters) {
          setState(() {
            _searchController.text = "${filters['vibe']} Cafes in Đà Lạt";
            _isSearching = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Applied ${filters['vibe']} Vibe Filter! ⚡"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'discovery.title'.tr(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input with tune icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'discovery.search_hint'.tr(),
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (val) {
                                setState(() {
                                  _isSearching = val.isNotEmpty;
                                });
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _isSearching = false;
                                });
                              },
                              child: const Icon(Icons.clear, color: Colors.grey, size: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _openFilters,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),

            if (_isSearching) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.saved_search, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Search Results for "${_searchController.text}"',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Horizontal Categories Carousel
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _activeCategory == cat;
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 24 : 0,
                      right: index == _categories.length - 1 ? 24 : 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeCategory = cat;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // AI Vibe Match Action Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'discovery.vibe_match_title'.tr(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Analyze squad chemistry and match destinations instantly.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AIVibeMatchScreen(
                              isDarkMode: widget.isDarkMode,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Match',
                          style: GoogleFonts.plusJakartaSans(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Curated Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'discovery.curated_for_squad'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _curatedSquadList.length,
                itemBuilder: (context, index) {
                  final place = _curatedSquadList[index];
                  final gradient = place['gradient'] as List<Color>;
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 24 : 0,
                      right: 16,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailScreen(
                              isDarkMode: widget.isDarkMode,
                              onThemeToggle: widget.onThemeToggle,
                              placeName: place['title'],
                              placeDescription: place['description'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 280,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: gradient),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    place['emoji'],
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'discovery.squad_match'.tr(namedArgs: {'percent': place['match'].replaceAll('%', '')}),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              place['title'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place['description'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              place['saves'],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Trending Feed Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'discovery.trending'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trendingList.length,
              itemBuilder: (context, index) {
                final place = _trendingList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailScreen(
                            isDarkMode: widget.isDarkMode,
                            onThemeToggle: widget.onThemeToggle,
                            placeName: place['title'],
                            placeDescription: place['description'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover photo mockup
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                colors: [primaryColor.withValues(alpha: 0.3), secondaryColor.withValues(alpha: 0.3)],
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(Icons.image_outlined, color: Colors.grey, size: 36),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'discovery.squad_match'.tr(namedArgs: {'percent': place['match'].replaceAll('%', '')}),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 10, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          place['location'],
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place['title'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  place['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.favorite, size: 14, color: primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      place['likes'],
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.mode_comment, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      place['comments'],
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.share, size: 14, color: Colors.grey),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
