import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/app_messenger.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/ai_repository.dart';

/// Câu lệnh AI gợi ý sẵn.
///
/// Trước đây màn này in cứng 2 prompt ngay trong app và gọi chúng là "prompt đã
/// lưu" — người dùng chưa lưu gì cả. App không có chỗ lưu prompt riêng, nên đây
/// là danh mục do team soạn, lấy từ `/ai/saved-prompts`, và tên màn nói đúng
/// điều đó. Chạm để chép prompt rồi dán vào Matey AI.
class AiSavedPromptsScreen extends ConsumerWidget {
  const AiSavedPromptsScreen({super.key});

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
          'ai.prompts_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: ref
          .watch(suggestedPromptsProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(suggestedPromptsProvider),
            ),
            data: (prompts) {
              if (prompts.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.bookmark_border,
                  title: 'ai.prompts_title'.tr(),
                  body: 'ai.prompts_empty'.tr(),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(GenZTokens.space5),
                itemCount: prompts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: GenZTokens.space3),
                itemBuilder: (_, i) => _tile(isDark, prompts[i]),
              );
            },
          ),
    );
  }

  Widget _tile(bool isDark, SuggestedPrompt p) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: p.prompt));
        showGlobalSnack('ai.prompt_copied'.tr());
      },
      child: Container(
        padding: const EdgeInsets.all(GenZTokens.space4),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.prompt,
                    style: AppFonts.body(
                      fontSize: 12.5,
                      color: inkSoft,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: GenZTokens.space3),
            Icon(Icons.copy_rounded, size: 18, color: inkSoft),
          ],
        ),
      ),
    );
  }
}
