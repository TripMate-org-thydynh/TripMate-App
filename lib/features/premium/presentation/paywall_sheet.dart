import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_service.dart';
import '../../../core/distribution_channel.dart';
import '../../../core/format/money.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../data/entitlement_provider.dart';
import '../pages/subscription_checkout_screen.dart';
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
  static Future<bool?> show(BuildContext context, {Quota? quota, int? limit}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallSheet(quota: quota, limit: limit),
    );
  }

  /// Mở paywall nếu [error] là lỗi vượt hạn mức ([ApiException.isQuotaExceeded]).
  ///
  /// Trả `false` nếu lỗi không phải vượt hạn mức hoặc context không còn mounted.
  /// Trả `true` nếu đã hiện paywall.
  static Future<bool> maybeShow(BuildContext context, Object error) async {
    if (error is! ApiException || !error.isQuotaExceeded) return false;
    if (!context.mounted) return false;

    final quotaRaw = error.details['quota'];
    final limitRaw = error.details['limit'];

    await show(
      context,
      quota: quotaFromName(quotaRaw is String ? quotaRaw : null),
      limit: limitRaw is num ? limitRaw.toInt() : null,
    );
    return true;
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
      Quota.membersPerTrip => 'paywall.headline_members'.tr(
        namedArgs: {'n': n},
      ),
      Quota.momentsPerTrip => 'paywall.headline_moments'.tr(
        namedArgs: {'n': n},
      ),
      Quota.aiPerMonth => 'paywall.headline_ai'.tr(namedArgs: {'n': n}),
    };
  }

  Future<void> _handleCheckout() async {
    // Nếu là kênh Play (bản phát hành CH Play): Google bắt buộc thanh toán qua Play Billing.
    // Điều hướng sang SubscriptionCheckoutScreen để người dùng mua qua Google Play,
    // tuyệt đối không mở VietQR/Ví để tránh vi phạm chính sách dẫn đến bị gỡ app.
    if (kDistributionChannel == DistributionChannel.play) {
      final upgraded = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const SubscriptionCheckoutScreen()),
      );
      if (mounted && upgraded == true) {
        ref.invalidate(entitlementProvider);
        Navigator.of(context).pop(true);
      }
      return;
    }

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
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final accent = theme.colorScheme.primary;
    final onAccent = theme.colorScheme.onPrimary;
    final accentSoft = isDark
        ? GenZTokens.accentSoftDark
        : GenZTokens.accentSoft;
    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'vi';
    final isPlayChannel = kDistributionChannel == DistributionChannel.play;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
          boxShadow: GenZTokens.hardShadow(GenZTokens.ink, isDark),
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
                    color: line,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _headline(),
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ink,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'paywall.sub'.tr(),
                style: AppFonts.body(fontSize: 13, color: inkSoft),
              ),
              const SizedBox(height: 14),

              // Squad Pass đặt TRƯỚC gói cá nhân.
              // TripMate vốn là app đi nhóm, nên chia cho 5 người là cách đọc tự
              // nhiên nhất về giá — và con số mỗi người thấp hơn hẳn gói cá nhân.
              GestureDetector(
                onTap: () => setState(() => _plan = _SelectedPlan.squad),
                child: _PlanCard(
                  title: 'paywall.plan_squad'.tr(),
                  price: formatMoney(99000, locale: locale),
                  perUnit: 'paywall.plan_squad_each'.tr(
                    namedArgs: {'price': formatMoney(19800, locale: locale)},
                  ),
                  highlighted: _plan == _SelectedPlan.squad,
                  ink: ink,
                  inkSoft: inkSoft,
                  accent: accent,
                  accentSoft: accentSoft,
                  surface: surface,
                  line: line,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _plan = _SelectedPlan.plusMonth),
                child: _PlanCard(
                  title: 'paywall.plan_plus'.tr(),
                  price: formatMoney(39000, locale: locale),
                  perUnit: 'paywall.plan_plus_year'.tr(
                    namedArgs: {'price': formatMoney(374000, locale: locale)},
                  ),
                  highlighted: _plan == _SelectedPlan.plusMonth,
                  ink: ink,
                  inkSoft: inkSoft,
                  accent: accent,
                  accentSoft: accentSoft,
                  surface: surface,
                  line: line,
                ),
              ),
              const SizedBox(height: 12),

              // Bộ chọn phương thức thanh toán: Nếu là kênh Google Play thì ẩn VietQR/Ví,
              // chỉ hiện bảo đảm thanh toán của Google Play để không vi phạm chính sách nộp store.
              if (isPlayChannel)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                    border: Border.all(
                      color: line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.shieldCheck(), size: 16, color: ink),
                      const SizedBox(width: 8),
                      Text(
                        'Google Play Billing',
                        style: AppFonts.heading(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _GatewayChip(
                        label: 'VietQR',
                        icon: PhosphorIcons.qrCode(),
                        selected: _gateway == _SelectedGateway.sepay,
                        ink: ink,
                        inkSoft: inkSoft,
                        accent: accent,
                        accentSoft: accentSoft,
                        fill: fill,
                        line: line,
                        onTap: () =>
                            setState(() => _gateway = _SelectedGateway.sepay),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _GatewayChip(
                        label: 'Ví MoMo',
                        icon: PhosphorIcons.wallet(),
                        selected: _gateway == _SelectedGateway.momo,
                        ink: ink,
                        inkSoft: inkSoft,
                        accent: accent,
                        accentSoft: accentSoft,
                        fill: fill,
                        line: line,
                        onTap: () =>
                            setState(() => _gateway = _SelectedGateway.momo),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _GatewayChip(
                        label: 'ZaloPay',
                        icon: PhosphorIcons.creditCard(),
                        selected: _gateway == _SelectedGateway.zalopay,
                        ink: ink,
                        inkSoft: inkSoft,
                        accent: accent,
                        accentSoft: accentSoft,
                        fill: fill,
                        line: line,
                        onTap: () =>
                            setState(() => _gateway = _SelectedGateway.zalopay),
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
                    foregroundColor: onAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(onAccent),
                          ),
                        )
                      : Text(
                          'paywall.cta'.tr(),
                          style: AppFonts.heading(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: onAccent,
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
                    style: AppFonts.body(fontSize: 13, color: inkSoft),
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
  final Color inkSoft;
  final Color accent;
  final Color accentSoft;
  final Color fill;
  final Color line;
  final VoidCallback onTap;

  const _GatewayChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.accentSoft,
    required this.fill,
    required this.line,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accentSoft : fill,
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          border: Border.all(
            color: selected ? accent : line,
            width: selected
                ? GenZTokens.borderWidth
                : GenZTokens.borderWidthThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? accent : inkSoft),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.heading(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : ink,
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
  final Color inkSoft;
  final Color accent;
  final Color accentSoft;
  final Color surface;
  final Color line;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.perUnit,
    required this.highlighted,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.accentSoft,
    required this.surface,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted ? accentSoft : surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: highlighted ? accent : line,
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
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  perUnit,
                  style: AppFonts.body(fontSize: 12, color: inkSoft),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: highlighted ? accent : ink,
            ),
          ),
        ],
      ),
    );
  }
}
