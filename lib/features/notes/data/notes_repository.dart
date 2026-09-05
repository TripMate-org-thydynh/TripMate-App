import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class TripNote {
  final String id;
  final String tripId;
  final String content;
  final String? title;
  final String color;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime updatedAt;

  const TripNote({
    required this.id,
    required this.tripId,
    required this.content,
    this.title,
    this.color = '#FFD84D',
    required this.authorName,
    this.authorAvatarUrl,
    required this.updatedAt,
  });

  factory TripNote.fromJson(Map<String, dynamic> j) => TripNote(
    id: j['id'] as String,
    tripId: j['tripId'] as String? ?? '',
    content: j['content'] as String? ?? '',
    title: j['title'] as String?,
    color: j['color'] as String? ?? '#FFD84D',
    authorName:
        (j['author'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    authorAvatarUrl:
        (j['author'] as Map<String, dynamic>?)?['avatarUrl'] as String?,
    updatedAt:
        DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class NotesRepository {
  final ApiClient _client;
  NotesRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/notes';

  Future<List<TripNote>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => TripNote.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  Future<TripNote> create(
    String tripId, {
    required String content,
    String? title,
    String? color,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'content': content,
      'title': ?title,
      'color': ?color,
    });
    return TripNote.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<TripNote> update(
    String tripId,
    String noteId, {
    String? content,
    String? title,
    String? color,
  }) async {
    final data = await _client.patchData('${_base(tripId)}/$noteId', {
      'content': ?content,
      'title': ?title,
      'color': ?color,
    });
    return TripNote.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> delete(String tripId, String noteId) =>
      _client.deleteData('${_base(tripId)}/$noteId');
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(apiClientProvider));
});
