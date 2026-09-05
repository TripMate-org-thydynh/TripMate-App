import 'dart:io';

import 'package:flutter/services.dart';

/// Xin ghim widget TripMate lên màn hình chính.
///
/// Không có lối tắt này thì người dùng phải tự mò: nhấn giữ màn hình chính →
/// khay tiện ích → cuộn tìm TripMate → kéo thả. Phần lớn sẽ không làm, và
/// widget dù đã cài vẫn không ai thấy — mà widget chính là thứ khiến vòng lặp
/// "gửi ảnh → bạn bè thấy ngay" hoạt động.
///
/// Chỉ Android hỗ trợ. iOS không cho app tự thêm widget: ở đó bắt buộc phải
/// hướng dẫn thủ công.
class WidgetPin {
  const WidgetPin._();

  static const _channel = MethodChannel('tripmate/widget_pin');

  /// Máy này có cho phép app tự ghim widget không.
  ///
  /// Trả `false` trên iOS, trên Android < 8, và trên các launcher không hỗ trợ
  /// (một số ROM tuỳ biến). Gọi trước khi hiện nút, để không mời người dùng
  /// bấm một thứ không chạy.
  static Future<bool> isSupported() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Mở hộp thoại ghim của hệ thống. Trả `true` nếu hộp thoại đã hiện ra.
  ///
  /// Người dùng vẫn có thể bấm huỷ — không có cách nào biết được kết quả cuối,
  /// đó là giới hạn của API.
  static Future<bool> request() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('requestPin') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
