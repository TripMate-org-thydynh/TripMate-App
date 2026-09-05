import 'package:intl/intl.dart';

/// Định dạng tiền tệ dùng chung cho toàn app.
///
/// Trước đây mỗi màn tự ghép chuỗi bằng `toStringAsFixed(0)`, nên số tiền hiện
/// ra dạng `1350000 đ` — người đọc phải tự đếm chữ số để biết là một triệu ba
/// hay mười ba triệu (BUG-010). Không nơi nào trong app dùng `NumberFormat`,
/// tức là chưa từng có tầng định dạng chung.
///
/// Đặt ở đây để sửa một lần cho mọi màn, thay vì vá từng chỗ — cùng bài học rút
/// ra từ BUG-002 (Decimal được chuẩn hoá ở interceptor thay vì từng service).
///
/// Không import `flutter/widgets` hay `easy_localization`: cả hai kéo theo
/// `TextDirection` của `dart:ui`, va chạm với `TextDirection` mà `intl` export.
/// Vì vậy locale được truyền vào dưới dạng chuỗi (`context.locale.languageCode`).
String formatMoney(num amount, {String locale = 'vi'}) {
  final grouped = NumberFormat.decimalPattern(locale).format(amount.round());
  // Tiếng Việt viết hậu tố "đ"; bản tiếng Anh dùng ký hiệu quốc tế "₫".
  return locale == 'vi' ? '$grouped đ' : '$grouped ₫';
}
