import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/itinerary_template.dart';

/// Lịch trình mẫu — `/itinerary-templates` và `/trips/:id/itinerary/templates`.
class ItineraryTemplatesRepository {
  ItineraryTemplatesRepository(this._client);
  final ApiClient _client;

  Future<List<ItineraryTemplate>> listPublic({
    String? query,
    String? tag,
    String sort = 'popular',
  }) async {
    final data = await _client.getData(
      '/itinerary-templates',
      query: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (tag != null && tag.isNotEmpty) 'tag': tag,
        'sort': sort,
        'limit': 50,
      },
    );
    final items = data is Map ? data['items'] : null;
    return _list(items);
  }

  Future<List<ItineraryTemplate>> featured() async {
    final data = await _client.getData('/itinerary-templates/featured');
    return _list(data);
  }

  Future<TemplateMyState> myState(String id) async {
    final data = await _client.getData('/itinerary-templates/$id/me');
    return TemplateMyState.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<List<TemplateRating>> ratings(String id) async {
    final data = await _client.getData('/itinerary-templates/$id/ratings');
    return data is List
        ? data
            .whereType<Map>()
            .map((e) => TemplateRating.fromJson(e.cast<String, dynamic>()))
            .toList()
        : const [];
  }

  Future<Map<String, dynamic>> rate(
    String id, {
    required int stars,
    String? comment,
  }) async {
    final data = await _client.postData('/itinerary-templates/$id/rating', {
      'stars': stars,
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    });
    return (data as Map).cast<String, dynamic>();
  }

  Future<List<ItineraryTemplate>> listMine() async =>
      _list(await _client.getData('/itinerary-templates/mine'));

  Future<ItineraryTemplate> fetch(String id) async {
    final data = await _client.getData('/itinerary-templates/$id');
    return ItineraryTemplate.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<ItineraryTemplate> publish(
    String tripId, {
    required String title,
    String? description,
    required bool isPublic,
    required bool includeNotes,
    List<String> tags = const [],
  }) async {
    final data = await _client.postData('/trips/$tripId/itinerary/templates', {
      'title': title,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      'isPublic': isPublic,
      'includeNotes': includeNotes,
      if (tags.isNotEmpty) 'tags': tags,
    });
    return ItineraryTemplate.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> setPublic(String id, bool isPublic) =>
      _client.patchData('/itinerary-templates/$id', {'isPublic': isPublic});

  Future<void> remove(String id) =>
      _client.deleteData('/itinerary-templates/$id');

  /// Nhân bản mẫu. Trả về id chuyến nhận lịch trình.
  Future<String> duplicate(
    String id, {
    String? intoTripId,
    String? name,
    DateTime? startDate,
  }) async {
    final data = await _client.postData('/itinerary-templates/$id/duplicate', {
      'tripId': intoTripId,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (startDate != null)
        'startDate': startDate.toIso8601String().substring(0, 10),
    });
    return (data as Map)['tripId'] as String;
  }

  List<ItineraryTemplate> _list(dynamic data) => data is List
      ? data
            .whereType<Map>()
            .map((e) => ItineraryTemplate.fromJson(e.cast<String, dynamic>()))
            .toList()
      : const [];
}

final itineraryTemplatesRepositoryProvider =
    Provider<ItineraryTemplatesRepository>(
      (ref) => ItineraryTemplatesRepository(ref.watch(apiClientProvider)),
    );

/// Khoá tìm kiếm cho danh sách công khai: (từ khoá, thẻ, cách sắp).
typedef TemplateQuery = ({String query, String? tag, String sort});

final publicTemplatesProvider = FutureProvider.autoDispose
    .family<List<ItineraryTemplate>, TemplateQuery>(
      (ref, q) => ref
          .watch(itineraryTemplatesRepositoryProvider)
          .listPublic(query: q.query, tag: q.tag, sort: q.sort),
    );

final featuredTemplatesProvider =
    FutureProvider.autoDispose<List<ItineraryTemplate>>(
  (ref) => ref.watch(itineraryTemplatesRepositoryProvider).featured(),
);

final templateMyStateProvider = FutureProvider.autoDispose
    .family<TemplateMyState, String>(
  (ref, id) => ref.watch(itineraryTemplatesRepositoryProvider).myState(id),
);

final templateRatingsProvider = FutureProvider.autoDispose
    .family<List<TemplateRating>, String>(
  (ref, id) => ref.watch(itineraryTemplatesRepositoryProvider).ratings(id),
);

final myTemplatesProvider = FutureProvider.autoDispose<List<ItineraryTemplate>>(
  (ref) => ref.watch(itineraryTemplatesRepositoryProvider).listMine(),
);

final templateDetailProvider = FutureProvider.autoDispose
    .family<ItineraryTemplate, String>(
      (ref, id) => ref.watch(itineraryTemplatesRepositoryProvider).fetch(id),
    );
