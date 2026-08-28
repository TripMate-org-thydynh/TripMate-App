import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Một dòng hoạt động của squad (dùng cho marquee ở màn Home).
class SquadActivity {
  final String id;
  final String type;
  final String tripName;
  final String actorName;

  const SquadActivity({
    required this.id,
    required this.type,
    required this.tripName,
    required this.actorName,
  });

  factory SquadActivity.fromJson(Map<String, dynamic> j) => SquadActivity(
    id: j['id'] as String? ?? '',
    type: j['type'] as String? ?? '',
    tripName: j['tripName'] as String? ?? '',
    actorName: j['actorName'] as String? ?? '',
  );

  /// Câu hiển thị đã dịch, vd "Minh vừa thêm một khoản chi".
  ///
  /// Key theo `ActivityType` của BE; loại lạ (BE thêm mới mà app chưa cập nhật)
  /// rơi về câu chung thay vì hiện mã enum thô cho người dùng.
  String get label {
    const known = {
      'TRIP_CREATED',
      'MEMBER_JOINED',
      'MEMBER_LEFT',
      'ITINERARY_ADDED',
      'EXPENSE_ADDED',
      'MOMENT_SHARED',
      'GAME_STARTED',
      'POLL_CREATED',
      'PAYMENT_MADE',
      'CHAT_SENT',
      'JOURNAL_WRITTEN',
      'NOTE_ADDED',
      'DOCUMENT_UPLOADED',
    };
    final key = known.contains(type)
        ? 'activity.${type.toLowerCase()}'
        : 'activity.generic';
    return key.tr(namedArgs: {'name': actorName, 'trip': tripName});
  }
}

/// Điểm lịch trình kế tiếp — thẻ "Up Next" ở màn Home.
class UpNextItem {
  final String tripId;
  final String tripName;
  final int day;
  final String startTime;
  final String placeName;
  final String? placeAddress;
  final int durationMinutes;

  const UpNextItem({
    required this.tripId,
    required this.tripName,
    required this.day,
    required this.startTime,
    required this.placeName,
    this.placeAddress,
    required this.durationMinutes,
  });

  factory UpNextItem.fromJson(Map<String, dynamic> j) => UpNextItem(
    tripId: j['tripId'] as String? ?? '',
    tripName: j['tripName'] as String? ?? '',
    day: (j['day'] as num?)?.toInt() ?? 1,
    startTime: j['startTime'] as String? ?? '',
    placeName: j['placeName'] as String? ?? '',
    placeAddress: j['placeAddress'] as String?,
    durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 0,
  );
}

/// Tổng hợp chi tiêu trên mọi chuyến — khối "The Roast" ở màn Home.
class ExpenseSummary {
  final bool hasData;
  final double totalAmount;
  final int paidCount;
  final int totalCount;
  final int paidPercent;
  final String? topDebtorName;
  final double topDebtorAmount;

  const ExpenseSummary({
    required this.hasData,
    required this.totalAmount,
    required this.paidCount,
    required this.totalCount,
    required this.paidPercent,
    this.topDebtorName,
    required this.topDebtorAmount,
  });

  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

  factory ExpenseSummary.fromJson(Map<String, dynamic> j) => ExpenseSummary(
    hasData: j['hasData'] as bool? ?? false,
    totalAmount: _num(j['totalAmount']),
    paidCount: (j['paidCount'] as num?)?.toInt() ?? 0,
    totalCount: (j['totalCount'] as num?)?.toInt() ?? 0,
    paidPercent: (j['paidPercent'] as num?)?.toInt() ?? 0,
    topDebtorName: j['topDebtorName'] as String?,
    topDebtorAmount: _num(j['topDebtorAmount']),
  );
}

/// Dữ liệu cho các khối tổng hợp ở màn Home (gộp nhiều chuyến).
class HomeFeedRepository {
  final ApiClient _client;
  HomeFeedRepository(this._client);

  Future<List<SquadActivity>> fetchActivities() async {
    final data = await _client.getData('/users/me/activities/recent');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => SquadActivity.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<ExpenseSummary> fetchExpenseSummary() async {
    final data = await _client.getData('/users/me/expense-summary');
    if (data is Map) {
      return ExpenseSummary.fromJson(data.cast<String, dynamic>());
    }
    return const ExpenseSummary(
      hasData: false,
      totalAmount: 0,
      paidCount: 0,
      totalCount: 0,
      paidPercent: 0,
      topDebtorAmount: 0,
    );
  }

  /// `null` = không có điểm nào sắp tới → màn Home ẩn thẻ đi.
  Future<UpNextItem?> fetchUpNext() async {
    final data = await _client.getData('/users/me/up-next');
    if (data is Map) {
      return UpNextItem.fromJson(data.cast<String, dynamic>());
    }
    return null;
  }
}

final homeFeedRepositoryProvider = Provider<HomeFeedRepository>((ref) {
  return HomeFeedRepository(ref.watch(apiClientProvider));
});

final squadActivitiesProvider = FutureProvider<List<SquadActivity>>((ref) {
  return ref.watch(homeFeedRepositoryProvider).fetchActivities();
});

final upNextProvider = FutureProvider<UpNextItem?>((ref) {
  return ref.watch(homeFeedRepositoryProvider).fetchUpNext();
});

final expenseSummaryProvider = FutureProvider<ExpenseSummary>((ref) {
  return ref.watch(homeFeedRepositoryProvider).fetchExpenseSummary();
});

/// Làm mới mọi khối tổng hợp ở màn Home.
///
/// Các provider này là `FutureProvider` nên chỉ nạp một lần; sau khi người dùng
/// thêm điểm lịch trình / ghi chi tiêu / đăng khoảnh khắc ở màn khác, Home vẫn
/// hiện dữ liệu cũ (vd "Nothing coming up" dù vừa thêm điểm). Gọi hàm này ở mọi
/// nơi có thay đổi dữ liệu mà Home phản ánh.
void invalidateHomeAggregates(Ref ref) {
  ref.invalidate(upNextProvider);
  ref.invalidate(squadActivitiesProvider);
  ref.invalidate(expenseSummaryProvider);
}

/// Bản dùng được từ widget (`WidgetRef`).
void invalidateHomeAggregatesFrom(WidgetRef ref) {
  ref.invalidate(upNextProvider);
  ref.invalidate(squadActivitiesProvider);
  ref.invalidate(expenseSummaryProvider);
}
