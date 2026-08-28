import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../../core/app_messenger.dart';
class ChatSearchScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ChatSearchScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Set<int> _selectedFilters = {0}; // 0 = Chaos Mode selected by default

  // ── Colour tokens ─────────────────────────────────────────────────────────
  static const _darkBg = Color(0xFF1A1712);
  static const _darkSurface = Color(0xFF262019);
  static const _primaryDark = Color(0xFFC9B8FF);
  static const _secondaryDark = Color(0xFF1FA85C);

  static const _lightBg = Color(0xFFFDF6D3);
  static const _primaryLight = Color(0xFF6D3BD7);
  static const _secondaryLight = Color(0xFF059669);

  static const List<Map<String, String>> _trendingItems = [
    {'rank': '1', 'name': 'Night Market Chaos', 'location': 'Shilin'},
    {'rank': '2', 'name': 'Hill Station Cafe', 'location': 'Da Lat'},
    {'rank': '3', 'name': 'Hidden Gem Beach', 'location': 'Phu Quoc'},
    {'rank': '4', 'name': 'Rooftop Chaos', 'location': 'HCM'},
    {'rank': '5', 'name': 'Lantern Night Walk', 'location': 'Hoi An'},
  ];

  static const List<Map<String, String>> _filters = [
    {'label': '🔥 Chaos Mode'},
    {'label': 'Chill Mode ☕'},
    {'label': '💎 Hidden Gem'},
    {'label': '💸 Budget'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final bg = isDark ? _darkBg : _lightBg;
    final surface = isDark ? _darkSurface : Colors.white;
    final primary = isDark ? _primaryDark : _primaryLight;
    final secondary = isDark ? _secondaryDark : _secondaryLight;

    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white54 : Colors.black45;

    final hasQuery = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primary,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Search 🔍',
          style: AppFonts.heading(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: textMuted,
              size: 22,
            ),
            onPressed: () =>
                showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
          ),
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textMuted,
                size: 20,
              ),
              onPressed: widget.onThemeToggle,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: isDark ? 0.5 : 0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: primary, width: 2),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppFonts.body(fontSize: 15, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'search the chaos...',
                      hintStyle: AppFonts.body(
                        fontSize: 15,
                        color: textMuted,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Icon(
                          Icons.search_rounded,
                          color: primary,
                          size: 22,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _query = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 4,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _query = val;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Filter chips ───────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_filters.length, (i) {
                final isSelected = _selectedFilters.contains(i);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedFilters.remove(i);
                      } else {
                        _selectedFilters.add(i);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? secondary.withValues(alpha: 0.2)
                          : surface.withValues(alpha: isDark ? 0.4 : 0.65),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? secondary
                            : primary.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      _filters[i]['label']!,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? secondary : textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // ── Body: trending or empty state ─────────────────────────────
          Expanded(
            child: hasQuery
                ? _EmptyState(textPrimary: textPrimary, textMuted: textMuted)
                : _TrendingSection(
                    isDark: isDark,
                    surface: surface,
                    primary: primary,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    trendingItems: _trendingItems,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Trending section ──────────────────────────────────────────────────────────
class _TrendingSection extends StatelessWidget {
  const _TrendingSection({
    required this.isDark,
    required this.surface,
    required this.primary,
    required this.textPrimary,
    required this.textMuted,
    required this.trendingItems,
  });

  final bool isDark;
  final Color surface;
  final Color primary;
  final Color textPrimary;
  final Color textMuted;
  final List<Map<String, String>> trendingItems;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Header
        Text(
          '🔥 Trending Now',
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...trendingItems.asMap().entries.map((entry) {
          final item = entry.value;
          return _TrendingTile(
            isDark: isDark,
            surface: surface,
            primary: primary,
            textPrimary: textPrimary,
            textMuted: textMuted,
            rank: item['rank']!,
            name: item['name']!,
            location: item['location']!,
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({
    required this.isDark,
    required this.surface,
    required this.primary,
    required this.textPrimary,
    required this.textMuted,
    required this.rank,
    required this.name,
    required this.location,
  });

  final bool isDark;
  final Color surface;
  final Color primary;
  final Color textPrimary;
  final Color textMuted;
  final String rank;
  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.5 : 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Text(
          rank,
          style: AppFonts.body(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: primary,
          ),
        ),
        title: Text(
          name,
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            const Text('📍', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 3),
            Text(
              location,
              style: AppFonts.body(fontSize: 12, color: textMuted),
            ),
          ],
        ),
        trailing: Icon(
          Icons.trending_up_rounded,
          color: primary.withValues(alpha: 0.6),
          size: 20,
        ),
        onTap: () => showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textPrimary, required this.textMuted});

  final Color textPrimary;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👻', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(
            'No chaos found.',
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try something less specific, bestie.',
            style: AppFonts.body(fontSize: 14, color: textMuted),
          ),
        ],
      ),
    );
  }
}
