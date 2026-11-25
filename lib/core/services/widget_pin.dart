import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Cầu nối điều khiển Widget Màn hình chính cho cả Android (`AppWidgetManager`)
/// và iOS (`WidgetKit` + multi-AppGroup bridge trong `AppDelegate.swift`).
class WidgetPin {
  const WidgetPin._();

  static const _channel = MethodChannel('tripmate/widget_pin');

  static bool get _isFlutterTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  /// Máy này có cho phép app tự mở hộp thoại ghim widget tự động không.
  ///
  /// Trả `true` trên Android 8+ (launcher hỗ trợ). Trên iOS trả `false` vì Apple
  /// yêu cầu người dùng thêm tiện ích từ khay WidgetKit — app sẽ hiển thị bảng
  /// Xem trước Widget trực tiếp (Live Preview) kèm hướng dẫn 3 bước chuẩn iOS.
  static Future<bool> isSupported() async {
    if (kIsWeb ||
        _isFlutterTest ||
        defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on Object {
      return false;
    }
  }

  /// Mở hộp thoại ghim của hệ thống Android. Trả `true` nếu hộp thoại đã hiện ra.
  static Future<bool> request() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>('requestPin') ?? false;
    } on Object {
      return false;
    }
  }

  /// Lấy danh sách App Group ID khả dụng trên iOS (bao gồm cả `ALTAppGroups` khi
  /// sideload qua `iloader-cli` lẫn `group.com.tripmate.app` trên App Store).
  static Future<List<String>> getIosAppGroups() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const ['group.com.tripmate.app'];
    }
    try {
      final raw = await _channel
          .invokeListMethod<String>('getAppGroups')
          .timeout(
            const Duration(milliseconds: 600),
            onTimeout: () => const <String>[],
          );
      if (raw != null && raw.isNotEmpty) return raw;
    } on Object {
      // Fallback safely in tests or if channel is not attached yet.
    }
    return const ['group.com.tripmate.app'];
  }

  /// Đếm số lượng tiện ích TripMate đang được gắn ngoài Màn hình chính iOS.
  static Future<int> getInstalledIosWidgetsCount() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return 0;
    try {
      return await _channel
              .invokeMethod<int>('getInstalledWidgetsCount')
              .timeout(
                const Duration(milliseconds: 600),
                onTimeout: () => 0,
              ) ??
          0;
    } on Object {
      return 0;
    }
  }

  /// Đồng bộ dữ liệu JSON + tải trước tối đa 3 ảnh thumbnail nén (ImageIO 600px)
  /// vào mọi App Group container trên iOS và gọi `WidgetCenter.shared.reloadAllTimelines()`.
  static Future<bool> syncNativeIosWidget({
    required String latestJson,
    required String feedJson,
    required String updatedAt,
    required List<String> imageUrls,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      return await _channel
              .invokeMethod<bool>('syncWidgetData', {
                'latestJson': latestJson,
                'feedJson': feedJson,
                'updatedAt': updatedAt,
                'imageUrls': imageUrls,
              })
              .timeout(
                const Duration(milliseconds: 800),
                onTimeout: () => false,
              ) ??
          false;
    } on Object {
      return false;
    }
  }

  /// Xoá sạch dữ liệu và ảnh đệm trong App Group iOS khi đăng xuất.
  static Future<bool> clearNativeIosWidget() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      return await _channel
              .invokeMethod<bool>('clearWidgetData')
              .timeout(
                const Duration(milliseconds: 600),
                onTimeout: () => false,
              ) ??
          false;
    } on Object {
      return false;
    }
  }
}
