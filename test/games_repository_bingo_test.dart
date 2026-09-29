import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/core/network/api_client.dart';
import 'package:tripmate/features/gamification/data/games_repository.dart';

class FakeApiClient extends ApiClient {
  dynamic getResult;
  String? lastGetPath;
  String? lastPatchPath;
  Map<String, dynamic>? lastPatchBody;

  FakeApiClient() : super(Dio());

  @override
  Future<dynamic> getData(String path, {Map<String, dynamic>? query}) async {
    lastGetPath = path;
    return getResult;
  }

  @override
  Future<dynamic> patchData(String path, [Map<String, dynamic>? body]) async {
    lastPatchPath = path;
    lastPatchBody = body;
    return null;
  }
}

void main() {
  group('GamesRepository - Bingo session handling', () {
    late FakeApiClient fakeClient;
    late GamesRepository repository;

    setUp(() {
      fakeClient = FakeApiClient();
      repository = GamesRepository(fakeClient);
    });

    test('fetchBingo trả về ván đang mở khi có cả ván kết thúc và ván active', () async {
      fakeClient.getResult = [
        {
          'id': 'session-ended',
          'tripId': 'trip-001',
          'gameType': 'CARD_MATCH',
          'stateJson': {
            'game': 'BINGO',
            'marked': [0, 1, 2],
          },
          'isActive': false,
          'createdAt': '2026-09-15T12:00:00.000Z',
        },
        {
          'id': 'session-active',
          'tripId': 'trip-001',
          'gameType': 'CARD_MATCH',
          'stateJson': {
            'game': 'BINGO',
            'marked': [3, 4, 8],
          },
          'isActive': true,
          'createdAt': '2026-09-15T11:00:00.000Z',
        },
      ];

      final bingo = await repository.fetchBingo('trip-001');

      expect(fakeClient.lastGetPath, '/trips/trip-001/games');
      expect(bingo, isNotNull);
      expect(bingo!.id, 'session-active');
      expect(bingo.marked, [3, 4, 8]);
    });

    test('fetchBingo trả về null khi chỉ có các ván đã kết thúc', () async {
      fakeClient.getResult = [
        {
          'id': 'session-ended-1',
          'tripId': 'trip-001',
          'gameType': 'CARD_MATCH',
          'stateJson': {
            'game': 'BINGO',
            'marked': [0, 1, 2],
          },
          'isActive': false,
        },
        {
          'id': 'session-ended-2',
          'tripId': 'trip-001',
          'gameType': 'CARD_MATCH',
          'stateJson': {
            'game': 'BINGO',
            'marked': [3, 4, 5],
          },
          'isActive': false,
        },
      ];

      final bingo = await repository.fetchBingo('trip-001');

      expect(fakeClient.lastGetPath, '/trips/trip-001/games');
      expect(bingo, isNull);
    });

    test('fetchBingo bỏ qua session khác CARD_MATCH hoặc stateJson không phải BINGO', () async {
      fakeClient.getResult = [
        {
          'id': 'session-memory',
          'tripId': 'trip-001',
          'gameType': 'CARD_MATCH',
          'stateJson': {
            'game': 'MEMORY_MATCH',
            'matched': [1, 2],
          },
          'isActive': true,
        },
        {
          'id': 'session-roulette',
          'tripId': 'trip-001',
          'gameType': 'SPIN_WHEEL',
          'stateJson': {
            'game': 'BINGO',
          },
          'isActive': true,
        },
        {
          'id': 'session-bingo-line-xp',
          'tripId': 'trip-001',
          'gameType': 'CARD_MATCH',
          'stateJson': {
            'game': 'BINGO_LINE',
            'lines': 1,
          },
          'isActive': true,
        },
      ];

      final bingo = await repository.fetchBingo('trip-001');

      expect(bingo, isNull);
    });

    test('endBingo gọi đúng endpoint PATCH /trips/:tripId/games/:sessionId/end', () async {
      await repository.endBingo('trip-123', 'session-abc');

      expect(fakeClient.lastPatchPath, '/trips/trip-123/games/session-abc/end');
    });
  });
}
