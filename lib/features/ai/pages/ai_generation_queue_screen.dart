import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/ai_repository.dart';

/// Hàng chờ xử lý AI của chính mình.
///
/// Trước đây màn này chạy 4 thanh tiến độ tự nhích bằng `Timer` — "Render Video
/// Recap Cinematic 74%", "Bóc tách 14 hóa đơn lẩu 92%" — cho mọi tài khoản, kể
/// cả người chưa từng gọi AI, và không hề có tác vụ nào chạy phía sau. Nay đọc
/// bảng yêu cầu AI thật qua `/ai/generation-queue`.
class AiGenerationQueueScreen extends ConsumerWidget {
  const AiGenerationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'ai.queue_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ink),
            onPressed: () => ref.invalidate(aiQueueProvider),
          ),
        ],
      ),
      body: ref
          .watch(aiQueueProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(aiQueueProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.auto_awesome_outlined,
                  title: 'ai.queue_title'.tr(),
                  body: 'ai_hub.empty_queue'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(aiQueueProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(GenZTokens.space5),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GenZTokens.space3),
                  itemBuilder: (_, i) => _tile(isDark, items[i]),
                ),
              );
            },
          ),
    );
  }

  Widget _tile(bool isDark, AiQueueItem item) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final color = item.isFailed
        ? GenZTokens.danger
        : item.isDone
        ? GenZTokens.success
        : GenZTokens.orange;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.isFailed
                    ? Icons.error_outline
                    : item.isDone
                    ? Icons.check_circle_outline
                    : Icons.hourglass_top,
                size: 18,
                color: color,
              ),
              const SizedBox(width: GenZTokens.space2),
              Expanded(
                child: Text(
                  item.task,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GenZTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: item.progress / 100,
              minHeight: 8,
              backgroundColor: inkSoft.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.type} · ${item.status}',
            style: AppFonts.body(fontSize: 12, color: inkSoft),
          ),
        ],
      ),
    );
  }
}
