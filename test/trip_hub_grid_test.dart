import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/core/providers/auth_provider.dart';
import 'package:tripmate/features/trips/domain/trip.dart';
import 'package:tripmate/features/trips/presentation/trip_hub_screen.dart';

import 'helpers/localized.dart';

class _FakeAuth extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuth()
      : super(AuthState(token: 'test-token', user: const {'id': 'u1'}));
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Trip _makeTrip() {
  return Trip(
    id: 'hub-trip-1',
    name: 'Chuyến Đà Lạt Test',
    startDate: DateTime(2026, 7, 10),
    endDate: DateTime(2026, 7, 15),
    inviteCode: 'HUB123',
    destination: 'Đà Lạt',
    budget: 5000000,
    vibe: 'CHILL',
    memberCount: 5,
    members: const [
      TripMemberLite(id: 'm1', name: 'An'),
      TripMemberLite(id: 'm2', name: 'Bình'),
    ],
  );
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  testWidgets('TripHubScreen không tràn pixel ở textScaler 1.0 trên màn Samsung S25 width 360',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0; // width = 360 dp
    addTearDown(() => tester.view.reset());

    final trip = _makeTrip();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuth()),
        ],
        child: MaterialApp(
          home: TripHubScreen(trip: trip, isDarkMode: false),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Không có overflow exception
    expect(tester.takeException(), isNull);
    expect(find.text('Chia tiền'), findsOneWidget);
    expect(find.text('Quỹ chuyến đi'), findsOneWidget);
  });

  testWidgets('TripHubScreen không tràn pixel khi người dùng tăng font hệ thống lên 1.3',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0; // width = 360 dp
    addTearDown(() => tester.view.reset());

    final trip = _makeTrip();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuth()),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            );
          },
          home: TripHubScreen(trip: trip, isDarkMode: false),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Không có overflow exception nào bị bắt
    expect(tester.takeException(), isNull);
    expect(find.text('Chia tiền'), findsOneWidget);
    expect(find.text('Quỹ chuyến đi'), findsOneWidget);
  });
}
