import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripBingoScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const TripBingoScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<TripBingoScreen> createState() => _TripBingoScreenState();
}

class _TripBingoScreenState extends State<TripBingoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _bingoTiles = [
    {
      'emoji': '☕',
      'title': 'Cafe at 2AM',
      'state': 'completed', // completed, active, normal
    },
    {
      'emoji': '📸',
      'title': 'Accidental Film Photo',
      'state': 'active',
    },
    {
      'emoji': '☔',
      'title': 'Survive Random Rain',
      'state': 'normal',
    },
    {
      'emoji': '🗺️',
      'title': 'Lost with Squad',
      'state': 'normal',
    },
    {
      'emoji': '💸',
      'title': 'Overspend Budget',
      'state': 'completed',
    },
    {
      'emoji': '🍕',
      'title': 'Eat 4th Meal',
      'state': 'active',
    },
    {
      'emoji': '🎤',
      'title': 'Public Karaoke',
      'state': 'normal',
    },
    {
      'emoji': '🏃',
      'title': 'Miss a Train',
      'state': 'completed',
    },
    {
      'emoji': '🌅',
      'title': 'Stay up til Sunrise',
      'state': 'normal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Recalculate chaos progress level dynamically
  double _getChaosLevel() {
    int completedCount = _bingoTiles.where((t) => t['state'] == 'completed').length;
    return (completedCount / _bingoTiles.length);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Design System colors
    final bgStart = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final bgEnd = isDark ? const Color(0xFF060E20) : const Color(0xFFF1EDE6);
    final surface = isDark ? const Color(0xFF171F33) : Colors.white;
    final primary = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondary = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
    final textMuted = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: Stack(
          children: [
            // Glowing background orbs
            if (isDark) ...[
              Positioned(
                top: -50,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                left: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ],

            SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Top App Bar
                    _buildTopAppBar(textPrimary),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),

                            // Heading titles
                            _buildHeaderSection(textPrimary, textMuted),

                            const SizedBox(height: 24),

                            // Chaos level progress bar panel
                            _buildChaosProgressCard(surface, secondary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // 3x3 Bingo Grid
                            _buildBingoGrid(surface, primary, secondary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // Financial Reward unlocked alert card
                            _buildRewardCard(surface, primary, secondary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 100), // Spacing for bottom navbar
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Custom Navbar
            _buildFloatingNavbar(surface, primary, secondary, textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(Color textPrimary) {
    final isDark = widget.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
          Text(
            'trip.mate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textPrimary.withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: widget.onThemeToggle,
              tooltip: 'Toggle Theme',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Color textPrimary, Color textMuted) {
    return Center(
      child: Column(
        children: [
          Text(
            'Trip Bingo 🎲',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete chaos challenges to win.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaosProgressCard(
      Color surface, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    final currentChaosRatio = _getChaosLevel();
    final remainingCount = _bingoTiles.where((t) => t['state'] != 'completed').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Squad Chaos Level',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                ),
              ),
              Text(
                'Level 3: Unhinged 🤪',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: currentChaosRatio,
                      backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(secondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(currentChaosRatio * 100).toInt()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remainingCount > 0
                ? 'Chaos level increasing. $remainingCount more for Bingo!'
                : 'Bingo achieved! Complete chaos unleashed! 🎉',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBingoGrid(
      Color surface, Color primary, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _bingoTiles.length,
      itemBuilder: (context, index) {
        final tile = _bingoTiles[index];
        final state = tile['state'] as String;

        Color tileBg = surface.withValues(alpha: isDark ? 0.35 : 0.65);
        Color tileBorder = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05);
        double borderWidth = 1.0;
        List<BoxShadow>? tileGlow;

        if (state == 'completed') {
          tileBg = secondary.withValues(alpha: 0.15);
          tileBorder = secondary;
          borderWidth = 1.5;
          tileGlow = [
            BoxShadow(
              color: secondary.withValues(alpha: 0.1),
              blurRadius: 10,
            )
          ];
        } else if (state == 'active') {
          tileBg = primary.withValues(alpha: 0.12);
          tileBorder = primary;
          borderWidth = 1.5;
          tileGlow = [
            BoxShadow(
              color: primary.withValues(alpha: 0.1),
              blurRadius: 10,
            )
          ];
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              if (state == 'completed') {
                tile['state'] = 'normal';
              } else {
                tile['state'] = 'completed';
              }
            });
            if (tile['state'] == 'completed') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tile "${tile['title']}" checked! 🎯🔥'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: secondary,
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tileBorder, width: borderWidth),
              boxShadow: tileGlow,
            ),
            padding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tile['emoji'] as String, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(
                      tile['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: state == 'completed' ? FontWeight.w900 : FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                if (state == 'completed')
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(Icons.check_circle_rounded, color: secondary, size: 14),
                  )
                else if (state == 'active')
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(
      Color surface, Color primary, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: secondary.withValues(alpha: 0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: secondary.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspace_premium_rounded, color: secondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial damage bonus unlocked! 💰',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+50 Chaos Points awarded to Squad.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
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

  Widget _buildFloatingNavbar(Color surface, Color primary, Color secondary, Color textMuted) {
    final isDark = widget.isDarkMode;
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavbarItem(Icons.explore_outlined, false, textMuted, secondary),
              _buildNavbarItem(Icons.payments_outlined, false, textMuted, secondary),
              _buildNavbarItem(Icons.explore_rounded, false, textMuted, secondary),
              _buildNavbarItem(Icons.auto_awesome_rounded, true, textMuted, secondary),
              _buildNavbarItem(Icons.person_outline_rounded, false, textMuted, secondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbarItem(IconData icon, bool isActive, Color textMuted, Color secondary) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isActive
          ? BoxDecoration(
              color: secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: Icon(
        icon,
        color: isActive ? secondary : textMuted,
        size: 24,
      ),
    );
  }
}
