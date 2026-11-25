import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/premium/data/entitlement_provider.dart';
import '../../features/premium/presentation/paywall_sheet.dart';
import '../network/api_exception.dart';
import '../theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';

/// Trạng thái rỗng dùng chung cho mọi màn hình (A×B: sáng kem, tối graphite).
class AppEmptyState extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String body;

  const AppEmptyState({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GenZTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(GenZTokens.space5),
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Icon(icon, size: 32, color: accent),
            ),
            const SizedBox(height: GenZTokens.space5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space2),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 13, color: inkSoft, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trạng thái lỗi dùng chung, có nút thử lại.
class AppErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  /// Lỗi bắt được — truyền vào để hiện đúng câu BE trả về thay vì một câu chung chung.
  final Object? error;

  const AppErrorState({
    super.key,
    required this.isDark,
    required this.onRetry,
    this.error,
  });

  ApiException? get _api =>
      error is ApiException ? error as ApiException : null;

  @override
  Widget build(BuildContext context) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    // Hết hạn mức không phải lỗi: "Thử lại" sẽ hỏng y hệt. Nói rõ cái gì bị
    // khoá, giới hạn bao nhiêu, và lối ra — kể cả lối không tốn tiền.
    if (_api?.isQuotaExceeded ?? false) {
      return _QuotaLocked(isDark: isDark, error: _api!);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GenZTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _api == null || _api!.isNetwork
                  ? PhosphorIcons.wifiSlash()
                  : PhosphorIcons.warningCircle(),
              size: 40,
              color: danger,
            ),
            const SizedBox(height: GenZTokens.space4),
            Text(
              _api?.message ?? 'errors.load_failed'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space4),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(PhosphorIcons.arrowClockwise(), size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                'common.retry'.tr(),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trạng thái "đã khoá" khi chạm hạn mức của gói Free.
///
/// Không dùng màu cảnh báo: người dùng không làm gì sai. Nói đúng giới hạn vừa
/// chạm (cùng câu với paywall), và với lượt AI thì nói luôn khi nào lượt miễn
/// phí quay lại — giấu điều đó để đẩy người ta trả tiền là mẫu tối.
class _QuotaLocked extends StatelessWidget {
  final bool isDark;
  final ApiException error;

  const _QuotaLocked({required this.isDark, required this.error});

  @override
  Widget build(BuildContext context) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    final quotaRaw = error.details['quota'];
    final limitRaw = error.details['limit'];
    final quota = quotaFromName(quotaRaw is String ? quotaRaw : null);
    final limit = limitRaw is num ? limitRaw.toInt() : null;
    final n = '${limit ?? ''}';
    final headline = switch (quota) {
      Quota.activeTrips => 'paywall.headline_trips'.tr(namedArgs: {'n': n}),
      Quota.membersPerTrip => 'paywall.headline_members'.tr(
        namedArgs: {'n': n},
      ),
      Quota.momentsPerTrip => 'paywall.headline_moments'.tr(
        namedArgs: {'n': n},
      ),
      Quota.aiPerMonth => 'paywall.headline_ai'.tr(namedArgs: {'n': n}),
      null => 'paywall.headline_generic'.tr(),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GenZTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.lockSimple(), size: 40, color: inkSoft),
            const SizedBox(height: GenZTokens.space4),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            if (quota == Quota.aiPerMonth) ...[
              const SizedBox(height: GenZTokens.space2),
              Text(
                'paywall.locked_ai_reset'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 13, color: inkSoft),
              ),
            ],
            const SizedBox(height: GenZTokens.space4),
            ElevatedButton.icon(
              onPressed: () =>
                  PaywallSheet.show(context, quota: quota, limit: limit),
              icon: Icon(PhosphorIcons.crown(), size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                'paywall.locked_see_plans'.tr(),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
