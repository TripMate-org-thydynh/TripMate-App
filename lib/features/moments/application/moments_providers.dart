import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/offline_provider.dart';

import '../data/moments_repository.dart';
import '../domain/moment.dart';

/// Moments của 1 trip với **optimistic reaction**, **optimistic board layout**,
/// **favorite**, và **comments**.
class MomentsNotifier extends FamilyAsyncNotifier<List<Moment>, String> {
  final _favoriteIntents = <String, bool>{};
  final _confirmedFavorites = <String, bool>{};
  final _favoriteWrites = <String>{};

  @override
  Future<List<Moment>> build(String tripId) {
    ref.listen(offlineProvider, (wasOffline, offline) {
      if (wasOffline == true && !offline) {
        for (final id in _favoriteIntents.keys.toList()) {
          unawaited(_flushFavorite(id));
        }
      }
    });
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
      await ref
          .read(momentsRepositoryProvider)
          .updateBoardLayout(
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
    final target = state.valueOrNull
        ?.where((m) => m.id == momentId)
        .firstOrNull;
    if (target == null) return;
    final nextFav = !target.isFavorite;
    _confirmedFavorites.putIfAbsent(momentId, () => target.isFavorite);
    _favoriteIntents[momentId] = nextFav;
    _setFavorite(momentId, nextFav);
    await _flushFavorite(momentId);
  }

  void _setFavorite(String momentId, bool favorite) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current
          .map(
            (moment) => moment.id == momentId
                ? moment.copyWith(isFavorite: favorite)
                : moment,
          )
          .toList(),
    );
  }

  Future<void> _flushFavorite(String id) async {
    if (ref.read(offlineProvider) || !_favoriteWrites.add(id)) return;
    try {
      final repo = ref.read(momentsRepositoryProvider);
      while (_favoriteIntents.containsKey(id)) {
        final desired = _favoriteIntents[id]!;
        await repo.setFavorite(arg, id, desired);
        _confirmedFavorites[id] = desired;
        if (_favoriteIntents[id] == desired) {
          _favoriteIntents.remove(id);
          _confirmedFavorites.remove(id);
        }
      }
      ref.invalidate(tripMomentsProvider(arg));
    } catch (error) {
      if (error is ApiException && error.isNetwork) {
        showGlobalSnack('errors.connection_lost'.tr(), isError: true);
        return;
      }
      _favoriteIntents.remove(id);
      final previous = _confirmedFavorites.remove(id);
      if (previous != null) _setFavorite(id, previous);
      showGlobalSnack('errors.generic_soft'.tr(), isError: true);
    } finally {
      _favoriteWrites.remove(id);
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
