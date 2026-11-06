import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/moments_repository.dart';
import '../domain/moment.dart';

/// Moments của 1 trip với **optimistic reaction**, **optimistic board layout**,
/// **favorite**, và **comments**.
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

  Future<void> addComment(String momentId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final current = state.valueOrNull;
    final created = await ref
        .read(momentsRepositoryProvider)
        .comment(arg, momentId, trimmed);
    if (current != null && created != null) {
      state = AsyncData(
        current
            .map(
              (m) => m.id == momentId
                  ? m.copyWith(
                      commentCount: m.commentCount + 1,
                      comments: [...m.comments, created],
                    )
                  : m,
            )
            .toList(),
      );
    } else {
      ref.invalidateSelf();
    }
  }

  Future<void> updateBoardLayout(
    String momentId, {
    double? boardX,
    double? boardY,
    double? boardRotation,
    double? boardScale,
    String? boardFilter,
    String? noteColor,
    bool? isPinned,
    bool? isFavorite,
    String? caption,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic update on the board so dragging/filtering feels instantaneous.
    final prev = current;
    state = AsyncData(
      current
          .map(
            (m) => m.id == momentId
                ? m.copyWith(
                    boardX: boardX,
                    boardY: boardY,
                    boardRotation: boardRotation,
                    boardScale: boardScale,
                    boardFilter: boardFilter,
                    noteColor: noteColor,
                    isPinned: isPinned,
                    isFavorite: isFavorite,
                    caption: caption,
                  )
                : m,
          )
          .toList(),
    );

    try {
      await ref.read(momentsRepositoryProvider).updateBoardLayout(
        arg,
        momentId,
        boardX: boardX,
        boardY: boardY,
        boardRotation: boardRotation,
        boardScale: boardScale,
        boardFilter: boardFilter,
        noteColor: noteColor,
        isPinned: isPinned,
        isFavorite: isFavorite,
        caption: caption,
      );
      ref.invalidate(tripMomentsProvider(arg));
    } catch (_) {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> toggleFavorite(String momentId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.where((m) => m.id == momentId).firstOrNull;
    if (target == null) return;

    final nextFav = !target.isFavorite;
    final prev = current;
    state = AsyncData(
      current
          .map((m) => m.id == momentId ? m.copyWith(isFavorite: nextFav) : m)
          .toList(),
    );

    try {
      await ref.read(momentsRepositoryProvider).toggleFavorite(arg, momentId);
      ref.invalidate(tripMomentsProvider(arg));
    } catch (_) {
      state = AsyncData(prev);
    }
  }

  Future<void> deleteMoment(String momentId) async {
    final current = state.valueOrNull;
    final prev = current;
    if (current != null) {
      state = AsyncData(current.where((m) => m.id != momentId).toList());
    }
    try {
      await ref.read(momentsRepositoryProvider).delete(arg, momentId);
      ref.invalidate(tripMomentsProvider(arg));
      ref.invalidate(recentMomentsProvider);
    } catch (_) {
      if (prev != null) state = AsyncData(prev);
      rethrow;
    }
  }
}

final momentsProvider =
    AsyncNotifierProvider.family<MomentsNotifier, List<Moment>, String>(
      MomentsNotifier.new,
    );
