import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplitTypeSelectionScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SplitTypeSelectionScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SplitTypeSelectionScreen> createState() => _SplitTypeSelectionScreenState();
}

class _SplitTypeSelectionScreenState extends State<SplitTypeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Selected card index (0: Equal, 1: Weighted, 2: Custom, 3: Selected Members)
  int _selectedOptionIndex = 0;

  final double _totalAmount = 124.50;

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

  // Calculate per-person values dynamically
  String _getPerPersonPreview() {
    switch (_selectedOptionIndex) {
      case 0: // Equal
        return '\$${(_totalAmount / 4).toStringAsFixed(2)}';
      case 1: // Weighted (simulation)
        return '\$48.50';
      case 2: // Custom (simulation)
        return '\$62.25';
      case 3: // Selected (simulation - e.g. 3 people)
        return '\$41.50';
      default:
        return '\$0.00';
    }
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
            // Floating background glow
            if (isDark) ...[
              Positioned(
                top: 100,
                right: -100,
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
                bottom: -50,
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Custom App Bar
                    _buildTopAppBar(textPrimary),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),

                            // Dinner Invoice Panel
                            _buildInvoiceCard(surface, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // Header Instructions
                            Text(
                              'Choose Your Chaos',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'How are we splitting this damage?',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Split type list options
                            _buildOptionCard(
                              index: 0,
                              icon: Icons.pie_chart_rounded,
                              title: 'Equal Split',
                              desc: 'everyone suffers equally 😭',
                              surface: surface,
                              primaryColor: primary,
                              secondaryColor: secondary,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),

                            _buildOptionCard(
                              index: 1,
                              icon: Icons.scale_rounded,
                              title: 'Weighted Split',
                              desc: 'someone ordered lobster again.',
                              surface: surface,
                              primaryColor: primary,
                              secondaryColor: secondary,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),

                            _buildOptionCard(
                              index: 2,
                              icon: Icons.edit_square,
                              title: 'Custom Split',
                              desc: 'financial chaos mode.',
                              surface: surface,
                              primaryColor: primary,
                              secondaryColor: secondary,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),

                            _buildOptionCard(
                              index: 3,
                              icon: Icons.group_remove_rounded,
                              title: 'Selected Members',
                              desc: 'only the survivors pay.',
                              surface: surface,
                              primaryColor: primary,
                              secondaryColor: secondary,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 32),

                            // Calculated dynamic preview panel
                            _buildPreviewCard(surface, secondary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // Confirm Button
                            _buildConfirmButton(primary, secondary),

                            const SizedBox(height: 32),
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

  Widget _buildInvoiceCard(Color surface, Color textPrimary, Color textMuted, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🍜', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Dinner at Neon Ramen',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '\$${_totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String desc,
    required Color surface,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    final isSelected = _selectedOptionIndex == index;
    final activeBorderColor = isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.black12);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : surface.withValues(alpha: isDark ? 0.35 : 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activeBorderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.15)
                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(Color surface, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview (4 people)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'calculated share',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _getPerPersonPreview(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: secondary,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '/ea',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(Color primary, Color secondary) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Split damage confirmed successfully! 💸🔥'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.maybePop(context);
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, secondary],
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
          'Confirm',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
