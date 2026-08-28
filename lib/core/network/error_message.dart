import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Chuyển đổi exception thành chuỗi thân thiện hiển thị cho người dùng.
///
/// Không bao giờ trả `e.toString()` hay chuỗi chứa "Exception"/"DioException".
/// Dùng ở mọi nơi hiện đang in raw `$e` / `$error` / `$err` ra UI.
String friendlyError(Object e) {
  if (e is ApiException) return e.message;
  if (e is DioException) return ApiException.fromDio(e).message;
  // Fallback chung — không trả e.toString()
  return 'Có lỗi xảy ra. Vui lòng thử lại.';
}
