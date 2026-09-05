import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/games_repository.dart';
import '../../../core/widgets/state_views.dart';

/// Màn danh sách nhiệm vụ dùng chung cho "Nhiệm vụ tuần" và "Sự kiện theo mùa".
///
/// Cả hai màn trước đây là danh sách cứng với tiến độ bịa. Nay mục tiêu vẫn do
/// backend biên soạn, nhưng **tiến độ tính từ dữ liệu thật** của chuyến.
class ChallengeListScreen extends ConsumerWidget {
  final String titleKey;
  final IconData emptyIcon;

  /// Provider trả danh sách nhiệm vụ (tuần hoặc mùa).
  final FutureProviderFamily<List<GameChallenge>, String> provider;

  const ChallengeListScreen({
    super.key,
    required this.titleKey,
    required this.emptyIcon,
    required this.provider,
  });

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
          titleKey.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: tripId == null
          ? AppEmptyState(
              isDark: isDark,
              icon: emptyIcon,
              title: 'games.need_trip_title'.tr(),
              body: 'games.need_trip_body'.tr(),
            )
          : ref
                .watch(provider(tripId))
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => AppErrorState(
                    isDark: isDark,
                    error: e,
                    onRetry: () => ref.invalidate(provider(tripId)),
                  ),
                  data: (items) => RefreshIndicator(
                    onRefresh: () async => ref.invalidate(provider(tripId)),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(GenZTokens.space5),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: GenZTokens.space4),
                      itemBuilder: (context, i) =>
                          _tile(context, isDark, items[i]),
                    ),
                  ),
                ),
    );
  }

  Widget _tile(BuildContext context, bool isDark, GameChallenge c) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: c.completed ? GenZTokens.green : surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.title,
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: c.completed ? GenZTokens.ink : ink,
                  ),
                ),
              ),
              const SizedBox(width: GenZTokens.space2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GenZTokens.space3,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GenZTokens.yellow,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: GenZTokens.ink,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  'games.reward_xp'.tr(namedArgs: {'xp': '${c.rewardXP}'}),
                  style: AppFonts.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GenZTokens.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            c.desc,
            style: AppFonts.body(
              fontSize: 13,
              height: 1.4,
              color: c.completed
                  ? GenZTokens.ink.withValues(alpha: 0.8)
                  : inkSoft,
            ),
          ),
          const SizedBox(height: GenZTokens.space4),
          ClipRRect(
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            child: LinearProgressIndicator(
              value: c.percent / 100,
              minHeight: 10,
              backgroundColor: ink.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                c.completed ? GenZTokens.ink : GenZTokens.green,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            c.completed
                ? 'games.challenge_done'.tr()
                : '${c.current}/${c.target}',
            style: AppFonts.mono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.completed ? GenZTokens.ink : inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
