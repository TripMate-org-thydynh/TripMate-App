import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumComparisonEliteTiersScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const PremiumComparisonEliteTiersScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<PremiumComparisonEliteTiersScreen> createState() =>
      _PremiumComparisonEliteTiersScreenState();
}

class _PremiumComparisonEliteTiersScreenState
    extends State<PremiumComparisonEliteTiersScreen> {
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
                          child: Icon(Icons.close, color: textPrimary, size: 18),
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
                          'Elite Squads Travel Differently',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unlock cinematic storytelling, endless themes, and expansive squad sizes. Make every journey legendary.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Free vs Elite Row Cards
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Free card column
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: glassBorder),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Free',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'The basics for casual trips.',
                                          style: GoogleFonts.inter(fontSize: 10, color: textSecondary),
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(color: Colors.white10),
                                        const SizedBox(height: 12),
                                        _buildCompareItem(Icons.sd_storage_outlined, 'Memory Storage', '2GB', textSecondary),
                                        _buildCompareItem(Icons.high_quality_rounded, 'AI Recap Quality', 'HD', textSecondary),
                                        _buildCompareItem(Icons.sentiment_satisfied_rounded, 'Sticker Packs', 'Basic', textSecondary),
                                        _buildCompareItem(Icons.palette_outlined, 'Themes', '2', textSecondary),
                                        _buildCompareItem(Icons.water_drop_rounded, 'Export Tools', 'Watermarked', textSecondary),
                                        _buildCompareItem(Icons.group_outlined, 'Squad Size', '5 members', textSecondary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Elite card column
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: tertiary.withValues(alpha: 0.3)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: tertiary.withValues(alpha: 0.1),
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
                                              'Elite',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: textPrimary,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: tertiary.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'POPULAR',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.w900,
                                                  color: tertiary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'The ultimate concierge experience.',
                                          style: GoogleFonts.inter(fontSize: 10, color: textSecondary),
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(color: Colors.white10),
                                        const SizedBox(height: 12),
                                        _buildCompareItem(Icons.cloud_done_rounded, 'Memory Storage', 'Unlimited', tertiary),
                                        _buildCompareItem(Icons.four_k_rounded, 'AI Recap Quality', 'Cinematic 4K', tertiary),
                                        _buildCompareItem(Icons.animation_rounded, 'Sticker Packs', 'Premium/Animated', tertiary),
                                        _buildCompareItem(Icons.auto_awesome, 'Themes', 'Unlimited', tertiary),
                                        _buildCompareItem(Icons.star_rounded, 'Export Tools', 'Pro Creator', tertiary),
                                        _buildCompareItem(Icons.groups_rounded, 'Squad Size', '20 members', tertiary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Action area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Free memories fade faster.',
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
                              colors: [primary, tertiary],
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
                              'Join the Elite',
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

  Widget _buildCompareItem(IconData icon, String title, String value, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: activeColor, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
