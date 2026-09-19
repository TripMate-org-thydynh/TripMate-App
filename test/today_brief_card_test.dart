import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/features/dashboard/data/today_brief_repository.dart';
import 'package:tripmate/features/dashboard/presentation/widgets/today_brief_card.dart';

import 'helpers/localized.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  group('TodayBriefCard widget tests', () {
    testWidgets('Ẩn thẻ khi chuyến chưa diễn ra (day < 1)', (tester) async {
      final briefBeforeTrip = TodayBrief(
        tripId: 'trip-pre',
        tripName: 'Chuyến Sắp Đi',
        day: 0,
        date: '2026-09-20',
        stops: [
          TodayBriefStop(
            id: 's1',
            startTime: '08:00',
            placeName: 'Sân bay Nội Bài',
          ),
        ],
        todos: [
          TodayBriefTodo(
            id: 't1',
            title: 'Check-in online',
            assigneeName: 'An',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayBriefProvider('trip-pre').overrideWith((ref) => briefBeforeTrip),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TodayBriefCard(tripId: 'trip-pre'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Thẻ phải ẩn hoàn toàn
      expect(find.textContaining('Hôm nay'), findsNothing);
      expect(find.text('Sân bay Nội Bài'), findsNothing);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('Ẩn thẻ khi không còn điểm dừng và việc cần làm', (tester) async {
      final briefEmpty = TodayBrief(
        tripId: 'trip-empty',
        tripName: 'Chuyến Nghỉ Ngơi',
        day: 3,
        date: '2026-09-20',
        stops: const [],
        todos: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayBriefProvider('trip-empty').overrideWith((ref) => briefEmpty),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TodayBriefCard(tripId: 'trip-empty'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Hôm nay'), findsNothing);
    });

    testWidgets('Hiện đầy đủ thông tin khi có dữ liệu hợp lệ (day >= 1)', (tester) async {
      final briefActive = TodayBrief(
        tripId: 'trip-active',
        tripName: 'Đà Lạt Săn Mây',
        day: 2,
        date: '2026-09-20',
        weather: const TodayBriefWeather(
          weatherCode: 0,
          tempMin: 16.0,
          tempMax: 24.0,
          rainProbability: 25,
        ),
        stops: [
          TodayBriefStop(
            id: 's1',
            startTime: '07:30',
            placeName: 'Đồi Chè Cầu Đất',
            rainRisk: 30,
          ),
          TodayBriefStop(
            id: 's2',
            startTime: '10:00',
            placeName: 'Tiệm Cà Phê Túi Mơ To',
          ),
        ],
        todos: [
          TodayBriefTodo(
            id: 't1',
            title: 'Mua quà lưu niệm',
            assigneeName: 'Hoàng Nam',
          ),
          TodayBriefTodo(
            id: 't2',
            title: 'Trả xe máy',
            assigneeName: null,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayBriefProvider('trip-active').overrideWith((ref) => briefActive),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TodayBriefCard(tripId: 'trip-active'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Kiểm tra tiêu đề ngày
      expect(find.textContaining('Ngày 2'), findsOneWidget);

      // Kiểm tra nhiệt độ và thời tiết
      expect(find.text('16°–24°C'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);

      // Kiểm tra các điểm dừng
      expect(find.text('07:30'), findsOneWidget);
      expect(find.text('Đồi Chè Cầu Đất'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget); // rain risk
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('Tiệm Cà Phê Túi Mơ To'), findsOneWidget);

      // Kiểm tra việc cần làm
      expect(find.textContaining('Mua quà lưu niệm — Hoàng Nam'), findsOneWidget);
      expect(find.textContaining('Trả xe máy — chưa ai nhận'), findsOneWidget);
    });
  });
}
