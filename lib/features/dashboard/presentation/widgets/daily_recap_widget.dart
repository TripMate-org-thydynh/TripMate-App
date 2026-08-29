import 'package:flutter/material.dart';
import '../../data/home_feed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/gen_z_widgets.dart';

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
              'colorHex': _colorFor(a.type),
            },
          )
          .toList(),
      orElse: () => const <Map<String, dynamic>>[],
    );
    final isLoading = async.isLoading;
    return _buildBody(context, activities, isLoading);
  }

  /// Màu viền theo loại hoạt động — giữ bảng màu brutalist của app.
  int _colorFor(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return 0xFF1FA85C;
      case 'MOMENT_SHARED':
        return 0xFF8B4DE8;
      case 'ITINERARY_ADDED':
        return 0xFF3D8BFF;
      case 'POLL_CREATED':
        return 0xFFD6248C;
      default:
        return 0xFFF5822B;
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
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'dashboard.recap_title'.tr(),
            style: AppFonts.heading(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
            ),
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
                        theme.colorScheme.primary,
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
                    color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
                    border: Border.all(
                      color: ink,
                      width: GenZTokens.borderWidthThin,
                    ),
                    boxShadow: [
                      BoxShadow(color: ink, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history_toggle_off,
                        size: 38,
                        color: GenZTokens.orange,
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
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'dashboard.recap_empty_sub'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: isDark
                                    ? GenZTokens.inkSoftDark
                                    : GenZTokens.inkSoft,
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
                    final themeColor = Color(item['colorHex'] as int);

                    return Container(
                      width: 270,
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusCard,
                        ),
                        color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
                        border: Border.all(
                          color: ink,
                          width: GenZTokens.borderWidthThin,
                        ),
                        boxShadow: [
                          BoxShadow(color: ink, offset: const Offset(0, 3)),
                        ],
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? GenZTokens.inkSoftDark
                                        : GenZTokens.inkSoft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['chaosVibe'] as String,
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w800,
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
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
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
