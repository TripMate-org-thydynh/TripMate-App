import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_localization/easy_localization.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

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

/// Một yêu cầu AI của chính user trong hàng chờ.
class AiQueueItem {
  final String id;
  final String task;
  final String type;
  final String status;
  final int progress;
  final DateTime? createdAt;

  const AiQueueItem({
    required this.id,
    required this.task,
    required this.type,
    required this.status,
    required this.progress,
    this.createdAt,
  });

  bool get isDone => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';

  factory AiQueueItem.fromJson(Map<String, dynamic> json) => AiQueueItem(
    id: json['id'] as String? ?? '',
    task: json['task'] as String? ?? '',
    type: json['type'] as String? ?? '',
    status: json['status'] as String? ?? '',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );
}

final aiQueueProvider = FutureProvider<List<AiQueueItem>>((ref) async {
  final data = await ref
      .watch(apiClientProvider)
      .getData('/ai/generation-queue');
  if (data is! List) return const [];
  return data
      .whereType<Map>()
      .map((e) => AiQueueItem.fromJson(e.cast<String, dynamic>()))
      .toList();
});

/// Câu lệnh AI gợi ý sẵn (danh mục do team soạn, không phải do user lưu).
class SuggestedPrompt {
  final String id;
  final String title;
  final String prompt;

  const SuggestedPrompt({
    required this.id,
    required this.title,
    required this.prompt,
  });

  factory SuggestedPrompt.fromJson(Map<String, dynamic> json) =>
      SuggestedPrompt(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        prompt: json['prompt'] as String? ?? '',
      );
}

final suggestedPromptsProvider = FutureProvider<List<SuggestedPrompt>>((
  ref,
) async {
  final data = await ref.watch(apiClientProvider).getData('/ai/saved-prompts');
  if (data is! List) return const [];
  return data
      .whereType<Map>()
      .map((e) => SuggestedPrompt.fromJson(e.cast<String, dynamic>()))
      .toList();
});

/// Trò chuyện với Matey AI qua `POST /ai/request`.
class MateyChatService {
  final ApiClient _client;
  MateyChatService(this._client);

  /// Gửi câu hỏi và trả về câu trả lời dạng văn bản.
  ///
  /// BE lưu kết quả dạng JSON theo từng `type`; ở đây dùng `ITINERARY_PLAN`
  /// (loại tổng quát nhất) rồi rút phần chữ để hiện trong bong bóng chat.
  Future<String> ask({required String prompt, String? tripId}) async {
    final data = await _client.postData('/ai/request', {
      'type': 'ITINERARY_PLAN',
      'prompt': prompt,
      'tripId': ?tripId,
    });
    final res = (data is Map) ? data['response'] : null;
    return _textOf(res) ?? prompt;
  }

  /// Lấy đoạn chữ dài nhất trong JSON trả về — mỗi loại yêu cầu có khoá khác
  /// nhau (`analysis`, `roastText`, `recapScript`...), nên không cố định khoá.
  String? _textOf(Object? node) {
    if (node is String) return node.trim().isEmpty ? null : node;
    if (node is List) {
      final parts = node.map(_textOf).whereType<String>();
      return parts.isEmpty ? null : parts.join('\n\n');
    }
    if (node is Map) {
      String? best;
      for (final v in node.values) {
        final t = _textOf(v);
        if (t != null && (best == null || t.length > best.length)) {
          best = t;
        }
      }
      return best;
    }
    return null;
  }
}

final mateyChatProvider = Provider<MateyChatService>(
  (ref) => MateyChatService(ref.watch(apiClientProvider)),
);

/// Lịch sử yêu cầu AI của tôi — dùng chung model với hàng chờ.
final aiHistoryProvider = FutureProvider<List<AiQueueItem>>((ref) async {
  final data = await ref.watch(apiClientProvider).getData('/ai/my-requests');
  if (data is! List) return const [];
  return data.whereType<Map>().map((e) {
    final m = e.cast<String, dynamic>();
    // `/my-requests` trả bản ghi thô (khoá `prompt`), khác hàng chờ (`task`).
    return AiQueueItem.fromJson({...m, 'task': m['prompt']});
  }).toList();
});

/// Kết quả Vibe Match do AI chấm cho một địa điểm.
class VibeMatch {
  final int matchPercentage;
  final List<String> vibeTags;
  final String analysis;
  final String locationName;
  final String locationAddress;

  const VibeMatch({
    required this.matchPercentage,
    required this.vibeTags,
    required this.analysis,
    required this.locationName,
    required this.locationAddress,
  });

  factory VibeMatch.fromJson(Map<String, dynamic> j) => VibeMatch(
    matchPercentage: (j['matchPercentage'] as num?)?.toInt() ?? 0,
    vibeTags:
        (j['vibeTags'] as List?)?.whereType<String>().toList() ?? const [],
    analysis: j['analysis'] as String? ?? '',
    locationName: j['locationName'] as String? ?? '',
    locationAddress: j['locationAddress'] as String? ?? '',
  );
}

/// Chấm độ hợp vibe của một địa điểm với squad.
///
/// Màn Vibe Match trước đây in cứng "The Hill Station · Old Town, Hội An" kèm
/// phần trăm và avatar của những người không tồn tại, không gọi API nào.
class VibeMatchService {
  final ApiClient _client;
  VibeMatchService(this._client);

  Future<VibeMatch> match({required String prompt, String? tripId}) async {
    final data = await _client.postData('/ai/request', {
      'type': 'VIBE_MATCH',
      'prompt': prompt,
      'tripId': ?tripId,
    });
    final res = (data is Map) ? data['response'] : null;
    if (res is! Map) {
      throw ApiException('errors.load_failed'.tr());
    }
    return VibeMatch.fromJson(res.cast<String, dynamic>());
  }
}

final vibeMatchServiceProvider = Provider<VibeMatchService>(
  (ref) => VibeMatchService(ref.watch(apiClientProvider)),
);
