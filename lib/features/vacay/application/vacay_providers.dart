import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vacay_repository.dart';

class VacayMyDaysNotifier extends AutoDisposeAsyncNotifier<VacayMyDaysResult> {
  @override
  Future<VacayMyDaysResult> build() {
    return ref.watch(vacayRepositoryProvider).fetchMyDays();
  }

  VacayRepository get _repo => ref.read(vacayRepositoryProvider);

  Future<void> refresh({int? year}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchMyDays(year: year));
  }

  Future<void> addDay({
    required String date,
    required String type,
    String? note,
  }) async {
    await _repo.addDay(date: date, type: type, note: note);
    ref.invalidateSelf();
    ref.invalidate(bridgeSuggestionsProvider);
  }

  Future<void> removeDay(String date) async {
    await _repo.deleteDay(date);
    ref.invalidateSelf();
    ref.invalidate(bridgeSuggestionsProvider);
  }
}

final vacayMyDaysProvider =
    AutoDisposeAsyncNotifierProvider<VacayMyDaysNotifier, VacayMyDaysResult>(
  VacayMyDaysNotifier.new,
);

final bridgeSuggestionsProvider =
    FutureProvider.autoDispose<List<BridgeSuggestion>>((ref) {
  return ref.watch(vacayRepositoryProvider).fetchBridgeSuggestions();
});
