import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../gamification/data/games_repository.dart';
import '../data/ai_repository.dart';

/// Hành trình gợi ý bằng AI.
///
/// Trước đây màn này in cứng 2 mốc ("Cafe The Hill Station" 08:00 và "Đền
/// Fushimi Inari" 14:00) — trộn Đà Lạt với Kyoto, không liên quan chuyến nào.
/// Nay gọi `/ai/trips/:id/timeline` để AI đề xuất theo chuyến thật.
class AiRecommendationTimelineScreen extends ConsumerWidget {
  const AiRecommendationTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'ai.timeline_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          if (tripId != null)
            IconButton(
              icon: Icon(Icons.refresh, color: ink),
              onPressed: () => ref.invalidate(aiTimelineProvider(tripId)),
            ),
        ],
      ),
      body: tripId == null
          ? AppEmptyState(
              isDark: isDark,
              icon: Icons.schedule_outlined,
              title: 'games.need_trip_title'.tr(),
              body: 'games.need_trip_body'.tr(),
            )
          : ref
                .watch(aiTimelineProvider(tripId))
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => AppErrorState(
                    isDark: isDark,
                    error: e,
                    onRetry: () => ref.invalidate(aiTimelineProvider(tripId)),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return AppEmptyState(
                        isDark: isDark,
                        icon: Icons.schedule_outlined,
                        title: 'ai.timeline_title'.tr(),
                        body: 'ai.timeline_empty'.tr(),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(aiTimelineProvider(tripId)),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(GenZTokens.space5),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: GenZTokens.space4),
                        itemBuilder: (_, i) => _card(isDark, items[i]),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _card(bool isDark, SuggestedActivity a) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GenZTokens.yellow,
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              border: Border.all(
                color: GenZTokens.ink,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Text(
              a.time,
              style: AppFonts.heading(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: GenZTokens.ink,
              ),
            ),
          ),
          const SizedBox(width: GenZTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.location,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                if (a.reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    a.reason,
                    style: AppFonts.body(
                      fontSize: 12.5,
                      color: inkSoft,
                      height: 1.4,
                    ),
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
