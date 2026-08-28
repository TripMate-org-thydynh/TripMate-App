import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/checkins_repository.dart';

class CheckinsNotifier extends FamilyAsyncNotifier<List<DayCheckin>, String> {
  @override
  Future<List<DayCheckin>> build(String tripId) {
    return ref.watch(checkinsRepositoryProvider).fetch(tripId);
  }

  CheckinsRepository get _repo => ref.read(checkinsRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch(arg));
  }

  Future<void> upsert({
    required int day,
    required String status,
    String? note,
  }) async {
    await _repo.upsert(arg, day: day, status: status, note: note);
    ref.invalidateSelf();
  }
}

final checkinsProvider =
    AsyncNotifierProvider.family<CheckinsNotifier, List<DayCheckin>, String>(
      CheckinsNotifier.new,
    );
