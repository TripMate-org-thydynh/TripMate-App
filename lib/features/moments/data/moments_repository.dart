import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/moment.dart';

/// Repository cho Moments — `/trips/:tripId/moments`.
class MomentsRepository {
  final ApiClient _client;
  MomentsRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/moments';

  Future<List<Moment>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Moment.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  /// Kỷ niệm mới nhất trên MỌI chuyến của user — dùng cho scrapbook màn Home.
  Future<List<RecentMoment>> fetchRecent() async {
    final data = await _client.getData('/users/me/moments/recent');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => RecentMoment.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<void> react(String tripId, String momentId, String emoji) => _client
      .postData('${_base(tripId)}/$momentId/reactions', {'emoji': emoji});

  Future<void> comment(String tripId, String momentId, String text) =>
      _client.postData('${_base(tripId)}/$momentId/comments', {'text': text});

  /// Đặt lại caption cho khoảnh khắc (chỉ tác giả sửa được).
  Future<void> updateCaption(
    String tripId,
    String momentId,
    String caption,
  ) => _client.patchData('${_base(tripId)}/$momentId', {'caption': caption});

  Future<void> delete(String tripId, String momentId) =>
      _client.deleteData('${_base(tripId)}/$momentId');

  Future<Moment> create({
    required String tripId,
    required String mediaUrl,
    required String type,
    String? caption,
    double? latitude,
    double? longitude,
    String? placeName,
  }) async {
    final res = await _client.postData(_base(tripId), {
      'mediaUrl': mediaUrl,
      'type': type,
      'caption': caption,
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
    });
    return Moment.fromJson(res as Map<String, dynamic>);
  }
}

final momentsRepositoryProvider = Provider<MomentsRepository>((ref) {
  return MomentsRepository(ref.watch(apiClientProvider));
});

final tripMomentsProvider = FutureProvider.family<List<Moment>, String>((
  ref,
  tripId,
) async {
  return ref.watch(momentsRepositoryProvider).fetch(tripId);
});


/// Kỷ niệm rút gọn cho scrapbook màn Home (gộp từ nhiều chuyến).
class RecentMoment {
  final String id;
  final String tripId;
  final String tripName;
  final String mediaUrl;
  final String? caption;
  final String authorName;
  final String location;

  const RecentMoment({
    required this.id,
    required this.tripId,
    required this.tripName,
    required this.mediaUrl,
    this.caption,
    required this.authorName,
    required this.location,
  });

  factory RecentMoment.fromJson(Map<String, dynamic> j) => RecentMoment(
    id: j['id'] as String? ?? '',
    tripId: j['tripId'] as String? ?? '',
    tripName: j['tripName'] as String? ?? '',
    mediaUrl: j['mediaUrl'] as String? ?? '',
    caption: j['caption'] as String?,
    authorName: j['authorName'] as String? ?? '',
    location: j['location'] as String? ?? '',
  );

  /// Tiêu đề hiển thị trên tấm polaroid.
  String get title => (caption?.trim().isNotEmpty ?? false)
      ? caption!.trim()
      : tripName;
}

/// Provider cho scrapbook màn Home.
final recentMomentsProvider = FutureProvider<List<RecentMoment>>((ref) {
  return ref.watch(momentsRepositoryProvider).fetchRecent();
});
