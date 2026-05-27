import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/filters_modal.dart';
import '../widgets/add_to_itinerary_sheet.dart';
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
  int _activeTab = 0; // 0: Snaps Feed, 1: Vibe Match, 2: Hidden Gems
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController(text: 'best chill cafes in Đà Lạt');

  // Interactivity states
  final List<bool> _isFavorited = [false, false];
  String _selectedCategoryFilter = 'discovery.category_chill';

  final List<Map<String, dynamic>> _trendingList = [
    {
      'title': 'Hidden Terraces',
      'match': '98%',
      'isMatch': true,
      'location': 'Pù Luông, Vietnam',
      'description': 'Escape the crowds. Trek through infinite green valleys and sleep above the clouds. Perfect for the nature squad.',
      'likes': '12k',
      'comments': '342',
      'tags': ['🌿 Nature', '🥾 Trekking', '📸 Aesthetic'],
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Misty Pine Forests',
      'match': 'Trending Now',
      'isMatch': false,
      'location': 'Măng Đen, Vietnam',
      'description': "The 'Da Lat' without the crowds. Chill vibes, winding forest roads, and cozy cafes.",
      'likes': '8.4k',
      'comments': '156',
      'tags': ['🌿 Chill', '🌲 Pine Forest', '📸 Aesthetic'],
      'image': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=1080&auto=format&fit=crop&q=80',
    },
  ];

  final List<Map<String, dynamic>> _vibeSpots = [
    {
      'title': 'Hanoi Street Food',
      'location': 'Old Quarter, Hanoi',
      'match': '96% match',
      'image': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600&auto=format&fit=crop&q=80',
      'vibe': '🔥 Nightlife & Foodie',
    },
    {
      'title': 'Secret Falls, Bali',
      'location': 'Ubud, Bali',
      'match': '92% match',
      'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600&auto=format&fit=crop&q=80',
      'vibe': '🌿 Chill & Adventure',
    },
    {
      'title': 'Tokyo Underground',
      'location': 'Shinjuku, Tokyo',
      'match': '98% match',
      'image': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600&auto=format&fit=crop&q=80',
      'vibe': '📸 Iconic & Party',
    },
  ];

  final List<Map<String, dynamic>> _curatedEcosystem = [
    {
      'title': 'Secret Đà Lạt Viewpoint',
      'location': 'Đà Lạt, Vietnam',
      'match': '98% match',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600&auto=format&fit=crop&q=80',
      'desc': 'Trốn khỏi khói bụi thành phố, ngắm trọn hoàng hôn bên rừng thông Đà Lạt chill đỉnh chóp.',
    },
    {
      'title': 'The Hill Station Cafe',
      'location': 'Sapa, Vietnam',
      'match': '94% match',
      'image': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
      'desc': 'Vintage style cafe inside Sapa fog. Highly romanticized vibes with great espresso drafts.',
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

  void _showAddToTripSheet(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToItinerarySheet(
        placeName: place['title'],
        placeAddress: place['location'],
        isDarkMode: widget.isDarkMode,
        onAdded: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Added ${place['title']} to Day ${data['day']}! 🎒"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: widget.isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final bgColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;

    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Sliding body based on _activeTab state
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 124),
            child: _buildActiveContent(isDark, primaryColor, secondaryColor, surfaceColor, textPrimary, textSecondary),
          ),

          // 2. Translucent Segment Tab Header Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 20,
                    right: 20,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.65),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Branding & Top Action Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: isDark
                                      ? [const Color(0xFFD0BCFF), const Color(0xFF45DFA4)]
                                      : [const Color(0xFF8B5CF6), const Color(0xFFE0533C)],
                                ).createShader(bounds),
                                child: Text(
                                  'trip.mate',
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
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
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.auto_awesome, size: 12, color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Notification bell trigger for Activity Hub
                              IconButton(
                                icon: Icon(Icons.notifications_none, color: textPrimary, size: 22),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Checking squad notifications hub... 🔔')),
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: widget.onThemeToggle,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                    color: textPrimary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Beautiful Horizontal Sliding Tabs
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            _buildTabItem(0, '🎬 Snaps Feed', primaryColor),
                            _buildTabItem(1, '🔍 AI Search', primaryColor),
                            _buildTabItem(2, '🌿 Hidden Gems', primaryColor),
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
  }

  Widget _buildTabItem(int index, String title, Color activeBgColor) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeBgColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Swapper content
  Widget _buildActiveContent(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    switch (_activeTab) {
      case 0:
        // Snaps PageView
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _trendingList.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final place = _trendingList[index];
            return _buildFeedCard(place, index, isDark, primaryColor, secondaryColor, surfaceColor);
          },
        );
      case 1:
        // AI Search & Vibe Matching (Screen 21)
        return _buildSearchMode(isDark, primaryColor, secondaryColor, surfaceColor, textPrimary, textSecondary);
      case 2:
        // Discovery Ecosystem (Screen 28)
        return _buildDiscoveryEcosystem(isDark, primaryColor, secondaryColor, surfaceColor, textPrimary, textSecondary);
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. Snaps vertical feed renderer (Original Screen 7)
  Widget _buildFeedCard(
    Map<String, dynamic> place,
    int index,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color surfaceColor,
  ) {
    final isFav = _isFavorited[index];

    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            place['image'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (place['isMatch'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text('98% Squad Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: secondaryColor.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text('Trending Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: secondaryColor, size: 16),
                          const SizedBox(width: 6),
                          Text(place['location'], style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(place['title'], style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(place['description'], maxLines: 3, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: (place['tags'] as List<String>).map((tag) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSidebarButton(
                      icon: isFav ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFav ? Colors.redAccent : Colors.white,
                      label: place['likes'],
                      onTap: () => setState(() => _isFavorited[index] = !isFav),
                    ),
                    const SizedBox(height: 20),
                    _buildSidebarButton(
                      icon: Icons.mode_comment_outlined,
                      iconColor: Colors.white,
                      label: place['comments'],
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    _buildSidebarButton(icon: Icons.send_outlined, iconColor: Colors.white, label: 'Share', onTap: () {}),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => _showAddToTripSheet(place),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 6),
                          Text('Add to Trip', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarButton({required IconData icon, required Color iconColor, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 2. AI Vibe Match Search Mode (Screen 21)
  Widget _buildSearchMode(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'discovery.where_to_next'.tr(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.normal,
              color: textSecondary,
            ),
          ),
          Text(
            'discovery.chaotic_squad'.tr(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Vibe capsule search field
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ask AI: best aesthetic spots...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  onPressed: _openFilters,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibes list matches',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
              ),
              Text(
                'See all',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vibes horizontally scrollable cards list
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _vibeSpots.length,
              itemBuilder: (context, index) {
                final spot = _vibeSpots[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(spot['image'], fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    spot['match'],
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(spot['vibe'], style: TextStyle(color: primaryColor, fontSize: 8, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(spot['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(spot['location'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. AI Hidden Gems Discovery Ecosystem (Screen 28)
  Widget _buildDiscoveryEcosystem(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final List<String> categories = ['🌿 Chill Cafes', '🔥 Nightlife', '📸 Hidden Gems', '🍜 Foodie', '🏕 Adventure'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category row scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryFilter = cat;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Curated for Squad
          Text(
            'Curated for your squad',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Big gem card
          ..._curatedEcosystem.map((gem) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(gem['image'], fit: BoxFit.cover),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                gem['match'],
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gem['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(gem['desc'], style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(gem['location'], style: TextStyle(color: secondaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: () => _showAddToTripSheet(gem),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Add to Trip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          // Section 2: Trending Near You
          Text(
            'Trending Near You',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Trending Dalat Market item card
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: const Text('Night Market Chaos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Dalat Old Market • 1.2k squad votes', style: TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
