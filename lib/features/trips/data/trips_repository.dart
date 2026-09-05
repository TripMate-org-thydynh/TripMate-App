import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/trip.dart';

/// Repository cho feature Trips — bọc các call tới BE `trips` module.
class TripsRepository {
  final ApiClient _client;
  TripsRepository(this._client);

  Future<List<Trip>> fetchTrips() async {
    // Endpoint list chuyến của user là /users/me/trips (không phải /trips → 404).
    final data = await _client.getData('/users/me/trips');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Trip.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<Trip> fetchTrip(String id) async {
    final data = await _client.getData('/trips/$id');
    return Trip.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<Trip> createTrip({
    required String name,
    String? description,
    String? destination,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImage,
    String currency = 'VND',
    double? budget,
    String? vibe,
    String? theme,
    bool isPublic = false,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'startDate': _date(startDate),
      'endDate': _date(endDate),
      'currency': currency,
      'isPublic': isPublic,
      'description': ?description,
      'destination': ?destination,
      'coverImage': ?coverImage,
      'budget': ?budget,
      'vibe': ?vibe,
      'theme': ?theme,
    };
    final data = await _client.postData('/trips', body);
    return Trip.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<Trip> joinTrip(String inviteCode) async {
    final data = await _client.postData('/trips/join', {
      'inviteCode': inviteCode,
    });
    return Trip.fromJson((data as Map).cast<String, dynamic>());
  }

  /// Tham gia bằng mã invite-link (bảng TripInvite — mã dùng chung khi chia sẻ).
  Future<Trip> joinByInviteLink(String code) async {
    final data = await _client.postData('/trips/join-link/$code');
    return Trip.fromJson((data as Map).cast<String, dynamic>());
  }

  /// Người dùng dán một mã bất kỳ mà không biết nó thuộc loại nào:
  /// thử mã invite-link trước (mã trong link chia sẻ), không khớp thì thử
  /// mã cố định của chuyến. Chỉ nuốt lỗi "không tìm thấy" của lần thử đầu —
  /// lỗi thật (mạng, hết hạn, đã là thành viên) vẫn nổi lên UI.
  Future<Trip> joinByAnyCode(String rawCode) async {
    final code = rawCode.trim();
    try {
      return await joinByInviteLink(code);
    } on ApiException catch (e) {
      if (e.statusCode != 404) rethrow;
      return joinTrip(code);
    }
  }

  Future<Trip> updateTrip(
    String id, {
    String? name,
    String? description,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImage,
    String? currency,
    double? budget,
    String? vibe,
    bool? isPublic,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      'description': ?description,
      'destination': ?destination,
      if (startDate != null) 'startDate': _date(startDate),
      if (endDate != null) 'endDate': _date(endDate),
      'coverImage': ?coverImage,
      'currency': ?currency,
      'budget': ?budget,
      'vibe': ?vibe,
      'isPublic': ?isPublic,
    };
    final data = await _client.patchData('/trips/$id', body);
    return Trip.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> leaveTrip(String id) => _client.deleteData('/trips/$id/leave');

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return TripsRepository(ref.watch(apiClientProvider));
});
