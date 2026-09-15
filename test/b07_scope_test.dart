import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/dashboard/data/home_feed_repository.dart';

void main() {
  group('b07 dashboard features unit tests', () {
    test('SquadActivity.fromJson parses correctly and handles known types', () {
      final json = {
        'id': 'act-1',
        'type': 'EXPENSE_ADDED',
        'tripName': 'Đà Lạt Chill',
        'actorName': 'Minh',
      };
      final act = SquadActivity.fromJson(json);
      expect(act.id, 'act-1');
      expect(act.type, 'EXPENSE_ADDED');
      expect(act.tripName, 'Đà Lạt Chill');
      expect(act.actorName, 'Minh');
    });

    test('UpNextItem.fromJson parses correctly', () {
      final json = {
        'tripId': 'trip-1',
        'tripName': 'Đà Lạt 3N2Đ',
        'day': 2,
        'startTime': '14:30',
        'placeName': 'Tiệm Cà Phê Hoàng Hôn',
        'placeAddress': 'Đà Lạt, Lâm Đồng',
        'durationMinutes': 90,
      };
      final item = UpNextItem.fromJson(json);
      expect(item.tripId, 'trip-1');
      expect(item.tripName, 'Đà Lạt 3N2Đ');
      expect(item.day, 2);
      expect(item.startTime, '14:30');
      expect(item.placeName, 'Tiệm Cà Phê Hoàng Hôn');
      expect(item.placeAddress, 'Đà Lạt, Lâm Đồng');
      expect(item.durationMinutes, 90);
    });

    test('ExpenseSummary.fromJson parses correctly', () {
      final json = {
        'hasData': true,
        'totalAmount': 3500000.0,
        'paidCount': 7,
        'totalCount': 10,
        'paidPercent': 70,
        'topDebtorName': 'Hải',
        'topDebtorAmount': 500000.0,
      };
      final sum = ExpenseSummary.fromJson(json);
      expect(sum.hasData, isTrue);
      expect(sum.totalAmount, 3500000.0);
      expect(sum.paidCount, 7);
      expect(sum.totalCount, 10);
      expect(sum.paidPercent, 70);
      expect(sum.topDebtorName, 'Hải');
      expect(sum.topDebtorAmount, 500000.0);
    });
  });
}
