import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/todos_repository.dart';

class TodosNotifier extends FamilyAsyncNotifier<TodoList, String> {
  @override
  Future<TodoList> build(String tripId) {
    return ref.watch(todosRepositoryProvider).fetch(tripId);
  }

  TodosRepository get _repo => ref.read(todosRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch(arg));
  }

  Future<void> toggle(String itemId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.items.firstWhere((i) => i.id == itemId);
    final next = !target.isDone;
    final updated = current.items
        .map((i) => i.id == itemId ? i.copyWith(isDone: next) : i)
        .toList();
    final done = updated.where((i) => i.isDone).length;
    state = AsyncData(
      TodoList(
        items: updated,
        total: updated.length,
        done: done,
        percent: updated.isEmpty ? 0 : ((done / updated.length) * 100).round(),
      ),
    );
    try {
      await _repo.toggleDone(arg, itemId, next);
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  Future<void> add({
    required String title,
    String priority = 'NORMAL',
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    await _repo.add(
      arg,
      title: title,
      priority: priority,
      assignedTo: assignedTo,
      dueDate: dueDate,
    );
    ref.invalidateSelf();
  }

  Future<void> assign(String itemId, String? userId) async {
    await _repo.assign(arg, itemId, userId);
    ref.invalidateSelf();
  }

  Future<void> remove(String itemId) async {
    await _repo.remove(arg, itemId);
    ref.invalidateSelf();
  }
}

final todosProvider =
    AsyncNotifierProvider.family<TodosNotifier, TodoList, String>(
      TodosNotifier.new,
    );
