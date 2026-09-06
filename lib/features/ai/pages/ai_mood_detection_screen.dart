import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  const AiMoodDetectionScreen({super.key});

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
          'ai.mood_title'.tr(),
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
              onPressed: () => ref.invalidate(squadMoodProvider(tripId)),
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
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
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
                    backgroundColor: inkSoft.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      level >= 4
                          ? GenZTokens.danger
                          : level >= 3
                          ? GenZTokens.orange
                          : GenZTokens.success,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$level/5',
                      style: AppFonts.heading(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
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
                  fontSize: 13.5,
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
