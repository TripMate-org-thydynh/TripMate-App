import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../application/packing_providers.dart';
import '../data/packing_repository.dart';

/// Packing list nhóm — template sẵn, gán món cho từng người, theo dõi tiến độ.
/// Wired BE thật (`/trips/:tripId/packing`).
class TripPackingScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;
  const TripPackingScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary => const Color(0xFF1FA85C);
  Color get _textPri => isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  // ── Category metadata (label + icon + color) ──
  static const _categories = <String, (String, IconData, Color)>{
    'CLOTHES': (
      'packing.cat_clothes',
      PhosphorIconsFill.tShirt,
      Color(0xFF3D8BFF),
    ),
    'TOILETRIES': (
      'packing.cat_toiletries',
      PhosphorIconsFill.drop,
      Color(0xFF06B6D4),
    ),
    'GADGETS': (
      'packing.cat_gadgets',
      PhosphorIconsFill.plugCharging,
      Color(0xFF8B4DE8),
    ),
    'DOCS': (
      'packing.cat_documents',
      PhosphorIconsFill.identificationCard,
      Color(0xFFF5822B),
    ),
    'OTHER': (
      'expense.cat_other',
      PhosphorIconsFill.package,
      Color(0xFFD6248C),
    ),
  };

  /// Phần tử thứ 1 trong `_categories` là KEY i18n — dịch ở đây để mọi chỗ
  /// gọi `_catMeta().$1` đều nhận nhãn theo ngôn ngữ hiện tại.
  (String, IconData, Color) _catMeta(String c) {
    final m = _categories[c] ?? _categories['OTHER']!;
    return (m.$1.tr(), m.$2, m.$3);
  }

  static const _templates = <String, (String, IconData)>{
    'ESSENTIALS': ('packing.tpl_essentials', PhosphorIconsFill.star),
    'BEACH': ('packing.tpl_beach', PhosphorIconsFill.umbrella),
    'CAMPING': ('packing.tpl_camping', PhosphorIconsFill.tent),
    'CITY': ('packing.tpl_city', PhosphorIconsFill.buildings),
  };

  void _toggle(WidgetRef ref, String itemId) {
    HapticFeedback.selectionClick();
    ref.read(packingProvider(tripId).notifier).togglePacked(itemId);
  }

  Future<void> _applyTemplate(WidgetRef ref, String template) async {
    HapticFeedback.mediumImpact();
    await ref.read(packingProvider(tripId).notifier).applyTemplate(template);
  }

  void _assignToMe(WidgetRef ref, PackingItem item) {
    final me = ref.read(authProvider).user?['id'] as String?;
    if (me == null) return;
    HapticFeedback.selectionClick();
    // Nếu đang gán cho tôi thì gỡ; ngược lại gán cho tôi.
    final next = item.assignee?.id == me ? null : me;
    ref.read(packingProvider(tripId).notifier).assign(item.id, next);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PackingItem item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'common.delete_confirm'.tr(namedArgs: {'name': item.name}),
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            color: _textPri,
            fontSize: 16,
          ),
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
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD8422B),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('general.delete2'.tr()),
          ),
        ],
      ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await ref.read(packingProvider(tripId).notifier).remove(item.id);
    }
  }

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    String category = 'OTHER';
    int quantity = 1;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'packing.add_title'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: _textPri,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: AppFonts.body(color: _textPri),
                decoration: InputDecoration(
                  hintText: 'packing.item_name'.tr(),
                  hintStyle: AppFonts.body(color: _textSec),
                  filled: true,
                  fillColor: _bgOf(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'packing.group'.tr(),
                style: AppFonts.body(
                  fontWeight: FontWeight.w700,
                  color: _textSec,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.entries.map((e) {
                  final selected = category == e.key;
                  return GestureDetector(
                    onTap: () => setSheet(() => category = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? e.value.$3 : _bgOf(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? e.value.$3
                              : _textSec.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            e.value.$2,
                            size: 15,
                            color: selected ? Colors.white : _textSec,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            e.value.$1.tr(),
                            style: AppFonts.body(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: selected ? Colors.white : _textPri,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'common.quantity'.tr(),
                    style: AppFonts.body(
                      fontWeight: FontWeight.w700,
                      color: _textSec,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  _qtyButton(context, Icons.remove, () {
                    if (quantity > 1) setSheet(() => quantity--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '$quantity',
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: _textPri,
                      ),
                    ),
                  ),
                  _qtyButton(
                    context,
                    Icons.add,
                    () => setSheet(() => quantity++),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'packing.add_to_list'.tr(),
                    style: AppFonts.heading(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();
      await ref
          .read(packingProvider(tripId).notifier)
          .add(
            name: nameCtrl.text.trim(),
            category: category,
            quantity: quantity,
          );
    }
  }

  Widget _qtyButton(BuildContext context, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _bgOf(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _textSec.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 18, color: _textPri),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(packingProvider(tripId));
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
          'packing.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () => ref.read(packingProvider(tripId).notifier).refresh(),
        child: async.when(
          loading: () => _skeleton(),
          error: (e, _) => _error(),
          data: (list) => _content(context, ref, list),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, PackingList list) {
    if (list.items.isEmpty) return _empty(ref);

    // Nhóm theo category, giữ thứ tự category cố định.
    final grouped = <String, List<PackingItem>>{};
    for (final it in list.items) {
      grouped.putIfAbsent(it.category, () => []).add(it);
    }
    final orderedKeys = [
      ..._categories.keys.where(grouped.containsKey),
      ...grouped.keys.where((k) => !_categories.containsKey(k)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        _progressHeader(context, list),
        const SizedBox(height: 20),
        for (final key in orderedKeys) ...[
          _sectionHeader(key, grouped[key]!.length),
          const SizedBox(height: 10),
          ...grouped[key]!.map((it) => _itemTile(context, ref, it)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _progressHeader(BuildContext context, PackingList list) {
    final done = list.percent >= 100 && list.total > 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _textPri.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                done
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsFill.suitcaseRolling,
                color: _primary,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  done
                      ? 'packing.all_ready'.tr()
                      : 'packing.packed_count'.tr(
                          namedArgs: {
                            'packed': '${list.packed}',
                            'total': '${list.total}',
                          },
                        ),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _textPri,
                  ),
                ),
              ),
              Text(
                '${list.percent}%',
                style: AppFonts.mono(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: list.total == 0 ? 0 : list.packed / list.total,
              minHeight: 10,
              backgroundColor: _bgOf(context),
              valueColor: AlwaysStoppedAnimation(_primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String category, int count) {
    final meta = _catMeta(category);
    return Row(
      children: [
        Icon(meta.$2, size: 18, color: meta.$3),
        const SizedBox(width: 8),
        Text(
          meta.$1,
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: _textPri,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: AppFonts.mono(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: _textSec,
          ),
        ),
      ],
    );
  }

  Widget _itemTile(BuildContext context, WidgetRef ref, PackingItem item) {
    final me = ref.watch(authProvider).user?['id'] as String?;
    final assignedToMe = item.assignee != null && item.assignee!.id == me;
    return GestureDetector(
      onLongPress: () => _confirmDelete(context, ref, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _textPri.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => _toggle(ref, item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: item.isPacked ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isPacked
                        ? _primary
                        : _textSec.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: item.isPacked
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.name,
                style: AppFonts.body(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  color: item.isPacked ? _textSec : _textPri,
                  decoration: item.isPacked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (item.quantity > 1)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _bgOf(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'x${item.quantity}',
                  style: AppFonts.mono(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _textSec,
                  ),
                ),
              ),
            // Assignee avatar → tap để gán cho tôi / bỏ gán.
            GestureDetector(
              onTap: () => _assignToMe(ref, item),
              child: _assigneeAvatar(item, assignedToMe),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assigneeAvatar(PackingItem item, bool assignedToMe) {
    if (item.assignee == null) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _textSec.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Icon(Icons.person_add_alt, size: 15, color: _textSec),
      );
    }
    final name = item.assignee!.name;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final url = item.assignee!.avatarUrl;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: assignedToMe ? _primary : _textSec,
        border: Border.all(
          color: assignedToMe ? _primary : Colors.transparent,
          width: 2,
        ),
        image: (url != null && url.isNotEmpty)
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: (url == null || url.isEmpty)
          ? Text(
              initial,
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _empty(WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 40),
      Icon(PhosphorIconsFill.suitcaseRolling, size: 64, color: _primary),
      const SizedBox(height: 16),
      Text(
        'packing.empty'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.heading(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: _textPri,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'packing.empty_sub'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.body(fontSize: 14, color: _textSec),
      ),
      const SizedBox(height: 24),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: _templates.entries
            .map((e) => _templateChip(ref, e.key, e.value.$1.tr(), e.value.$2))
            .toList(),
      ),
    ],
  );

  Widget _templateChip(WidgetRef ref, String key, String label, IconData icon) {
    return GestureDetector(
      onTap: () => _applyTemplate(ref, key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: _primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: _textPri,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      6,
      (i) => Container(
        height: 56,
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

  Widget _error() => ListView(
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
              'common.list_load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
