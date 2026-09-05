import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Wishlist item (địa điểm/quán muốn đi) — BE `wishlist` module.
class WishlistItem {
  final String id;
  final String name;
  final String type;
  final String? address;
  final String? link;
  final String? notes;
  final int voteCount;

  const WishlistItem({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.link,
    this.notes,
    this.voteCount = 0,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> j) => WishlistItem(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    type: j['type'] as String? ?? 'PLACE',
    address: j['address'] as String?,
    link: j['link'] as String?,
    notes: j['notes'] as String?,
    voteCount: (j['voteCount'] as num?)?.toInt() ?? 0,
  );

  WishlistItem copyWith({int? voteCount}) => WishlistItem(
    id: id,
    name: name,
    type: type,
    address: address,
    link: link,
    notes: notes,
    voteCount: voteCount ?? this.voteCount,
  );
}

/// Repository cho Wishlist — `/trips/:tripId/wishlist`.
class WishlistRepository {
  final ApiClient _client;
  WishlistRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/wishlist';

  Future<List<WishlistItem>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => WishlistItem.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<WishlistItem> add(
    String tripId, {
    required String name,
    String type = 'PLACE',
    String? address,
    String? link,
    String? notes,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'name': name,
      'type': type,
      'address': ?address,
      'link': ?link,
      'notes': ?notes,
    });
    return WishlistItem.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> toggleVote(String tripId, String itemId) =>
      _client.postData('${_base(tripId)}/$itemId/vote');
}

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(apiClientProvider));
});

final tripWishlistProvider = FutureProvider.family<List<WishlistItem>, String>((
  ref,
  tripId,
) async {
  return ref.watch(wishlistRepositoryProvider).fetch(tripId);
});
