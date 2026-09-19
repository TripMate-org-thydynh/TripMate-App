import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../gamification/data/games_repository.dart';
import '../data/ai_repository.dart';

/// Phân tích tính cách squad — AI "roast" từng thành viên dựa trên chi tiêu.
///
/// Trước đây màn này in cứng 3 người không tồn tại (Alex Nguyễn / Trần Bình /
/// Minh Nhật) và không hề gọi API, nên ai mở ra cũng thấy y hệt nhau. Nay gọi
/// `/ai/trips/:id/personality` với chuyến thật; AI bận thì BE trả 503 và màn
/// này hiện đúng thông báo đó.
class AiPersonalityAnalysisScreen extends ConsumerWidget {
  final bool? isDarkMode;

  const AiPersonalityAnalysisScreen({super.key, this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark =
        isDarkMode ?? (Theme.of(context).brightness == Brightness.dark);
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'ai.personality_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        actions: [
          if (tripId != null)
            IconButton(
              icon: Icon(PhosphorIcons.arrowsClockwise(), color: ink),
              onPressed: () => ref.invalidate(squadPersonalityProvider(tripId)),
              tooltip: 'common.refresh'.tr(),
            ),
        ],
      ),
      body: tripId == null
          ? AppEmptyState(
              isDark: isDark,
              icon: PhosphorIcons.maskHappy(),
              title: 'games.need_trip_title'.tr(),
              body: 'games.need_trip_body'.tr(),
            )
          : ref
                .watch(squadPersonalityProvider(tripId))
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => AppErrorState(
                    isDark: isDark,
                    error: e,
                    onRetry: () =>
                        ref.invalidate(squadPersonalityProvider(tripId)),
                  ),
                  data: (roasts) {
                    if (roasts.isEmpty) {
                      return AppEmptyState(
                        isDark: isDark,
                        icon: PhosphorIcons.maskHappy(),
                        title: 'ai.personality_title'.tr(),
                        body: 'ai.personality_empty'.tr(),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(squadPersonalityProvider(tripId)),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(GenZTokens.space5),
                        itemCount: roasts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: GenZTokens.space4),
                        itemBuilder: (ctx, i) => _card(ctx, isDark, roasts[i]),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _card(BuildContext context, bool isDark, SquadRoast r) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = Theme.of(context).colorScheme.primary;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
              ),
              if (r.type.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  ),
                  child: Text(
                    r.type,
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          if (r.roast.isNotEmpty) ...[
            const SizedBox(height: GenZTokens.space3),
            Text(
              r.roast,
              style: AppFonts.body(
                fontSize: 15,
                color: inkSoft,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
