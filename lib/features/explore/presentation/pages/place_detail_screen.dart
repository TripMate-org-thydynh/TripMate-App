import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String? placeName;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const PlaceDetailScreen({
    super.key,
    this.placeName,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen>
    with TickerProviderStateMixin {
  bool _isSaved = false;
  bool _isAdded = false;
  int _selectedTab = 0;
  late AnimationController _saveController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _saveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFFD0BCFF) : const Color(0xFF7C3AED);
    final secondaryColor = isDark ? const Color(0xFF45DFA4) : const Color(0xFF059669);
    final bgColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // FULLSCREEN HERO IMAGE
          Positioned(
            top: 0, left: 0, right: 0,
            height: 340,
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 340,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: primaryColor.withValues(alpha: 0.2),
                    child: Center(child: Icon(Icons.landscape, size: 80, color: primaryColor)),
                  ),
                ),
                // Gradient over image
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SCROLL BODY
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // GLASS HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                      // Save button
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _isSaved = !_isSaved);
                              _saveController.forward().then((_) => _saveController.reverse());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _isSaved ? Colors.red.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Icon(
                                _isSaved ? Icons.favorite : Icons.favorite_border,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SCROLLABLE CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 220),
                        // WHITE SHEET
                        Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              // PLACE NAME
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.placeName ?? 'The Hill Station',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              color: textPrimary,
                                              letterSpacing: -0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, size: 14, color: textMuted),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Đà Lạt, Lâm Đồng',
                                                style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Rating & Reviews
                                          Row(
                                            children: [
                                              ...List.generate(5, (i) => Icon(
                                                i < 4 ? Icons.star : Icons.star_half,
                                                size: 16,
                                                color: Colors.amber[500],
                                              )),
                                              const SizedBox(width: 8),
                                              Text(
                                                '4.8  ·  2,341 reviews',
                                                style: GoogleFonts.inter(fontSize: 13, color: textMuted, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Crew Match Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                                      ),
                                      child: Column(
                                        children: [
                                          Text('🧠', style: const TextStyle(fontSize: 20)),
                                          Text(
                                            'Matey Pick',
                                            style: GoogleFonts.inter(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // TABS
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  children: ['Overview', 'Photos', 'Reviews'].asMap().entries.map((e) {
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedTab = e.key),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                        decoration: BoxDecoration(
                                          color: _selectedTab == e.key
                                              ? primaryColor
                                              : isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          e.value,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _selectedTab == e.key ? Colors.white : textMuted,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // INFO PILLS ROW
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  children: [
                                    _buildPill('🕘', 'Open Now', Colors.green, isDark),
                                    const SizedBox(width: 10),
                                    _buildPill('💰', '150k - 400k ₫', primaryColor, isDark),
                                    const SizedBox(width: 10),
                                    _buildPill('🕑', '2h avg stay', Colors.amber[600]!, isDark),
                                    const SizedBox(width: 10),
                                    _buildPill('🅿️', 'Free Parking', primaryColor, isDark),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // DESCRIPTION
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  'The Hill Station is a Dalat landmark celebrated for its charming colonial architecture, curated vintage decor, and spectacular valley views. Famous for its signature cold cuts and fine wine selection.',
                                  style: GoogleFonts.inter(fontSize: 14, color: textMuted, height: 1.6),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // AI MATCHCARD
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.auto_awesome, color: primaryColor, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Why Matey picked this 🤖',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '"3 crew members bookmarked this. Matches your Chill + Nature vibes at 94%. Best slot: 9-11AM for crowd-free golden light."',
                                        style: GoogleFonts.inter(fontSize: 13, color: textMuted.withValues(alpha: 0.9), height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FLOATING BOTTOM
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomAction(isDark, primaryColor, secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String emoji, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(bool isDark, Color primaryColor, Color secondaryColor) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x800B1326) : const Color(0x9EFFFFFF),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() => _isAdded = !_isAdded);
              if (!_isAdded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('The Hill Station added to your itinerary! 📅'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                decoration: BoxDecoration(
                  gradient: _isAdded
                      ? null
                      : LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: _isAdded ? primaryColor.withValues(alpha: 0.15) : null,
                  borderRadius: BorderRadius.circular(28),
                  border: _isAdded
                      ? Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5)
                      : null,
                  boxShadow: _isAdded
                      ? []
                      : [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3 + 0.1 * _pulseController.value),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          )
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isAdded ? Icons.check_circle : Icons.add_circle_outline,
                      color: _isAdded ? primaryColor : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isAdded ? 'Added to Itinerary' : 'Add to Itinerary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _isAdded ? primaryColor : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
