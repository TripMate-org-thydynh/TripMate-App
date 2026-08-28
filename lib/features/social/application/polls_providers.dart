import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/polls_repository.dart';
import '../domain/poll.dart';

/// Polls của 1 trip với **optimistic vote** (cập nhật UI tức thì, rollback nếu lỗi).
class PollsNotifier extends FamilyAsyncNotifier<List<Poll>, String> {
  @override
  Future<List<Poll>> build(String tripId) {
    return ref.watch(pollsRepositoryProvider).fetch(tripId);
  }

  Future<void> vote(String optionId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // 1) Optimistic: +1 cho option được chọn ngay lập tức.
    state = AsyncData(_applyVote(current, optionId, 1));

    // 2) Gửi BE; lỗi thì rollback bằng refetch.
    try {
      await ref.read(pollsRepositoryProvider).vote(arg, optionId);
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  List<Poll> _applyVote(List<Poll> polls, String optionId, int delta) {
    return polls.map((poll) {
      if (!poll.options.any((o) => o.id == optionId)) return poll;
      return poll.copyWith(
        options: poll.options
            .map(
              (o) => o.id == optionId
                  ? o.copyWith(voteCount: o.voteCount + delta)
                  : o,
            )
            .toList(),
      );
    }).toList();
  }
}

final pollsProvider =
    AsyncNotifierProvider.family<PollsNotifier, List<Poll>, String>(
      PollsNotifier.new,
    );
