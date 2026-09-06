import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/network/api_exception.dart';
import '../data/entitlement_provider.dart';
import '../data/trial_provider.dart';

/// Paywall hiện khi người dùng vừa chạm đúng một giới hạn.
///
/// Nguyên tắc: **nói đúng thứ vừa bị chặn**, không quảng cáo chung chung. Người
/// dùng vừa bấm "tạo chuyến" thì tiêu đề phải nói về chuyến, kèm con số giới
/// hạn họ vừa chạm — chứ không phải một danh sách quyền lợi rời rạc.
///
/// Backend đã trả sẵn `code: QUOTA_EXCEEDED` kèm `quota`, `limit`, `plan` trong
/// thân lỗi, nên chỗ này chỉ việc đọc ra và nói lại.
class PaywallSheet extends ConsumerWidget {
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

  /// Mở paywall nếu `error` là lỗi vượt hạn mức; ngược lại trả `false` để nơi
  /// gọi xử lý như lỗi thường.
  ///
  /// Gom vào một chỗ vì chốt chặn hạn mức nằm rải ở bốn luồng khác nhau (tạo
  /// chuyến, vào chuyến, đăng moment, gọi AI). Chép tay bốn lần thì sớm muộn
  /// cũng có luồng quên, và người dùng ở luồng đó nhận một lỗi 403 trần trụi
  /// thay vì lời mời nâng cấp.
  static Future<bool> maybeShow(BuildContext context, Object error) async {
    if (error is! ApiException || !error.isQuotaExceeded) return false;
    if (!context.mounted) return false;
    await show(
      context,
      quota: quotaFromName(error.details['quota'] as String?),
      limit: (error.details['limit'] as num?)?.toInt(),
    );
    return true;
  }

  /// Dòng tiêu đề gắn với đúng thứ vừa bị chặn.
  String _headline() {
    if (quota == null) return 'paywall.headline_generic'.tr();
    final n = '${limit ?? ''}';
    return switch (quota!) {
      Quota.activeTrips => 'paywall.headline_trips'.tr(namedArgs: {'n': n}),
      Quota.membersPerTrip => 'paywall.headline_members'.tr(namedArgs: {'n': n}),
      Quota.momentsPerTrip => 'paywall.headline_moments'.tr(namedArgs: {'n': n}),
      Quota.aiPerMonth => 'paywall.headline_ai'.tr(namedArgs: {'n': n}),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = theme.colorScheme.onSurface;
    final accent = theme.colorScheme.primary;
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    // Lấy locale qua `Localizations` thay vì `context.locale`.
    //
    // `context.locale` của easy_localization ném thẳng khi widget không nằm
    // dưới `EasyLocalization` — chỉ dùng để định dạng tiền mà làm cả paywall
    // sập thì không đáng. Thiếu thì rơi về 'vi'.
    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'vi';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          boxShadow: [BoxShadow(color: ink, offset: const Offset(0, 6))],
        ),
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
            const SizedBox(height: 18),
            Text(
              _headline(),
              style: AppFonts.heading(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: ink,
                height: 1.2,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'paywall.sub'.tr(),
              style: AppFonts.body(
                fontSize: 14,
                color: ink.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Squad Pass đặt TRƯỚC gói cá nhân.
            //
            // TripMate vốn là app đi nhóm, nên chia cho 5 người là cách đọc tự
            // nhiên nhất về giá — và con số mỗi người thấp hơn hẳn gói cá nhân.
            _PlanCard(
              title: 'paywall.plan_squad'.tr(),
              price: formatMoney(99000, locale: locale),
              perUnit: 'paywall.plan_squad_each'.tr(
                namedArgs: {'price': formatMoney(19800, locale: locale)},
              ),
              highlighted: true,
              ink: ink,
              accent: accent,
            ),
            const SizedBox(height: 10),
            _PlanCard(
              title: 'paywall.plan_plus'.tr(),
              price: formatMoney(39000, locale: locale),
              perUnit: 'paywall.plan_plus_year'.tr(
                namedArgs: {'price': formatMoney(299000, locale: locale)},
              ),
              highlighted: false,
              ink: ink,
              accent: accent,
            ),

            const SizedBox(height: 18),

            // Mời dùng thử — chỉ hiện với người chưa từng dùng.
            //
            // Đặt TRƯỚC nút mua và nói đủ điều khoản ngay tại đây: bao nhiêu
            // ngày, hết hạn thì sao, sau đó giá bao nhiêu, dừng ở đâu. Người
            // dùng phải biết trọn vẹn thứ mình đang bấm vào trước khi bấm.
            _TrialOffer(ink: ink, accent: accent, locale: locale),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: GenZTokens.ink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: ink, width: GenZTokens.borderWidth),
                  ),
                ),
                child: Text(
                  'paywall.cta'.tr(),
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: GenZTokens.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted
            ? accent.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
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
                    fontSize: 16,
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
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Khối mời dùng thử 3 ngày.
///
/// Chỉ hiện khi người dùng thật sự còn dùng thử được — mời rồi báo "bạn đã
/// dùng rồi" là một lần bấm vô ích và một lần thất vọng.
class _TrialOffer extends ConsumerWidget {
  final Color ink;
  final Color accent;
  final String locale;

  const _TrialOffer({
    required this.ink,
    required this.accent,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(trialStatusProvider).valueOrNull;
    if (status == null || !status.canStart) return const SizedBox.shrink();

    final t = status.terms;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () async {
                try {
                  await ref.read(trialActionsProvider).start();
                  if (context.mounted) Navigator.of(context).pop(true);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('trial.start_failed'.tr())),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: ink, width: GenZTokens.borderWidth),
                ),
              ),
              child: Text(
                'trial.cta'.tr(namedArgs: {'n': '${t.days}'}),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Điều khoản đặt ngay dưới nút, cùng cỡ chữ đọc được — không phải
          // một dòng xám nhạt ở cuối màn.
          Text(
            t.autoCharge
                ? 'trial.terms_autocharge'.tr(
                    namedArgs: {
                      'n': '${t.days}',
                      'price': formatMoney(t.priceAfter, locale: locale),
                    },
                  )
                : 'trial.terms_no_charge'.tr(
                    namedArgs: {
                      'n': '${t.days}',
                      'price': formatMoney(t.priceAfter, locale: locale),
                    },
                  ),
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 12,
              height: 1.4,
              color: ink.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
