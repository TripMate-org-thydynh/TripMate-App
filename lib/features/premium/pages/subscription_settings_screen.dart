import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/trial_provider.dart';

/// Thiết lập gói cước.
///
/// Trước đây màn này dựng sẵn một gói "Elite Squad" đang chạy cho MỌI tài
/// khoản: ngày gia hạn 20/06/2026, nguồn tiền "Visa **** 4242", công tắc tự
/// động gia hạn và nút huỷ gói — tất cả đều không gọi đâu cả, kể cả với người
/// chưa từng mua. Nay đọc trạng thái thật từ `/premium/subscriptions`.
///
/// Gói bán qua Google Play Billing nên việc đổi nguồn tiền, bật/tắt gia hạn và
/// huỷ gói đều do Play quản lý — app không dựng lại các công tắc đó.
class SubscriptionSettingsScreen extends ConsumerStatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  ConsumerState<SubscriptionSettingsScreen> createState() =>
      _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState
    extends ConsumerState<SubscriptionSettingsScreen> {
  Map<String, dynamic>? _sub;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final res = await ApiService.get('/premium/subscriptions');
    if (!mounted) return;
    setState(() {
      _sub = res;
      _failed = res == null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'premium.settings_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: _body(isDark),
    );
  }

  Widget _body(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_failed) {
      return AppErrorState(isDark: isDark, onRetry: _fetch);
    }

    final isActive = _sub?['status'] == 'ACTIVE';
    if (!isActive) {
      return AppEmptyState(
        isDark: isDark,
        icon: Icons.workspace_premium_outlined,
        title: 'premium.no_plan_title'.tr(),
        body: 'premium.no_plan_body'.tr(),
      );
    }

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final price = (_sub?['price'] as num?)?.toInt() ?? 0;
    // `activeUntil`, không phải `nextBillingDate`: backend chưa từng trả về
    // trường đó, nên trước đây ngày hết hạn luôn null và dòng này không bao giờ
    // hiện — kể cả với người đang có gói.
    final next = _parseDate(_sub?['activeUntil'] as String?);
    final plan = _sub?['plan'] as String? ?? 'PLUS';
    final via = _sub?['via'] as String? ?? 'own';
    final isTrial = _sub?['isTrial'] as bool? ?? false;

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.all(GenZTokens.space5),
        children: [
          Container(
            padding: const EdgeInsets.all(GenZTokens.space5),
            decoration: BoxDecoration(
              color: GenZTokens.lilac,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: GenZTokens.ink,
                width: GenZTokens.borderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'premium.plan_$plan'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: GenZTokens.ink,
                  ),
                ),
                const SizedBox(height: GenZTokens.space2),
                Text(
                  // Đang dùng thử thì KHÔNG hiện "39.000đ/tháng" như thể đang
                  // bị thu tiền — chưa đồng nào rời tài khoản của họ.
                  isTrial
                      ? 'trial.badge'.tr()
                      : 'premium.price_monthly'.tr(args: [_money(price)]),
                  style: AppFonts.body(fontSize: 13, color: GenZTokens.ink),
                ),
                if (next != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'premium.active_until'.tr(
                      args: [
                        DateFormat.yMMMd(
                          context.locale.toLanguageTag(),
                        ).format(next),
                      ],
                    ),
                    style: AppFonts.body(fontSize: 13, color: GenZTokens.ink),
                  ),
                ],
              ],
            ),
          ),
          if (isTrial) ...[
            const SizedBox(height: GenZTokens.space4),
            // Nút dừng đặt ngay đây, ngang hàng với thẻ gói.
            //
            // Chôn nó vào ba lớp menu chẳng giữ được ai: người muốn dừng sẽ
            // dừng, chỉ là bằng cách gỡ app thay vì bấm nút. Ở đây họ dừng
            // xong vẫn còn là người dùng.
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _cancelTrial,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                    side: BorderSide(
                      color: ink,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                ),
                child: Text(
                  'trial.cancel_cta'.tr(),
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: GenZTokens.space5),
          // Gói mua qua ví là trả một lần cho một kỳ, KHÔNG tự động gia hạn —
          // ví Việt Nam không có cơ chế trừ tiền định kỳ. Nên ở đây không có
          // nút huỷ: không có gì để huỷ. Nói thẳng điều đó thay vì dựng một
          // công tắc "tự động gia hạn" không nối vào đâu, như bản trước.
          Container(
            padding: const EdgeInsets.all(GenZTokens.space4),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: inkSoft),
                const SizedBox(width: GenZTokens.space3),
                Expanded(
                  child: Text(
                    isTrial
                        ? 'trial.settings_notice'.tr()
                        : via == 'seat'
                        ? 'premium.via_seat_notice'.tr()
                        : 'premium.no_autorenew_notice'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      color: inkSoft,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dừng dùng thử, có xác nhận một lần.
  ///
  /// Hỏi lại một câu vì thao tác này cắt quyền ngay lập tức và không lấy lại
  /// được — nhưng chỉ một câu, và nút đồng ý không bị làm mờ đi.
  Future<void> _cancelTrial() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('trial.cancel_title'.tr()),
        content: Text('trial.cancel_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('trial.cancel_keep'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('trial.cancel_confirm'.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(trialActionsProvider).cancel();
    } catch (_) {
      // ApiClient đã hiện lỗi; vẫn tải lại để màn không kẹt ở trạng thái cũ.
    }
    if (mounted) await _fetch();
  }

  static DateTime? _parseDate(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

  /// 99000 -> "99.000" (kiểu VN, không phụ thuộc locale đang chọn).
  static String _money(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}
