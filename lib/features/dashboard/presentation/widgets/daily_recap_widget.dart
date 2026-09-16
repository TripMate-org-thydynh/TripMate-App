import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../data/home_feed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/gen_z_widgets.dart';
import '../../../moments/presentation/pages/trip_recap_reel_screen.dart';
import '../../../trips/application/trips_providers.dart';
import '../../../gamification/data/games_repository.dart';

/// Recap hoạt động trong ngày của squad.
///
/// Trước đây widget tự gọi API một lần trong `initState`. Màn Home nằm trong
/// `IndexedStack` nên widget không bao giờ dựng lại — thêm chi tiêu hay điểm
/// lịch trình xong quay về vẫn thấy "Chưa có hoạt động nào". Nay dùng chung
/// `squadActivitiesProvider` với marquee và Live Updates, được invalidate sau
/// mọi thao tác.
class DailyRecapWidget extends ConsumerWidget {
  const DailyRecapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(squadActivitiesProvider);
    final activities = async.maybeWhen(
      data: (items) => items
          .take(6)
          .map(
            (a) => {
              'title': _activityTitle(a.type),
              'time': a.tripName,
              'chaosVibe': _activityVibe(a.type),
              'details': a.label,
              'color': _colorFor(a.type, isDark),
            },
          )
          .toList(),
      orElse: () => const <Map<String, dynamic>>[],
    );
    final isLoading = async.isLoading;
    return _buildBody(context, activities, isLoading, isDark);
  }

  Color _colorFor(String type, bool isDark) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return isDark ? GenZTokens.successDark : GenZTokens.success;
      case 'MOMENT_SHARED':
        return GenZTokens.chart5;
      case 'ITINERARY_ADDED':
        return isDark ? GenZTokens.infoDark : GenZTokens.info;
      case 'POLL_CREATED':
        return GenZTokens.chart2;
      default:
        return isDark ? GenZTokens.accentDark : GenZTokens.accent;
    }
  }

  String _activityTitle(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return 'dashboard.act_expense'.tr();
      case 'MOMENT_SHARED':
        return 'dashboard.act_moment'.tr();
      case 'GAME_STARTED':
        return 'dashboard.act_game'.tr();
      case 'CHAT_SENT':
        return 'dashboard.act_chat'.tr();
      case 'ITINERARY_ADDED':
        return 'dashboard.act_itinerary'.tr();
      case 'MEMBER_JOINED':
        return 'dashboard.act_member'.tr();
      default:
        return 'dashboard.act_default'.tr();
    }
  }

  String _activityVibe(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return 'dashboard.vibe_expense'.tr();
      case 'MOMENT_SHARED':
        return 'dashboard.vibe_moment'.tr();
      case 'GAME_STARTED':
        return 'dashboard.vibe_game'.tr();
      case 'CHAT_SENT':
        return 'dashboard.vibe_chat'.tr();
      case 'ITINERARY_ADDED':
        return 'dashboard.vibe_itinerary'.tr();
      case 'POLL_CREATED':
        return 'dashboard.vibe_poll'.tr();
      default:
        return 'dashboard.vibe_default'.tr();
    }
  }

  Widget _buildBody(
    BuildContext context,
    List<Map<String, dynamic>> activities,
    bool isLoading,
    bool isDark,
  ) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'dashboard.recap_title'.tr(),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.5,
                    color: ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final container = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );
                  final activeId = container.read(activeTripIdProvider);
                  final trips = container.read(tripsProvider).maybeWhen(
                    data: (list) => list,
                    orElse: () => const [],
                  );
                  final tripId =
                      activeId ?? (trips.isNotEmpty ? trips.first.id : null);
                  if (tripId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'trips.none_yet_cta2'.tr(),
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripRecapReelScreen(
                        isDarkMode: isDark,
                        tripId: tripId,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                    border: Border.all(
                      color: line,
                      width: GenZTokens.borderWidthThin,
                    ),
                    boxShadow: GenZTokens.hardShadow(ink, isDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                        size: 14,
                        color: accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'dashboard.wrapped_reel'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accent,
                      ),
                    ),
                  ),
                )
              : activities.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                    color: surface,
                    border: Border.all(
                      color: line,
                      width: GenZTokens.borderWidthThin,
                    ),
                    boxShadow: GenZTokens.hardShadow(ink, isDark),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.clockCounterClockwise(),
                        size: 38,
                        color: accent,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'dashboard.recap_empty_title'.tr(),
                              style: AppFonts.heading(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'dashboard.recap_empty_sub'.tr(),
                              style: AppFonts.body(
                                fontSize: 12,
                                color: inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final item = activities[index];
                    final themeColor = item['color'] as Color;

                    return Container(
                      width: 270,
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusCard,
                        ),
                        color: surface,
                        border: Border.all(
                          color: line,
                          width: GenZTokens.borderWidthThin,
                        ),
                        boxShadow: GenZTokens.hardShadow(ink, isDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PillTag(
                                text: item['title'] as String,
                                color: themeColor,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  (item['time'] as String).toUpperCase(),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: AppFonts.mono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: inkSoft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['chaosVibe'] as String,
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              item['details'] as String,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                fontSize: 12,
                                color: inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
