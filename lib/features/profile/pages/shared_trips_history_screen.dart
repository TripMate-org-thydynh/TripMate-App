import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/trip_cover_image.dart';
import '../../trips/application/trips_providers.dart';
import '../../trips/domain/trip.dart';

/// Lịch sử các chuyến đã đi xong.
///
/// Trước đây màn này in cứng 2 chuyến bịa ("Phú Quốc Escape", "Đà Lạt Săn Mây")
/// với danh sách thành viên không tồn tại. Nay lọc từ chuyến THẬT của user —
/// những chuyến đã qua ngày kết thúc — và hiện đúng thành viên của chuyến.
class SharedTripsHistoryScreen extends ConsumerWidget {
  const SharedTripsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'profile.trip_history_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: ref
          .watch(tripsProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.read(tripsProvider.notifier).refresh(),
            ),
            data: (trips) {
              // So theo ngày (bỏ giờ) để chuyến kết thúc hôm nay vẫn tính là
              // đang diễn ra, không nhảy vào lịch sử sớm một ngày.
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final past =
                  trips.where((t) => t.endDate.isBefore(today)).toList()
                    ..sort((a, b) => b.endDate.compareTo(a.endDate));

              if (past.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.history,
                  title: 'profile.trip_history_empty_title'.tr(),
                  body: 'profile.trip_history_empty_body'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref.read(tripsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(GenZTokens.space5),
                  itemCount: past.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GenZTokens.space4),
                  itemBuilder: (_, i) => _card(context, isDark, past[i]),
                ),
              );
            },
          ),
    );
  }

  Widget _card(BuildContext context, bool isDark, Trip t) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fmt = DateFormat.yMMMd(context.locale.toLanguageTag());
    final names = t.members.map((m) => m.name).where((n) => n.isNotEmpty);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            width: double.infinity,
            child: TripCoverImage(source: t.coverImage),
          ),
          Padding(
            padding: const EdgeInsets.all(GenZTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: ink,
                  ),
                ),
                const SizedBox(height: GenZTokens.space2),
                Text(
                  '${fmt.format(t.startDate)} – ${fmt.format(t.endDate)}',
                  style: AppFonts.body(fontSize: 12.5, color: inkSoft),
                ),
                if (names.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    names.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 12.5, color: inkSoft),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
