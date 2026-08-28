import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class JournalPhoto {
  final String id;
  final String mediaUrl;
  final String? caption;

  const JournalPhoto({
    required this.id,
    required this.mediaUrl,
    this.caption,
  });

  factory JournalPhoto.fromJson(Map<String, dynamic> j) => JournalPhoto(
        id: j['id'] as String,
        mediaUrl: j['mediaUrl'] as String? ?? '',
        caption: j['caption'] as String?,
      );
}

class JournalEntry {
  final String id;
  final String tripId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String? title;
  final String body;
  final String mood;
  final DateTime entryDate;
  final double? latitude;
  final double? longitude;
  final List<JournalPhoto> photos;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.tripId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    this.title,
    required this.body,
    required this.mood,
    required this.entryDate,
    this.latitude,
    this.longitude,
    this.photos = const [],
    required this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] as String,
        tripId: j['tripId'] as String? ?? '',
        authorId: (j['author'] as Map<String, dynamic>?)?['id'] as String? ?? '',
        authorName: (j['author'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        authorAvatarUrl:
            (j['author'] as Map<String, dynamic>?)?['avatarUrl'] as String?,
        title: j['title'] as String?,
        body: j['body'] as String? ?? '',
        mood: j['mood'] as String? ?? 'CHILL',
        entryDate:
            DateTime.tryParse(j['entryDate'] as String? ?? '') ?? DateTime.now(),
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        photos: (j['photos'] as List?)
                ?.whereType<Map>()
                .map((e) => JournalPhoto.fromJson(e.cast<String, dynamic>()))
                .toList() ??
            [],
        createdAt:
            DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class JournalRepository {
  final ApiClient _client;
  JournalRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/journal';

  Future<List<JournalEntry>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => JournalEntry.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  Future<JournalEntry> create(
    String tripId, {
    required String body,
    required String mood,
    required String entryDate,
    String? title,
    double? latitude,
    double? longitude,
    List<Map<String, dynamic>>? photos,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'body': body,
      'mood': mood,
      'entryDate': entryDate,
      'title': ?title,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'photos': ?photos,
    });
    return JournalEntry.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> delete(String tripId, String entryId) =>
      _client.deleteData('${_base(tripId)}/$entryId');
}

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(apiClientProvider));
});
