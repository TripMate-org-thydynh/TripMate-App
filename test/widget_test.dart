// Unit tests cho data layer của TripMate.
// (Smoke test cũ phụ thuộc full app boot + easy_localization nên không ổn định —
//  thay bằng unit test thuần, chạy nhanh và đáng tin trong CI.)

import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/trips/domain/trip.dart';
import 'package:tripmate/features/expense_tracker/domain/expense.dart';
import 'package:tripmate/features/social/domain/poll.dart';
import 'package:tripmate/features/social/domain/chat_message.dart';
import 'package:tripmate/features/moments/domain/moment.dart';
import 'package:tripmate/features/trip_planner/domain/itinerary_item.dart';
import 'package:tripmate/core/network/api_exception.dart';

void main() {
  group('Trip.fromJson', () {
    test('parse đầy đủ field + memberCount từ _count', () {
      final trip = Trip.fromJson({
        'id': 't1',
        'name': 'Đà Lạt Chill',
        'startDate': '2026-06-15',
        'endDate': '2026-06-18',
        'inviteCode': 'ABC123',
        'currency': 'VND',
        '_count': {'members': 4},
      });

      expect(trip.id, 't1');
      expect(trip.name, 'Đà Lạt Chill');
      expect(trip.inviteCode, 'ABC123');
      expect(trip.memberCount, 4);
      expect(trip.durationDays, 4); // 15→18 inclusive
    });

    test('memberCount fallback theo length của members khi thiếu _count', () {
      final trip = Trip.fromJson({
        'id': 't2',
        'name': 'Trip',
        'startDate': '2026-01-01',
        'endDate': '2026-01-01',
        'inviteCode': 'X',
        'members': [
          {'role': 'CREATOR', 'user': {'id': 'u1', 'name': 'Minh'}},
          {'role': 'MEMBER', 'user': {'id': 'u2', 'name': 'Hà'}},
        ],
      });

      expect(trip.memberCount, 2);
      expect(trip.members.first.name, 'Minh');
      expect(trip.members.first.role, 'CREATOR');
      expect(trip.durationDays, 1);
    });
  });

  group('ApiException', () {
    test('cờ trạng thái theo statusCode', () {
      expect(ApiException('x', statusCode: 401).isUnauthorized, isTrue);
      expect(ApiException('x', statusCode: 403).isForbidden, isTrue);
      expect(ApiException('x', statusCode: 500).isServer, isTrue);
      expect(ApiException('x').isNetwork, isTrue);
    });
  });

  group('BalancesResult.fromJson', () {
    test('parse balances + settlements với amount số', () {
      final r = BalancesResult.fromJson({
        'balances': [
          {'user': {'id': 'u1', 'name': 'Minh'}, 'balance': 150},
          {'user': {'id': 'u2', 'name': 'Hà'}, 'balance': -150},
        ],
        'settlements': [
          {
            'from': {'id': 'u2', 'name': 'Hà'},
            'to': {'id': 'u1', 'name': 'Minh'},
            'amount': 150,
          },
        ],
      });
      expect(r.balances.length, 2);
      expect(r.balances.first.balance, 150);
      expect(r.settlements.single.from.name, 'Hà');
      expect(r.settlements.single.amount, 150);
    });
  });

  group('Poll', () {
    test('tổng vote cộng dồn từ các option', () {
      final p = Poll.fromJson({
        'id': 'p1',
        'question': 'Ăn gì tối nay?',
        'options': [
          {'id': 'o1', 'text': 'Lẩu', '_count': {'votes': 3}},
          {'id': 'o2', 'text': 'Nướng', '_count': {'votes': 1}},
        ],
      });
      expect(p.totalVotes, 4);
      expect(p.options.first.voteCount, 3);
    });

    test('copyWith giữ optimistic vote +1 đúng option', () {
      final p = Poll.fromJson({
        'id': 'p1',
        'question': 'Q',
        'options': [
          {'id': 'o1', 'text': 'A', '_count': {'votes': 1}},
          {'id': 'o2', 'text': 'B', '_count': {'votes': 0}},
        ],
      });
      final updated = p.copyWith(
        options: p.options
            .map((o) => o.id == 'o1' ? o.copyWith(voteCount: o.voteCount + 1) : o)
            .toList(),
      );
      expect(updated.totalVotes, 2); // ban đầu 1, +1 = 2
      expect(updated.options.firstWhere((o) => o.id == 'o1').voteCount, 2);
      expect(updated.options.firstWhere((o) => o.id == 'o2').voteCount, 0);
    });
  });

  group('Các model khác', () {
    test('ChatMessage lấy tên sender từ nested', () {
      final m = ChatMessage.fromJson({
        'id': 'm1',
        'content': 'hi',
        'senderId': 'u1',
        'sender': {'id': 'u1', 'name': 'Minh'},
        'createdAt': '2026-06-19T10:00:00Z',
      });
      expect(m.content, 'hi');
      expect(m.senderName, 'Minh');
    });

    test('Moment optimistic reaction +1', () {
      final mo = Moment.fromJson({
        'id': 'mm1',
        'mediaUrl': 'http://x',
        'user': {'name': 'Hà'},
        '_count': {'reactions': 2, 'comments': 1},
      });
      expect(mo.reactionCount, 2);
      expect(mo.copyWith(reactionCount: mo.reactionCount + 1).reactionCount, 3);
    });

    test('ItineraryItem parse mặc định an toàn', () {
      final it = ItineraryItem.fromJson({
        'id': 'i1',
        'day': 2,
        'startTime': '09:00',
        'placeName': 'Hồ Xuân Hương',
      });
      expect(it.day, 2);
      expect(it.durationMinutes, 60);
      expect(it.placeName, 'Hồ Xuân Hương');
    });
  });
}
