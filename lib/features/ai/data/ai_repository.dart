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

/// Tâm trạng squad do AI đánh giá từ chi tiêu và quy mô nhóm.
class SquadMood {
  final String overallMood;
  final int tensionLevel;
  final String moodAnalysis;

  const SquadMood({
    required this.overallMood,
    required this.tensionLevel,
    required this.moodAnalysis,
  });

  factory SquadMood.fromJson(Map<String, dynamic> json) => SquadMood(
    overallMood: json['overallMood'] as String? ?? '',
    tensionLevel: (json['tensionLevel'] as num?)?.toInt() ?? 0,
    moodAnalysis: json['moodAnalysis'] as String? ?? '',
  );
}

final squadMoodProvider = FutureProvider.family<SquadMood, String>((
  ref,
  tripId,
) async {
  final data = await ref
      .watch(apiClientProvider)
      .getData('/ai/trips/$tripId/mood');
  return SquadMood.fromJson((data as Map).cast<String, dynamic>());
});

/// Một gợi ý trong lịch trình do AI đề xuất.
class SuggestedActivity {
  final String time;
  final String location;
  final String reason;

  const SuggestedActivity({
    required this.time,
    required this.location,
    required this.reason,
  });

  factory SuggestedActivity.fromJson(Map<String, dynamic> json) =>
      SuggestedActivity(
        time: json['time'] as String? ?? '',
        location: json['location'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
      );
}

final aiTimelineProvider =
    FutureProvider.family<List<SuggestedActivity>, String>((ref, tripId) async {
      final data = await ref
          .watch(apiClientProvider)
          .getData('/ai/trips/$tripId/timeline');
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((e) => SuggestedActivity.fromJson(e.cast<String, dynamic>()))
          .toList();
    });
