import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class DayCheckin {
  final String id;
  final String tripId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final int day;
  final String status; // GOING | MAYBE | OUT
  final String? note;

  const DayCheckin({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.day,
    required this.status,
    this.note,
  });

  factory DayCheckin.fromJson(Map<String, dynamic> j) => DayCheckin(
        id: j['id'] as String,
        tripId: j['tripId'] as String? ?? '',
        userId: (j['user'] as Map<String, dynamic>?)?['id'] as String? ?? '',
        userName: (j['user'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        userAvatarUrl:
            (j['user'] as Map<String, dynamic>?)?['avatarUrl'] as String?,
        day: (j['day'] as num?)?.toInt() ?? 1,
        status: j['status'] as String? ?? 'GOING',
        note: j['note'] as String?,
      );
}

class CheckinsRepository {
  final ApiClient _client;
  CheckinsRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/checkins';

  Future<List<DayCheckin>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => DayCheckin.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  Future<DayCheckin> upsert(
    String tripId, {
    required int day,
    required String status,
    String? note,
  }) async {
    final data = await _client.putData(_base(tripId), {
      'day': day,
      'status': status,
      'note': ?note,
    });
    return DayCheckin.fromJson((data as Map).cast<String, dynamic>());
  }
}

final checkinsRepositoryProvider = Provider<CheckinsRepository>((ref) {
  return CheckinsRepository(ref.watch(apiClientProvider));
});
