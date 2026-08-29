import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notes_repository.dart';

class NotesNotifier extends FamilyAsyncNotifier<List<TripNote>, String> {
  @override
  Future<List<TripNote>> build(String tripId) {
    return ref.watch(notesRepositoryProvider).fetch(tripId);
  }

  NotesRepository get _repo => ref.read(notesRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch(arg));
  }

  Future<void> add({
    required String content,
    String? title,
    String? color,
  }) async {
    await _repo.create(arg, content: content, title: title, color: color);
    ref.invalidateSelf();
  }

  Future<void> edit(
    String noteId, {
    String? content,
    String? title,
    String? color,
  }) async {
    await _repo.update(
      arg,
      noteId,
      content: content,
      title: title,
      color: color,
    );
    ref.invalidateSelf();
  }

  Future<void> remove(String noteId) async {
    await _repo.delete(arg, noteId);
    ref.invalidateSelf();
  }
}

final notesProvider =
    AsyncNotifierProvider.family<NotesNotifier, List<TripNote>, String>(
      NotesNotifier.new,
    );
