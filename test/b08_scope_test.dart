import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/ai/data/ai_repository.dart';

void main() {
  group('b08 AI features unit tests', () {
    test('SquadRoast.fromJson parses json correctly', () {
      final json = {
        'name': 'Alex',
        'type': 'Chúa Tể Đi Trễ',
        'roast': 'Lúc nào cũng đến muộn 2 tiếng',
      };
      final roast = SquadRoast.fromJson(json);
      expect(roast.name, 'Alex');
      expect(roast.type, 'Chúa Tể Đi Trễ');
      expect(roast.roast, 'Lúc nào cũng đến muộn 2 tiếng');
    });

    test('SquadMood.fromJson parses json correctly', () {
      final json = {
        'overallMood': 'Chill & Vui vẻ',
        'tensionLevel': 2,
        'moodAnalysis': 'Cả nhóm chi tiêu rất hợp lý',
      };
      final mood = SquadMood.fromJson(json);
      expect(mood.overallMood, 'Chill & Vui vẻ');
      expect(mood.tensionLevel, 2);
      expect(mood.moodAnalysis, 'Cả nhóm chi tiêu rất hợp lý');
    });

    test('SuggestedActivity.fromJson parses json correctly', () {
      final json = {
        'time': '08:00',
        'location': 'Tiệm Cà Phê Hoàng Hôn',
        'reason': 'View đồi săn mây cực chill',
      };
      final act = SuggestedActivity.fromJson(json);
      expect(act.time, '08:00');
      expect(act.location, 'Tiệm Cà Phê Hoàng Hôn');
      expect(act.reason, 'View đồi săn mây cực chill');
    });

    test('AiQueueItem.fromJson parses status and progress', () {
      final json = {
        'id': 'q-1',
        'task': 'Lập lịch trình Đà Lạt',
        'type': 'ITINERARY_PLAN',
        'status': 'COMPLETED',
        'progress': 100,
        'createdAt': '2026-09-15T00:00:00.000Z',
      };
      final item = AiQueueItem.fromJson(json);
      expect(item.id, 'q-1');
      expect(item.isDone, isTrue);
      expect(item.isFailed, isFalse);
      expect(item.progress, 100);
    });

    test('SuggestedPrompt.fromJson parses json correctly', () {
      final json = {
        'id': 'p-1',
        'title': 'Tối ưu hóa hóa đơn',
        'prompt': 'Hãy quét và chỉ ra ai đang nợ tiền tôi nhiều nhất',
      };
      final prompt = SuggestedPrompt.fromJson(json);
      expect(prompt.id, 'p-1');
      expect(prompt.title, 'Tối ưu hóa hóa đơn');
      expect(prompt.prompt, 'Hãy quét và chỉ ra ai đang nợ tiền tôi nhiều nhất');
    });

    test('VibeMatch.fromJson parses json correctly', () {
      final json = {
        'matchPercentage': 92,
        'vibeTags': ['chill', 'aesthetic'],
        'analysis': 'Rất hợp gu nhóm bạn',
        'locationName': 'Cafe The Hill',
        'locationAddress': 'Dalat',
      };
      final match = VibeMatch.fromJson(json);
      expect(match.matchPercentage, 92);
      expect(match.vibeTags, contains('chill'));
      expect(match.analysis, 'Rất hợp gu nhóm bạn');
      expect(match.locationName, 'Cafe The Hill');
    });
  });
}
