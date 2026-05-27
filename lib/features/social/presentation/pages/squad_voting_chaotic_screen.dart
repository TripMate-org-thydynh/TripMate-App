import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadVotingChaoticScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SquadVotingChaoticScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SquadVotingChaoticScreen> createState() => _SquadVotingChaoticScreenState();
}

class _SquadVotingChaoticScreenState extends State<SquadVotingChaoticScreen>
    with SingleTickerProviderStateMixin {
  // Timer State
  int _secondsLeft = 102; // 1 minute 42 seconds
  Timer? _countdownTimer;

  // Voting State
  int _bunBoVotes = 13;
  int _bbqVotes = 7;
  int? _userVoteIndex; // null = hasn't voted, 0 = Bun Bo, 1 = BBQ

  // Active status feed
  final List<String> _activityFeed = [
    'Minh just swiped 🍜',
    'Thảo Ly voted for BBQ 🔥',
    'Phú Khang skipped voting 💀',
    'Vy swiped 🍜',
  ];
  int _feedIndex = 0;
  late Timer _feedTimer;

  // Animation controller for pulsers
  late AnimationController _pulseController;

  static const _darkBgStart = Color(0xFF0F172A);
  static const _darkBgEnd = Color(0xFF020617);
  static const _darkSurface = Color(0xFF1E293B);
  static const _primaryDark = Color(0xFFD0BCFF);
  static const _secondaryDark = Color(0xFF45DFA4);

  static const _lightBgStart = Color(0xFFF8FAFC);
  static const _lightBgEnd = Color(0xFFF1F5F9);
  static const _primaryLight = Color(0xFF6D3BD7);
  static const _secondaryLight = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _secondsLeft = 102; // Reset for visual looping
          }
        });
      }
    });

    // Activity feed loop
    _feedTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _feedIndex = (_feedIndex + 1) % _activityFeed.length;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _feedTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final bgStart = isDark ? _darkBgStart : _lightBgStart;
    final bgEnd = isDark ? _darkBgEnd : _lightBgEnd;
    final surface = isDark ? _darkSurface : Colors.white;
    final primary = isDark ? _primaryDark : _primaryLight;
    final secondary = isDark ? _secondaryDark : _secondaryLight;

    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white70 : Colors.black54;

    // Vote math
    final totalVotes = _bunBoVotes + _bbqVotes;
    final bunBoPercent = totalVotes > 0 ? (_bunBoVotes / totalVotes) * 100 : 50.0;
    final bbqPercent = totalVotes > 0 ? (_bbqVotes / totalVotes) * 100 : 50.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header Bar ─────────────────────────────────────────────
              _buildHeader(isDark, textPrimary, primary),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // ── Tagline: democracy but emotionally unstable. ────────
                      _buildTaglineSection(isDark, textPrimary, textMuted, secondary),

                      const SizedBox(height: 24),

                      // ── Question Header ──────────────────────────────────
                      _buildQuestionHeader(textPrimary),

                      const SizedBox(height: 20),

                      // ── Interactive Voting Options ───────────────────────
                      _buildVotingOption(
                        isDark: isDark,
                        index: 0,
                        title: 'Bún bò Huế (The OG)',
                        emoji: '🍜',
                        percent: bunBoPercent,
                        votes: _bunBoVotes,
                        primary: primary,
                        secondary: secondary,
                        surface: surface,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onVote: () {
                          setState(() {
                            if (_userVoteIndex == null) {
                              _bunBoVotes++;
                              _userVoteIndex = 0;
                            } else if (_userVoteIndex == 1) {
                              _bbqVotes--;
                              _bunBoVotes++;
                              _userVoteIndex = 0;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildVotingOption(
                        isDark: isDark,
                        index: 1,
                        title: 'Korean BBQ (Chaos Mode)',
                        emoji: '🔥',
                        percent: bbqPercent,
                        votes: _bbqVotes,
                        primary: primary,
                        secondary: secondary,
                        surface: surface,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onVote: () {
                          setState(() {
                            if (_userVoteIndex == null) {
                              _bbqVotes++;
                              _userVoteIndex = 1;
                            } else if (_userVoteIndex == 0) {
                              _bunBoVotes--;
                              _bbqVotes++;
                              _userVoteIndex = 1;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Activity Swiped Alert ────────────────────────────
                      _buildSwipeFeed(isDark, surface, secondary, textPrimary),

                      const SizedBox(height: 24),

                      // ── AI Suggestion Banner ─────────────────────────────
                      _buildAiSuggestion(isDark, surface, primary, secondary, textPrimary, textMuted),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Bottom Nav Bar ─────────────────────────────────────────
              _buildBottomNavBar(isDark, surface, primary, secondary, textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color textPrimary, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // [Interactive] Text: "arrow_back"
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primary, size: 20),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'arrow_back',
          ),
          // [h1] trip.mate
          Text(
            'trip.mate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: textPrimary, size: 24),
                onPressed: () {},
                tooltip: 'notifications',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaglineSection(
      bool isDark, Color textPrimary, Color textMuted, Color secondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [h2] democracy but emotionally unstable.
              Text(
                'democracy but emotionally unstable.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Let the chaos decide your meals.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Timer display: timer + "1:42 left"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.9 + 0.2 * math.sin(_pulseController.value * math.pi * 2),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Text(
                '$_formattedTime left',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(Color textPrimary) {
    // [h3] 🍜 Bún bò or BBQ?
    return Text(
      '🍜 Bún bò or BBQ?',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
    );
  }

  Widget _buildVotingOption({
    required bool isDark,
    required int index,
    required String title,
    required String emoji,
    required double percent,
    required int votes,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color textPrimary,
    required Color textMuted,
    required VoidCallback onVote,
  }) {
    final isSelected = _userVoteIndex == index;
    final voteColor = index == 0 ? primary : secondary;

    return GestureDetector(
      onTap: onVote,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? voteColor : primary.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: voteColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Glowing Glassmorphic Progress Indicator bar
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final targetWidth = constraints.maxWidth * (percent / 100);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: targetWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            voteColor.withValues(alpha: 0.1),
                            voteColor.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(19),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Text and Details Content Layer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  // Emoji container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: voteColor.withValues(alpha: 0.15),
                      border: Border.all(color: voteColor.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Option Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$votes votes',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Percentage text
                  Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: voteColor,
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

  Widget _buildSwipeFeed(bool isDark, Color surface, Color secondary, Color textPrimary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.swipe_rounded, color: secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                _activityFeed[_feedIndex],
                key: ValueKey<int>(_feedIndex),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
          ),
          Text(
            'Live',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestion(
      bool isDark, Color surface, Color primary, Color secondary, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // [span] smart_toy / Matey AI Suggests
              Icon(Icons.smart_toy_rounded, color: secondary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Matey AI Suggests',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // [p] "Why not both? BBQ first, Bún bò for breakfast."
          Text(
            '"Why not both? BBQ first, Bún bò for breakfast."',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The squad has spoken.',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(
      bool isDark, Color surface, Color primary, Color secondary, Color textMuted) {
    // Bottom Nav Bar mimicking:
    // [Interactive] Text: "home_max"
    // [Interactive] Text: "group" (Selected with shadow bg-secondary/20 shadow-[0_0_15px_rgba(69,223,164,0.4)])
    // [Interactive] Text: "map"
    // [Interactive] Text: "notifications"

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.75 : 0.85),
        border: Border(
          top: BorderSide(
            color: primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home_max_rounded, color: textMuted, size: 24),
            onPressed: () {},
            tooltip: 'home_max',
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.group_rounded, color: secondary, size: 24),
          ),
          IconButton(
            icon: Icon(Icons.map_outlined, color: textMuted, size: 24),
            onPressed: () {},
            tooltip: 'map',
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: textMuted, size: 24),
            onPressed: () {},
            tooltip: 'notifications',
          ),
        ],
      ),
    );
  }
}
