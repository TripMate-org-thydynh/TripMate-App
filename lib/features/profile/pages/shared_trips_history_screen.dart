import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'profile.trip_history_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
      ),
      body: ref
          .watch(tripsProvider)
          .when(
            loading: () =>
                Center(child: CircularProgressIndicator(color: accent, strokeWidth: 2)),
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
                  icon: PhosphorIcons.clockCounterClockwise(),
                  title: 'profile.trip_history_empty_title'.tr(),
                  body: 'profile.trip_history_empty_body'.tr(),
                );
              }
              return RefreshIndicator(
                color: accent,
                onRefresh: () => ref.read(tripsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(GenZTokens.space4),
                  itemCount: past.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GenZTokens.space3),
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
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fmt = DateFormat.yMMMd(context.locale.toLanguageTag());
    final names = t.members.map((m) => m.name).where((n) => n.isNotEmpty);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCoverImage(
            source: t.coverImage,
            aspectRatio: 16 / 9,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: GenZTokens.space2),
                Text(
                  '${fmt.format(t.startDate)} – ${fmt.format(t.endDate)}',
                  style: AppFonts.body(fontSize: 12, color: inkSoft),
                ),
                if (names.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    names.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 12, color: inkSoft),
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
