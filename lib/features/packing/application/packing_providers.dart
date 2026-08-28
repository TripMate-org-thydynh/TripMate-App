import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/packing_repository.dart';

/// Packing list của 1 trip với **optimistic toggle** khi check/uncheck món đồ.
class PackingNotifier extends FamilyAsyncNotifier<PackingList, String> {
  @override
  Future<PackingList> build(String tripId) {
    return ref.watch(packingRepositoryProvider).fetch(tripId);
  }

  PackingRepository get _repo => ref.read(packingRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch(arg));
  }

  Future<void> togglePacked(String itemId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final target = current.items.firstWhere((i) => i.id == itemId);
    final newPacked = !target.isPacked;

    // Optimistic: cập nhật item + đếm lại tiến độ ngay.
    final updated = current.items
        .map((i) => i.id == itemId ? i.copyWith(isPacked: newPacked) : i)
        .toList();
    final packed = updated.where((i) => i.isPacked).length;
    state = AsyncData(
      PackingList(
        items: updated,
        total: updated.length,
        packed: packed,
        percent: updated.isEmpty ? 0 : ((packed / updated.length) * 100).round(),
      ),
    );

    try {
      await _repo.togglePacked(arg, itemId, newPacked);
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  Future<void> add({
    required String name,
    String category = 'OTHER',
    int quantity = 1,
    String? assignedTo,
  }) async {
    await _repo.add(
      arg,
      name: name,
      category: category,
      quantity: quantity,
      assignedTo: assignedTo,
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

  Future<void> applyTemplate(String template) async {
    await _repo.applyTemplate(arg, template);
    ref.invalidateSelf();
  }
}

final packingProvider =
    AsyncNotifierProvider.family<PackingNotifier, PackingList, String>(
      PackingNotifier.new,
    );
