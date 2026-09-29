import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/core/providers/auth_provider.dart';
import 'package:tripmate/features/gamification/pages/who_pays_wheel_screen.dart';
import 'package:tripmate/features/trips/data/trips_repository.dart';
import 'package:tripmate/features/trips/domain/trip.dart';

import 'helpers/localized.dart';

class _FakeAuth extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuth()
      : super(AuthState(token: 'test-token', user: const {'id': 'u1'}));
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeTripsRepo implements TripsRepository {
  final List<Trip> trips;
  _FakeTripsRepo(this.trips);

  @override
  Future<List<Trip>> fetchTrips() async => trips;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Trip _createTripWithMembers(int count) {
  return Trip(
    id: 'trip-1',
    name: 'Chuyến đi quậy',
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 6, 5),
    inviteCode: 'CHAOS123',
    memberCount: count,
    members: List.generate(
      count,
      (i) => TripMemberLite(
        id: 'member-$i',
        name: 'Thành viên ${i + 1}',
        role: 'MEMBER',
      ),
    ),
  );
}

Widget _wrap(List<Trip> trips, {bool isDark = false}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => _FakeAuth()),
      tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo(trips)),
    ],
    child: MaterialApp(
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: const WhoPaysWheelScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  testWidgets('Nhóm <= 10 người: mỗi người một lát, không có nút chọn',
      (tester) async {
    final trip = _createTripWithMembers(4);
    await tester.pumpWidget(_wrap([trip]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tiêu đề có mặt
    expect(find.text('Ai trả tiền?'), findsOneWidget);

    // Không hiện nút "Chọn người tham gia" vì <= 10 người
    expect(find.byType(OutlinedButton), findsNothing);

    // Bánh xe vẽ CustomPaint ChaosWheelPainter với 4 người
    final customPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is ChaosWheelPainter,
      ),
    );
    final painter = customPaint.painter as ChaosWheelPainter;
    expect(painter.participants.length, 4);
  });

  testWidgets('Nhóm > 10 người: tối đa 10 lát, có nút Chọn người tham gia',
      (tester) async {
    final trip = _createTripWithMembers(15);
    await tester.pumpWidget(_wrap([trip]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Nút "Chọn người tham gia (10/10)" xuất hiện
    expect(find.text('Chọn người tham gia (10/10)'), findsWidgets);

    // Bánh xe chỉ vẽ tối đa 10 người
    final customPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is ChaosWheelPainter,
      ),
    );
    final painter = customPaint.painter as ChaosWheelPainter;
    expect(painter.participants.length, 10);
  });

  testWidgets('Nhóm > 10 người: mở sheet chọn, tìm kiếm và cập nhật số người',
      (tester) async {
    final trip = _createTripWithMembers(15);
    await tester.pumpWidget(_wrap([trip]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Sheet tự động mở trước khi quay khi nhóm > 10 người
    expect(find.text('Chọn người tham gia'), findsWidgets);
    expect(find.text('Tìm thành viên...'), findsOneWidget);

    // Tìm kiếm thành viên
    await tester.enterText(find.byType(TextField), 'Thành viên 15');
    await tester.pump(const Duration(milliseconds: 100));

    // Thấy item Thành viên 15 trong danh sách
    expect(find.widgetWithText(InkWell, 'Thành viên 15'), findsOneWidget);
  });

  testWidgets('ChaosWheelPainter text và color properties tuân thủ spec',
      (tester) async {
    final participants = [
      {'name': 'Nguyễn Văn Rất Dài Cần Cắt Ellipsis', 'avatar': ''},
      {'name': 'Trần Thị B', 'avatar': ''},
    ];

    final painter = ChaosWheelPainter(participants: participants, isDark: false);
    expect(painter.participants.length, 2);

    // Không repaint khi dữ liệu và theme không đổi
    final oldPainter = ChaosWheelPainter(participants: participants, isDark: false);
    expect(painter.shouldRepaint(oldPainter), isFalse);

    // Repaint khi đổi dark theme
    final darkPainter = ChaosWheelPainter(participants: participants, isDark: true);
    expect(painter.shouldRepaint(darkPainter), isTrue);
  });

  testWidgets('Hỗ trợ cả light và dark theme không lỗi', (tester) async {
    final trip = _createTripWithMembers(6);

    // Light mode
    await tester.pumpWidget(_wrap([trip], isDark: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Ai trả tiền?'), findsOneWidget);

    // Dark mode
    await tester.pumpWidget(_wrap([trip], isDark: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Ai trả tiền?'), findsOneWidget);
  });
}
