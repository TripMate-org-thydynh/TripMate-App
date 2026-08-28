import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Một dòng "roast" tính cách do AI viết cho một thành viên THẬT của chuyến.
class SquadRoast {
  final String name;
  final String type;
  final String roast;

  const SquadRoast({
    required this.name,
    required this.type,
    required this.roast,
  });

  factory SquadRoast.fromJson(Map<String, dynamic> json) => SquadRoast(
    name: json['name'] as String? ?? '',
    type: json['type'] as String? ?? '',
    roast: json['roast'] as String? ?? '',
  );
}

/// Phân tích tính cách squad của một chuyến.
///
/// Màn hình trước đây in cứng 3 người không tồn tại và không hề gọi API. Nay
/// gọi `/ai/trips/:id/personality`; khi AI chưa sẵn sàng BE trả 503 và UI hiện
/// thông báo thật thay vì roast người lạ.
final squadPersonalityProvider =
    FutureProvider.family<List<SquadRoast>, String>((ref, tripId) async {
      final data = await ref
          .watch(apiClientProvider)
          .getData('/ai/trips/$tripId/personality');
      final list = (data is Map) ? data['squadAnalysis'] : null;
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((e) => SquadRoast.fromJson(e.cast<String, dynamic>()))
          .toList();
    });
