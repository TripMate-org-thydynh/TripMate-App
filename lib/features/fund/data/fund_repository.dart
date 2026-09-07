import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// Chuyển đổi an toàn giá trị num/string sang double.
double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

/// Thông tin người đóng góp quỹ (subset của User).
class FundUser {
  final String id;
  final String name;
  final String? avatarUrl;

  const FundUser({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory FundUser.fromJson(Map<String, dynamic> j) => FundUser(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        avatarUrl: j['avatarUrl'] as String?,
      );
}

/// Một khoản đóng góp vào quỹ.
class FundContribution {
  final String id;
  final double amount;
  final String? note;
  final String? status;
  final DateTime? createdAt;
  final FundUser? user;

  const FundContribution({
    required this.id,
    required this.amount,
    this.note,
    this.status,
    this.createdAt,
    this.user,
  });

  factory FundContribution.fromJson(Map<String, dynamic> j) => FundContribution(
        id: j['id']?.toString() ?? '',
        amount: _toDouble(j['amount']),
        note: j['note'] as String?,
        status: j['status'] as String?,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())?.toLocal()
            : null,
        user: j['user'] is Map
            ? FundUser.fromJson((j['user'] as Map).cast<String, dynamic>())
            : null,
      );
}

/// Quỹ chuyến đi kèm tiến độ và danh sách các khoản đóng góp.
class TripFund {
  final String? id;
  final double targetAmount;
  final DateTime? deadline;
  final String? note;
  final double totalCollected;
  final double progressPercent;
  final List<FundContribution> contributions;

  const TripFund({
    this.id,
    required this.targetAmount,
    this.deadline,
    this.note,
    this.totalCollected = 0.0,
    this.progressPercent = 0.0,
    this.contributions = const [],
  });

  factory TripFund.fromJson(Map<String, dynamic> j) {
    final rawContributions = j['contributions'];
    final contributions = rawContributions is List
        ? rawContributions
            .whereType<Map>()
            .map((e) => FundContribution.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <FundContribution>[];

    return TripFund(
      id: j['id']?.toString(),
      targetAmount: _toDouble(j['targetAmount']),
      deadline: j['deadline'] != null
          ? DateTime.tryParse(j['deadline'].toString())?.toLocal()
          : null,
      note: j['note'] as String?,
      totalCollected: _toDouble(j['totalCollected']),
      progressPercent: _toDouble(j['progressPercent']),
      contributions: contributions,
    );
  }
}

/// Repository cho Quỹ chuyến đi — `/trips/:tripId/fund`.
class FundRepository {
  final ApiClient _client;
  FundRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/fund';

  /// Lấy thông tin quỹ. Nếu chuyến chưa có quỹ (404), trả về `null` thay vì ném lỗi.
  Future<TripFund?> getFund(String tripId) async {
    try {
      final data = await _client.getData(_base(tripId));
      if (data is Map) {
        return TripFund.fromJson(data.cast<String, dynamic>());
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Tạo quỹ mới cho chuyến đi.
  Future<void> createFund(
    String tripId, {
    required double targetAmount,
    DateTime? deadline,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'targetAmount': targetAmount,
      if (deadline != null) 'deadline': deadline.toUtc().toIso8601String(),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    };
    await _client.postData(_base(tripId), body);
  }

  /// Đóng góp vào quỹ chuyến đi.
  Future<void> contribute(
    String tripId, {
    required double amount,
    String? note,
    String? clientRequestId,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (clientRequestId != null && clientRequestId.trim().isNotEmpty)
        'clientRequestId': clientRequestId.trim(),
    };
    await _client.postData('${_base(tripId)}/contribute', body);
  }

  /// Xóa một khoản đóng góp khỏi quỹ.
  Future<void> deleteContribution(String tripId, String contributionId) =>
      _client.deleteData('${_base(tripId)}/contributions/$contributionId');
}

final fundRepositoryProvider = Provider<FundRepository>((ref) {
  return FundRepository(ref.watch(apiClientProvider));
});
