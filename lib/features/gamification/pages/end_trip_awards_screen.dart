import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/widgets/state_views.dart';
import '../data/games_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart' show tr;
import '../../../core/app_messenger.dart';
class EndTripAwardsScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const EndTripAwardsScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<EndTripAwardsScreen> createState() => _EndTripAwardsScreenState();
}

class _EndTripAwardsScreenState extends ConsumerState<EndTripAwardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  late Animation<double> _shimmerAnim;
  late Animation<double> _floatAnim;

  /// Giải thưởng tính từ ĐÓNG GÓP THẬT của từng thành viên.
  ///
  /// Trước đây màn này liệt kê 5 giải cứng trao cho Minh Nhật / Thảo Ly /
  /// Nam Trung / Hoàng / Lan — những người không có trong chuyến.
  /// Gửi bảng giải ra ngoài app (Zalo/Messenger/...).
  Future<void> _shareAwards(List<Map<String, dynamic>> awards) async {
    if (awards.isEmpty) {
      showGlobalSnack(tr('games.awards_empty'));
      return;
    }
    final lines = awards
        .map((a) => '${a['emoji']} ${a['label']}: ${a['winner']}')
        .join('\n');
    await Share.share(
      '${tr('games.awards_title')}\n$lines',
      subject: 'TripMate — ${tr('games.awards_title')}',
    );
  }

  List<Map<String, dynamic>> _buildAwards(List<LeaderboardRow> rows) {
    if (rows.isEmpty) return const [];

    LeaderboardRow? topBy(int Function(LeaderboardRow) metric) {
      LeaderboardRow? best;
      for (final r in rows) {
        if (metric(r) <= 0) continue;
        if (best == null || metric(r) > metric(best)) best = r;
      }
      return best;
    }

    final defs = <Map<String, dynamic>>[];

    void add(
      String emoji,
      String labelKey,
      String descKey,
      Color color,
      LeaderboardRow? winner,
      int count,
    ) {
      if (winner == null) return;
      defs.add({
        'emoji': emoji,
        'label': tr(labelKey),
        'winner': winner.name,
        'desc': tr(descKey, namedArgs: {'count': '$count'}),
        'color': color,
      });
    }

    final photographer = topBy((r) => r.moments);
    add('📸', 'games.award_photographer', 'games.award_photographer_desc',
        const Color(0xFFC9B8FF), photographer, photographer?.moments ?? 0);

    final sponsor = topBy((r) => r.expenses);
    add('💸', 'games.award_sponsor', 'games.award_sponsor_desc',
        const Color(0xFF1FA85C), sponsor, sponsor?.expenses ?? 0);

    final planner = topBy((r) => r.plans);
    add('🗺️', 'games.award_planner', 'games.award_planner_desc',
        const Color(0xFFFFC107), planner, planner?.plans ?? 0);

    final scribe = topBy((r) => r.notes);
    add('📝', 'games.award_scribe', 'games.award_scribe_desc',
        const Color(0xFF64B5F6), scribe, scribe?.notes ?? 0);

    // Giải chung cuộc cho người đóng góp nhiều XP nhất.
    final mvp = rows.first.xp > 0 ? rows.first : null;
    add('🏆', 'games.award_mvp', 'games.award_mvp_desc',
        const Color(0xFFFF6B6B), mvp, mvp?.xp ?? 0);

    return defs;
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final tripId = ref.watch(activeTripIdProvider);
    final rows = tripId == null
        ? const <LeaderboardRow>[]
        : ref.watch(leaderboardProvider(tripId)).maybeWhen(
            data: (r) => r,
            orElse: () => const <LeaderboardRow>[],
          );
    final awards = _buildAwards(rows);
    if (awards.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF0F0FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        ),
        body: AppEmptyState(
          isDark: isDark,
          icon: Icons.emoji_events_outlined,
          title: tr('games.awards_empty_title'),
          body: tr('games.awards_empty_body'),
        ),
      );
    }
    final bg = isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF0F0FF);
    final surface = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                        isDark: isDark,
                      ),
                      const Spacer(),
                      _buildGlassButton(
                        icon: isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        onTap: widget.onThemeToggle ?? () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // TRIP WRAPPED badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFFC9B8FF,
                              ).withValues(alpha: 0.5),
                            ),
                            color: const Color(
                              0xFFC9B8FF,
                            ).withValues(alpha: isDark ? 0.1 : 0.2),
                          ),
                          child: Text(
                            'TRIP WRAPPED',
                            style: AppFonts.heading(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: const Color(0xFFC9B8FF),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Trophy floating animation
                        AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          ),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFD700),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 0,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🏆', style: TextStyle(fontSize: 44)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'The Phú Quốc Awards',
                          style: AppFonts.heading(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Friendship survived 7 days of financial chaos.',
                          style: AppFonts.body(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // Award cards
                        ...List.generate(awards.length, (index) {
                          final award = awards[index];
                          return _buildAwardCard(
                            award: award,
                            surface: surface,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          );
                        }),

                        const SizedBox(height: 24),

                        // Share button
                        AnimatedBuilder(
                          animation: _shimmerAnim,
                          builder: (context, child) => Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color(0xFFC9B8FF),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFC9B8FF,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 0,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                // Chia sẻ THẬT danh sách giải. Trước đây nút
                                // này chỉ hiện "đang được hoàn thiện".
                                onTap: () => _shareAwards(awards),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.share,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Share the Damage',
                                        style: AppFonts.heading(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardCard({
    required Map<String, dynamic> award,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final Color accentColor = award['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.15),
                    border: Border.all(color: accentColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      award['emoji'] as String,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: accentColor.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          award['label'] as String,
                          style: AppFonts.heading(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        award['winner'] as String,
                        style: AppFonts.heading(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        award['desc'] as String,
                        style: AppFonts.body(
                          fontSize: 12,
                          color: textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
    );
  }
}
