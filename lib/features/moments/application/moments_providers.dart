import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/moments_repository.dart';
import '../domain/moment.dart';

/// Moments của 1 trip với **optimistic reaction**.
class MomentsNotifier extends FamilyAsyncNotifier<List<Moment>, String> {
  @override
  Future<List<Moment>> build(String tripId) {
    return ref.watch(momentsRepositoryProvider).fetch(tripId);
  }

  Future<void> react(String momentId, {String emoji = '❤️'}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic +1 tim ngay.
    state = AsyncData(
      current
          .map(
            (m) => m.id == momentId
                ? m.copyWith(reactionCount: m.reactionCount + 1)
                : m,
          )
          .toList(),
    );

    try {
      await ref.read(momentsRepositoryProvider).react(arg, momentId, emoji);
    } catch (_) {
      ref.invalidateSelf();
    }
  }
}

final momentsProvider =
    AsyncNotifierProvider.family<MomentsNotifier, List<Moment>, String>(
      MomentsNotifier.new,
    );
