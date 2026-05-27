import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StickerReactionTray extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const StickerReactionTray({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<StickerReactionTray> createState() => _StickerReactionTrayState();
}

class _StickerReactionTrayState extends State<StickerReactionTray>
    with SingleTickerProviderStateMixin {
  String _activeCategory = 'Recent';
  String _searchQuery = '';
  bool _isSearching = false;
  double _reactionEnergyScale = 1.0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Recent', 'icon': Icons.schedule_rounded},
    {'name': 'Trending', 'icon': Icons.local_fire_department_rounded},
    {'name': 'Memories', 'icon': Icons.photo_library_rounded},
    {'name': 'Chaos', 'icon': Icons.tornado_rounded},
    {'name': 'Gems', 'icon': Icons.diamond_rounded},
  ];

  final List<Map<String, dynamic>> _trendingStickers = [
    {
      'title': 'moving',
      'icon': Icons.directions_run_rounded,
      'emoji': '🏃‍♂️💨',
      'color': Color(0xFF38BDF8),
    },
    {
      'title': 'financially ruined',
      'icon': Icons.account_balance_wallet_rounded,
      'emoji': '💸📉',
      'color': Color(0xFFF43F5E),
    },
    {
      'title': 'main character energy',
      'icon': Icons.workspace_premium_rounded,
      'emoji': '👑✨',
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'cafe addiction',
      'icon': Icons.coffee_rounded,
      'emoji': '☕🫠',
      'color': Color(0xFF10B981),
    },
    {
      'title': 'grab ate my budget',
      'icon': Icons.directions_car_rounded,
      'emoji': '🚕💔',
      'color': Color(0xFF8B5CF6),
    },
  ];

  final List<Map<String, dynamic>> _customMemes = [
    {
      'title': 'THE AUDACITY',
      'text': '💅 THE AUDACITY',
      'color': Color(0xFFEC4899),
    },
    {
      'title': 'ded.',
      'text': '💀 ded.',
      'color': Color(0xFF6B7280),
    },
  ];

  static const _darkSurface = Color(0xFF0F172A);
  static const _darkCard = Color(0xFF1E293B);
  static const _primaryDark = Color(0xFFD0BCFF);
  static const _secondaryDark = Color(0xFF45DFA4);

  static const _lightSurface = Color(0xFFFCFAF6);
  static const _lightCard = Colors.white;
  static const _primaryLight = Color(0xFF6D3BD7);
  static const _secondaryLight = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final surfaceColor = isDark ? _darkSurface : _lightSurface;
    final cardColor = isDark ? _darkCard : _lightCard;
    final primary = isDark ? _primaryDark : _primaryLight;
    final secondary = isDark ? _secondaryDark : _secondaryLight;

    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: isDark ? 0.8 : 0.92),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Drag Indicator
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Title Header Row
              _buildHeader(isDark, textPrimary, primary),

              // Category scrollview
              _buildCategoriesList(isDark, cardColor, primary, secondary, textPrimary, textMuted),

              const SizedBox(height: 16),

              // Main body containing stickers grid
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Trending
                      _buildSectionHeader('Trending', textPrimary),
                      const SizedBox(height: 12),
                      _buildTrendingGrid(isDark, cardColor, textPrimary, textMuted),

                      const SizedBox(height: 24),

                      // Section 2: Squad Custom Custom Meme stickers
                      _buildSectionHeader('Squad Custom', textPrimary, showAddButton: true),
                      const SizedBox(height: 12),
                      _buildCustomSquadGrid(isDark, cardColor, textPrimary, textMuted),

                      const SizedBox(height: 32),

                      // Action Button: reaction energy unlocked
                      _buildActionButton(isDark, primary, secondary),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color textPrimary, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // [h1] express the chaos.
          _isSearching
              ? Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      autofocus: true,
                      style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'search stickers...',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: textPrimary.withValues(alpha: 0.4)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                )
              : Text(
                  'express the chaos.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
          const SizedBox(width: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, color: textPrimary),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    _searchQuery = '';
                  });
                },
                tooltip: 'search',
              ),
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              // [Interactive] Text: "close"
              IconButton(
                icon: Icon(Icons.close_rounded, color: textPrimary),
                onPressed: () => Navigator.maybePop(context),
                tooltip: 'close',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
      bool isDark, Color cardColor, Color primary, Color secondary, Color textPrimary, Color textMuted) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final catName = cat['name'] as String;
          final catIcon = cat['icon'] as IconData;
          final isActive = _activeCategory == catName;

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeCategory = catName;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? secondary.withValues(alpha: 0.2) : cardColor.withValues(alpha: isDark ? 0.4 : 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? secondary : primary.withValues(alpha: 0.1),
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.15),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    catIcon,
                    size: 16,
                    color: isActive ? secondary : textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    catName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? secondary : textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textPrimary, {bool showAddButton = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        if (showAddButton)
          GestureDetector(
            onTap: () {
              // Simulate adding custom stickers
              setState(() {
                _customMemes.add({
                  'title': 'NO CAP',
                  'text': '🧢 NO CAP',
                  'color': const Color(0xFFF59E0B),
                });
              });
            },
            child: Row(
              children: [
                const Icon(Icons.add_rounded, size: 16, color: Colors.greenAccent),
                const SizedBox(width: 4),
                Text(
                  'New Meme',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'View All',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textPrimary.withValues(alpha: 0.4),
              letterSpacing: 0.5,
            ),
          ),
      ],
    );
  }

  Widget _buildTrendingGrid(bool isDark, Color cardColor, Color textPrimary, Color textMuted) {
    final filtered = _trendingStickers.where((st) {
      if (_searchQuery.isEmpty) return true;
      return st['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No stickers match search.', style: GoogleFonts.inter(color: textMuted)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final Color themeColor = item['color'] as Color;

        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sticker selected: ${item['title']}'),
                duration: const Duration(seconds: 1),
                backgroundColor: themeColor,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: isDark ? 0.45 : 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: themeColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Sticker Emoji/Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    item['emoji'] as String,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomSquadGrid(bool isDark, Color cardColor, Color textPrimary, Color textMuted) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _customMemes.length,
        itemBuilder: (context, index) {
          final item = _customMemes[index];
          final Color themeColor = item['color'] as Color;

          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected custom meme: ${item['title']}'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: themeColor,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: isDark ? 0.45 : 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  item['text'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(bool isDark, Color primary, Color secondary) {
    // [Interactive] Text: "boltreaction energy unlocked"
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _reactionEnergyScale = 0.95;
        });
      },
      onTapUp: (_) {
        setState(() {
          _reactionEnergyScale = 1.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Reaction Energy Unlocked! Go wild, bestie.'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
      },
      child: AnimatedScale(
        scale: _reactionEnergyScale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [primary, secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'reaction energy unlocked',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
