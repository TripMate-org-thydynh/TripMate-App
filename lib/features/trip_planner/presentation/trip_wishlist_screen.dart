import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/gen_z_tokens.dart';
import '../application/wishlist_providers.dart';
import '../data/wishlist_repository.dart';

/// Wishlist nhóm — nơi cả squad thả địa điểm muốn đi & vote. Wired BE thật.
class TripWishlistScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;
  const TripWishlistScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  bool _isDark(BuildContext context) =>
      isDarkMode || Theme.of(context).brightness == Brightness.dark;

  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _surfaceOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color _lineOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.fillDark : GenZTokens.fill;
  Color _accentOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color _onAccentOf(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  Color _accentSoftOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color _textPriOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSecOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color _dangerOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.dangerDark : GenZTokens.danger;

  void _vote(WidgetRef ref, String itemId) {
    HapticFeedback.lightImpact();
    ref.read(wishlistProvider(tripId).notifier).toggleVote(itemId);
  }

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
        title: Text(
          'itinerary.wishlist_add_place'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: AppFonts.body(fontSize: 15, color: textPri),
              decoration: InputDecoration(
                hintText: 'itinerary.place_name'.tr(),
                hintStyle: AppFonts.body(fontSize: 15, color: textSec),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addrCtrl,
              style: AppFonts.body(fontSize: 15, color: textPri),
              decoration: InputDecoration(
                hintText: 'itinerary.place_address'.tr(),
                hintStyle: AppFonts.body(fontSize: 15, color: textSec),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(fontSize: 15, color: textSec),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'packing.add'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: onAccent,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      await ref
          .read(wishlistRepositoryProvider)
          .add(
            tripId,
            name: nameCtrl.text.trim(),
            address: addrCtrl.text.trim().isEmpty ? null : addrCtrl.text.trim(),
          );
      ref.invalidate(wishlistProvider(tripId));
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final danger = _dangerOf(context);
    final onAccent = _onAccentOf(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
        title: Text(
          'wishlist.delete_item'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        content: Text(
          'wishlist.delete_item_confirm'.tr(namedArgs: {'name': item.name}),
          style: AppFonts.body(fontSize: 15, color: textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(fontSize: 15, color: textSec),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: danger,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'general.delete'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: onAccent,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(wishlistProvider(tripId).notifier).deleteItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('wishlist.deleted_success'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wishlistProvider(tripId));
    final bg = _bgOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);
    final textPri = _textPriOf(context);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        ),
        onPressed: () => _addItem(context, ref),
        icon: Icon(PhosphorIcons.plus(), size: 20),
        label: Text(
          'packing.add'.tr(),
          style: AppFonts.heading(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: onAccent,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'wishlist.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: accent,
        onRefresh: () async => ref.invalidate(wishlistProvider(tripId)),
        child: async.when(
          loading: () => _skeleton(context),
          error: (e, _) => _error(context, ref, e),
          data: (items) {
            if (items.isEmpty) return _empty(context);
            final sorted = [...items]
              ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, i) => _card(context, ref, sorted[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _skeleton(BuildContext context) {
    final fill = _fillOf(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        5,
        (i) => Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          ),
        ),
      ),
    );
  }

  Widget _error(BuildContext context, WidgetRef ref, Object e) {
    final danger = _dangerOf(context);
    final textPri = _textPriOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);

    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(
                PhosphorIcons.cloudSlash(),
                color: danger,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'wishlist.load_failed'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
                onPressed: () => ref.invalidate(wishlistProvider(tripId)),
                icon: Icon(PhosphorIcons.arrowsClockwise(), size: 18),
                label: Text(
                  'general.retry'.tr(),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context) {
    final fill = _fillOf(context);
    final line = _lineOf(context);
    final accent = _accentOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    return ListView(
      children: [
        const SizedBox(height: 130),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.heart(PhosphorIconsStyle.fill),
                  color: accent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'wishlist.empty'.tr(),
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'wishlist.empty_sub'.tr(),
                style: AppFonts.body(fontSize: 15, color: textSec),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, WishlistItem item) {
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final fill = _fillOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final accent = _accentOf(context);
    final accentSoft = _accentSoftOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(
              PhosphorIcons.mapPin(),
              color: textSec,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                if (item.address != null)
                  Text(
                    item.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 12, color: textSec),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _vote(ref, item.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: item.voteCount > 0 ? accentSoft : fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                border: Border.all(
                  color: item.voteCount > 0 ? accent : line,
                  width: item.voteCount > 0
                      ? GenZTokens.borderWidth
                      : GenZTokens.borderWidthThin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.fire(PhosphorIconsStyle.fill),
                    size: 14,
                    color: item.voteCount > 0 ? accent : textSec,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${item.voteCount}',
                    style: AppFonts.heading(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: item.voteCount > 0 ? accent : textSec,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              PhosphorIcons.trash(),
              size: 18,
              color: textSec,
            ),
            tooltip: 'general.delete'.tr(),
            onPressed: () => _deleteItem(context, ref, item),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
