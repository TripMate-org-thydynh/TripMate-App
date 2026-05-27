import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumStickerPacksScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const PremiumStickerPacksScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<PremiumStickerPacksScreen> createState() =>
      _PremiumStickerPacksScreenState();
}

class _PremiumStickerPacksScreenState extends State<PremiumStickerPacksScreen> {
  final List<Map<String, dynamic>> _packs = [
    {
      'title': '😭 Emotional Damage',
      'desc': '16 Animated Stickers',
      'btnText': 'Get Pack',
      'isPremium': true,
      'color': const Color(0xFFD0BCFF),
      'icon': Icons.water_drop_rounded,
    },
    {
      'title': '☕ Cafe Addiction+',
      'desc': '12 Static, 4 Animated',
      'btnText': 'Get Pack',
      'isPremium': true,
      'color': const Color(0xFFFFB783),
      'icon': Icons.local_cafe_rounded,
    },
    {
      'title': '🌃 Midnight Squad',
      'desc': '20 Animated Stickers',
      'btnText': 'Get Pack',
      'isPremium': false,
      'color': const Color(0xFF45DFA4),
      'icon': Icons.nightlife_rounded,
    },
    {
      'title': '📸 Main Character Deluxe',
      'desc': '15 Animated Stickers',
      'btnText': 'Get Pack',
      'isPremium': false,
      'color': const Color(0xFFD0BCFF),
      'icon': Icons.photo_camera_rounded,
    },
    {
      'title': '💸 Financial Ruin Premium',
      'desc': '24 Animated Stickers',
      'btnText': 'Unlock for \$2.99',
      'isPremium': true,
      'isSpecialAction': true,
      'color': const Color(0xFFFFB4AB),
      'icon': Icons.payments_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primary = isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6D3BD7);
    final secondary = isDark ? const Color(0xFF45DFA4) : const Color(0xFF00BD85);
    final tertiary = isDark ? const Color(0xFFFFB783) : const Color(0xFFF59E0B);
    final error = isDark ? const Color(0xFFFFB4AB) : const Color(0xFFD32F2F);

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
                      ? [const Color(0xFF5B1D35).withValues(alpha: 0.12), Colors.transparent]
                      : [const Color(0xFFFFEDF2).withValues(alpha: 0.45), Colors.transparent],
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
                          'Premium Drops',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'elite emotional damage unlocked. premium chaos reactions acquired.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Legendary Drop Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: tertiary.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: tertiary.withValues(alpha: 0.1),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: tertiary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.local_fire_department_rounded, color: tertiary, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'LEGENDARY DROP',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: tertiary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome, color: primary, size: 14),
                                        const SizedBox(width: 4),
                                        Icon(Icons.motion_photos_on_outlined, color: secondary, size: 14),
                                        const SizedBox(width: 4),
                                        Icon(Icons.bolt_rounded, color: tertiary, size: 14),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '🔥 Chaos Elite',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'For when the group chat goes completely off the rails. Features 24 animated reactions that perfectly encapsulate sheer panic and unbridled hype.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    gradient: LinearGradient(
                                      colors: [primary, secondary, primary],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                    ),
                                    child: Text(
                                      'Unlock Premium Pack - \$4.99',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
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
                        const SizedBox(height: 32),

                        // Stickers Inventory Grid Title
                        Text(
                          'Sticker Inventory',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Stickers packs list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _packs.length,
                          itemBuilder: (context, index) {
                            final pack = _packs[index];
                            final packColor = pack['color'] as Color;
                            final isAction = pack['isSpecialAction'] == true;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: glassBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: packColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(pack['icon'] as IconData, color: packColor, size: 20),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                pack['title'],
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: textPrimary,
                                                ),
                                              ),
                                              if (pack['isPremium'] == true) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: packColor.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'PREMIUM',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 7,
                                                      fontWeight: FontWeight.w900,
                                                      color: packColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            pack['desc'],
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  isAction
                                      ? ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: error,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            minimumSize: Size.zero,
                                          ),
                                          child: Text(
                                            pack['btnText'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: packColor.withValues(alpha: 0.5)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            minimumSize: Size.zero,
                                          ),
                                          child: Text(
                                            pack['btnText'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: packColor,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Nav
          _buildBottomNav(cardBg, primary, secondary, textSecondary, isDark),
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
                    child: Icon(Icons.explore_rounded, color: secondary, size: 24),
                  ),
                ),
                _buildNavItem(Icons.add_circle_rounded, 'add', false, textMuted, primary),
                _buildNavItem(Icons.group_rounded, 'group', false, textMuted, primary),
                _buildNavItem(Icons.person_rounded, 'person', false, textMuted, primary),
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
