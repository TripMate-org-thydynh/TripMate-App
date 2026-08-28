import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Trạng thái rỗng dùng chung cho các màn game.
///
/// Các màn game trước đây luôn hiển thị số liệu và người chơi bịa; nay khi
/// chưa có chuyến/dữ liệu thì hiện khối này để người dùng biết cần làm gì.
class GameEmptyState extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String body;

  const GameEmptyState({
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
class GameErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const GameErrorState({
    super.key,
    required this.isDark,
    required this.onRetry,
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
            Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: inkSoft.withValues(alpha: 0.8),
            ),
            const SizedBox(height: GenZTokens.space4),
            Text(
              'errors.load_failed'.tr(),
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
