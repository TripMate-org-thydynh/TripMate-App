import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'envelope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import '../distribution_channel.dart';

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

  /// Mở một luồng SSE và trả về từng sự kiện `(event, data)`.
  ///
  /// Dùng cho câu trả lời chảy từng mẩu chữ: người dùng thấy chữ hiện dần
  /// thay vì nhìn vòng xoay tới lúc câu trả lời xong hẳn.
  ///
  /// Không dùng `_send` vì thân phản hồi ở đây là luồng byte chưa kết thúc,
  /// không phải một gói JSON đọc một lần là xong.
  Stream<(String, Map<String, dynamic>)> postSse(
    String path,
    Map<String, dynamic> body,
  ) async* {
    late final Response<ResponseBody> res;
    try {
      res = await dio.post<ResponseBody>(
        path,
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // Câu trả lời dài có thể im lặng vài giây giữa các mẩu.
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
    } on DioException catch (e) {
      _log(e, 'POST(SSE)', path);
      throw ApiException.fromDio(e);
    }

    // SSE ngăn cách các sự kiện bằng dòng trống; một mẩu byte có thể cắt
    // ngang giữa dòng nên phải gom lại rồi mới tách.
    var buffer = '';
    String? event;
    await for (final chunk in res.data!.stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      while (true) {
        final nl = buffer.indexOf('\n');
        if (nl < 0) break;
        final line = buffer.substring(0, nl).trimRight();
        buffer = buffer.substring(nl + 1);
        if (line.startsWith('event: ')) {
          event = line.substring(7);
        } else if (line.startsWith('data: ')) {
          final raw = line.substring(6);
          try {
            final parsed = jsonDecode(raw);
            if (parsed is Map<String, dynamic>) {
              yield (event ?? 'message', parsed);
            }
          } catch (_) {
            // Dòng rác giữa chừng: bỏ qua, đừng làm đứt cả luồng.
          }
        }
      }
    }
  }

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
        // Server dua vao day de biet nen bay Play Billing hay VietQR.
        options.headers['X-Client-Channel'] = kDistributionChannel.wire;
        // Goi AI di qua Gemini nen thuong 15-40s. Voi timeout chung 15s thi
        // moi lan nho AI viet caption deu bi huy giua chung ma nguoi dung
        // khong hieu vi sao.
        if (options.path.startsWith('/ai/')) {
          options.receiveTimeout = const Duration(seconds: 60);
        }
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
