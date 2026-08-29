import 'package:flutter/material.dart';

import 'theme/gen_z_tokens.dart';

/// Key toàn cục để hiện SnackBar từ nơi không có BuildContext (vd interceptor).
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Hiện thông báo nổi ở cuối màn.
///
/// Trước đây thành công dùng `0xFFFF6A4A` (cam đỏ) còn lỗi dùng
/// `Colors.redAccent` — hai màu gần như y hệt nhau, nên "Đã lưu" và "Lưu thất
/// bại" trông giống nhau. Nay tách hẳn: xanh cho thành công, đỏ cho lỗi, kèm
/// icon để đọc lướt là biết.
///
/// [onRetry] thêm nút "Thử lại" — dùng cho lỗi mà người dùng làm lại được ngay.
void showGlobalSnack(
  String message, {
  bool isError = false,
  VoidCallback? onRetry,
  String retryLabel = 'Thử lại',
}) {
  rootMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? GenZTokens.danger : GenZTokens.success,
        // Lỗi cần thời gian đọc hơn thông báo thành công.
        duration: Duration(seconds: isError ? 5 : 3),
        action: onRetry == null
            ? null
            : SnackBarAction(
                label: retryLabel,
                textColor: Colors.white,
                onPressed: onRetry,
              ),
      ),
    );
}
