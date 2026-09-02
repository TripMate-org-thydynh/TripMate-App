import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/moments/data/trip_recap_repository.dart';

void main() {
  group('TripRecap Model Real API Parsing', () {
    test('parses real backend getRecap JSON successfully', () {
      final json = {
        'tripId': 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee1',
        'tripName': 'Đà Lạt Vibe Squad 2026',
        'destination': 'Đà Lạt, Lâm Đồng',
        'coverImage': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200',
        'startDate': '2026-03-10T00:00:00.000Z',
        'endDate': '2026-03-14T00:00:00.000Z',
        'days': 5,
        'memberCount': 5,
        'members': [
          {
            'id': 'fcce0f29-4ad3-46e2-814e-c64a994d61f6',
            'name': 'Nguyễn Đình Thi',
            'avatarUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400'
          },
          {
            'id': '11111111-2222-3333-4444-555555555551',
            'name': 'Lê Thảo Ly',
            'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400'
          }
        ],
        'placeCount': 12,
        'momentCount': 8,
        'expenseCount': 8,
        'totalSpent': 8650000,
        'currency': 'VND',
        'moments': [
          {
            'id': 'm1',
            'mediaUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1000',
            'posterUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1000',
            'type': 'PHOTO',
            'caption': 'Săn mây thành công lúc 5h30 sáng tại Cầu Đất! Vibe đỉnh chóp ☁️✨',
            'authorName': 'Lê Thảo Ly',
            'authorAvatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
            'reactionCount': 4,
            'commentCount': 2,
            'createdAt': '2026-09-02T12:47:39.083Z'
          }
        ],
        'mvp': {
          'userId': '11111111-2222-3333-4444-555555555551',
          'name': 'Lê Thảo Ly',
          'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
          'moments': 2,
          'expenses': 3,
          'xp': 155
        },
        'hasData': true
      };

      final recap = TripRecap.fromJson(json);

      expect(recap.tripName, equals('Đà Lạt Vibe Squad 2026'));
      expect(recap.destination, equals('Đà Lạt, Lâm Đồng'));
      expect(recap.days, equals(5));
      expect(recap.memberCount, equals(5));
      expect(recap.placeCount, equals(12));
      expect(recap.momentCount, equals(8));
      expect(recap.expenseCount, equals(8));
      expect(recap.totalSpent, equals(8650000.0));
      expect(recap.mvpName, equals('Lê Thảo Ly'));
      expect(recap.mvpAvatarUrl, contains('unsplash'));
      expect(recap.moments.length, equals(1));
      expect(recap.moments.first.caption, contains('Săn mây'));
      expect(recap.members.length, equals(2));
      expect(recap.hasData, isTrue);
    });
  });
}
