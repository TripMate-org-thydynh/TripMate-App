import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Dữ liệu thời tiết tóm tắt trong bản tin hôm nay.
class TodayBriefWeather {
  final int weatherCode;
  final double tempMin;
  final double tempMax;
  final int rainProbability;

  const TodayBriefWeather({
    required this.weatherCode,
    required this.tempMin,
    required this.tempMax,
    required this.rainProbability,
  });

  factory TodayBriefWeather.fromJson(Map<String, dynamic> j) {
    return TodayBriefWeather(
      weatherCode: (j['weatherCode'] as num?)?.toInt() ?? 0,
      tempMin: (j['tempMin'] as num?)?.toDouble() ?? 0.0,
      tempMax: (j['tempMax'] as num?)?.toDouble() ?? 0.0,
      rainProbability: (j['rainProbability'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Điểm dừng kế tiếp trong bản tin hôm nay.
class TodayBriefStop {
  final String id;
  final String startTime;
  final String placeName;
  final int? rainRisk;

  const TodayBriefStop({
    required this.id,
    required this.startTime,
    required this.placeName,
    this.rainRisk,
  });

  factory TodayBriefStop.fromJson(Map<String, dynamic> j) {
    return TodayBriefStop(
      id: j['id'] as String? ?? '',
      startTime: j['startTime'] as String? ?? '',
      placeName: j['placeName'] as String? ?? '',
      rainRisk: (j['rainRisk'] as num?)?.toInt(),
    );
  }
}

/// Việc cần làm trong ngày.
class TodayBriefTodo {
  final String id;
  final String title;
  final String? assigneeName;
  final String priority;

  const TodayBriefTodo({
    required this.id,
    required this.title,
    this.assigneeName,
    this.priority = 'NORMAL',
  });

  factory TodayBriefTodo.fromJson(Map<String, dynamic> j) {
    return TodayBriefTodo(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      assigneeName: j['assigneeName'] as String?,
      priority: j['priority'] as String? ?? 'NORMAL',
    );
  }
}

/// Bản tin hôm nay của chuyến: `GET /trips/:tripId/brief/today`.
class TodayBrief {
  final String tripId;
  final String tripName;
  final int day;
  final String date;
  final TodayBriefWeather? weather;
  final List<TodayBriefStop> stops;
  final List<TodayBriefTodo> todos;
  final String? summary;

  const TodayBrief({
    required this.tripId,
    required this.tripName,
    required this.day,
    required this.date,
    this.weather,
    this.stops = const [],
    this.todos = const [],
    this.summary,
  });

  factory TodayBrief.fromJson(Map<String, dynamic> j) {
    return TodayBrief(
      tripId: j['tripId'] as String? ?? '',
      tripName: j['tripName'] as String? ?? '',
      day: (j['day'] as num?)?.toInt() ?? 0,
      date: j['date'] as String? ?? '',
      weather: j['weather'] != null
          ? TodayBriefWeather.fromJson(
              (j['weather'] as Map).cast<String, dynamic>(),
            )
          : null,
      stops: (j['stops'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => TodayBriefStop.fromJson(e.cast<String, dynamic>()))
          .toList(),
      todos: (j['todos'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => TodayBriefTodo.fromJson(e.cast<String, dynamic>()))
          .toList(),
      summary: j['summary'] as String?,
    );
  }
}

class TodayBriefRepository {
  TodayBriefRepository(this._client);
  final ApiClient _client;

  Future<TodayBrief?> getTodayBrief(String tripId) async {
    try {
      final data = await _client.getData('/trips/$tripId/brief/today');
      if (data is Map) {
        return TodayBrief.fromJson(data.cast<String, dynamic>());
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

final todayBriefRepositoryProvider = Provider<TodayBriefRepository>(
  (ref) => TodayBriefRepository(ref.watch(apiClientProvider)),
);

final todayBriefProvider =
    FutureProvider.autoDispose.family<TodayBrief?, String>((ref, tripId) async {
  try {
    return await ref
        .watch(todayBriefRepositoryProvider)
        .getTodayBrief(tripId);
  } catch (_) {
    return null;
  }
});
