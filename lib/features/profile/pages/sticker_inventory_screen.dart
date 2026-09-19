import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/xp_repository.dart';
import '../widgets/xp_balance_chip.dart';
import 'sticker_store_screen.dart';

/// Kho sticker đã sở hữu.
///
/// Trước đây màn này 789 dòng, hiện 4 gói in cứng ("Cafe Addiction"...) như thể
/// đã sở hữu dù chưa mua gì, và kho thật thì lấy từ một object trong RAM server
/// nên mất sạch sau mỗi lần khởi động lại. Nay đọc từ bảng `user_stickers`.
class StickerInventoryScreen extends ConsumerWidget {
  final bool isDarkMode;

  const StickerInventoryScreen({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark =
        isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'xp.my_stickers'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        actions: [
          XpBalanceChip(isDark: isDark),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StickerStoreScreen(isDarkMode: isDark),
          ),
        ),
        backgroundColor: accent,
        foregroundColor: onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        ),
        icon: Icon(PhosphorIcons.storefront()),
        label: Text(
          'xp.open_store'.tr(),
          style: AppFonts.heading(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: onAccent,
          ),
        ),
      ),
      body: ref
          .watch(myStickersProvider)
          .when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: accent,
                strokeWidth: 2,
              ),
            ),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(myStickersProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: PhosphorIcons.smiley(),
                  title: 'xp.my_stickers'.tr(),
                  body: 'xp.inventory_empty'.tr(),
                );
              }
              return RefreshIndicator(
                color: accent,
                onRefresh: () async => invalidateXp(ref),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    GenZTokens.space4,
                    GenZTokens.space4,
                    GenZTokens.space4,
                    96,
                  ),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: GenZTokens.space3,
                    mainAxisSpacing: GenZTokens.space3,
                    mainAxisExtent: max(
                      116.0,
                      MediaQuery.textScalerOf(context).scale(34) + 82,
                    ),
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _tile(isDark, items[i]),
                ),
              );
            },
          ),
    );
  }

  Widget _tile(bool isDark, StoreItem item) {
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.emoji != null && item.emoji!.isNotEmpty)
            Text(item.emoji!, style: const TextStyle(fontSize: 36))
          else
            Icon(PhosphorIcons.sticker(), size: 36, color: inkSoft),
          const SizedBox(height: 6),
          Text(
            item.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(fontSize: 12, color: inkSoft),
          ),
        ],
      ),
    );
  }
}
