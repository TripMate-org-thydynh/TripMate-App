import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wishlist_repository.dart';

/// Wishlist của 1 trip với **optimistic vote**.
class WishlistNotifier extends FamilyAsyncNotifier<List<WishlistItem>, String> {
  @override
  Future<List<WishlistItem>> build(String tripId) {
    return ref.watch(wishlistRepositoryProvider).fetch(tripId);
  }

  Future<void> toggleVote(String itemId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic +1 (refetch sẽ chỉnh lại nếu thực ra là bỏ vote).
    state = AsyncData(
      current
          .map(
            (i) => i.id == itemId ? i.copyWith(voteCount: i.voteCount + 1) : i,
          )
          .toList(),
    );

    try {
      await ref.read(wishlistRepositoryProvider).toggleVote(arg, itemId);
      ref.invalidateSelf(); // đồng bộ con số chính xác từ BE
    } catch (_) {
      ref.invalidateSelf();
    }
  }
}

final wishlistProvider =
    AsyncNotifierProvider.family<WishlistNotifier, List<WishlistItem>, String>(
      WishlistNotifier.new,
    );
