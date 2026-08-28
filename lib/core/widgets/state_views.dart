import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../network/api_exception.dart';
import '../theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';

/// Trạng thái rỗng dùng chung cho mọi màn hình.
///
/// Nhiều màn trước đây luôn hiển thị số liệu và người bịa; nay khi chưa có
/// dữ liệu thật thì hiện khối này để người dùng biết cần làm gì tiếp.
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GenZTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(GenZTokens.space5),
              decoration: BoxDecoration(
                color: GenZTokens.yellow,
                shape: BoxShape.circle,
                border: Border.all(color: ink, width: GenZTokens.borderWidth),
              ),
              child: Icon(icon, size: 34, color: GenZTokens.ink),
            ),
            const SizedBox(height: GenZTokens.space5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space2),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 14, color: inkSoft, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trạng thái lỗi dùng chung, có nút thử lại.
///
/// Trước đây các màn game nuốt lỗi và hiện dữ liệu cứng, nên người dùng không
/// bao giờ biết là tải hỏng.
class AppErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  /// Lỗi bắt được — truyền vào để hiện đúng câu BE trả về (hết quota AI, chuyến
  /// không tồn tại...) thay vì một câu chung chung.
  final Object? error;

  const AppErrorState({
    super.key,
    required this.isDark,
    required this.onRetry,
    this.error,
  });

  /// Câu thông báo: ưu tiên message của [ApiException]; mất mạng thì đổi icon.
  ApiException? get _api => error is ApiException ? error as ApiException : null;

  @override
  Widget build(BuildContext context) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GenZTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _api == null || _api!.isNetwork
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              size: 40,
              color: inkSoft.withValues(alpha: 0.8),
            ),
            const SizedBox(height: GenZTokens.space4),
            Text(
              _api?.message ?? 'errors.load_failed'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space4),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: GenZTokens.yellow,
                foregroundColor: GenZTokens.ink,
                elevation: 0,
                side: BorderSide(color: ink, width: GenZTokens.borderWidth),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                'general.retry'.tr(),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GenZTokens.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
