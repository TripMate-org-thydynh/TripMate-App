import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'envelope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  // Active language code synced with the UI localization state
  static String currentLanguage = 'vi';

  ApiClient(this.dio);

  /// URL backend theo môi trường.
  ///
  /// Ưu tiên `--dart-define=API_BASE_URL=...` (staging/prod, bắt buộc https).
  /// Không truyền → fallback localhost cho dev (Android emulator dùng 10.0.2.2).
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      assert(
        _envBaseUrl.startsWith('https://') ||
            _envBaseUrl.contains('localhost') ||
            _envBaseUrl.contains('10.0.2.2'),
        'API_BASE_URL phải dùng https ở môi trường thật.',
      );
      return _envBaseUrl;
    }

    // Release build BẮT BUỘC truyền --dart-define=API_BASE_URL=https://...
    // Nếu không, app sẽ trỏ localhost và chết hoàn toàn trên máy thật →
    // fail sớm, rõ ràng thay vì lỗi mạng mơ hồ ở mọi màn hình.
    if (kReleaseMode) {
      throw StateError(
        'API_BASE_URL chưa được cấu hình. Build release phải truyền '
        '--dart-define=API_BASE_URL=https://<domain>/api/v1',
      );
    }

    // Dev fallback (chỉ khi không truyền dart-define).
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api/v1';
      }
    } catch (_) {
      // non-io / web
    }
    return 'http://localhost:3000/api/v1';
  }

  // ── Raw methods (trả nguyên envelope, ném ApiException khi fail) ─────────────
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _log(e, 'GET', path);
      throw ApiException.fromDio(e);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await dio.post(path, data: body);
      return response.data;
    } on DioException catch (e) {
      _log(e, 'POST', path);
      throw ApiException.fromDio(e);
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final response = await dio.patch(path, data: body);
      return response.data;
    } on DioException catch (e) {
      _log(e, 'PATCH', path);
      throw ApiException.fromDio(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      _log(e, 'DELETE', path);
      throw ApiException.fromDio(e);
    }
  }

  // ── Typed methods cho repository: unwrap {success,data}, ném ApiException ────
  Future<dynamic> getData(String path, {Map<String, dynamic>? query}) =>
      _send(() => dio.get(path, queryParameters: query), 'GET', path);

  Future<dynamic> postData(String path, [Map<String, dynamic>? body]) =>
      _send(() => dio.post(path, data: body), 'POST', path);

  Future<dynamic> patchData(String path, [Map<String, dynamic>? body]) =>
      _send(() => dio.patch(path, data: body), 'PATCH', path);

  Future<dynamic> putData(String path, [Map<String, dynamic>? body]) =>
      _send(() => dio.put(path, data: body), 'PUT', path);

  Future<dynamic> deleteData(String path) =>
      _send(() => dio.delete(path), 'DELETE', path);

  Future<dynamic> _send(
    Future<Response<dynamic>> Function() call,
    String method,
    String path,
  ) async {
    try {
      final res = await call();
      // BE bọc mọi response: { success, data, timestamp } → trả về data.
      return unwrapEnvelope(res.data);
    } on DioException catch (e) {
      _log(e, method, path);
      throw ApiException.fromDio(e);
    }
  }

  void _log(DioException e, String method, String path) {
    debugPrint('ApiClient $method $path → ${e.response?.statusCode}');
    if (kDebugMode) debugPrint('Body: ${e.response?.data}');
  }
}

// Global Providers
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiClient.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // Add Accept-Language header interceptor dynamically
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Accept-Language'] = ApiClient.currentLanguage;
        return handler.next(options);
      },
    ),
  );

  // Add our dynamic authorization interceptor
  dio.interceptors.add(AuthInterceptor(ref));

  // Add LogInterceptor in debug mode for seamless network troubleshooting
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
