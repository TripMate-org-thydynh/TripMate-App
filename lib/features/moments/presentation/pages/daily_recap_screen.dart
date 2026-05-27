import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyRecapScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const DailyRecapScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<DailyRecapScreen> createState() => _DailyRecapScreenState();
}

class _DailyRecapScreenState extends State<DailyRecapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Color helpers ──────────────────────────────────────────────────────────
  Color get _bg =>
      widget.isDarkMode ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
  Color get _primary =>
      widget.isDarkMode ? const Color(0xFFD0BCFF) : const Color(0xFF6D3BD7);
  Color get _secondary =>
      widget.isDarkMode ? const Color(0xFF45DFA4) : const Color(0xFF059669);
  Color get _tertiary => const Color(0xFFFFB783);
  Color get _error => const Color(0xFFFFB4AB);
  Color get _textPrimary =>
      widget.isDarkMode ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
  Color get _textMuted =>
      widget.isDarkMode ? Colors.white38 : Colors.black38;
  Color get _glassBorder =>
      widget.isDarkMode
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07);
  Color get _glassBg =>
      widget.isDarkMode
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.7);

  // ── Stagger helper ─────────────────────────────────────────────────────────
  Animation<double> _stagger(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight + 56),

                // 1 ── Hero stat card
                _buildFadeSlide(
                  anim: _stagger(0.0, 0.55),
                  child: _buildHeroStatCard(),
                ),
                const SizedBox(height: 24),

                // 2 ── Polaroid strip
                _buildFadeSlide(
                  anim: _stagger(0.15, 0.65),
                  child: _buildPolaroidStrip(),
                ),
                const SizedBox(height: 28),

                // 3 ── Squad Moments header + grid
                _buildFadeSlide(
                  anim: _stagger(0.3, 0.80),
                  child: _buildMomentsSection(),
                ),
                const SizedBox(height: 28),

                // 4 ── CTA button
                _buildFadeSlide(
                  anim: _stagger(0.5, 1.0),
                  child: _buildCTAButton(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [_primary, _secondary],
        ).createShader(bounds),
        child: Text(
          "Today's Scrapbook ✨",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: _secondary),
          onPressed: () {},
        ),
        if (widget.onThemeToggle != null)
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: _textPrimary,
            ),
            onPressed: widget.onThemeToggle,
          ),
      ],
    );
  }

  // ── Slide + fade wrapper ───────────────────────────────────────────────────
  Widget _buildFadeSlide({
    required Animation<double> anim,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final val = anim.value;
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - val)),
            child: child,
          ),
        );
      },
    );
  }

  // ── 1. Hero Stat Card ──────────────────────────────────────────────────────
  Widget _buildHeroStatCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _glassBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _glassBorder),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // headline + stars icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [_primary, _secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'financially unstable.\nemotionally unforgettable.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.auto_awesome, color: _primary, size: 26),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Today's Scrapbook",
                  style: GoogleFonts.inter(fontSize: 12, color: _textMuted),
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    _buildStatCol('6', 'memories\nuploaded', _secondary),
                    _buildVertDivider(),
                    _buildStatCol('420k', 'spent\ntotal', _error),
                    _buildVertDivider(),
                    _buildStatCol('3', 'hidden gems\nunlocked', _tertiary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildVertDivider() {
    return Container(
      width: 1,
      height: 52,
      color: _glassBorder,
    );
  }

  // ── 2. Polaroid Strip ──────────────────────────────────────────────────────
  Widget _buildPolaroidStrip() {
    final polaroids = [
      _PolaroidData(
        caption: 'cafe chaos ☕',
        rotate: -0.05,
        gradColors: [_primary, _secondary.withValues(alpha: 0.5)],
      ),
      _PolaroidData(
        caption: 'night market vibes 🌙',
        rotate: 0.03,
        gradColors: [_secondary, _tertiary.withValues(alpha: 0.5)],
      ),
      _PolaroidData(
        caption: 'squad goals 🤝',
        rotate: -0.02,
        gradColors: [_tertiary, _error.withValues(alpha: 0.5)],
      ),
      _PolaroidData(
        caption: 'hidden gem unlocked 💎',
        rotate: 0.04,
        gradColors: [_error, _primary.withValues(alpha: 0.5)],
      ),
    ];

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: polaroids.map((p) => _buildPolaroidCard(p)).toList(),
        ),
      ),
    );
  }

  Widget _buildPolaroidCard(_PolaroidData data) {
    return Transform.rotate(
      angle: data.rotate,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 148,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image placeholder
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.gradColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data.caption,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Moments Grid ────────────────────────────────────────────────────────
  Widget _buildMomentsSection() {
    final memories = [
      _MemoryData(
        emoji: '☕',
        time: '2:34 PM',
        gradColors: [_primary.withValues(alpha: 0.8), _secondary.withValues(alpha: 0.6)],
      ),
      _MemoryData(
        emoji: '🌙',
        time: '8:15 PM',
        gradColors: [const Color(0xFF1A1A4E), _primary.withValues(alpha: 0.5)],
      ),
      _MemoryData(
        emoji: '🎉',
        time: '11:02 PM',
        gradColors: [_tertiary.withValues(alpha: 0.8), _error.withValues(alpha: 0.5)],
      ),
      _MemoryData(
        emoji: '🏖️',
        time: '4:45 PM',
        gradColors: [_secondary.withValues(alpha: 0.8), _tertiary.withValues(alpha: 0.6)],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Squad Moments 📸',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: memories.map(_buildMemoryCard).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(_MemoryData data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _glassBorder),
          ),
          child: Stack(
            children: [
              // Gradient placeholder
              Positioned.fill(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: data.gradColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Emoji bottom-left
              Positioned(
                bottom: 10,
                left: 10,
                child: Text(data.emoji, style: const TextStyle(fontSize: 22)),
              ),
              // Timestamp bottom-right
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.time,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 4. CTA Button ─────────────────────────────────────────────────────────
  Widget _buildCTAButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_secondary, _primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _secondary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing your scrapbook recap! 📤✨'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text(
            'Share Recap 📤',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────────────────────
class _PolaroidData {
  final String caption;
  final double rotate;
  final List<Color> gradColors;

  const _PolaroidData({
    required this.caption,
    required this.rotate,
    required this.gradColors,
  });
}

class _MemoryData {
  final String emoji;
  final String time;
  final List<Color> gradColors;

  const _MemoryData({
    required this.emoji,
    required this.time,
    required this.gradColors,
  });
}
