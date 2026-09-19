import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
