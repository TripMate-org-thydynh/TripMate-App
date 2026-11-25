import 'dart:convert';
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

  /// Chọn ảnh đại diện từ thư viện/camera và tải lên.
  Future<String?> pickAndUploadAvatar({
    required ImageSource source,
    String? tripId,
  }) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (file == null) return null;
    final ioFile = File(file.path);
    final contentType = _guessType(file.path, file.mimeType);
    if (tripId != null && tripId.isNotEmpty) {
      try {
        final uploaded = await uploadFile(
          tripId: tripId,
          file: ioFile,
          contentType: contentType,
        );
        return uploaded.url;
      } catch (_) {}
    }
    final bytes = await ioFile.readAsBytes();
    return 'data:$contentType;base64,${base64Encode(bytes)}';
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

    // 4. Pre-warm Edge CDN cho các kích thước chuẩn (boardThumb & background)
    //    để các thành viên tiếp theo mở bảng/chuyến đi nhận thẳng từ Edge Cache.
    // ignore: unawaited_futures
    warmUpCdnCache(url);

    return UploadedMedia(url: url, contentType: contentType, sizeBytes: bytes);
  }

  /// Chủ động gọi ngầm lên Edge CDN ngay sau khi 1 thành viên upload ảnh để
  /// CDN tạo sẵn và lưu cache các biến thể chuẩn (`avatar`, `boardThumb`, `background`).
  /// Khi các thành viên khác mở màn hình, CDN trả về ngay lập tức (< 25ms).
  Future<void> warmUpCdnCache(
    String url, {
    List<CdnTier> tiers = const [
      CdnTier.avatar,
      CdnTier.boardThumb,
      CdnTier.background,
    ],
  }) async {
    if (!url.contains('/upload/')) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    for (final tier in tiers) {
      final derivedUrl = cdnUrlForTier(url, tier);
      try {
        await _plainDio.head<void>(
          derivedUrl,
          options: Options(
            sendTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 4),
          ),
        );
      } catch (_) {}
    }
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

  static String cdnUrlForTier(String url, CdnTier tier) =>
      optimizedMedia(url, width: tier.width);

  static String cdnCacheKey(String url, {CdnTier? tier}) {
    final clean = url.split('?').first;
    if (tier == null) return clean;
    return '${clean}__w${tier.width}';
  }
}

final mediaUploaderProvider = Provider<MediaUploader>(
  (ref) => MediaUploader(ref.watch(apiClientProvider)),
);

/// 4 nấc kích thước CDN chuẩn hóa toàn dự án để mọi thiết bị đều dùng chung
/// đúng 1 khóa cache trên Edge CDN và trên ổ đĩa:
/// - [avatar]: 200px (ảnh đại diện Profile, chip thành viên, bong bóng chat)
/// - [boardThumb]: 480px (ảnh Polaroid trên Bảng Kỷ Niệm 2D, lưới ảnh, bản đồ)
/// - [background]: 960px (ảnh bìa chuyến đi, background màn hình, thẻ khám phá)
/// - [full]: 1600px (xem ảnh phóng to chi tiết 1x/2x/3x)
enum CdnTier {
  avatar(200),
  boardThumb(480),
  background(960),
  full(1600);

  final int width;
  const CdnTier(this.width);
}

/// Chuẩn hóa chiều rộng bất kỳ về 1 trong 4 nấc CDN cố định để tránh việc mỗi
/// kích thước màn hình tạo ra một URL khác nhau làm trượt cache CDN.
int canonicalCdnWidth(int requestedWidth) {
  if (requestedWidth <= 240) return CdnTier.avatar.width;
  if (requestedWidth <= 560) return CdnTier.boardThumb.width;
  if (requestedWidth <= 1080) return CdnTier.background.width;
  return CdnTier.full.width;
}

/// Tạo URL Cloudinary CDN đã tối ưu hóa (`f_auto,q_auto`) theo nấc [tier].
String cdnUrlForTier(String url, CdnTier tier) {
  return optimizedMedia(url, width: tier.width);
}

/// Tạo khóa cache ổn định cho `CachedNetworkImage` theo nấc [tier].
String cdnCacheKey(String url, {CdnTier? tier}) {
  final clean = url.split('?').first;
  if (tier == null) return clean;
  return '${clean}__w${tier.width}';
}

/// Biến URL Cloudinary thành URL đã tối ưu cho đúng kích thước cần hiển thị.
///
/// Lý do quan trọng: app đang dùng CÙNG một ảnh gốc cho marker 50×50 trên bản
/// đồ lẫn ảnh xem toàn màn hình — một tấm 400 KB bị tải nguyên vẹn để vẽ một
/// chấm bé xíu. `f_auto` trả WebP/AVIF khi máy hỗ trợ, `q_auto` chọn mức nén,
/// và `canonicalCdnWidth` gộp mọi request về đúng 4 nấc chuẩn trên Edge CDN.
String optimizedMedia(String url, {int? width}) {
  if (!url.contains('/upload/')) return url;
  // Nếu URL đã có sẵn chuỗi biến đổi f_auto,q_auto thì tránh chèn trùng.
  if (url.contains('/upload/f_auto,q_auto')) return url;
  final t = <String>['f_auto', 'q_auto'];
  if (width != null) {
    final canonicalW = canonicalCdnWidth(width);
    t
      ..add('w_$canonicalW')
      ..add('c_limit');
  }
  return url.replaceFirst('/upload/', '/upload/${t.join(',')}/');
}

/// Ảnh bìa cho một moment: với VIDEO thì đổi đuôi sang .jpg để Cloudinary trả
/// frame đầu. Cùng quy tắc mà backend dùng ở `StorageService.posterFor`, để
/// chỗ nào vẽ bằng widget ảnh cũng không ra ô "không tải được ảnh".
String posterMedia(String url, String type, {int? width}) {
  if (type != 'VIDEO') return optimizedMedia(url, width: width);
  final dot = url.lastIndexOf('.');
  final slash = url.lastIndexOf('/');
  final jpg = dot > slash ? '${url.substring(0, dot)}.jpg' : '$url.jpg';
  return optimizedMedia(jpg, width: width);
}
