// Widget test cho TripWishlistScreen — verify các state (empty/data) render đúng
// bằng cách override repository provider với fake (không gọi mạng thật).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/localized.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/features/trip_planner/data/wishlist_repository.dart';
import 'package:tripmate/features/trip_planner/presentation/trip_wishlist_screen.dart';

class _FakeWishlistRepo implements WishlistRepository {
  final List<WishlistItem> items;
  _FakeWishlistRepo(this.items);

  @override
  Future<List<WishlistItem>> fetch(String tripId) async => items;

  @override
  Future<WishlistItem> add(String tripId,
      {required String name,
      String type = 'PLACE',
      String? address,
      String? link,
      String? notes}) async {
    return WishlistItem(id: 'new', name: name, type: type, address: address);
  }

  @override
  Future<void> toggleVote(String tripId, String itemId) async {}
}

Widget _wrap(WishlistRepository repo) {
  return ProviderScope(
    overrides: [wishlistRepositoryProvider.overrideWithValue(repo)],
    child: localized(const TripWishlistScreen(tripId: 't1', isDarkMode: true)),
  );
}

void main() {
  setUpAll(() async {
    // Tránh tải font qua mạng trong test.
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  testWidgets('hiện empty state khi không có item', (tester) async {
    await tester.pumpWidget(_wrap(_FakeWishlistRepo([])));
    await tester.pump(); // resolve future
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Wishlist trống'), findsOneWidget);
  });

  testWidgets('render item + vote count khi có data', (tester) async {
    final repo = _FakeWishlistRepo([
      const WishlistItem(id: '1', name: 'Hồ Xuân Hương', type: 'PLACE', voteCount: 5),
      const WishlistItem(id: '2', name: 'Chợ đêm', type: 'PLACE', voteCount: 2),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Hồ Xuân Hương'), findsOneWidget);
    expect(find.text('Chợ đêm'), findsOneWidget);
    // item nhiều vote hơn xếp trên (sort desc)
    expect(find.text('5'), findsOneWidget);
  });
}
