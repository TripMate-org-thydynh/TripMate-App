import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final isDark = isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'xp.my_stickers'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [XpBalanceChip(isDark: isDark), const SizedBox(width: 12)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StickerStoreScreen(isDarkMode: isDark),
          ),
        ),
        backgroundColor: GenZTokens.yellow,
        foregroundColor: GenZTokens.ink,
        icon: const Icon(Icons.storefront_outlined),
        label: Text(
          'xp.open_store'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800),
        ),
      ),
      body: ref
          .watch(myStickersProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(myStickersProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.emoji_emotions_outlined,
                  title: 'xp.my_stickers'.tr(),
                  body: 'xp.inventory_empty'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => invalidateXp(ref),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    GenZTokens.space5,
                    GenZTokens.space5,
                    GenZTokens.space5,
                    96,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: GenZTokens.space3,
                        mainAxisSpacing: GenZTokens.space3,
                        childAspectRatio: 0.85,
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
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji ?? '❔', style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(
            item.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(fontSize: 11.5, color: inkSoft),
          ),
        ],
      ),
    );
  }
}
