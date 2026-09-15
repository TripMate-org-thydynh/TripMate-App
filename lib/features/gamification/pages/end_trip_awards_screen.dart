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
      GenZTokens.lilac,
      photographer,
      photographer?.moments ?? 0,
    );

    final sponsor = topBy((r) => r.expenses);
    add(
      PhosphorIcons.money(PhosphorIconsStyle.fill),
      'games.award_sponsor',
      'games.award_sponsor_desc',
      GenZTokens.green,
      sponsor,
      sponsor?.expenses ?? 0,
    );

    final planner = topBy((r) => r.plans);
    add(
      PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
      'games.award_planner',
      'games.award_planner_desc',
      GenZTokens.yellow,
      planner,
      planner?.plans ?? 0,
    );

    final scribe = topBy((r) => r.notes);
    add(
      PhosphorIcons.notepad(PhosphorIconsStyle.fill),
      'games.award_scribe',
      'games.award_scribe_desc',
      GenZTokens.blue,
      scribe,
      scribe?.notes ?? 0,
    );

    // Giải chung cuộc cho người đóng góp nhiều XP nhất.
    final mvp = rows.first.xp > 0 ? rows.first : null;
    add(
      PhosphorIcons.trophy(PhosphorIconsStyle.fill),
      'games.award_mvp',
      'games.award_mvp_desc',
      GenZTokens.red,
      mvp,
      mvp?.xp ?? 0,
    );

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
    final isDark = widget.isDarkMode;
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
          backgroundColor: Colors.transparent,
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
    // Nen the mo (trang alpha 0.7) tung lam noi dung the khong duoc ve ra
    // tren may — dung mau surface dac cua design token.
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

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
              decoration: const BoxDecoration(
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
              decoration: const BoxDecoration(
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
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GenZTokens.lilac.withValues(alpha: 0.5),
                            ),
                            color: GenZTokens.lilac
                                .withValues(alpha: isDark ? 0.1 : 0.2),
                          ),
                          child: Text(
                            'games.trip_wrapped'.tr(),
                            style: AppFonts.heading(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: GenZTokens.lilac,
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
                              color: GenZTokens.yellow,
                              border: Border.all(
                                color: isDark
                                    ? GenZTokens.inkDark
                                    : GenZTokens.ink,
                                width: GenZTokens.borderWidthThin,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GenZTokens.yellow
                                      .withValues(alpha: 0.4),
                                  blurRadius: 0,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                PhosphorIcons.trophy(PhosphorIconsStyle.fill),
                                color: GenZTokens.ink,
                                size: 44,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          // Ten chuyen THAT — truoc day moi chuyen deu hien
                          // "The Phu Quoc Awards".
                          'games.awards_title'.tr(args: [_tripName]),
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
                          // So ngay THAT cua chuyen, khong con in cung "7 days".
                          'games.awards_sub'.plural(_tripDays),
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
                              color: GenZTokens.yellow,
                              border: Border.all(
                                color: isDark
                                    ? GenZTokens.inkDark
                                    : GenZTokens.ink,
                                width: GenZTokens.borderWidthThin,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? GenZTokens.inkDark
                                          : GenZTokens.ink)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 0,
                                  offset: const Offset(0, 4),
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
                                      Icon(
                                        PhosphorIcons.shareNetwork(
                                          PhosphorIconsStyle.bold,
                                        ),
                                        color: GenZTokens.ink,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'games.share_damage'.tr(),
                                        style: AppFonts.heading(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: GenZTokens.ink,
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
                  child: Icon(
                    award['icon'] as IconData,
                    color: accentColor,
                    size: 26,
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
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
            border: Border.all(
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
          ),
        ),
      ),
    );
  }
}
