import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Số liệu tổng kết một chuyến (Trip Wrapped).
///
/// Trước đây màn Wrapped in cứng "7 địa điểm / 142 khoảnh khắc / 186 km", MVP
/// "Thảo Ly" và tổng chi 6.020.000đ — giống hệt nhau ở mọi chuyến. Nay lấy từ
/// `/trips/:id/recap`, đếm thật trong DB.
class TripRecap {
  final String tripName;
  final int days;
  final int memberCount;
  final int placeCount;
  final int momentCount;
  final int expenseCount;
  final double totalSpent;
  final String currency;
  final String? mvpName;

  /// `false` khi chuyến chưa có điểm lịch trình, khoảnh khắc lẫn khoản chi.
  final bool hasData;

  const TripRecap({
    required this.tripName,
    required this.days,
    required this.memberCount,
    required this.placeCount,
    required this.momentCount,
    required this.expenseCount,
    required this.totalSpent,
    required this.currency,
    required this.hasData,
    this.mvpName,
  });

  /// Chi bình quân đầu người — 0 khi chuyến chưa có thành viên nào.
  double get perHead => memberCount == 0 ? 0 : totalSpent / memberCount;

  factory TripRecap.fromJson(Map<String, dynamic> json) {
    final mvp = json['mvp'];
    return TripRecap(
      tripName: json['tripName'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      placeCount: (json['placeCount'] as num?)?.toInt() ?? 0,
      momentCount: (json['momentCount'] as num?)?.toInt() ?? 0,
      expenseCount: (json['expenseCount'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'VND',
      hasData: json['hasData'] as bool? ?? false,
      mvpName: mvp is Map ? mvp['name'] as String? : null,
    );
  }
}

final tripRecapProvider = FutureProvider.family<TripRecap, String>((
  ref,
  tripId,
) async {
  final data = await ref.watch(apiClientProvider).getData('/trips/$tripId/recap');
  return TripRecap.fromJson((data as Map).cast<String, dynamic>());
});
