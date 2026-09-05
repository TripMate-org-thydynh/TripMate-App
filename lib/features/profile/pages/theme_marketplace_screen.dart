import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/state_views.dart';
import '../data/xp_repository.dart';
import '../widgets/xp_balance_chip.dart';

/// Chợ giao diện — đổi XP lấy accent mới.
///
/// Trước đây màn này 1573 dòng, không có endpoint mua nào ở backend, và mọi nút
/// đều chỉ hiện "Tính năng đang được hoàn thiện 🚧". Nay mua thật bằng XP, và
/// mua xong **áp dụng được ngay** cho cả app (accent thật trong `AppAccent`).
class ThemeMarketplaceScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const ThemeMarketplaceScreen({super.key, this.isDarkMode = false});

  @override
  ConsumerState<ThemeMarketplaceScreen> createState() =>
      _ThemeMarketplaceScreenState();
}

class _ThemeMarketplaceScreenState
    extends ConsumerState<ThemeMarketplaceScreen> {
  String? _busy;

  Future<void> _buy(StoreItem item) async {
    if (_busy != null) return;
    setState(() => _busy = item.id);
    try {
      await ref.read(xpRepositoryProvider).buyTheme(item.id);
      if (!mounted) return;
      invalidateXp(ref);
      HapticFeedback.mediumImpact();
      showGlobalSnack('xp.bought'.tr(args: [item.label]));
    } catch (e) {
      if (!mounted) return;
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Áp dụng accent đã mở khoá cho toàn app.
  void _apply(StoreItem item) {
    final accent = AppAccent.values
        .where((a) => a.key == item.accentKey)
        .firstOrNull;
    if (accent == null) return;
    ref.read(accentProvider.notifier).setAccent(accent);
    HapticFeedback.selectionClick();
    showGlobalSnack('xp.bought'.tr(args: [item.label]));
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
          'xp.theme_store'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          XpBalanceChip(isDark: isDark),
          const SizedBox(width: 12),
        ],
      ),
      body: ref
          .watch(themeStoreProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(themeStoreProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.palette_outlined,
                  title: 'xp.theme_store'.tr(),
                  body: 'xp.store_empty'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => invalidateXp(ref),
                child: ListView.separated(
                  padding: const EdgeInsets.all(GenZTokens.space5),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GenZTokens.space4),
                  itemBuilder: (_, i) => _card(isDark, items[i]),
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
    final busy = _busy == item.id;
    final preview = _parseHex(item.colorHex) ?? GenZTokens.lilac;
    final current = ref.watch(accentProvider);
    final isActive = current.key == item.accentKey;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: ink,
          width: isActive ? GenZTokens.borderWidth : GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Xem trước bằng chính màu accent — không cần file ảnh, và cũ trước
          // đây trỏ vào assets/themes/* vốn không tồn tại.
          Container(height: 90, width: double.infinity, color: preview),
          Padding(
            padding: const EdgeInsets.all(GenZTokens.space4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.owned
                            ? 'xp.theme_owned'.tr()
                            : '${item.costXp} XP',
                        style: AppFonts.body(fontSize: 12.5, color: inkSoft),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: GenZTokens.space3),
                if (isActive)
                  Icon(Icons.check_circle, color: GenZTokens.success, size: 26)
                else
                  ElevatedButton(
                    onPressed: busy
                        ? null
                        : item.owned
                        ? () => _apply(item)
                        : item.affordable
                        ? () => _buy(item)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.owned
                          ? GenZTokens.green
                          : GenZTokens.yellow,
                      foregroundColor: GenZTokens.ink,
                      disabledBackgroundColor: inkSoft.withValues(alpha: 0.2),
                      elevation: 0,
                      side: BorderSide(
                        color: ink,
                        width: GenZTokens.borderWidthThin,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                      ),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            item.owned
                                ? 'xp.theme_apply'.tr()
                                : item.affordable
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
          ),
        ],
      ),
    );
  }

  /// '#FF2E93' -> Color. Trả `null` nếu chuỗi lạ, để rơi về màu mặc định.
  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    final v = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    return v == null ? null : Color(0xFF000000 | v);
  }
}
