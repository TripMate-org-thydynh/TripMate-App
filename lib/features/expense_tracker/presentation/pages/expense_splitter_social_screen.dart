import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
class ExpenseSplitterSocialScreen extends StatefulWidget {
  const ExpenseSplitterSocialScreen({super.key});

  @override
  State<ExpenseSplitterSocialScreen> createState() =>
      _ExpenseSplitterSocialScreenState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class _ExpenseSplitterSocialScreenState
    extends State<ExpenseSplitterSocialScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────────────────
  late final AnimationController _graphController;
  late final AnimationController _barController;
  late final AnimationController _pulseController;

  late final Animation<double> _graphAnim;
  late final Animation<double> _friendshipAnim;
  late final Animation<double> _foodBarAnim;
  late final Animation<double> _transportBarAnim;
  late final Animation<double> _pulseAnim;

  int _activeNavIndex = 3; // payments tab active

  @override
  void initState() {
    super.initState();

    _graphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _graphAnim = CurvedAnimation(
      parent: _graphController,
      curve: Curves.easeOutCubic,
    );
    _friendshipAnim = Tween<double>(begin: 0, end: 0.45).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic),
    );
    _foodBarAnim = Tween<double>(begin: 0, end: 0.80).animate(
      CurvedAnimation(
        parent: _barController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _transportBarAnim = Tween<double>(begin: 0, end: 0.20).animate(
      CurvedAnimation(
        parent: _barController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.microtask(() {
      _graphController.forward();
      _barController.forward();
    });
  }

  @override
  void dispose() {
    _graphController.dispose();
    _barController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Palette helpers ──────────────────────────────────────────────────────
  Color _bg(bool dark) => dark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
  Color _surface(bool dark) => dark ? const Color(0xFF171F33) : Colors.white;
  Color _primary(bool dark) => dark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
  Color _secondary(bool dark) => dark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
  Color _text(bool dark) => dark ? Colors.white : const Color(0xFF1E2022);
  Color _subText(bool dark) =>
      dark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF1E2022).withValues(alpha: 0.55);

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _bg(isDark),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(isDark)),
            // ── Debt graph ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildDebtGraph(isDark)),
            // ── Friendship status ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildFriendshipSection(isDark)),
            // ── Squad spending stats ─────────────────────────────────────
            SliverToBoxAdapter(child: _buildSquadStats(isDark)),
            // ── Stats grid ───────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildStatsGrid(isDark)),
            // ── Live feed ───────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildLiveFeed(isDark)),
            // ── Bottom padding (for nav bar) ─────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  // =========================================================================
  // HEADER
  // =========================================================================
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: _glassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF8B5CF6), const Color(0xFF34D399)]
                      : [const Color(0xFFE0533C), const Color(0xFFEBA83A)],
                ).createShader(bounds),
                child: Text(
                  'trip.mate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              _glassIconButton(
                icon: Icons.notifications_none_rounded,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: _secondary(isDark),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Squad Debt: Optimized ✨',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _subText(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton({required IconData icon, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _surface(isDark).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.4),
              width: 1,
            ),
          ),
          child: Icon(icon, color: _text(isDark), size: 18),
        ),
      ),
    );
  }

  // =========================================================================
  // SOCIAL DEBT GRAPH
  // =========================================================================
  Widget _buildDebtGraph(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Social Debt Graph', isDark),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: _surface(isDark).withValues(alpha: isDark ? 0.6 : 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primary(isDark).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Graph canvas
                    AnimatedBuilder(
                      animation: _graphAnim,
                      builder: (context, _) => CustomPaint(
                        painter: _DebtGraphPainter(
                          progress: _graphAnim.value,
                          isDark: isDark,
                          primary: _primary(isDark),
                          secondary: _secondary(isDark),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // AI badge
                    Positioned(
                      top: 14,
                      right: 14,
                      child: _aiBadge(isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiBadge(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                      const Color(0xFF34D399).withValues(alpha: 0.25),
                    ]
                  : [
                      const Color(0xFFE0533C).withValues(alpha: 0.25),
                      const Color(0xFFEBA83A).withValues(alpha: 0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _primary(isDark).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: _primary(isDark), size: 12),
              const SizedBox(width: 4),
              Text(
                'AI Simplified Graph',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _primary(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // FRIENDSHIP STATUS
  // =========================================================================
  Widget _buildFriendshipSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: _glassCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Friendship Status', isDark),
            const SizedBox(height: 14),
            // Progress label row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '45% Restored 💙',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _secondary(isDark),
                  ),
                ),
                Text(
                  '55% Tension',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _subText(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Animated progress bar
            AnimatedBuilder(
              animation: _friendshipAnim,
              builder: (context, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: _friendshipAnim.value,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _primary(isDark),
                                _secondary(isDark),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: _secondary(isDark).withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            // Action buttons
            Row(
              children: [
                // Quick Clear – flex 2
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]
                              : [const Color(0xFFE0533C), const Color(0xFFD64430)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _primary(isDark).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Clear',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // QR – flex 1 (glass)
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _surface(isDark).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _primary(isDark).withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: _primary(isDark),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'QR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _primary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SQUAD SPENDING STATS
  // =========================================================================
  Widget _buildSquadStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: _glassCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Squad Spending Stats', isDark),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donut chart
                SizedBox(
                  width: 110,
                  height: 110,
                  child: AnimatedBuilder(
                    animation: _barController,
                    builder: (context, _) => CustomPaint(
                      painter: _DonutPainter(
                        progress: _barController.value,
                        primary: _primary(isDark),
                        secondary: _secondary(isDark),
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Bar breakdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3.8M total',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _text(isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _spendingBar(
                        label: 'Food & Drink',
                        emoji: '🍜',
                        animation: _foodBarAnim,
                        color: _primary(isDark),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _spendingBar(
                        label: 'Transport',
                        emoji: '🛵',
                        animation: _transportBarAnim,
                        color: _secondary(isDark),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // AI Insight box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          const Color(0xFF34D399).withValues(alpha: 0.08),
                        ]
                      : [
                          const Color(0xFFE0533C).withValues(alpha: 0.08),
                          const Color(0xFFEBA83A).withValues(alpha: 0.06),
                        ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _primary(isDark).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Insight: 80% of your budget went to bún bò 😭',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _text(isDark),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spendingBar({
    required String label,
    required String emoji,
    required Animation<double> animation,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _subText(isDark),
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) => Text(
                '${(animation.value * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: animation.value,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 6,
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
    );
  }

  // =========================================================================
  // STATS GRID
  // =========================================================================
  Widget _buildStatsGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          // Chaos score card
          Expanded(
            child: _glassCard(
              isDark: isDark,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌪️', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: [
                        const Color(0xFFFB923C),
                        const Color(0xFFEF4444),
                      ],
                    ).createShader(b),
                    child: Text(
                      '9.2',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Chaos Score',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _subText(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Most reliable card
          Expanded(
            child: _glassCard(
              isDark: isDark,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: _secondary(isDark),
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Most Reliable',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _secondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'PK',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _text(isDark),
                    ),
                  ),
                  Text(
                    'Phú Khang',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _text(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12% Reliable 😅',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _subText(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // LIVE FEED
  // =========================================================================
  Widget _buildLiveFeed(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle('Live Feed & Roasts', isDark),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _secondary(isDark),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _secondary(isDark).withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Live',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _secondary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _feedItem(
            isDark: isDark,
            emoji: '💸',
            content: 'Nam Trung — just cleared 420k. Legend behavior. 🙌',
            time: 'Just now',
            reaction: '🔥',
            reactionCount: null,
            opacity: 1.0,
          ),
          const SizedBox(height: 10),
          _feedItem(
            isDark: isDark,
            emoji: '💀',
            content:
                'Phú Khang: "bro i forgot my wallet at the hostel" 💀',
            time: '5m ago',
            reaction: null,
            reactionCount: 12,
            commentLabel: 'Roast Comments 👀',
            opacity: 1.0,
          ),
          const SizedBox(height: 10),
          _feedItem(
            isDark: isDark,
            emoji: '🥷',
            content: '2 people still hiding from homestay bill...',
            time: '',
            reaction: null,
            reactionCount: null,
            opacity: 0.55,
          ),
        ],
      ),
    );
  }

  Widget _feedItem({
    required bool isDark,
    required String emoji,
    required String content,
    required String time,
    String? reaction,
    int? reactionCount,
    String? commentLabel,
    required double opacity,
  }) {
    return Opacity(
      opacity: opacity,
      child: _glassCard(
        isDark: isDark,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _text(isDark),
                      height: 1.4,
                    ),
                  ),
                  if (time.isNotEmpty || commentLabel != null)
                    const SizedBox(height: 6),
                  if (time.isNotEmpty || commentLabel != null)
                    Row(
                      children: [
                        if (time.isNotEmpty)
                          Text(
                            time,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _subText(isDark),
                            ),
                          ),
                        if (commentLabel != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            '•',
                            style: TextStyle(
                              color: _subText(isDark),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              Text(
                                commentLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _primary(isDark),
                                ),
                              ),
                              if (reactionCount != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '$reactionCount',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _primary(isDark),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
            if (reaction != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _primary(isDark).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primary(isDark).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child:
                    Text(reaction, style: const TextStyle(fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // BOTTOM NAV
  // =========================================================================
  Widget _buildBottomNav(bool isDark) {
    final items = [
      Icons.home_rounded,
      Icons.explore_rounded,
      Icons.add_circle_rounded, // elevated center
      Icons.payments_rounded,
      Icons.person_rounded,
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: _surface(isDark).withValues(alpha: isDark ? 0.85 : 0.9),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final isCenter = i == 2;
                final isActive = _activeNavIndex == i;

                if (isCenter) {
                  return GestureDetector(
                    onTap: () => setState(() => _activeNavIndex = i),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFF34D399),
                                ]
                              : [
                                  const Color(0xFFE0533C),
                                  const Color(0xFFEBA83A),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary(isDark).withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => setState(() => _activeNavIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _primary(isDark).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      items[i],
                      size: 24,
                      color: isActive
                          ? _primary(isDark)
                          : _subText(isDark),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // HELPERS
  // =========================================================================
  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _text(isDark),
      ),
    );
  }

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: _surface(isDark).withValues(alpha: isDark ? 0.6 : 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// =============================================================================
// DEBT GRAPH PAINTER
// =============================================================================
class _DebtGraphPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primary;
  final Color secondary;

  const _DebtGraphPainter({
    required this.progress,
    required this.isDark,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Node positions
    final centerPos = Offset(cx, cy); // You
    final ntPos = Offset(cx * 0.38, cy * 0.42); // NT top-left
    final tlPos = Offset(cx * 0.28, cy * 1.55); // TL bottom-left
    final xPos = Offset(cx * 1.62, cy * 0.42); // -50k top-right

    // ── Draw animated bezier connection lines ──────────────────────────────
    final linePaint = Paint()
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final connections = [
      (centerPos, ntPos, const Color(0xFFEF4444)),
      (centerPos, tlPos, const Color(0xFF34D399)),
      (centerPos, xPos, const Color(0xFFFB923C)),
      (ntPos, tlPos, Colors.white.withValues(alpha: 0.2)),
    ];

    for (final (start, end, color) in connections) {
      final animEnd = Offset.lerp(start, end, progress)!;
      final cp = Offset(
        (start.dx + end.dx) / 2 + (end.dy - start.dy) * 0.3,
        (start.dy + end.dy) / 2 - (end.dx - start.dx) * 0.3,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(cp.dx, cp.dy, animEnd.dx, animEnd.dy);

      linePaint.color = color.withValues(alpha: progress * 0.7);
      canvas.drawPath(path, linePaint);
    }

    // ── Draw nodes ─────────────────────────────────────────────────────────
    if (progress > 0.3) {
      final np = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);

      _drawNode(canvas, ntPos, 'NT', '-750k', const Color(0xFFEF4444), np);
      _drawNode(canvas, tlPos, 'TL', '+200k', const Color(0xFF34D399), np);
      _drawNode(canvas, xPos, '😐', '-50k', const Color(0xFFFB923C), np);
    }

    // ── Draw center "You" node last (always on top) ──────────────────────
    _drawCenterNode(canvas, centerPos, progress);
  }

  void _drawNode(
    Canvas canvas,
    Offset pos,
    String label,
    String amount,
    Color borderColor,
    double alpha,
  ) {
    final r = 32.0;
    final bgPaint = Paint()
      ..color = (isDark
              ? const Color(0xFF1E2A45)
              : Colors.white)
          .withValues(alpha: alpha * 0.9);

    canvas.drawCircle(pos, r, bgPaint);

    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, r, borderPaint);

    // Glow
    final glowPaint = Paint()
      ..color = borderColor.withValues(alpha: alpha * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(pos, r, glowPaint);

    _paintText(canvas, label, pos.translate(0, -7), 13, FontWeight.w700,
        Colors.white.withValues(alpha: alpha));
    _paintText(canvas, amount, pos.translate(0, 9), 10, FontWeight.w600,
        borderColor.withValues(alpha: alpha));
  }

  void _drawCenterNode(Canvas canvas, Offset pos, double alpha) {
    final r = 38.0;

    // Gradient fill
    final rect = Rect.fromCircle(center: pos, radius: r);
    final gradPaint = Paint()
      ..shader = LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..color = Colors.white.withValues(alpha: alpha);

    canvas.drawCircle(pos, r, gradPaint);

    // Glow ring
    final glowPaint = Paint()
      ..color = primary.withValues(alpha: alpha * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(pos, r + 4, glowPaint);

    _paintText(canvas, 'You', pos.translate(0, -6), 13, FontWeight.w800,
        Colors.white.withValues(alpha: alpha));
    _paintText(canvas, 'Center', pos.translate(0, 8), 9, FontWeight.w500,
        Colors.white.withValues(alpha: alpha * 0.8));
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset position,
    double fontSize,
    FontWeight weight,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      position.translate(-tp.width / 2, -tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_DebtGraphPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

// =============================================================================
// DONUT PAINTER
// =============================================================================
class _DonutPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;
  final bool isDark;

  const _DonutPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeW = 14.0;
    final r = (size.width / 2) - strokeW / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    const foodFraction = 0.80;
    const transportFraction = 0.20;
    const startAngle = -pi / 2;

    // Food arc
    final foodPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [primary, primary.withValues(alpha: 0.7)],
        startAngle: startAngle,
        endAngle: startAngle + 2 * pi * foodFraction,
      ).createShader(rect);

    canvas.drawArc(
      rect,
      startAngle,
      2 * pi * foodFraction * progress,
      false,
      foodPaint,
    );

    // Transport arc
    final transportPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW - 3
      ..strokeCap = StrokeCap.round
      ..color = secondary.withValues(alpha: 0.85);

    canvas.drawArc(
      rect,
      startAngle + 2 * pi * foodFraction,
      2 * pi * transportFraction * progress,
      false,
      transportPaint,
    );

    // Center text
    _paintCenteredText(canvas, size, '80%', primary, 18, FontWeight.w800);
    _paintCenteredText(
        canvas, size.translate(0, 20), 'food', primary.withValues(alpha: 0.7), 10, FontWeight.w500);
  }

  void _paintCenteredText(
    Canvas canvas,
    Size size,
    String text,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        size.width / 2 - tp.width / 2,
        size.height / 2 - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

extension _SizeTranslate on Size {
  Size translate(double dx, double dy) => Size(width + dx, height + dy);
}
