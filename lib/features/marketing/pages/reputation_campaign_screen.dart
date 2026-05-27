import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReputationCampaignScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ReputationCampaignScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<ReputationCampaignScreen> createState() => _ReputationCampaignScreenState();
}

class _ReputationCampaignScreenState extends State<ReputationCampaignScreen> {
  String? _selectedVoteKey; // 'FLAKER', 'CHAOS_KING', 'OVER_PLANNER'
  int _flakerVotes = 32;
  int _chaosKingVotes = 58;
  int _overPlannerVotes = 10;
  bool _hasVoted = false;

  void _handleVote(String key) {
    if (_hasVoted) return;
    setState(() {
      _selectedVoteKey = key;
      _hasVoted = true;

      // Increment vote counts dynamically
      if (key == 'FLAKER') _flakerVotes++;
      if (key == 'CHAOS_KING') _chaosKingVotes++;
      if (key == 'OVER_PLANNER') _overPlannerVotes++;

      // Normalize to 100% total
      final total = _flakerVotes + _chaosKingVotes + _overPlannerVotes;
      _flakerVotes = ((_flakerVotes / total) * 100).round();
      _chaosKingVotes = ((_chaosKingVotes / total) * 100).round();
      _overPlannerVotes = 100 - _flakerVotes - _chaosKingVotes; // Make sure it sums to 100
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔥 Đã bình chọn thành công! Cảm ơn cưng đã định hình Vibe Squad.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: TripMateTheme.darkSecondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final bgColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Ambient aurora backgrounds
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.08),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Hub Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: textPrimary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'trip.mate',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                              color: primaryColor,
                            ),
                            onPressed: widget.onThemeToggle,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: borderCol),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.notifications_none, color: textPrimary),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campaign badge tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '👑 SQUAD REPUTATION',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'who is the chaos\nking in your group?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Every trip has one. The instigator, the wildcard, the reason you barely made your flight. Time to call them out.",
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Option 1: The Flaker
                        _buildPollCard(
                          'FLAKER',
                          'The Flaker 🦥',
                          '"Yeah I\'ll be ready in 5 mins" *is currently in the shower*',
                          _flakerVotes,
                          borderCol,
                          surfaceColor,
                          textPrimary,
                          textSecondary,
                        ),
                        const SizedBox(height: 12),

                        // Option 2: The Chaos King (Trending active layout)
                        _buildPollCard(
                          'CHAOS_KING',
                          'The Chaos King 🔥👑',
                          'Thrives on no sleep. Suggests a 4 AM hike after a night out. Will fight a seagull.',
                          _chaosKingVotes,
                          borderCol,
                          surfaceColor,
                          textPrimary,
                          textSecondary,
                          isTrending: true,
                        ),
                        const SizedBox(height: 12),

                        // Option 3: The Over-Planner
                        _buildPollCard(
                          'OVER_PLANNER',
                          'The Over-Planner 📋',
                          'Has an itinerary broken down by the minute. Cries internally when plans change.',
                          _overPlannerVotes,
                          borderCol,
                          surfaceColor,
                          textPrimary,
                          textSecondary,
                        ),

                        const SizedBox(height: 36),

                        // Poll Submit action button
                        GestureDetector(
                          onTap: _hasVoted ? null : () => _handleVote('CHAOS_KING'),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  secondaryColor,
                                  secondaryColor.withValues(alpha: 0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryColor.withValues(alpha: 0.35),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.how_to_vote, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _hasVoted ? 'Vote Submitted' : 'Vote as Chaos King',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Mock Bottom Navigation
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(top: BorderSide(color: borderCol)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBottomIcon(Icons.explore_outlined, false, textSecondary, primaryColor),

                      // highlighted active squad tab
                      Transform.translate(
                        offset: const Offset(0, -14),
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: secondaryColor.withValues(alpha: 0.2),
                            border: Border.all(color: secondaryColor.withValues(alpha: 0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Icon(Icons.group, color: secondaryColor, size: 28),
                        ),
                      ),

                      _buildBottomIcon(Icons.map_outlined, false, textSecondary, primaryColor),
                      _buildBottomIcon(Icons.person_outline, false, textSecondary, primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(
    String key,
    String title,
    String desc,
    int percentage,
    Color borderCol,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary, {
    bool isTrending = false,
  }) {
    final isSelected = _selectedVoteKey == key;
    final theme = Theme.of(context);
    final secondaryColor = theme.brightness == Brightness.dark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final primaryColor = theme.brightness == Brightness.dark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;

    return GestureDetector(
      onTap: () => _handleVote(key),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? secondaryColor
                : isTrending
                    ? primaryColor.withValues(alpha: 0.5)
                    : borderCol,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Custom progress track overlay inside card
            if (_hasVoted)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isSelected ? secondaryColor : Colors.grey).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: textPrimary,
                              ),
                            ),
                            if (isTrending) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 10),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Trending',
                                      style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: GoogleFonts.inter(fontSize: 12, color: textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  // Vote percentages
                  if (_hasVoted) ...[
                    const SizedBox(width: 16),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isSelected ? secondaryColor : textPrimary,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, bool isActive, Color inactiveCol, Color activeCol) {
    return Icon(
      icon,
      color: isActive ? activeCol : inactiveCol.withValues(alpha: 0.6),
      size: 24,
    );
  }
}
