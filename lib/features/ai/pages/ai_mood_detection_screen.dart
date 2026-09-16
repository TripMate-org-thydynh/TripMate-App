import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../gamification/data/games_repository.dart';
import '../data/ai_repository.dart';

/// Đo chỉ số tâm trạng squad.
///
/// Trước đây màn này in cứng `_tensionLevel = 2` và câu "Tâm Trạng: Hơi Hỗn
/// Loạn" — không gọi API nào, nên mọi chuyến và mọi tài khoản đều thấy y hệt.
/// Nay lấy từ `/ai/trips/:id/mood`, AI đánh giá theo chi tiêu và quy mô nhóm.
class AiMoodDetectionScreen extends ConsumerWidget {
  final bool? isDarkMode;

  const AiMoodDetectionScreen({super.key, this.isDarkMode});

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
          'ai.mood_title'.tr(),
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
              onPressed: () => ref.invalidate(squadMoodProvider(tripId)),
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
                .watch(squadMoodProvider(tripId))
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => AppErrorState(
                    isDark: isDark,
                    error: e,
                    onRetry: () => ref.invalidate(squadMoodProvider(tripId)),
                  ),
                  data: (mood) => _body(context, isDark, mood),
                ),
    );
  }

  Widget _body(BuildContext context, bool isDark, SquadMood mood) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;
    final warning = isDark ? GenZTokens.warningDark : GenZTokens.warning;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

    // Kẹp về 0..5 phòng khi AI trả số ngoài thang.
    final level = mood.tensionLevel.clamp(0, 5);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GenZTokens.space5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(GenZTokens.space6),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: level / 5,
                    strokeWidth: 10,
                    backgroundColor: fill,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      level >= 4
                          ? danger
                          : level >= 3
                          ? warning
                          : success,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$level/5',
                      style: AppFonts.heading(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    Text(
                      'ai.mood_tension'.tr(),
                      style: AppFonts.body(fontSize: 12, color: inkSoft),
                    ),
                  ],
                ),
              ],
            ),
            if (mood.overallMood.isNotEmpty) ...[
              const SizedBox(height: GenZTokens.space5),
              Text(
                mood.overallMood,
                textAlign: TextAlign.center,
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),
            ],
            if (mood.moodAnalysis.isNotEmpty) ...[
              const SizedBox(height: GenZTokens.space3),
              Text(
                mood.moodAnalysis,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13,
                  color: inkSoft,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
