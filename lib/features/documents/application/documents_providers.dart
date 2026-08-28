import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/documents_repository.dart';

class DocumentsNotifier
    extends FamilyAsyncNotifier<List<TripDocument>, String> {
  @override
  Future<List<TripDocument>> build(String tripId) {
    return ref.watch(documentsRepositoryProvider).fetch(tripId);
  }

  DocumentsRepository get _repo => ref.read(documentsRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch(arg));
  }

  Future<void> add({
    required String name,
    required String url,
    required String mimeType,
    int? sizeBytes,
    String? linkedType,
    String? linkedId,
  }) async {
    await _repo.create(
      arg,
      name: name,
      url: url,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      linkedType: linkedType,
      linkedId: linkedId,
    );
    ref.invalidateSelf();
  }

  Future<void> remove(String documentId) async {
    await _repo.delete(arg, documentId);
    ref.invalidateSelf();
  }
}

final documentsProvider =
    AsyncNotifierProvider.family<DocumentsNotifier, List<TripDocument>, String>(
      DocumentsNotifier.new,
    );
