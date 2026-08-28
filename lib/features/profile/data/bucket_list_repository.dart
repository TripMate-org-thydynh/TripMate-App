import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/travel_stats.dart';

/// Repository cho Bucket List du lịch — BE `users/me/bucket-list`.
class BucketListRepository {
  final ApiClient _client;
  BucketListRepository(this._client);

  static const _base = '/users/me/bucket-list';

  BucketItem _parse(Map<String, dynamic> j) => BucketItem(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    isCompleted: j['isCompleted'] as bool? ?? false,
  );

  Future<List<BucketItem>> fetch() async {
    final data = await _client.getData(_base);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => _parse(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<void> add(String title) =>
      _client.postData(_base, {'title': title});

  Future<void> setCompleted(String id, bool isCompleted) =>
      _client.patchData('$_base/$id', {'isCompleted': isCompleted});

  Future<void> remove(String id) => _client.deleteData('$_base/$id');
}

final bucketListRepositoryProvider = Provider<BucketListRepository>((ref) {
  return BucketListRepository(ref.watch(apiClientProvider));
});

/// Bucket list với optimistic toggle khi tick hoàn thành.
class BucketListNotifier extends AsyncNotifier<List<BucketItem>> {
  @override
  Future<List<BucketItem>> build() {
    return ref.watch(bucketListRepositoryProvider).fetch();
  }

  BucketListRepository get _repo => ref.read(bucketListRepositoryProvider);

  Future<void> toggle(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.firstWhere((i) => i.id == id);
    final next = !target.isCompleted;

    state = AsyncData([
      for (final i in current)
        if (i.id == id)
          BucketItem(id: i.id, title: i.title, isCompleted: next)
        else
          i,
    ]);
    try {
      await _repo.setCompleted(id, next);
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  Future<void> add(String title) async {
    await _repo.add(title.trim());
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    ref.invalidateSelf();
  }
}

final bucketListProvider =
    AsyncNotifierProvider<BucketListNotifier, List<BucketItem>>(
      BucketListNotifier.new,
    );
