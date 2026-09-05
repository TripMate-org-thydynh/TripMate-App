import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/poll.dart';

/// Repository cho Polls — `/trips/:tripId/polls`.
class PollsRepository {
  final ApiClient _client;
  PollsRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/polls';

  Future<List<Poll>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Poll.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<Poll> create(
    String tripId, {
    required String question,
    required List<Map<String, String?>> options,
    bool isMultiple = false,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'question': question,
      'options': options,
      'isMultiple': isMultiple,
    });
    return Poll.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> vote(String tripId, String optionId) =>
      _client.postData('${_base(tripId)}/options/$optionId/vote');
}

final pollsRepositoryProvider = Provider<PollsRepository>((ref) {
  return PollsRepository(ref.watch(apiClientProvider));
});

final tripPollsProvider = FutureProvider.family<List<Poll>, String>((
  ref,
  tripId,
) async {
  return ref.watch(pollsRepositoryProvider).fetch(tripId);
});
