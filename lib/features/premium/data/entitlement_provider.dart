import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Những thứ bản Free bị giới hạn. Tên khớp với backend.
enum Quota { activeTrips, membersPerTrip, momentsPerTrip, aiPerMonth }

Quota? quotaFromName(String? raw) {
  for (final q in Quota.values) {
    if (q.name == raw) return q;
  }
  return null;
}

/// Quyền hiện tại của người dùng: gói nào, còn hạn tới bao giờ, hạn mức bao nhiêu.
class Entitlement {
  /// `FREE`, `PLUS` hoặc `SQUAD`.
  final String plan;

  /// `own` = gói của chính mình, `seat` = ghế người khác cấp,
  /// `trial` = đang dùng thử, `none` = chưa có gì.
  final String via;

  final DateTime? activeUntil;
  final Map<String, int> limits;

  /// Quyền đang đến từ 3 ngày dùng thử, không phải từ tiền.
  ///
  /// Cần tách bạch để banner nói đúng chuyện: người đang dùng thử cần thấy
  /// đồng hồ đếm ngược, người đã trả tiền thì không.
  final bool isTrial;

  const Entitlement({
    required this.plan,
    required this.via,
    required this.activeUntil,
    required this.limits,
    this.isTrial = false,
  });

  /// Mặc định khi chưa gọi được API.
  ///
  /// Rơi về Free thay vì đoán là đã trả tiền: đoán sai theo hướng này thì người
  /// dùng thấy paywall một cách vô lý, còn đoán sai hướng kia thì phát không
  /// tính năng trả phí.
  static const free = Entitlement(
    plan: 'FREE',
    via: 'none',
    activeUntil: null,
    limits: {
      'activeTrips': 2,
      'membersPerTrip': 8,
      'momentsPerTrip': 100,
      'aiPerMonth': 15,
    },
  );

  bool get isPaid => via != 'none';

  int limitOf(Quota q) => limits[q.name] ?? 0;

  factory Entitlement.fromJson(Map<String, dynamic> j) => Entitlement(
    plan: j['plan'] as String? ?? 'FREE',
    via: j['via'] as String? ?? 'none',
    activeUntil: DateTime.tryParse(j['activeUntil'] as String? ?? '')?.toUtc(),
    isTrial: j['isTrial'] as bool? ?? false,
    limits:
        (j['limits'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ) ??
        const {},
  );
}

/// Quyền của người dùng hiện tại.
///
/// Chỉ là **bản sao để hiển thị**. Quyết định thật vẫn nằm ở backend: mọi hạn
/// mức đều được kiểm lại ở đó, nên sửa được giá trị này trên máy cũng không mở
/// khoá được gì.
final entitlementProvider = FutureProvider<Entitlement>((ref) async {
  final data = await ref.watch(apiClientProvider).getData('/premium/entitlement');
  if (data is! Map) return Entitlement.free;
  return Entitlement.fromJson(data.cast<String, dynamic>());
});
