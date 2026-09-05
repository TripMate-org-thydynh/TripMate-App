import 'package:flutter/widgets.dart';

/// Kích thước khung thiết kế gốc của TripMate (dp).
///
/// Toàn bộ `fontSize`, padding và chiều cao trong app được chọn mắt trên khung
/// này (xấp xỉ Pixel 7). Máy nào có khung nhỏ hơn thì mọi thứ trông quá khổ.
const Size kDesignSize = Size(411, 914);

/// Hệ số co giãn giao diện theo khung nhìn thật của máy.
///
/// **Không dò mẫu máy.** Số mẫu điện thoại là vô hạn và một mẫu còn đổi kích
/// thước theo cài đặt người dùng: SM-A920F ở đây có màn 1080×2220 nhưng người
/// dùng đặt "Chế độ hiển thị" phóng to (override density 480), nên khung thật
/// chỉ còn **360×740 dp** trong khi khung thiết kế là 411×914 — thấp hơn 19%.
/// Cùng một mẫu máy, người khác để mặc định sẽ ra con số khác hẳn. Vì vậy phải
/// đo khung nhìn thực tế chứ không tra theo tên máy.
///
/// Lấy theo cạnh chật hơn để không bao giờ phóng to quá khung, và kẹp trong
/// khoảng [0.82, 1.0]: chỉ thu nhỏ trên máy chật, không phóng to trên máy rộng
/// (máy rộng nên hiện thêm nội dung chứ không phải chữ to hơn).
double uiScaleOf(Size size) {
  final byWidth = size.width / kDesignSize.width;
  final byHeight = size.height / kDesignSize.height;
  final raw = byWidth < byHeight ? byWidth : byHeight;
  return raw.clamp(0.82, 1.0);
}

extension ResponsiveContext on BuildContext {
  /// Hệ số co giãn của khung hiện tại.
  double get uiScale => uiScaleOf(MediaQuery.sizeOf(this));

  /// Quy đổi một giá trị dp thiết kế sang dp thật của máy.
  ///
  /// Dùng cho chiều cao/padding cố định: `SizedBox(height: context.rs(120))`.
  double rs(double designValue) => designValue * uiScale;
}
