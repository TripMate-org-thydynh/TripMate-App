import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';

/// Kết quả tải lên: URL công khai để lưu vào moment/tài liệu.
class UploadedMedia {
  final String url;
  final String contentType;
  final int sizeBytes;

  const UploadedMedia({
    required this.url,
    required this.contentType,
    required this.sizeBytes,
  });
}

/// Tải ảnh lên Cloudinary.
///
/// Backend cấp một "vé" đã ký (sống 1 giờ); app gửi file THẲNG lên Cloudinary
/// bằng vé đó. Ảnh không đi qua backend, và app không giữ API secret.
///
/// Trước đây app hoàn toàn không có đường nào để đưa ảnh lên: `MomentsRepository
/// .create()` nhận sẵn một `mediaUrl` nhưng không nơi nào gọi, còn màn Tài liệu
/// thì bắt người dùng tự dán URL.
class MediaUploader {
  final ApiClient _client;
  final Dio _plainDio;

  /// Dio riêng, KHÔNG gắn interceptor auth của app: request đi Cloudinary
  /// không được kèm JWT của TripMate.
  MediaUploader(this._client) : _plainDio = Dio();

  /// Chọn ảnh rồi tải lên. Trả `null` nếu người dùng bấm huỷ.
  ///
  /// Nén ngay lúc chọn: ảnh 12MP gốc làm payload phình to mà hiển thị không
  /// cần tới. Cloudinary còn nén tiếp bằng `q_auto` khi phục vụ.
  Future<UploadedMedia?> pickAndUpload({
    required String tripId,
    required ImageSource source,
    int maxWidth = 1600,
    int quality = 85,
    void Function(double progress)? onProgress,
  }) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    if (file == null) return null;
    return uploadFile(
      tripId: tripId,
      file: File(file.path),
      contentType: _guessType(file.path, file.mimeType),
      onProgress: onProgress,
    );
  }

  /// Tải một file đã có sẵn trên máy.
  Future<UploadedMedia> uploadFile({
    required String tripId,
    required File file,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await file.length();

    // 1. Xin vé. Backend kiểm mình có trong chuyến không, chặn loại file lạ và
    //    file quá lớn trước khi tốn công tải.
    final ticketRaw = await _client.postData(
      '/trips/$tripId/storage/upload-ticket',
      {'contentType': contentType, 'sizeBytes': bytes},
    );
    final ticket = (ticketRaw as Map).cast<String, dynamic>();
    final uploadUrl = ticket['uploadUrl'] as String?;
    final fields = (ticket['fields'] as Map?)?.cast<String, dynamic>();
    if (uploadUrl == null || fields == null) {
      throw ApiException('errors.storage.notConfigured');
    }

    // 2. Gửi thẳng lên Cloudinary.
    final form = FormData.fromMap({
      for (final e in fields.entries) e.key: '${e.value}',
      'file': await MultipartFile.fromFile(file.path),
    });

    final Response<dynamic> res;
    try {
      res = await _plainDio.post<dynamic>(
        uploadUrl,
        data: form,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }

    final url = (res.data as Map?)?['secure_url'] as String?;
    if (url == null) {
      throw ApiException('errors.storage.uploadFailed');
    }

    // 3. Báo backend ghi vào bảng `media` (theo dõi dung lượng, dọn ảnh mồ côi).
    //    Hỏng bước này không nên chặn người dùng — ảnh đã lên rồi.
    try {
      await _client.postData('/trips/$tripId/storage/confirm', {
        'url': url,
        'contentType': contentType,
        'sizeBytes': bytes,
      });
    } catch (_) {
      // Bỏ qua có chủ đích.
    }

    return UploadedMedia(url: url, contentType: contentType, sizeBytes: bytes);
  }

  static String _guessType(String path, String? mime) {
    if (mime != null && mime.isNotEmpty) return mime;
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.heic')) return 'image/heic';
    if (p.endsWith('.mp4')) return 'video/mp4';
    if (p.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }
}

final mediaUploaderProvider = Provider<MediaUploader>(
  (ref) => MediaUploader(ref.watch(apiClientProvider)),
);

/// Biến URL Cloudinary thành URL đã tối ưu cho đúng kích thước cần hiển thị.
///
/// Lý do quan trọng: app đang dùng CÙNG một ảnh gốc cho marker 50×50 trên bản
/// đồ lẫn ảnh xem toàn màn hình — một tấm 400 KB bị tải nguyên vẹn để vẽ một
/// chấm bé xíu. `f_auto` trả WebP/AVIF khi máy hỗ trợ, `q_auto` chọn mức nén.
String optimizedMedia(String url, {int? width}) {
  if (!url.contains('/upload/')) return url;
  final t = <String>['f_auto', 'q_auto'];
  if (width != null) {
    t..add('w_$width')..add('c_limit');
  }
  return url.replaceFirst('/upload/', '/upload/${t.join(',')}/');
}
