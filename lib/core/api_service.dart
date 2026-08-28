import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../features/system_states/pages/no_internet_screen.dart';
import 'app_messenger.dart';
import 'network/api_client.dart';
import 'network/envelope.dart';

class ApiService {
  // Global Navigator Key for system-level redirection
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isOfflineScreenShowing = false;

  static void _navigateToNoInternet() {
    if (_isOfflineScreenShowing) return;
    final context = navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      _isOfflineScreenShowing = true;
      // Theo theme thật của app (Theme.of) thay vì hardcode dark.
      final isDark = Theme.of(context).brightness == Brightness.dark;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoInternetScreen(isDarkMode: isDark),
        ),
      ).then((_) {
        _isOfflineScreenShowing = false;
      });
    }
  }

  static String get baseUrl => ApiClient.baseUrl;

  // Secure in-memory token cache for authenticated requests
  static String? authToken;

  // Active language code synced with the UI localization state
  static String currentLanguage = 'vi';

  // Persistent static Dio instance to mimic API client interceptors for legacy screens
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              // Chỉ gắn token thật; không dùng dummy-token fallback.
              if (authToken != null) {
                options.headers['authorization'] = 'Bearer $authToken';
              }
              options.headers['content-type'] = 'application/json';
              options.headers['Accept-Language'] = currentLanguage;
              return handler.next(options);
            },
            onError: (err, handler) {
              if (err.type == DioExceptionType.connectionTimeout ||
                  err.type == DioExceptionType.receiveTimeout ||
                  err.error is SocketException) {
                _navigateToNoInternet();
              }
              return handler.next(err);
            },
          ),
        );

  /// BE bọc mọi response trong `{ success, data, timestamp }`.
  /// Trả về phần `data` để caller đọc trực tiếp field (không phải res['data']['x']).
  /// Giữ tương thích: nếu response không có envelope thì trả nguyên body.
  static dynamic _unwrap(dynamic body) => unwrapEnvelope(body);

  /// Hiện thông báo lỗi từ server (4xx/5xx) cho người dùng, giữ hợp đồng trả null.
  /// Lỗi mạng đã có NoInternetScreen nên bỏ qua ở đây (tránh trùng).
  static void _surfaceError(Object e, String method, String path) {
    debugPrint('ApiService $method $path exception: $e');
    if (e is! DioException) return;
    final isNetwork =
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
    if (isNetwork) return;
    String? msg;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      msg = m is List ? m.join(', ') : m.toString();
    }
    showGlobalSnack(msg ?? 'Có lỗi xảy ra. Vui lòng thử lại.', isError: true);
  }

  static Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get(path);
      return _unwrap(response.data);
    } catch (e) {
      // GET load nền thường có fallback → không spam snackbar, chỉ log.
      debugPrint('ApiService GET $path exception: $e');
      return null;
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(path, data: body);
      return _unwrap(response.data);
    } catch (e) {
      _surfaceError(e, 'POST', path);
      return null;
    }
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch(path, data: body);
      return _unwrap(response.data);
    } catch (e) {
      _surfaceError(e, 'PATCH', path);
      return null;
    }
  }
}
