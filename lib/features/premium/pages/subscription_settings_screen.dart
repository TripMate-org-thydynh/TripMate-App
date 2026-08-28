import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';

/// Thiết lập gói cước.
///
/// Trước đây màn này dựng sẵn một gói "Elite Squad" đang chạy cho MỌI tài
/// khoản: ngày gia hạn 20/06/2026, nguồn tiền "Visa **** 4242", công tắc tự
/// động gia hạn và nút huỷ gói — tất cả đều không gọi đâu cả, kể cả với người
/// chưa từng mua. Nay đọc trạng thái thật từ `/premium/subscriptions`.
///
/// Gói bán qua Google Play Billing nên việc đổi nguồn tiền, bật/tắt gia hạn và
/// huỷ gói đều do Play quản lý — app không dựng lại các công tắc đó.
class SubscriptionSettingsScreen extends StatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  State<SubscriptionSettingsScreen> createState() =>
      _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState
    extends State<SubscriptionSettingsScreen> {
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
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
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
    final next = _parseDate(_sub?['nextBillingDate'] as String?);
    final benefits = (_sub?['benefits'] as List?)?.whereType<String>().toList();

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
                  'premium.plan_elite'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: GenZTokens.ink,
                  ),
                ),
                const SizedBox(height: GenZTokens.space2),
                Text(
                  'premium.price_monthly'.tr(
                    args: [_money(price)],
                  ),
                  style: AppFonts.body(fontSize: 13, color: GenZTokens.ink),
                ),
                if (next != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'premium.next_billing'.tr(
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
          if (benefits != null && benefits.isNotEmpty) ...[
            const SizedBox(height: GenZTokens.space5),
            Text(
              'premium.benefits'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space3),
            for (final b in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 16, color: GenZTokens.success),
                    const SizedBox(width: GenZTokens.space2),
                    Expanded(
                      child: Text(
                        b,
                        style: AppFonts.body(fontSize: 13, color: ink),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: GenZTokens.space5),
          // Play Billing quản lý gia hạn/huỷ gói — app chỉ nói rõ chỗ làm,
          // không dựng công tắc giả như trước.
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
                    'premium.manage_in_play'.tr(),
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
