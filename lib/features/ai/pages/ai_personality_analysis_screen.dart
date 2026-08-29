import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  const AiPersonalityAnalysisScreen({super.key});

  static const _cardColors = [
    GenZTokens.yellow,
    GenZTokens.lilac,
    GenZTokens.pink,
    GenZTokens.green,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'ai.personality_title'.tr(),
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
              onPressed: () =>
                  ref.invalidate(squadPersonalityProvider(tripId)),
            ),
        ],
      ),
      body: tripId == null
          ? AppEmptyState(
              isDark: isDark,
              icon: Icons.theater_comedy_outlined,
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
                        icon: Icons.theater_comedy_outlined,
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
                        itemBuilder: (_, i) => _card(roasts[i], i),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _card(SquadRoast r, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: _cardColors[index % _cardColors.length],
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: GenZTokens.ink,
          width: GenZTokens.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: GenZTokens.ink,
            ),
          ),
          if (r.type.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              r.type,
              style: AppFonts.heading(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: GenZTokens.ink,
              ),
            ),
          ],
          if (r.roast.isNotEmpty) ...[
            const SizedBox(height: GenZTokens.space3),
            Text(
              r.roast,
              style: AppFonts.body(
                fontSize: 13.5,
                color: GenZTokens.ink,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
