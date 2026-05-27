import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetAnalyticsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const BudgetAnalyticsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<BudgetAnalyticsScreen> createState() => _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends State<BudgetAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;
  int _selectedPeriod = 1;

  final List<String> _periods = ['Day', 'Week', 'Total'];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Accommodation', 'emoji': '🏠', 'amount': 2400000, 'pct': 0.40, 'color': const Color(0xFFD0BCFF)},
    {'label': 'Food & Drinks', 'emoji': '🍜', 'amount': 1620000, 'pct': 0.27, 'color': const Color(0xFF45DFA4)},
    {'label': 'Transport', 'emoji': '🛵', 'amount': 900000, 'pct': 0.15, 'color': const Color(0xFFFFBB6C)},
    {'label': 'Activities', 'emoji': '🏕', 'amount': 720000, 'pct': 0.12, 'color': const Color(0xFFFF6B8A)},
    {'label': 'Shopping', 'emoji': '🛍️', 'amount': 360000, 'pct': 0.06, 'color': const Color(0xFF6C8EFF)},
  ];

  final List<Map<String, dynamic>> _dailyBars = [
    {'day': 'Mon', 'val': 0.55},
    {'day': 'Tue', 'val': 0.80},
    {'day': 'Wed', 'val': 0.45},
    {'day': 'Thu', 'val': 1.00},
    {'day': 'Fri', 'val': 0.70},
    {'day': 'Sat', 'val': 0.90},
    {'day': 'Sun', 'val': 0.30},
  ];

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barAnim = CurvedAnimation(parent: _barController, curve: Curves.easeOut);
    _barController.forward();
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFFD0BCFF) : const Color(0xFF7C3AED);
    final secondaryColor = isDark ? const Color(0xFF45DFA4) : const Color(0xFF059669);
    final bgColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // GLASS APP BAR
            _buildAppBar(isDark, primaryColor, textPrimary, textMuted),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // HERO SPENDING CARD
                    _buildSpendingHeroCard(isDark, primaryColor, secondaryColor, cardBg, textPrimary, textMuted),
                    const SizedBox(height: 20),

                    // PERIOD SELECTOR
                    _buildPeriodSelector(primaryColor, textMuted, textPrimary, isDark),
                    const SizedBox(height: 20),

                    // DAILY BAR CHART
                    _buildBarChart(isDark, primaryColor, secondaryColor, cardBg, textPrimary, textMuted),
                    const SizedBox(height: 20),

                    // CATEGORY BREAKDOWN
                    Text(
                      'Category Breakdown',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._categories.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCategoryRow(e.value, isDark, cardBg, textPrimary, textMuted),
                      );
                    }),
                    const SizedBox(height: 20),

                    // MEMBER SPEND BREAKDOWN
                    _buildMemberBreakdown(isDark, primaryColor, cardBg, textPrimary, textMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color primaryColor, Color textPrimary, Color textMuted) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x800B1326) : const Color(0x9EFFFFFF),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 18),
              ),
              Text(
                'Budget Analytics',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              GestureDetector(
                onTap: widget.onThemeToggle,
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: isDark ? Colors.white60 : Colors.black54,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingHeroCard(bool isDark, Color primaryColor, Color secondaryColor, Color cardBg, Color textPrimary, Color textMuted) {
    final total = 6000000;
    final budget = 8000000;
    final pct = total / budget;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A2340), const Color(0xFF252D50)]
              : [Colors.white, const Color(0xFFF5F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Squad Total Spent',
                style: GoogleFonts.inter(fontSize: 13, color: textMuted, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '12% under budget',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primaryColor, secondaryColor],
            ).createShader(bounds),
            child: Text(
              '6,000,000 ₫',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'of 8,000,000 ₫ budget · 5 days',
            style: GoogleFonts.inter(fontSize: 12, color: textMuted),
          ),
          const SizedBox(height: 16),
          // Budget progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(pct * 100).toInt()}% used',
                style: GoogleFonts.inter(fontSize: 12, color: textMuted, fontWeight: FontWeight.w600),
              ),
              Text(
                '2,000,000 ₫ remaining',
                style: GoogleFonts.inter(fontSize: 12, color: secondaryColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(Color primaryColor, Color textMuted, Color textPrimary, bool isDark) {
    return Row(
      children: _periods.asMap().entries.map((e) {
        final isSelected = _selectedPeriod == e.key;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedPeriod = e.key;
            _barController.reset();
            _barController.forward();
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10)]
                  : null,
            ),
            child: Text(
              e.value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarChart(bool isDark, Color primaryColor, Color secondaryColor, Color cardBg, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Spending',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _dailyBars.asMap().entries.map((e) {
              final bar = e.value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // BAR
                      AnimatedBuilder(
                        animation: _barAnim,
                        builder: (_, child) => Container(
                          height: (bar['val'] as double) * 100 * _barAnim.value,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bar['day'] as String,
                        style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> cat, bool isDark, Color cardBg, Color textPrimary, Color textMuted) {
    final color = cat['color'] as Color;
    final pct = cat['pct'] as double;
    final amount = cat['amount'] as int;

    return AnimatedBuilder(
      animation: _barAnim,
      builder: (_, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Center(child: Text(cat['emoji'] as String, style: const TextStyle(fontSize: 17))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cat['label'] as String,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                ),
                Text(
                  '${(pct * 100).toInt()}%',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(amount / 1000).toStringAsFixed(0)}k ₫',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct * _barAnim.value,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberBreakdown(bool isDark, Color primaryColor, Color cardBg, Color textPrimary, Color textMuted) {
    final members = [
      {'name': 'Minh Nhật', 'emoji': '👦', 'amount': 1440000, 'pct': 0.24},
      {'name': 'Thảo Ly', 'emoji': '👧', 'amount': 1200000, 'pct': 0.20},
      {'name': 'Nam Trung', 'emoji': '🧑', 'amount': 1080000, 'pct': 0.18},
      {'name': 'Alex Nguyễn', 'emoji': '👱', 'amount': 960000, 'pct': 0.16},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Per Member',
          style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: members.asMap().entries.map((entry) {
              final m = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: entry.key < members.length - 1 ? 14 : 0),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.1),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Center(child: Text(m['emoji'] as String, style: const TextStyle(fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['name'] as String,
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          AnimatedBuilder(
                            animation: _barAnim,
                            builder: (_, child) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (m['pct'] as double) * _barAnim.value,
                                minHeight: 5,
                                backgroundColor: primaryColor.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation(primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${((m['amount'] as int) / 1000).toStringAsFixed(0)}k ₫',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
