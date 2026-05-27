import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumCheckoutScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const PremiumCheckoutScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<PremiumCheckoutScreen> createState() => _PremiumCheckoutScreenState();
}

class _PremiumCheckoutScreenState extends State<PremiumCheckoutScreen> {
  bool _isYearly = false; // Toggle state
  int _selectedTierIndex = 2; // Default to Elite Squad (Squad Goals)

  final List<Map<String, dynamic>> _tiers = [
    {
      'title': 'Basic Chaos',
      'subtitle': 'Free',
      'priceMonthly': 0,
      'priceYearly': 0,
      'isFeatured': false,
      'color': const Color(0xFFCBC3D7),
      'icon': Icons.check_circle_outline_rounded,
    },
    {
      'title': 'Main Character',
      'subtitle': 'Elite Solo',
      'priceMonthly': 8,
      'priceYearly': 5,
      'isFeatured': false,
      'color': const Color(0xFFD0BCFF),
      'icon': Icons.palette_outlined,
    },
    {
      'title': 'Squad Goals',
      'subtitle': 'Elite Squad',
      'priceMonthly': 15,
      'priceYearly': 9,
      'isFeatured': true,
      'color': const Color(0xFF45DFA4),
      'icon': Icons.all_inclusive_rounded,
    },
    {
      'title': 'Viral Legend',
      'subtitle': 'Creator Pack',
      'priceMonthly': 25,
      'priceYearly': 15,
      'isFeatured': false,
      'color': const Color(0xFFFFB783),
      'icon': Icons.movie_edit,
    },
  ];

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
                  center: Alignment.topRight,
                  radius: 1.3,
                  colors: isDark
                      ? [const Color(0xFF2C1B4D).withValues(alpha: 0.15), Colors.transparent]
                      : [const Color(0xFFF5EDFF).withValues(alpha: 0.45), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cardBg,
                            border: Border.all(color: glassBorder),
                          ),
                          child: Icon(Icons.close, color: primary, size: 18),
                        ),
                      ),
                      const Spacer(),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primary, secondary, tertiary],
                        ).createShader(bounds),
                        child: Text(
                          'Upgrade Plan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.onThemeToggle != null)
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: textPrimary.withValues(alpha: 0.7),
                          ),
                          onPressed: widget.onThemeToggle,
                        )
                      else
                        const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Upgrade Your Chaos',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'your memories deserve premium treatment.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Monthly / Yearly toggle switcher
                        Center(
                          child: Container(
                            width: 280,
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: glassBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isYearly = false),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      decoration: BoxDecoration(
                                        color: !_isYearly ? primary.withValues(alpha: 0.2) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Monthly',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: !_isYearly ? textPrimary : textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isYearly = true),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      decoration: BoxDecoration(
                                        color: _isYearly ? primary.withValues(alpha: 0.2) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Yearly',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: _isYearly ? textPrimary : textSecondary,
                                              ),
                                            ),
                                            Text(
                                              'SAVE 40%',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: secondary,
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
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Horizontal tiers scrolling
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _tiers.length,
                            itemBuilder: (context, index) {
                              final tier = _tiers[index];
                              final isSelected = _selectedTierIndex == index;
                              final tierColor = tier['color'] as Color;
                              final price = _isYearly ? tier['priceYearly'] : tier['priceMonthly'];

                              return GestureDetector(
                                onTap: () => setState(() => _selectedTierIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? tierColor.withValues(alpha: 0.15) : cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? tierColor : glassBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: tierColor.withValues(alpha: 0.25), blurRadius: 10)]
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(tier['icon'] as IconData, color: isSelected ? tierColor : textSecondary, size: 20),
                                          if (tier['isFeatured'] == true)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: tierColor.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Featured',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.w900,
                                                  color: tierColor,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        tier['title'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$$price/mo',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected ? tierColor : textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Features Summary list
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Elite Plans Include',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureIncludeItem(Icons.auto_awesome, '✨ AI cinematic recap', primary),
                              _buildFeatureIncludeItem(Icons.palette_outlined, '🎨 exclusive themes', primary),
                              _buildFeatureIncludeItem(Icons.sentiment_very_satisfied_outlined, '😭 premium stickers', primary),
                              _buildFeatureIncludeItem(Icons.photo_library_outlined, '📸 unlimited memories', primary),
                              _buildFeatureIncludeItem(Icons.movie_outlined, '🔥 creator export tools', primary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Actions Area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Financially irresponsible. Visually elite.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              colors: [primary, secondary],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.35),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            label: Text(
                              'Continue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIncludeItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
