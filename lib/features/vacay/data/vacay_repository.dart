import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class VacationDay {
  final String id;
  final String userId;
  final DateTime date;
  final String type; // LEAVE | HOLIDAY | WEEKEND
  final String? note;

  const VacationDay({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    this.note,
  });

  factory VacationDay.fromJson(Map<String, dynamic> j) => VacationDay(
        id: j['id'] as String? ?? '',
        userId: j['userId'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        type: j['type'] as String? ?? 'LEAVE',
        note: j['note'] as String?,
      );
}

class VacationSummary {
  final int totalLeave;
  final int totalHoliday;
  final int remaining;

  const VacationSummary({
    required this.totalLeave,
    required this.totalHoliday,
    required this.remaining,
  });

  factory VacationSummary.fromJson(Map<String, dynamic> j) => VacationSummary(
        totalLeave: (j['totalLeave'] as num?)?.toInt() ?? 0,
        totalHoliday: (j['totalHoliday'] as num?)?.toInt() ?? 0,
        remaining: (j['remaining'] as num?)?.toInt() ?? 0,
      );
}

class VacationHoliday {
  final String date;
  final String name;
  final String key;

  const VacationHoliday({
    required this.date,
    required this.name,
    required this.key,
  });

  factory VacationHoliday.fromJson(Map<String, dynamic> j) => VacationHoliday(
        date: j['date'] as String? ?? '',
        name: j['name'] as String? ?? '',
        key: j['key'] as String? ?? '',
      );
}

class BridgeSuggestion {
  final String from;
  final String to;
  final int days;
  final List<String> holidays;

  const BridgeSuggestion({
    required this.from,
    required this.to,
    required this.days,
    required this.holidays,
  });

  factory BridgeSuggestion.fromJson(Map<String, dynamic> j) => BridgeSuggestion(
        from: j['from'] as String? ?? '',
        to: j['to'] as String? ?? '',
        days: (j['days'] as num?)?.toInt() ?? 0,
        holidays: (j['holidays'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class VacayMyDaysResult {
  final List<VacationDay> days;
  final VacationSummary summary;
  final List<VacationHoliday> holidays;

  const VacayMyDaysResult({
    required this.days,
    required this.summary,
    required this.holidays,
  });

  factory VacayMyDaysResult.fromJson(Map<String, dynamic> j) => VacayMyDaysResult(
        days: (j['days'] as List?)
                ?.whereType<Map>()
                .map((e) => VacationDay.fromJson(e.cast<String, dynamic>()))
                .toList() ??
            [],
        summary: VacationSummary.fromJson(
            (j['summary'] as Map? ?? {}).cast<String, dynamic>()),
        holidays: (j['holidays'] as List?)
                ?.whereType<Map>()
                .map((e) => VacationHoliday.fromJson(e.cast<String, dynamic>()))
                .toList() ??
            [],
      );
}

class VacayRepository {
  final ApiClient _client;
  VacayRepository(this._client);

  Future<VacayMyDaysResult> fetchMyDays({int? year}) async {
    final Map<String, dynamic> q = {};
    if (year != null) q['year'] = year.toString();
    final data = await _client.getData('/vacay/my-days', query: q);
    return VacayMyDaysResult.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<VacationDay> addDay({
    required String date,
    required String type,
    String? note,
  }) async {
    final data = await _client.postData('/vacay/my-days', {
      'date': date,
      'type': type,
      'note': ?note,
    });
    return VacationDay.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> deleteDay(String date) =>
      _client.deleteData('/vacay/my-days/$date');

  Future<List<BridgeSuggestion>> fetchBridgeSuggestions() async {
    final data = await _client.getData('/vacay/bridge-suggestions');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => BridgeSuggestion.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }
}

final vacayRepositoryProvider = Provider<VacayRepository>((ref) {
  return VacayRepository(ref.watch(apiClientProvider));
});
