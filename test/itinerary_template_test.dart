import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/itinerary_templates/domain/itinerary_template.dart';

void main() {
  group('ItineraryTemplate JSON parsing', () {
    test('Parse đầy đủ các trường mới: tags, isFeatured, ratingAvg, ratingCount', () {
      final json = {
        'id': 'tpl-1',
        'authorId': 'u123',
        'author': {
          'name': 'Hoàng Nam',
          'avatarUrl': 'https://example.com/avatar.jpg',
        },
        'title': 'Đà Lạt 3N2Đ Chill Hết Nấc',
        'description': 'Lịch trình thong thả săn mây và cafe',
        'destination': 'Đà Lạt',
        'coverImage': 'https://example.com/dalat.jpg',
        'vibe': 'CHILL',
        'dayCount': 3,
        'stopCount': 8,
        'isPublic': true,
        'useCount': 42,
        'tags': ['CHILL', 'FOODIE', 'BUDGET_MID'],
        'isFeatured': true,
        'ratingAvg': 4.8,
        'ratingCount': 19,
        'items': [],
      };

      final template = ItineraryTemplate.fromJson(json);

      expect(template.id, 'tpl-1');
      expect(template.authorId, 'u123');
      expect(template.authorName, 'Hoàng Nam');
      expect(template.tags, ['CHILL', 'FOODIE', 'BUDGET_MID']);
      expect(template.isFeatured, isTrue);
      expect(template.ratingAvg, 4.8);
      expect(template.ratingCount, 19);
    });

    test('Parse an toàn khi thiếu các trường mới -> nhận giá trị mặc định', () {
      final json = {
        'id': 'tpl-legacy',
        'title': 'Hà Nội Phố Cổ',
      };

      final template = ItineraryTemplate.fromJson(json);

      expect(template.id, 'tpl-legacy');
      expect(template.tags, isEmpty);
      expect(template.isFeatured, isFalse);
      expect(template.ratingAvg, 0.0);
      expect(template.ratingCount, 0);
    });

    test('TemplateMyState & TemplateRating parse đúng', () {
      final myStateJson = {
        'used': true,
        'myStars': 5,
      };
      final myState = TemplateMyState.fromJson(myStateJson);
      expect(myState.used, isTrue);
      expect(myState.myStars, 5);

      final ratingJson = {
        'stars': 4,
        'comment': 'Lịch trình rất hợp lý!',
        'updatedAt': '2026-09-18T10:00:00Z',
        'user': {
          'id': 'u2',
          'name': 'Bình An',
          'avatarUrl': null,
        },
      };
      final rating = TemplateRating.fromJson(ratingJson);
      expect(rating.stars, 4);
      expect(rating.comment, 'Lịch trình rất hợp lý!');
      expect(rating.user.name, 'Bình An');
      expect(rating.user.id, 'u2');
    });

    test('TemplateTags helpers kiểm tra đúng nhóm ngân sách', () {
      expect(TemplateTags.isBudget('BUDGET_LOW'), isTrue);
      expect(TemplateTags.isBudget('BUDGET_MID'), isTrue);
      expect(TemplateTags.isBudget('BUDGET_HIGH'), isTrue);
      expect(TemplateTags.isBudget('CHILL'), isFalse);
      expect(TemplateTags.isBudget('FOODIE'), isFalse);
    });
  });
}
