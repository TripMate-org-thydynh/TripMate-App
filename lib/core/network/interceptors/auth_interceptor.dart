import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../app_messenger.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authState = _ref.read(authProvider);

    // Chỉ gắn header khi có token thật. Không token → BE trả 401 (không dùng dummy-token).
    if (authState.token != null) {
      options.headers['authorization'] = 'Bearer ${authState.token}';
    }

    options.headers['content-type'] = 'application/json';
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token hết hạn/không hợp lệ — báo người dùng rồi logout (router đưa về /auth).
      final wasAuthed = _ref.read(authProvider).isAuthenticated;
      if (wasAuthed) {
        showGlobalSnack(
          'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          isError: true,
        );
      }
      _ref.read(authProvider.notifier).logout();
    }
    return super.onError(err, handler);
  }
}
