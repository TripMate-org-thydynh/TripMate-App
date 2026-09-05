import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/journal_repository.dart';

class JournalNotifier extends FamilyAsyncNotifier<List<JournalEntry>, String> {
  @override
  Future<List<JournalEntry>> build(String tripId) {
    return ref.watch(journalRepositoryProvider).fetch(tripId);
  }

  JournalRepository get _repo => ref.read(journalRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch(arg));
  }

  Future<void> add({
    required String body,
    required String mood,
    required String entryDate,
    String? title,
    double? latitude,
    double? longitude,
    List<Map<String, dynamic>>? photos,
  }) async {
    await _repo.create(
      arg,
      body: body,
      mood: mood,
      entryDate: entryDate,
      title: title,
      latitude: latitude,
      longitude: longitude,
      photos: photos,
    );
    ref.invalidateSelf();
  }

  Future<void> remove(String entryId) async {
    await _repo.delete(arg, entryId);
    ref.invalidateSelf();
  }
}

final journalProvider =
    AsyncNotifierProvider.family<JournalNotifier, List<JournalEntry>, String>(
      JournalNotifier.new,
    );
