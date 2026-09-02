import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary =>
      isDarkMode ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
  Color get _textPri => isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  void _vote(WidgetRef ref, String itemId) {
    HapticFeedback.mediumImpact();
    ref.read(wishlistProvider(tripId).notifier).toggleVote(itemId);
  }

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'itinerary.wishlist_add_place'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800, color: _textPri),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: AppFonts.body(color: _textPri),
              decoration: InputDecoration(
                hintText: 'Tên địa điểm',
                hintStyle: AppFonts.body(color: _textSec),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addrCtrl,
              style: AppFonts.body(color: _textPri),
              decoration: InputDecoration(
                hintText: 'Địa chỉ (tuỳ chọn)',
                hintStyle: AppFonts.body(color: _textSec),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: _textSec),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('packing.add'.tr()),
          ),
        ],
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wishlistProvider(tripId));
    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        onPressed: () => _addItem(context, ref),
        icon: const Icon(Icons.add),
        label: Text(
          'packing.add'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'wishlist.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () async => ref.invalidate(wishlistProvider(tripId)),
        child: async.when(
          loading: () => _skeleton(),
          error: (e, _) => _error(context, ref, e),
          data: (items) {
            if (items.isEmpty) return _empty();
            final sorted = [...items]
              ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: sorted.length,
              itemBuilder: (context, i) => _card(context, ref, sorted[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      5,
      (i) => Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  Widget _error(BuildContext context, WidgetRef ref, Object e) => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'wishlist.load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _primary),
              onPressed: () => ref.invalidate(wishlistProvider(tripId)),
              icon: const Icon(Icons.refresh),
              label: Text('general.retry'.tr()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _empty() => ListView(
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
                color: _primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                PhosphorIcons.heart(PhosphorIconsStyle.fill),
                color: _primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'wishlist.empty'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'wishlist.empty_sub'.tr(),
              style: AppFonts.body(fontSize: 14, color: _textSec),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _card(BuildContext context, WidgetRef ref, WishlistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(PhosphorIcons.mapPin(), color: _primary, size: 22),
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
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                  ),
                ),
                if (item.address != null)
                  Text(
                    item.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 12, color: _textSec),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _vote(ref, item.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.fire(PhosphorIconsStyle.fill),
                    size: 14,
                    color: _primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${item.voteCount}',
                    style: AppFonts.heading(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
