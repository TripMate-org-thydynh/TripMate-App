import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import 'entitlement_provider.dart';

/// Điều khoản dùng thử, do server quy định.
///
/// Không hardcode ở client: nếu app nói "3 ngày, 39.000đ/tháng" mà server đổi
/// giá thì màn mời đang nói dối người dùng, và đó là kiểu nói dối tệ nhất —
/// nói dối về tiền.
class TrialTerms {
  final int days;
  final String plan;

  /// Có tự động trừ tiền khi hết hạn hay không.
  ///
  /// Hiện là `false`: Momo và ZaloPay ở mức tích hợp hiện tại không có cơ chế
  /// trừ tiền định kỳ. Đọc từ server thay vì giả định, để khi nào có cổng hỗ
  /// trợ thì màn mời tự nói đúng.
  final bool autoCharge;

  /// Gói rơi về sau khi hết hạn.
  final String revertsTo;

  /// Giá nếu người dùng chủ động mua tiếp.
  final int priceAfter;

  const TrialTerms({
    required this.days,
    required this.plan,
    required this.autoCharge,
    required this.revertsTo,
    required this.priceAfter,
  });

  static const fallback = TrialTerms(
    days: 3,
    plan: 'PLUS',
    autoCharge: false,
    revertsTo: 'FREE',
    priceAfter: 39000,
  );

  factory TrialTerms.fromJson(Map<String, dynamic> j) => TrialTerms(
    days: (j['days'] as num?)?.toInt() ?? 3,
    plan: j['plan'] as String? ?? 'PLUS',
    autoCharge: j['autoCharge'] as bool? ?? false,
    revertsTo: j['revertsTo'] as String? ?? 'FREE',
    priceAfter: (j['priceAfter'] as num?)?.toInt() ?? 0,
  );
}

/// Tình trạng dùng thử của người dùng hiện tại.
class TrialStatus {
  final bool active;

  /// Mốc kết thúc, **luôn ở UTC**.
  ///
  /// Server trả ISO có hậu tố `Z`; giữ nguyên UTC và chỉ đổi sang giờ địa
  /// phương ở lúc hiển thị. Trừ hai mốc khác múi giờ với nhau là cách đồng hồ
  /// đếm ngược lệch đúng bằng số giờ chênh lệch — và app này tồn tại để phục
  /// vụ những người đang bay qua múi giờ khác.
  final DateTime? endsAt;

  final bool hasTrialed;
  final String? outcome;
  final TrialTerms terms;

  const TrialStatus({
    required this.active,
    required this.endsAt,
    required this.hasTrialed,
    required this.outcome,
    required this.terms,
  });

  static const none = TrialStatus(
    active: false,
    endsAt: null,
    hasTrialed: false,
    outcome: null,
    terms: TrialTerms.fallback,
  );

  factory TrialStatus.fromJson(Map<String, dynamic> j) => TrialStatus(
    active: j['active'] as bool? ?? false,
    endsAt: DateTime.tryParse(j['endsAt'] as String? ?? '')?.toUtc(),
    hasTrialed: j['hasTrialed'] as bool? ?? false,
    outcome: j['outcome'] as String?,
    terms: j['terms'] is Map
        ? TrialTerms.fromJson((j['terms'] as Map).cast<String, dynamic>())
        : TrialTerms.fallback,
  );

  /// Thời gian còn lại. So hai mốc **cùng ở UTC**.
  Duration get remaining {
    final end = endsAt;
    if (end == null) return Duration.zero;
    final left = end.difference(DateTime.now().toUtc());
    return left.isNegative ? Duration.zero : left;
  }

  /// Chưa từng dùng thử và chưa trả tiền → còn mời được.
  bool get canStart => !active && !hasTrialed;
}

final trialStatusProvider = FutureProvider<TrialStatus>((ref) async {
  final data = await ref.watch(apiClientProvider).getData('/premium/trial');
  if (data is! Map) return TrialStatus.none;
  return TrialStatus.fromJson(data.cast<String, dynamic>());
});

/// Mã thiết bị ổn định, sinh tại máy và lưu lại.
///
/// Không dùng id phần cứng (IMEI, Android ID, IDFV): chúng là định danh bền
/// gắn với một con người, cả hai kho ứng dụng đều siết việc thu thập, và ở đây
/// không cần tới mức đó. Một chuỗi ngẫu nhiên sinh lần đầu chạy trả lời đủ câu
/// hỏi duy nhất mà server cần: "cài đặt này đã xin dùng thử bao giờ chưa".
///
/// Người dùng xoá dữ liệu app là mất — và điều đó chấp nhận được: đây chỉ là
/// một trong nhiều tín hiệu, không phải chốt chặn. Server không bao giờ nhận
/// giá trị này làm bằng chứng một mình.
Future<String> deviceInstallId() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'device_install_id';
  final existing = prefs.getString(key);
  if (existing != null && existing.isNotEmpty) return existing;

  final rnd = Random.secure();
  final id = List.generate(
    32,
    (_) => '0123456789abcdef'[rnd.nextInt(16)],
  ).join();
  await prefs.setString(key, id);
  return id;
}

/// Bắt đầu / dừng dùng thử.
class TrialActions {
  final Ref _ref;
  TrialActions(this._ref);

  /// Bắt đầu 3 ngày dùng thử.
  ///
  /// Chỉ gửi `deviceId`. Số ngày và gói do server quyết định — gửi lên cũng bị
  /// bỏ qua, và không nên tạo cảm giác là client có tiếng nói ở đó.
  Future<void> start() async {
    await _ref
        .read(apiClientProvider)
        .postData('/premium/trial/start', {
          'deviceId': await deviceInstallId(),
        });
    _invalidate();
  }

  Future<void> cancel() async {
    await _ref.read(apiClientProvider).postData('/premium/trial/cancel', {});
    _invalidate();
  }

  /// Quyền và tình trạng dùng thử đổi cùng lúc — làm mới cả hai, nếu không thì
  /// paywall vẫn hiện dù người dùng vừa mở khoá xong.
  void _invalidate() {
    _ref.invalidate(trialStatusProvider);
    _ref.invalidate(entitlementProvider);
  }
}

final trialActionsProvider = Provider<TrialActions>(TrialActions.new);
