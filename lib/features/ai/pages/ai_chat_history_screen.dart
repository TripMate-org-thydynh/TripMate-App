import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/ai_repository.dart';

/// Lịch sử những gì mình đã hỏi Matey AI.
///
/// Trước đây màn này in cứng "Pinned Gold" và "Recent Processing" — các ghi chú
/// về mưa ở Đà Lạt và quán ăn đêm gần hostel — cho mọi tài khoản, kể cả người
/// chưa từng hỏi AI câu nào. Nay đọc `/ai/my-requests`.
class AiChatHistoryScreen extends ConsumerWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AiChatHistoryScreen({
    super.key,
    required this.isDarkMode,
    this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'ai.history_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ink),
            onPressed: () => ref.invalidate(aiHistoryProvider),
          ),
        ],
      ),
      body: ref
          .watch(aiHistoryProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(aiHistoryProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.history_rounded,
                  title: 'ai.history_title'.tr(),
                  body: 'ai.history_empty'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(aiHistoryProvider),
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
    final at = item.createdAt;

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
          Text(
            item.task,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(fontSize: 14, color: ink, height: 1.4),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                item.isFailed
                    ? Icons.error_outline
                    : item.isDone
                    ? Icons.check_circle_outline
                    : Icons.hourglass_top,
                size: 14,
                color: item.isFailed ? GenZTokens.danger : inkSoft,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  at == null
                      ? item.type
                      : '${item.type} · ${DateFormat.yMMMd().add_Hm().format(at.toLocal())}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 12, color: inkSoft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
