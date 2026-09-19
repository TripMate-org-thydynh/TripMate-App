import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/app_messenger.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../trips/application/trips_providers.dart';
import '../data/games_repository.dart';

class EndTripAwardsScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const EndTripAwardsScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<EndTripAwardsScreen> createState() =>
      _EndTripAwardsScreenState();
}

class _EndTripAwardsScreenState extends ConsumerState<EndTripAwardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
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
        .map((a) => '${a['label']}: ${a['winner']}')
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
      IconData icon,
      String labelKey,
      String descKey,
      Color color,
      LeaderboardRow? winner,
      int count,
    ) {
      if (winner == null) return;
      defs.add({
        'icon': icon,
        'label': tr(labelKey),
        'winner': winner.name,
        'desc': tr(descKey, namedArgs: {'count': '$count'}),
        'color': color,
      });
    }

    final photographer = topBy((r) => r.moments);
    add(
      PhosphorIcons.camera(PhosphorIconsStyle.fill),
      'games.award_photographer',
      'games.award_photographer_desc',
      GenZTokens.chart3,
      photographer,
      photographer?.moments ?? 0,
    );

    final sponsor = topBy((r) => r.expenses);
    add(
      PhosphorIcons.money(PhosphorIconsStyle.fill),
      'games.award_sponsor',
      'games.award_sponsor_desc',
      GenZTokens.chart1,
      sponsor,
      sponsor?.expenses ?? 0,
    );

    final planner = topBy((r) => r.plans);
    add(
      PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
      'games.award_planner',
      'games.award_planner_desc',
      GenZTokens.chart4,
      planner,
      planner?.plans ?? 0,
    );

    final scribe = topBy((r) => r.notes);
    add(
      PhosphorIcons.notepad(PhosphorIconsStyle.fill),
      'games.award_scribe',
      'games.award_scribe_desc',
      GenZTokens.chart5,
      scribe,
      scribe?.notes ?? 0,
    );

    // Giải chung cuộc cho người đóng góp nhiều XP nhất.
    final mvp = rows.first.xp > 0 ? rows.first : null;
    add(
      PhosphorIcons.trophy(PhosphorIconsStyle.fill),
      'games.award_mvp',
      'games.award_mvp_desc',
      GenZTokens.accent,
      mvp,
      mvp?.xp ?? 0,
    );

    return defs;
  }

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  /// Ten chuyen dang mo — rong thi de trong de khong bia ten.
  String get _tripName {
    final id = ref.watch(activeTripIdProvider);
    return ref
            .watch(tripsProvider)
            .maybeWhen(
              data: (trips) {
                for (final t in trips) {
                  if (t.id == id) return t.name;
                }
                return null;
              },
              orElse: () => null,
            ) ??
        '';
  }

  /// So ngay cua chuyen, tinh tu startDate/endDate that.
  int get _tripDays {
    final id = ref.watch(activeTripIdProvider);
    final t = ref
        .watch(tripsProvider)
        .maybeWhen(
          data: (trips) {
            for (final x in trips) {
              if (x.id == id) return x;
            }
            return null;
          },
          orElse: () => null,
        );
    if (t == null) return 0;
    return t.endDate.difference(t.startDate).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final tripId = ref.watch(activeTripIdProvider);
    final rows = tripId == null
        ? const <LeaderboardRow>[]
        : ref
              .watch(leaderboardProvider(tripId))
              .maybeWhen(
                data: (r) => r,
                orElse: () => const <LeaderboardRow>[],
              );
    final awards = _buildAwards(rows);
    if (awards.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
        appBar: AppBar(
          backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
          ),
        ),
        body: AppEmptyState(
          isDark: isDark,
          icon: PhosphorIcons.trophy(),
          title: tr('games.awards_empty_title'),
          body: tr('games.awards_empty_body'),
        ),
      );
    }
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
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
                    icon: PhosphorIcons.arrowLeft(),
                    onTap: () => Navigator.pop(context),
                    isDark: isDark,
                  ),
                  const Spacer(),
                  _buildGlassButton(
                    icon: isDark
                        ? PhosphorIcons.sun()
                        : PhosphorIcons.moon(),
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
                        borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                        border: Border.all(
                          color: isDark ? GenZTokens.lineDark : GenZTokens.line,
                          width: GenZTokens.borderWidthThin,
                        ),
                        color: isDark
                            ? GenZTokens.accentSoftDark
                            : GenZTokens.accentSoft,
                      ),
                      child: Text(
                        'games.trip_wrapped'.tr(),
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: isDark
                              ? GenZTokens.accentDark
                              : GenZTokens.accent,
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? GenZTokens.fillDark : GenZTokens.fill,
                          border: Border.all(
                            color: isDark
                                ? GenZTokens.lineDark
                                : GenZTokens.line,
                            width: GenZTokens.borderWidthThin,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            PhosphorIcons.trophy(PhosphorIconsStyle.fill),
                            color: isDark
                                ? GenZTokens.accentDark
                                : GenZTokens.accent,
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'games.awards_title'.tr(args: [_tripName]),
                      style: AppFonts.heading(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'games.awards_sub'.plural(_tripDays),
                      style: AppFonts.body(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

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

                    // Share button (Single Accent Action of screen)
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                        color: isDark ? GenZTokens.accentDark : GenZTokens.accent,
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                          onTap: () => _shareAwards(awards),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.shareNetwork(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  color: isDark
                                      ? GenZTokens.onAccentDark
                                      : GenZTokens.onAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'games.share_damage'.tr(),
                                  style: AppFonts.heading(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? GenZTokens.onAccentDark
                                        : GenZTokens.onAccent,
                                  ),
                                ),
                              ],
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
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(GenZTokens.space4),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: line,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Center(
                child: Icon(
                  award['icon'] as IconData,
                  color: accentColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
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
                      borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                      color: accentColor.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      award['label'] as String,
                      style: AppFonts.heading(
                        fontSize: 12,
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
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    award['desc'] as String,
                    style: AppFonts.body(
                      fontSize: 12,
                      color: textSecondary,
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
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: surface,
          border: Border.all(
            color: line,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: ink,
        ),
      ),
    );
  }
}
