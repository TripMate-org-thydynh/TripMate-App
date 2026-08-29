import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/xp_repository.dart';
import '../widgets/xp_balance_chip.dart';

/// Cửa hàng sticker — đổi XP lấy sticker để gửi trong Squad Chat.
///
/// Trước đây màn này gọi một endpoint không hề trừ XP (mua gì cũng miễn phí) và
/// kho lưu trong RAM server nên mất sạch sau mỗi lần khởi động lại. Nay số dư,
/// giá và quyền sở hữu đều thật.
class StickerStoreScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const StickerStoreScreen({super.key, this.isDarkMode = false});

  @override
  ConsumerState<StickerStoreScreen> createState() => _StickerStoreScreenState();
}

class _StickerStoreScreenState extends ConsumerState<StickerStoreScreen> {
  /// Id đang xử lý mua — để khoá nút, tránh bấm hai lần trừ hai lần.
  String? _buying;

  Future<void> _buy(StoreItem item) async {
    if (_buying != null) return;
    setState(() => _buying = item.id);
    try {
      await ref.read(xpRepositoryProvider).buySticker(item.id);
      if (!mounted) return;
      invalidateXp(ref);
      HapticFeedback.mediumImpact();
      showGlobalSnack('xp.bought'.tr(args: [item.label]));
    } catch (e) {
      if (!mounted) return;
      // Hiện đúng lý do BE trả: thiếu XP, đã sở hữu, hết hàng...
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _buying = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'xp.sticker_store'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [XpBalanceChip(isDark: isDark), const SizedBox(width: 12)],
      ),
      body: ref
          .watch(stickerStoreProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(stickerStoreProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.emoji_emotions_outlined,
                  title: 'xp.sticker_store'.tr(),
                  body: 'xp.store_empty'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => invalidateXp(ref),
                child: ListView(
                  padding: const EdgeInsets.all(GenZTokens.space5),
                  children: [
                    Text(
                      'xp.store_hint'.tr(),
                      style: AppFonts.body(
                        fontSize: 13,
                        color: isDark
                            ? GenZTokens.inkSoftDark
                            : GenZTokens.inkSoft,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space5),
                    for (final item in items) ...[
                      _card(isDark, item),
                      const SizedBox(height: GenZTokens.space3),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _card(bool isDark, StoreItem item) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final busy = _buying == item.id;
    // Rõ ràng ba trạng thái: đã có / mua được / chưa đủ XP.
    final canBuy = !item.owned && item.affordable && _buying == null;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: item.owned ? GenZTokens.green.withValues(alpha: 0.16) : surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        children: [
          Text(item.emoji ?? '❔', style: const TextStyle(fontSize: 34)),
          const SizedBox(width: GenZTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${'xp.rarity_${item.rarity.toLowerCase()}'.tr()} · ${item.costXp} XP',
                  style: AppFonts.body(fontSize: 12.5, color: inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: GenZTokens.space3),
          if (item.owned)
            Icon(Icons.check_circle, color: GenZTokens.success, size: 26)
          else
            ElevatedButton(
              onPressed: canBuy ? () => _buy(item) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: GenZTokens.yellow,
                foregroundColor: GenZTokens.ink,
                disabledBackgroundColor: inkSoft.withValues(alpha: 0.2),
                elevation: 0,
                side: BorderSide(color: ink, width: GenZTokens.borderWidthThin),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      item.affordable
                          ? 'xp.buy'.tr()
                          : 'xp.not_enough_short'.tr(),
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: GenZTokens.ink,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
