import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Một người đã đi chung chuyến với mình.
///
/// App không có tính năng kết bạn riêng, nên "bạn bè" ở đây là đồng đội thật
/// trong các chuyến — thay cho 3 người bịa (Alex Nguyễn / Trần Bình / Lê Minh)
/// mà màn Danh sách bạn bè hiển thị trước đây.
class TravelBuddy {
  final String id;
  final String name;
  final String? avatarUrl;

  /// Số chuyến đã đi chung.
  final int sharedTrips;

  /// Tên chuyến chung gần nhất — dùng làm dòng phụ.
  final String lastTripName;

  const TravelBuddy({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.sharedTrips = 0,
    this.lastTripName = '',
  });

  factory TravelBuddy.fromJson(Map<String, dynamic> json) => TravelBuddy(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    avatarUrl: json['avatarUrl'] as String?,
    sharedTrips: (json['sharedTrips'] as num?)?.toInt() ?? 0,
    lastTripName: json['lastTripName'] as String? ?? '',
  );
}

final travelBuddiesProvider = FutureProvider<List<TravelBuddy>>((ref) async {
  final data = await ref.watch(apiClientProvider).getData('/users/me/buddies');
  if (data is! List) return const [];
  return data
      .whereType<Map>()
      .map((e) => TravelBuddy.fromJson(e.cast<String, dynamic>()))
      .toList();
});
