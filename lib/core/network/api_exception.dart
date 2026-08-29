import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

/// Lỗi API có kiểu — thay cho việc trả `null` âm thầm.
/// UI bắt cái này để hiển thị thông báo phù hợp; 401 do interceptor xử lý logout.
/// Message có phải chuỗi kỹ thuật đổ ra từ validator không.
bool _looksTechnical(String m) =>
    m.contains('constraints:') ||
    m.contains('whitelistValidation') ||
    (m.startsWith('{') && m.contains('property:'));

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;

  ApiException(this.message, {this.statusCode, this.code});

  bool get isNetwork => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isServer => statusCode != null && statusCode! >= 500;

  factory ApiException.fromDio(DioException e) {
    // Lỗi mạng / timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiException('errors.connection_lost'.tr());
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;

    // BE trả message trong body (envelope lỗi hoặc Nest exception)
    String message = 'errors.unknown_error'.tr();
    String? code;
    if (data is Map) {
      final m = data['message'] ?? data['error'];
      if (m is String) {
        message = m;
      } else if (m is List && m.isNotEmpty) {
        message = m.first.toString();
      }
      if (data['code'] is String) code = data['code'] as String;
    }

    if (status == 401) message = 'errors.session_expired'.tr();
    if (status == 403) message = 'errors.unauthorized'.tr();
    if (status != null && status >= 500) {
      message = 'errors.server_error'.tr();
    }

    // Lỗi validation của class-validator đổ nguyên cấu trúc đối tượng ra
    // message — người dùng từng thấy nguyên chuỗi "{property: placeName,
    // value: null, target: {mediaUrl: https://..., type: PHOTO, ...},
    // constraints: {whitelistValidation: ...}}" trên màn hình. Đây là lỗi lập
    // trình chứ không phải lỗi người dùng, nên hiện câu chung và ghi chi tiết
    // vào log để dev còn soát.
    if (_looksTechnical(message)) {
      debugPrint('Lỗi validation từ BE: $message');
      message = 'errors.request_invalid'.tr();
    }

    return ApiException(message, statusCode: status, code: code);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
