// Widget test cho MyTripsScreen — màn lõi, override trips + notifications repo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/features/trips/data/trips_repository.dart';
import 'package:tripmate/features/trips/domain/trip.dart';
import 'package:tripmate/features/trips/presentation/my_trips_screen.dart';
import 'package:tripmate/features/social/data/notifications_repository.dart';
import 'package:tripmate/core/providers/auth_provider.dart';

/// Auth giả — đã đăng nhập để TripsNotifier.build không trả [] sớm.
class _FakeAuth extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuth() : super(AuthState(token: 'test-token', user: const {'id': 'u1'}));
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeTripsRepo implements TripsRepository {
  final List<Trip> trips;
  _FakeTripsRepo(this.trips);

  @override
  Future<List<Trip>> fetchTrips() async => trips;
  @override
  Future<Trip> fetchTrip(String id) async => trips.firstWhere((t) => t.id == id);
  @override
  Future<Trip> createTrip(
          {required String name,
          String? description,
          String? destination,
          required DateTime startDate,
          required DateTime endDate,
          String? coverImage,
          String currency = 'VND',
          double? budget,
          String? vibe,
          String? theme,
          bool isPublic = false}) async =>
      Trip(id: 'new', name: name, startDate: startDate, endDate: endDate, inviteCode: 'NEW123');
  @override
  Future<Trip> joinTrip(String inviteCode) async => trips.first;
  @override
  Future<Trip> joinByInviteLink(String code) async => trips.first;
  @override
  Future<Trip> joinByAnyCode(String rawCode) async => trips.first;
  @override
  Future<Trip> updateTrip(String id,
          {String? name,
          String? description,
          String? destination,
          DateTime? startDate,
          DateTime? endDate,
          String? coverImage,
          String? currency,
          double? budget,
          String? vibe,
          bool? isPublic}) async =>
      trips.firstWhere((t) => t.id == id);
  @override
  Future<void> leaveTrip(String id) async {}
}

class _FakeNotifRepo implements NotificationsRepository {
  @override
  Future<List<AppNotification>> fetch() async => const [];
  @override
  Future<void> markRead(String id) async {}
  @override
  Future<void> markAllRead() async {}
}

Widget _wrap(TripsRepository repo) {
  return ProviderScope(
    overrides: [
      tripsRepositoryProvider.overrideWithValue(repo),
      notificationsRepositoryProvider.overrideWithValue(_FakeNotifRepo()),
      authProvider.overrideWith((ref) => _FakeAuth()),
    ],
    child: const MaterialApp(home: MyTripsScreen(isDarkMode: true)),
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('empty state khi chưa có chuyến', (tester) async {
    await tester.pumpWidget(_wrap(_FakeTripsRepo([])));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Chưa có chuyến nào'), findsOneWidget);
    expect(find.text('Chuyến mới'), findsOneWidget); // FAB
  });

  testWidgets('render danh sách chuyến + mã mời', (tester) async {
    final repo = _FakeTripsRepo([
      Trip(
        id: 't1',
        name: 'Đà Lạt Chill',
        startDate: DateTime(2026, 6, 15),
        endDate: DateTime(2026, 6, 18),
        inviteCode: 'ABC123',
        memberCount: 4,
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // stagger anim

    expect(find.text('Đà Lạt Chill'), findsOneWidget);
    expect(find.text('ABC123'), findsOneWidget);
  });
}
