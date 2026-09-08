import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_service.dart';
import '../../../core/format/money.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/entitlement_provider.dart';
import 'vietqr_payment_sheet.dart';

enum _SelectedPlan { squad, plusMonth, plusYear }

enum _SelectedGateway { sepay, momo, zalopay }

/// Paywall hiện khi người dùng vừa chạm đúng một giới hạn.
///
/// Nguyên tắc: **nói đúng thứ vừa bị chặn**, không quảng cáo chung chung. Người
/// dùng vừa bấm "tạo chuyến" thì tiêu đề phải nói về chuyến, kèm con số giới
/// hạn họ vừa chạm — chứ không phải một danh sách quyền lợi rời rạc.
///
/// Backend đã trả sẵn `code: QUOTA_EXCEEDED` kèm `quota`, `limit`, `plan` trong
/// thân lỗi, nên chỗ này chỉ việc đọc ra và nói lại.
class PaywallSheet extends ConsumerStatefulWidget {
  /// Giới hạn vừa chạm. `null` khi mở từ menu (không có ngữ cảnh cụ thể).
  final Quota? quota;

  /// Giá trị giới hạn của bản Free, lấy từ chính lỗi backend trả về.
  final int? limit;

  const PaywallSheet({super.key, this.quota, this.limit});

  /// Mở paywall. Trả `true` nếu người dùng bấm nâng cấp.
  static Future<bool?> show(
    BuildContext context, {
    Quota? quota,
    int? limit,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallSheet(quota: quota, limit: limit),
    );
  }

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  _SelectedPlan _plan = _SelectedPlan.squad;
  _SelectedGateway _gateway = _SelectedGateway.sepay;
  bool _loading = false;

  /// Dòng tiêu đề gắn với đúng thứ vừa bị chặn.
  String _headline() {
    if (widget.quota == null) return 'paywall.headline_generic'.tr();
    final n = '${widget.limit ?? ''}';
    return switch (widget.quota!) {
      Quota.activeTrips => 'paywall.headline_trips'.tr(namedArgs: {'n': n}),
      Quota.membersPerTrip => 'paywall.headline_members'.tr(namedArgs: {'n': n}),
      Quota.momentsPerTrip => 'paywall.headline_moments'.tr(namedArgs: {'n': n}),
      Quota.aiPerMonth => 'paywall.headline_ai'.tr(namedArgs: {'n': n}),
    };
  }

  Future<void> _handleCheckout() async {
    setState(() => _loading = true);
    try {
      final planCode = _plan == _SelectedPlan.squad ? 'SQUAD' : 'PLUS';
      final months = _plan == _SelectedPlan.plusYear ? 12 : 1;
      final method = switch (_gateway) {
        _SelectedGateway.sepay => 'SEPAY',
        _SelectedGateway.momo => 'MOMO',
        _SelectedGateway.zalopay => 'ZALOPAY',
      };

      final res = await ApiService.post('/premium/checkout', {
        'plan': planCode,
        'months': months,
        'paymentMethod': method,
      });

      if (res != null && res is Map && res['payUrl'] != null) {
        final orderCode =
            res['orderCode'] as String? ?? res['orderId'] as String? ?? '';
        final qrUrl =
            res['vietqrUrl'] as String? ?? res['qrUrl'] as String? ?? '';
        final amount = (res['amount'] as num?)?.toInt() ?? 39000;
        final payUrl = res['payUrl'] as String?;
        final bankInfo = res['bankInfo'] as Map<String, dynamic>?;

        if (!mounted) return;

        if (_gateway == _SelectedGateway.sepay && qrUrl.isNotEmpty) {
          await VietQrPaymentSheet.show(
            context,
            orderCode: orderCode,
            amount: amount,
            qrUrl: qrUrl,
            payUrl: payUrl,
            bankInfo: bankInfo,
          );
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          final uri = Uri.tryParse(payUrl ?? '');
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
        ref.invalidate(entitlementProvider);
        return;
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = theme.colorScheme.onSurface;
    final accent = theme.colorScheme.primary;
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'vi';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          boxShadow: [BoxShadow(color: ink, offset: const Offset(0, 6))],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ink.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _headline(),
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'paywall.sub'.tr(),
                style: AppFonts.body(
                  fontSize: 13,
                  color: ink.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),

              // Squad Pass đặt TRƯỚC gói cá nhân.
              // TripMate vốn là app đi nhóm, nên chia cho 5 người là cách đọc tự
              // nhiên nhất về giá — và con số mỗi người thấp hơn hẳn gói cá nhân.
              GestureDetector(
                onTap: () => setState(() => _plan = _SelectedPlan.squad),
                child: _PlanCard(
                  title: 'paywall.plan_squad'.tr(),
                  price: formatMoney(10000, locale: locale),
                  perUnit: 'paywall.plan_squad_each'.tr(
                    namedArgs: {'price': formatMoney(2000, locale: locale)},
                  ),
                  highlighted: _plan == _SelectedPlan.squad,
                  ink: ink,
                  accent: accent,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _plan = _SelectedPlan.plusMonth),
                child: _PlanCard(
                  title: 'paywall.plan_plus'.tr(),
                  price: formatMoney(39000, locale: locale),
                  perUnit: 'paywall.plan_plus_year'.tr(
                    namedArgs: {'price': formatMoney(299000, locale: locale)},
                  ),
                  highlighted: _plan == _SelectedPlan.plusMonth,
                  ink: ink,
                  accent: accent,
                ),
              ),
              const SizedBox(height: 12),

              // Bộ chọn phương thức thanh toán
              Row(
                children: [
                  Expanded(
                    child: _GatewayChip(
                      label: 'VietQR',
                      icon: Icons.qr_code_2_rounded,
                      selected: _gateway == _SelectedGateway.sepay,
                      ink: ink,
                      accent: accent,
                      onTap: () => setState(() => _gateway = _SelectedGateway.sepay),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _GatewayChip(
                      label: 'Ví MoMo',
                      icon: Icons.account_balance_wallet_outlined,
                      selected: _gateway == _SelectedGateway.momo,
                      ink: ink,
                      accent: accent,
                      onTap: () => setState(() => _gateway = _SelectedGateway.momo),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _GatewayChip(
                      label: 'ZaloPay',
                      icon: Icons.payment_outlined,
                      selected: _gateway == _SelectedGateway.zalopay,
                      ink: ink,
                      accent: accent,
                      onTap: () => setState(() => _gateway = _SelectedGateway.zalopay),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: GenZTokens.ink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: ink, width: GenZTokens.borderWidth),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'paywall.cta'.tr(),
                          style: AppFonts.heading(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: GenZTokens.ink,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'paywall.later'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      color: ink.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewayChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color ink;
  final Color accent;
  final VoidCallback onTap;

  const _GatewayChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.ink,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? ink : ink.withValues(alpha: 0.25),
            width: selected ? GenZTokens.borderWidth : GenZTokens.borderWidthThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: ink),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.heading(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String perUnit;
  final bool highlighted;
  final Color ink;
  final Color accent;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.perUnit,
    required this.highlighted,
    required this.ink,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: highlighted
            ? accent.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? ink : ink.withValues(alpha: 0.25),
          width: highlighted
              ? GenZTokens.borderWidth
              : GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  perUnit,
                  style: AppFonts.body(
                    fontSize: 12,
                    color: ink.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}
