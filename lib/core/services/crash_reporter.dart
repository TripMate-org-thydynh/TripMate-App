import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Gửi lỗi chưa bắt được về `POST /observability/client-errors`.
///
/// App chưa có Crashlytics/Sentry nên trước đây crash bản phát hành là vô
/// hình. Đây là lớp tối thiểu: chỉ thông điệp + stack (không token, không
/// dữ liệu người dùng), chống dội, và không bao giờ tự ném lỗi.
class CrashReporter {
  CrashReporter._();

  /// Dio riêng, không interceptor auth: lỗi có thể xảy ra trước khi đăng nhập
  /// và không được kéo JWT theo.
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  /// Tối đa 5 báo cáo mỗi lần mở app, và không gửi lặp cùng một lỗi —
  /// một lỗi trong `build` có thể bắn hàng trăm lần mỗi giây.
  static const _maxPerSession = 5;
  static int _sent = 0;
  static final Set<int> _seen = {};

  static const _appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'dev',
  );

  /// Gắn vào FlutterError + PlatformDispatcher. Gọi một lần, đầu `main()`.
  static void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      previous?.call(details);
      report(details.exception, details.stack, source: 'flutter');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack, source: 'platform');
      // true = đã xử lý: không để engine coi là crash và đóng app.
      return true;
    };
  }

  static Future<void> report(
    Object error,
    StackTrace? stack, {
    required String source,
  }) async {
    // Bản debug đã in ra console; gửi về server chỉ làm nhiễu số liệu.
    if (kDebugMode) return;
    try {
      final message = error.toString();
      final key = Object.hash(message, stack?.toString().split('\n').first);
      if (_sent >= _maxPerSession || !_seen.add(key)) return;
      _sent++;
      await _dio.post(
        '${ApiClient.baseUrl}/observability/client-errors',
        data: {
          'message': message.length > 500 ? message.substring(0, 500) : message,
          if (stack != null)
            'stack': stack.toString().length > 4000
                ? stack.toString().substring(0, 4000)
                : stack.toString(),
          'source': source,
          'appVersion': _appVersion,
          'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );
    } catch (_) {
      // Báo lỗi mà lỗi thì thôi — không được gây thêm lỗi.
    }
  }
}
