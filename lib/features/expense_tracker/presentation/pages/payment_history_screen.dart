import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const PaymentHistoryScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
            // Ambient glows
            if (isDark) ...[
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
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
                    // Top Bar
                    _buildTopBar(textPrimary),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),

                            // Header Text Blocks
                            _buildHeaderSection(textPrimary, textMuted),

                            const SizedBox(height: 24),

                            // Total Damage Banner
                            _buildTotalDamageCard(surface, primary, secondary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // Settle Up / Remind buttons row
                            _buildActionRow(primary, textPrimary, isDark),

                            const SizedBox(height: 28),

                            // Timeline Feed Sections
                            _buildTimelineFeed(surface, primary, secondary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 100), // Spacing for navbar
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildFloatingNavbar(surface, primary, secondary, textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textPrimary) {
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
            'The Damage Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'friendship survived another payment... barely.',
            textAlign: TextAlign.center,
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

  Widget _buildTotalDamageCard(
      Color surface, Color primary, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Total Damage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₫ 2.4m',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Horizontal streak alert badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: secondary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: secondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Maya just cleared Grab chaos 🔥 • Khoa paid BBQ disaster 💸',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
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

  Widget _buildActionRow(Color primary, Color textPrimary, bool isDark) {
    return Row(
      children: [
        // Settle Up
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withRed(160)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Settle Up',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Remind Squad
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: (isDark ? Colors.white10 : Colors.black12)),
              ),
              alignment: Alignment.center,
              child: Text(
                'Remind Squad',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineFeed(
      Color surface, Color primary, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Day 3 section
        _buildSectionHeader('Day 3 — financial destruction'),
        const SizedBox(height: 12),

        // Grab chaos item
        _buildFeedCard(
          isDark: isDark,
          surface: surface,
          primaryColor: primary,
          secondaryColor: secondary,
          textPrimary: textPrimary,
          textMuted: textMuted,
          avatarText: '🔥',
          paidInfo: 'Nam Trung paid • 1.2m',
          shareAmount: '- ₫ 300k',
          shareLabel: 'Your share',
          tagText: 'Financial Pain',
          tagColor: Colors.redAccent,
        ),

        const SizedBox(height: 14),

        // BBQ item
        _buildFeedCard(
          isDark: isDark,
          surface: surface,
          primaryColor: primary,
          secondaryColor: secondary,
          textPrimary: textPrimary,
          textMuted: textMuted,
          avatarText: '🚕',
          paidInfo: 'Khoa paid • 240k',
          shareAmount: '- ₫ 60k',
          shareLabel: 'Your share',
          tagText: 'Just okay',
          tagColor: secondary,
        ),

        const SizedBox(height: 28),

        // Day 2 section
        _buildSectionHeader('Day 2 — caffeinated survival'),
        const SizedBox(height: 12),

        // Highlands item
        _buildFeedCard(
          isDark: isDark,
          surface: surface,
          primaryColor: primary,
          secondaryColor: secondary,
          textPrimary: textPrimary,
          textMuted: textMuted,
          avatarText: '☕',
          paidInfo: 'You paid • 180k',
          shareAmount: '+ ₫ 120k',
          shareLabel: 'They owe u',
          tagText: 'Main Character Energy',
          tagColor: primary,
          isReceiving: true,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = widget.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76),
        ),
      ),
    );
  }

  Widget _buildFeedCard({
    required bool isDark,
    required Color surface,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textMuted,
    required String avatarText,
    required String paidInfo,
    required String shareAmount,
    required String shareLabel,
    required String tagText,
    required Color tagColor,
    bool isReceiving = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(avatarText, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paidInfo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tagText,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: tagColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mini quick reaction button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        ),
                        child: Icon(
                          Icons.add_reaction_rounded,
                          size: 14,
                          color: textMuted.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                shareAmount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isReceiving ? secondaryColor : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              Text(
                shareLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ],
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
              _buildNavbarItem(Icons.group_outlined, false, textMuted, secondary),
              _buildNavbarItem(Icons.add_circle_outline_rounded, false, textMuted, secondary),
              _buildNavbarItem(Icons.account_balance_wallet_rounded, true, textMuted, secondary),
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
