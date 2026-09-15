import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/fund/data/fund_repository.dart';
import 'package:tripmate/features/packing/data/packing_repository.dart';
import 'package:tripmate/features/reservations/data/reservations_repository.dart';
import 'package:tripmate/features/system_states/application/tripmate_mcp_config.dart';
import 'package:tripmate/features/todos/data/todos_repository.dart';

void main() {
  group('b02 features unit tests', () {
    test('Reservation.fromJson parses valid json and enum type', () {
      final json = {
        'id': 'res-1',
        'type': 'FLIGHT',
        'title': 'Flight VN123',
        'location': 'SGN -> HAN',
        'confirmationNumber': 'CONF123',
        'price': 1500000,
        'startTime': '2026-10-01T10:00:00Z',
        'status': 'CONFIRMED',
      };
      final res = Reservation.fromJson(json);
      expect(res.id, 'res-1');
      expect(res.type, ReservationType.flight);
      expect(res.title, 'Flight VN123');
      expect(res.price, 1500000.0);
    });

    test('TodoList.fromJson parses items and progress', () {
      final json = {
        'items': [
          {
            'id': 'todo-1',
            'title': 'Book tour',
            'priority': 'HIGH',
            'isDone': true,
          },
          {
            'id': 'todo-2',
            'title': 'Buy tickets',
            'priority': 'NORMAL',
            'isDone': false,
          },
        ],
        'progress': {
          'total': 2,
          'done': 1,
          'percent': 50,
        },
      };
      final list = TodoList.fromJson(json);
      expect(list.items.length, 2);
      expect(list.total, 2);
      expect(list.done, 1);
      expect(list.percent, 50);
      expect(list.items.first.isDone, isTrue);
    });

    test('PackingList.fromJson parses items and calculates progress', () {
      final json = {
        'items': [
          {
            'id': 'pack-1',
            'name': 'Sunscreen',
            'category': 'TOILETRIES',
            'quantity': 2,
            'isPacked': true,
          },
          {
            'id': 'pack-2',
            'name': 'Passport',
            'category': 'DOCS',
            'quantity': 1,
            'isPacked': false,
          },
        ],
        'progress': {
          'total': 2,
          'packed': 1,
          'percent': 50,
        },
      };
      final list = PackingList.fromJson(json);
      expect(list.items.length, 2);
      expect(list.total, 2);
      expect(list.packed, 1);
      expect(list.percent, 50);
      expect(list.items.first.name, 'Sunscreen');
    });

    test('TripFund.fromJson parses contributions and targetAmount', () {
      final json = {
        'id': 'fund-1',
        'targetAmount': 5000000,
        'totalCollected': 2500000,
        'progressPercent': 50.0,
        'contributions': [
          {
            'id': 'c-1',
            'amount': 2500000,
            'note': 'Deposit',
            'user': {
              'id': 'u-1',
              'name': 'Alice',
            },
          },
        ],
      };
      final fund = TripFund.fromJson(json);
      expect(fund.id, 'fund-1');
      expect(fund.targetAmount, 5000000.0);
      expect(fund.totalCollected, 2500000.0);
      expect(fund.contributions.length, 1);
      expect(fund.contributions.first.user?.name, 'Alice');
    });

    test('TripMateMcpConfig schema contains correct server name and tools', () {
      expect(TripMateMcpConfig.schema['server']['name'], 'tripmate-mcp-server');
      final tools = TripMateMcpConfig.schema['tools'] as List;
      expect(tools.length, 3);
    });
  });
}
