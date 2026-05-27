import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseCategoryDetailScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ExpenseCategoryDetailScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<ExpenseCategoryDetailScreen> createState() => _ExpenseCategoryDetailScreenState();
}

class _ExpenseCategoryDetailScreenState extends State<ExpenseCategoryDetailScreen>
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
            // Ambient Orbs
            if (isDark) ...[
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
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
                    // Top Custom App Bar
                    _buildTopAppBar(textPrimary, surface),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hero Total Spend Category Header
                            _buildHeroHeader(textPrimary, textMuted, primary),

                            const SizedBox(height: 24),

                            // AI Insight Card
                            _buildAIInsightCard(surface, primary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // Top Spender Section
                            _buildTopSpender(surface, secondary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // Distribution (Who Paid What) Pie-list
                            _buildPaidDistribution(surface, primary, textPrimary, textMuted, isDark),

                            const SizedBox(height: 28),

                            // The Evidence Timeline list
                            _buildEvidenceList(surface, textPrimary, textMuted, isDark),

                            const SizedBox(height: 40),
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

  Widget _buildTopAppBar(Color textPrimary, Color surface) {
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

  Widget _buildHeroHeader(Color textPrimary, Color textMuted, Color primary) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🍜', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 12),
          Text(
            'Food Damage',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '4.2m ₫',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          Text(
            'Total spent on Food & Drinks',
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

  Widget _buildAIInsightCard(Color surface, Color primary, Color textPrimary, Color textMuted, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primary.withValues(alpha: 0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.05),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy_rounded, color: primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'AI Insight',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '73% of your money disappeared into food 😭. Y\'all literally ate through the budget.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSpender(Color surface, Color secondary, Color textPrimary, Color textMuted, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Top Spender 👑',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Podiums Rank badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '#1',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: secondary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minh Nhật',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'The Hungry One',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '1.8m ₫',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    '42% of total',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaidDistribution(Color surface, Color primary, Color textPrimary, Color textMuted, bool isDark) {
    final List<Map<String, dynamic>> distributions = [
      {'name': 'Minh Nhật', 'pct': 0.42, 'val': '1.8m ₫', 'color': const Color(0xFFE0533C)},
      {'name': 'Leo', 'pct': 0.25, 'val': '1.05m ₫', 'color': const Color(0xFF34D399)},
      {'name': 'Chloe', 'pct': 0.20, 'val': '840k ₫', 'color': const Color(0xFF8B5CF6)},
      {'name': 'Maya', 'pct': 0.13, 'val': '546k ₫', 'color': const Color(0xFFEBA83A)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Who paid what?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Horizontal combined percentage bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: distributions.map((dist) {
                  return Expanded(
                    flex: (dist['pct'] * 100).toInt(),
                    child: Container(
                      color: dist['color'] as Color,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List legend
          Column(
            children: distributions.map((dist) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dist['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dist['name'] as String,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${(dist['pct'] * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      dist['val'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceList(Color surface, Color textPrimary, Color textMuted, bool isDark) {
    final List<Map<String, dynamic>> evidences = [
      {
        'emoji': '🍜',
        'title': 'Late night Bún Chả',
        'sub': 'Paid by Leo • 2 hrs ago',
        'amount': '450k',
      },
      {
        'emoji': '☕',
        'title': 'Highlands Coffee chaos',
        'sub': 'Paid by Chloe • Yesterday',
        'amount': '320k',
      },
      {
        'emoji': '🍻',
        'title': 'Bia Hơi round 1',
        'sub': 'Paid by Minh Nhật • Yesterday',
        'amount': '800k',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'The Evidence',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...evidences.map((ev) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(ev['emoji'] as String, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ev['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ev['sub'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  ev['amount'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
