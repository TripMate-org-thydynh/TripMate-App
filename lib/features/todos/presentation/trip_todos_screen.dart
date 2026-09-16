import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:tripmate/core/theme/gen_z_tokens.dart';

import '../../../core/providers/auth_provider.dart';
import '../application/todos_providers.dart';
import '../data/todos_repository.dart';

/// Việc cần làm của nhóm — checklist, gán người, ưu tiên, hạn. Wired BE thật.
class TripTodosScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;
  const TripTodosScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  bool _isDark(BuildContext context) =>
      isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _surface(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _primary => GenZTokens.purple;
  Color _textPri(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSec(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color _border(BuildContext context) => _isDark(context)
      ? GenZTokens.inkDark.withValues(alpha: 0.1)
      : GenZTokens.ink.withValues(alpha: 0.06);

  static const _prio = <String, (String, Color)>{
    'HIGH': ('todos.priority_urgent', GenZTokens.danger),
    'NORMAL': ('todos.priority_normal', GenZTokens.blue),
    'LOW': ('todos.priority_relaxed', GenZTokens.inkSoft),
  };

  /// Phần tử thứ 1 trong `_prio` là KEY i18n (const map không gọi được .tr()).
  (String, Color) _prioMeta(String p) {
    final m = _prio[p] ?? _prio['NORMAL']!;
    return (m.$1.tr(), m.$2);
  }

  void _toggle(WidgetRef ref, String id) {
    HapticFeedback.selectionClick();
    ref.read(todosProvider(tripId).notifier).toggle(id);
  }

  void _assignToMe(WidgetRef ref, TodoItem it) {
    final me = ref.read(authProvider).user?['id'] as String?;
    if (me == null) return;
    HapticFeedback.selectionClick();
    ref
        .read(todosProvider(tripId).notifier)
        .assign(it.id, it.assignee?.id == me ? null : me);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TodoItem it,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'common.delete_confirm'.tr(namedArgs: {'name': it.title}),
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            color: _textPri(context),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: _textSec(context)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GenZTokens.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('general.delete2'.tr()),
          ),
        ],
      ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await ref.read(todosProvider(tripId).notifier).remove(it.id);
    }
  }

  Future<void> _addTodo(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    var priority = 'NORMAL';
    DateTime? due;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface(context),
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
                'todos.add'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: _textPri(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                style: AppFonts.body(color: _textPri(context)),
                decoration: InputDecoration(
                  hintText: 'todos.item_hint'.tr(),
                  hintStyle: AppFonts.body(color: _textSec(context)),
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
                'todos.priority'.tr(),
                style: AppFonts.body(
                  fontWeight: FontWeight.w700,
                  color: _textSec(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _prio.entries.map((e) {
                  final sel = priority == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setSheet(() => priority = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? e.value.$2 : _bgOf(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? e.value.$2
                                : _textSec(context).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          e.value.$1.tr(),
                          style: AppFonts.body(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: sel ? GenZTokens.paper : _textPri(context),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: due ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (d != null) setSheet(() => due = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _bgOf(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.calendar(), size: 18, color: _primary),
                      const SizedBox(width: 10),
                      Text(
                        due == null
                            ? 'todos.due_hint'.tr()
                            : '${due!.day.toString().padLeft(2, '0')}/${due!.month.toString().padLeft(2, '0')}/${due!.year}',
                        style: AppFonts.body(
                          fontWeight: FontWeight.w600,
                          color: due == null ? _textSec(context) : _textPri(context),
                        ),
                      ),
                    ],
                  ),
                ),
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
                    'todos.add'.tr(),
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && titleCtrl.text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();
      await ref
          .read(todosProvider(tripId).notifier)
          .add(title: titleCtrl.text.trim(), priority: priority, dueDate: due);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todosProvider(tripId));
    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: GenZTokens.paper,
        onPressed: () => _addTodo(context, ref),
        icon: Icon(PhosphorIcons.plus()),
        label: Text(
          'todos.add'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'todos.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri(context),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () => ref.read(todosProvider(tripId).notifier).refresh(),
        child: async.when(
          loading: () => _skeleton(context),
          error: (e, _) => _error(context),
          data: (list) => list.items.isEmpty
              ? _empty(context)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  children: [
                    _progress(context, list),
                    const SizedBox(height: 18),
                    ...list.items.map((it) => _tile(context, ref, it)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _progress(BuildContext context, TodoList list) {
    final done = list.percent >= 100 && list.total > 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                done
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsFill.listChecks,
                color: _primary,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  done
                      ? 'todos.all_done'.tr()
                      : 'todos.done_count'.tr(
                          namedArgs: {
                            'done': '${list.done}',
                            'total': '${list.total}',
                          },
                        ),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _textPri(context),
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
              value: list.total == 0 ? 0 : list.done / list.total,
              minHeight: 10,
              backgroundColor: _bgOf(context),
              valueColor: AlwaysStoppedAnimation(_primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, TodoItem it) {
    final me = ref.watch(authProvider).user?['id'] as String?;
    final mine = it.assignee != null && it.assignee!.id == me;
    final pm = _prioMeta(it.priority);
    return GestureDetector(
      onLongPress: () => _confirmDelete(context, ref, it),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(context)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggle(ref, it.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: it.isDone ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: it.isDone
                        ? _primary
                        : _textSec(context).withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: it.isDone
                    ? Icon(PhosphorIcons.check(), size: 18, color: GenZTokens.paper)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    it.title,
                    style: AppFonts.body(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: it.isDone ? _textSec(context) : _textPri(context),
                      decoration: it.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: pm.$2.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pm.$1,
                          style: AppFonts.mono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: pm.$2,
                          ),
                        ),
                      ),
                      if (it.dueDate != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          PhosphorIcons.calendar(),
                          size: 14,
                          color: _textSec(context),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${it.dueDate!.toLocal().day.toString().padLeft(2, '0')}/${it.dueDate!.toLocal().month.toString().padLeft(2, '0')}',
                          style: AppFonts.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textSec(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _assignToMe(ref, it),
              child: _avatar(context, it, mine),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context, TodoItem it, bool mine) {
    if (it.assignee == null) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _textSec(context).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          PhosphorIcons.userPlus(),
          size: 15,
          color: _textSec(context),
        ),
      );
    }
    final url = it.assignee!.avatarUrl;
    final initial = it.assignee!.name.isNotEmpty
        ? it.assignee!.name[0].toUpperCase()
        : '?';
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: mine ? _primary : _textSec(context),
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
                color: GenZTokens.paper,
              ),
            )
          : null,
    );
  }

  Widget _empty(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 50),
      Icon(PhosphorIconsFill.listChecks, size: 60, color: _primary),
      const SizedBox(height: 16),
      Text(
        'todos.empty'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.heading(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: _textPri(context),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'todos.empty_sub'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.body(fontSize: 14, color: _textSec(context)),
      ),
    ],
  );

  Widget _skeleton(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      6,
      (i) => Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _isDark(context)
              ? GenZTokens.inkDark.withValues(alpha: 0.06)
              : GenZTokens.ink.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  Widget _error(BuildContext context) => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            Icon(
              PhosphorIcons.cloudSlash(),
              color: GenZTokens.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'common.list_load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri(context),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
