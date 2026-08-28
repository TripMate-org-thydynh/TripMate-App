import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class TripDocument {
  final String id;
  final String tripId;
  final String name;
  final String url;
  final String mimeType;
  final int? sizeBytes;
  final String? linkedType;
  final String uploaderName;
  final String? uploaderAvatarUrl;
  final DateTime createdAt;

  const TripDocument({
    required this.id,
    required this.tripId,
    required this.name,
    required this.url,
    required this.mimeType,
    this.sizeBytes,
    this.linkedType,
    required this.uploaderName,
    this.uploaderAvatarUrl,
    required this.createdAt,
  });

  factory TripDocument.fromJson(Map<String, dynamic> j) => TripDocument(
        id: j['id'] as String,
        tripId: j['tripId'] as String? ?? '',
        name: j['name'] as String? ?? '',
        url: j['url'] as String? ?? '',
        mimeType: j['mimeType'] as String? ?? 'application/octet-stream',
        sizeBytes: (j['sizeBytes'] as num?)?.toInt(),
        linkedType: j['linkedType'] as String?,
        uploaderName:
            (j['uploader'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        uploaderAvatarUrl:
            (j['uploader'] as Map<String, dynamic>?)?['avatarUrl'] as String?,
        createdAt:
            DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';

  String get sizeLabel {
    if (sizeBytes == null) return '';
    final kb = sizeBytes! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

class DocumentsRepository {
  final ApiClient _client;
  DocumentsRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/documents';

  Future<List<TripDocument>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => TripDocument.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  Future<TripDocument> create(
    String tripId, {
    required String name,
    required String url,
    required String mimeType,
    int? sizeBytes,
    String? linkedType,
    String? linkedId,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'name': name,
      'url': url,
      'mimeType': mimeType,
      'sizeBytes': ?sizeBytes,
      'linkedType': ?linkedType,
      'linkedId': ?linkedId,
    });
    return TripDocument.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> delete(String tripId, String documentId) =>
      _client.deleteData('${_base(tripId)}/$documentId');
}

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepository(ref.watch(apiClientProvider));
});
