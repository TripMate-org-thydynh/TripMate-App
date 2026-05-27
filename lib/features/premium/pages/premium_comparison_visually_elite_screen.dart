import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumComparisonVisuallyEliteScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const PremiumComparisonVisuallyEliteScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<PremiumComparisonVisuallyEliteScreen> createState() =>
      _PremiumComparisonVisuallyEliteScreenState();
}

class _PremiumComparisonVisuallyEliteScreenState
    extends State<PremiumComparisonVisuallyEliteScreen> {
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
                          child: Icon(Icons.arrow_back, color: primary, size: 20),
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
                      if (widget.onThemeToggle != null)
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: textPrimary.withValues(alpha: 0.7),
                          ),
                          onPressed: widget.onThemeToggle,
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Hero area
                        Text(
                          'financially irresponsible.\nvisually elite.',
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
                          'free memories fade faster. elite squads travel differently.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Three Column Tier Deck
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTierCard(
                                title: 'Free',
                                subtitle: 'NPC basic plan',
                                price: '\$0',
                                desc: 'Basic plotting for NPCs.',
                                btnText: 'Current Plan',
                                isPrimary: false,
                                isOutline: true,
                                color: const Color(0xFFCBC3D7),
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                glassBorder: glassBorder,
                              ),
                              const SizedBox(width: 12),
                              _buildTierCard(
                                title: 'Elite Solo',
                                subtitle: 'Most Popular',
                                price: '\$8/mo',
                                desc: 'Unlock AI magic and premium exports.',
                                btnText: 'Upgrade Now',
                                isPrimary: true,
                                isOutline: false,
                                color: primary,
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                glassBorder: glassBorder,
                                activeColors: [primary, secondary],
                              ),
                              const SizedBox(width: 12),
                              _buildTierCard(
                                title: 'Elite Squad',
                                subtitle: 'Squad shared benefits',
                                price: '\$24/mo',
                                desc: 'Cover up to 6 mates. shared benefits.',
                                btnText: 'Upgrade Squad',
                                isPrimary: false,
                                isOutline: true,
                                color: secondary,
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                glassBorder: glassBorder,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Full Specifications Matrix table Title
                        Text(
                          'The Breakdown',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Specs Table Matrix
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: glassBorder),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.4),
                                1: FlexColumnWidth(1.0),
                                2: FlexColumnWidth(1.0),
                                3: FlexColumnWidth(1.0),
                              },
                              children: [
                                // Table Header
                                TableRow(
                                  decoration: BoxDecoration(color: primary.withValues(alpha: 0.1)),
                                  children: [
                                    _buildTableCell('Feature', isHeader: true, color: textPrimary),
                                    _buildTableCell('Free', isHeader: true, color: textPrimary),
                                    _buildTableCell('Elite', isHeader: true, color: primary),
                                    _buildTableCell('Creator', isHeader: true, color: secondary),
                                  ],
                                ),
                                // Row 1
                                TableRow(
                                  children: [
                                    _buildTableCell('Memories Storage'),
                                    _buildTableCell('1GB', color: textSecondary),
                                    _buildTableCell('Unlimited', color: primary),
                                    _buildTableCell('Unlimited', color: secondary),
                                  ],
                                ),
                                // Row 2
                                TableRow(
                                  children: [
                                    _buildTableCell('AI Recap Quality'),
                                    _buildTableCell('Standard', color: textSecondary),
                                    _buildTableCell('Cinematic 4K', color: primary),
                                    _buildTableCell('ProRes Raw', color: secondary),
                                  ],
                                ),
                                // Row 3
                                TableRow(
                                  children: [
                                    _buildTableCell('Squad Size'),
                                    _buildTableCell('Up to 3', color: textSecondary),
                                    _buildTableCell('Up to 12', color: primary),
                                    _buildTableCell('Unlimited', color: secondary),
                                  ],
                                ),
                                // Row 4
                                TableRow(
                                  children: [
                                    _buildTableCell('Sticker Packs'),
                                    _buildTableCellIcon(Icons.close, Colors.redAccent),
                                    _buildTableCellIcon(Icons.check, secondary),
                                    _buildTableCellIcon(Icons.check, secondary),
                                  ],
                                ),
                                // Row 5
                                TableRow(
                                  children: [
                                    _buildTableCell('Advanced Analytics'),
                                    _buildTableCellIcon(Icons.close, Colors.redAccent),
                                    _buildTableCellIcon(Icons.close, Colors.redAccent),
                                    _buildTableCellIcon(Icons.check, secondary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildTierCard({
    required String title,
    required String subtitle,
    required String price,
    required String desc,
    required String btnText,
    required bool isPrimary,
    required bool isOutline,
    required Color color,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color glassBorder,
    List<Color>? activeColors,
  }) {
    return Container(
      width: 172,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPrimary ? color : glassBorder, width: isPrimary ? 2 : 1),
        boxShadow: isPrimary
            ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 9, color: isPrimary ? color : textSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isPrimary ? color : textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          isOutline
              ? OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    btnText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                )
              : Container(
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: activeColors ?? [color, color],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      btnText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? FontWeight.w900 : FontWeight.w600,
          color: color ?? Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildTableCellIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }
}
