import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumComparisonScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const PremiumComparisonScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<PremiumComparisonScreen> createState() =>
      _PremiumComparisonScreenState();
}

class _PremiumComparisonScreenState extends State<PremiumComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primary = isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6D3BD7);
    final secondary = isDark ? const Color(0xFF45DFA4) : const Color(0xFF00BD85);
    final tertiary = isDark ? const Color(0xFFFFB783) : const Color(0xFFF59E0B);

    final bg = isDark ? const Color(0xFF040914) : const Color(0xFFFCFAF6);
    final cardBg = isDark ? const Color(0xFF171F33) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);
    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background soft aurora glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.3,
                  colors: isDark
                      ? [const Color(0xFF1B3F68).withValues(alpha: 0.12), Colors.transparent]
                      : [const Color(0xFFEDF5FF).withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cardBg,
                            border: Border.all(color: glassBorder),
                          ),
                          child: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 16),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primary, secondary, tertiary],
                        ).createShader(bounds),
                        child: Text(
                          'trip.mate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.onThemeToggle != null)
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: textPrimary.withValues(alpha: 0.7),
                              ),
                              onPressed: widget.onThemeToggle,
                            ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cardBg,
                              border: Border.all(color: glassBorder),
                            ),
                            child: Icon(Icons.notifications, color: primary, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'elite squads\ntravel differently.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -1.0,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'free memories fade faster. Upgrade to capture every chaotic moment in cinematic detail.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Specifications Matrix Title
                        Text(
                          'Features',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Specifications Rows
                        _buildFeatureCompareRow(
                          icon: Icons.cloud_outlined,
                          title: 'Memories Storage',
                          basic: '1GB',
                          premium: 'Unlimited',
                          primaryColor: primary,
                          secondaryColor: secondary,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCompareRow(
                          icon: Icons.movie_outlined,
                          title: 'AI Recap Quality',
                          basic: '1080p',
                          premium: '4K Cinematic',
                          primaryColor: primary,
                          secondaryColor: secondary,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCompareRow(
                          icon: Icons.animation_rounded,
                          title: 'Sticker Packs',
                          basic: 'Standard',
                          premium: 'Premium Animated',
                          primaryColor: primary,
                          secondaryColor: secondary,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCompareRow(
                          icon: Icons.group_outlined,
                          title: 'Squad Size',
                          basic: 'Up to 5',
                          premium: 'Unlimited',
                          primaryColor: primary,
                          secondaryColor: secondary,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCompareRow(
                          icon: Icons.insights_rounded,
                          title: 'Analytics',
                          basic: 'Basic',
                          premium: 'Spotify-Style Odyssey',
                          primaryColor: primary,
                          secondaryColor: secondary,
                          cardBg: cardBg,
                          glassBorder: glassBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 32),

                        // Two column deck selector
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: glassBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Basic',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'For the casual weekend warrior.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '\$0/mo',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                        side: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: Text(
                                        'Current Plan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Premium card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'TripMate+',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: secondary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'POPULAR',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 7,
                                              fontWeight: FontWeight.w900,
                                              color: secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Unlock the full chaotic potential.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '\$9.99/mo',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: primary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [primary, secondary],
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          minimumSize: const Size.fromHeight(40),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: Text(
                                          'Upgrade Now',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Aesthetic navigation
          _buildBottomNav(cardBg, primary, secondary, textSecondary, isDark),
        ],
      ),
    );
  }

  Widget _buildFeatureCompareRow({
    required IconData icon,
    required String title,
    required String basic,
    required String premium,
    required Color primaryColor,
    required Color secondaryColor,
    required Color cardBg,
    required Color glassBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Basic: ',
                      style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
                    ),
                    Text(
                      basic,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'TripMate+: ',
                      style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
                    ),
                    Text(
                      premium,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: secondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
      Color surface, Color primary, Color secondary, Color textMuted, bool isDark) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.explore_rounded, 'explore', false, textMuted, primary),
                _buildNavItem(Icons.group_rounded, 'group', false, textMuted, primary),
                _buildNavItem(Icons.add_circle_rounded, 'add', false, textMuted, primary),
                _buildNavItem(Icons.palette_rounded, 'palette', false, textMuted, primary),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondary.withValues(alpha: 0.15),
                      border: Border.all(color: secondary.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(Icons.person_rounded, color: secondary, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Color textMuted, Color primary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? primary : textMuted.withValues(alpha: 0.6),
          size: 24,
        ),
      ],
    );
  }
}
