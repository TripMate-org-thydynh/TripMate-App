import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadActivityFeedScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SquadActivityFeedScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SquadActivityFeedScreen> createState() => _SquadActivityFeedScreenState();
}

class _SquadActivityFeedScreenState extends State<SquadActivityFeedScreen>
    with TickerProviderStateMixin {
  late AnimationController _livePulse;

  @override
  void initState() {
    super.initState();
    _livePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _livePulse.dispose();
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
            // CUSTOM APP BAR
            _buildAppBar(isDark, primaryColor, secondaryColor, textPrimary),
            const SizedBox(height: 4),

            // SQUAD ACTIVITY TITLE & LIVE PILL
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Squad Activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Text(
                        'Live updates from the trip ⚡️',
                        style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                      ),
                    ],
                  ),
                  // LIVE BADGE
                  AnimatedBuilder(
                    animation: _livePulse,
                    builder: (_, child) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2340) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4 + 0.3 * _livePulse.value),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.2 * _livePulse.value),
                            blurRadius: 12,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4ADE80),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4ADE80).withValues(alpha: 0.7 * _livePulse.value),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ACTIVITY FEED
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ITEM 1: Thảo Ly uploaded memories
                  _buildMemoryUploadItem(isDark, primaryColor, secondaryColor, cardBg, textPrimary, textMuted),
                  const SizedBox(height: 14),

                  // ITEM 2: Nam Trung paid
                  _buildPaymentItem(isDark, primaryColor, secondaryColor, cardBg, textPrimary, textMuted),
                  const SizedBox(height: 14),

                  // ITEM 3: Phú Khang unlocked chaos bingo
                  _buildBingoItem(isDark, primaryColor, secondaryColor, cardBg, textPrimary, textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark, primaryColor, secondaryColor),
    );
  }

  Widget _buildAppBar(bool isDark, Color primaryColor, Color secondaryColor, Color textPrimary) {
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
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  ),
                  child: Icon(Icons.diamond, color: primaryColor, size: 20),
                ),
              ),
              Text(
                'trip.mate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: primaryColor,
                  letterSpacing: -1.2,
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

  Widget _buildMemoryUploadItem(bool isDark, Color primaryColor, Color secondaryColor, Color cardBg, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Center(child: Text('📸', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Thảo Ly ',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'uploaded 6 memories 📸',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('2m ago', style: TextStyle(fontSize: 11, color: textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Photo thumbnails stack
          Row(
            children: [
              ...['🏔️', '☕', '🌿', '🎋', '🌄'].asMap().entries.map((e) {
                return Container(
                  margin: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: primaryColor.withValues(alpha: 0.1 + e.key * 0.03),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Center(child: Text(e.value, style: const TextStyle(fontSize: 24))),
                );
              }),
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: primaryColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    '+4',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Reactions row
          Row(
            children: [
              _buildReactionChip('🔥', '4', isDark),
              const SizedBox(width: 8),
              _buildReactionChip('😍', '2', isDark),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Icon(Icons.add_reaction, size: 16, color: textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(bool isDark, Color primaryColor, Color secondaryColor, Color cardBg, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.payments_outlined, color: Colors.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nam Trung ',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                      TextSpan(
                        text: 'paid 120k 💸',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Late night Pho runs', style: GoogleFonts.inter(fontSize: 13, color: textMuted)),
                const SizedBox(height: 4),
                Text('45m ago', style: TextStyle(fontSize: 11, color: textMuted.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '120k ₫',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBingoItem(bool isDark, Color primaryColor, Color secondaryColor, Color cardBg, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(alpha: 0.15),
                ),
                child: const Center(child: Text('🛵', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Phú Khang ',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                          TextSpan(
                            text: 'unlocked chaos bingo 🔥',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text('2h ago', style: TextStyle(fontSize: 11, color: textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Mini bingo quote
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Text(
              '"Lost the rental key"',
              style: GoogleFonts.caveat(
                fontSize: 17,
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bingo progress
          Row(
            children: [
              Icon(Icons.hotel_class, size: 14, color: Colors.amber[600]),
              const SizedBox(width: 6),
              Text(
                '3/9 Bingo squares completed',
                style: GoogleFonts.inter(fontSize: 12, color: textMuted, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              // Mini 3x3 bingo grid
              SizedBox(
                width: 48,
                height: 48,
                child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemBuilder: (_, i) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i < 3
                          ? Colors.orange.withValues(alpha: 0.5)
                          : isDark
                              ? Colors.white12
                              : Colors.black12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionChip(String emoji, String count, bool isDark) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, Color primaryColor, Color secondaryColor) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? const Color(0x80171F33) : const Color(0xC0FFFFFF),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.map_outlined, color: isDark ? Colors.white38 : Colors.black38, size: 26),
              Icon(Icons.add_circle_outline, color: isDark ? Colors.white38 : Colors.black38, size: 26),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.auto_awesome, color: primaryColor, size: 26),
              ),
              Icon(Icons.search_outlined, color: isDark ? Colors.white38 : Colors.black38, size: 26),
              Icon(Icons.person_outline, color: isDark ? Colors.white38 : Colors.black38, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
