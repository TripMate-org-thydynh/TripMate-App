import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

/// Kho tile bản đồ trên máy — để bản đồ còn dùng được khi mất sóng.
///
/// Mọi tile đã từng hiện đều được giữ lại (như cache trình duyệt). Ngoài ra
/// [OfflineMapStore.prefetch] tải trước một vùng nhỏ quanh các điểm của chuyến.
///
/// Giấy phép: nhà cung cấp tile miễn phí (Esri, OSM) KHÔNG cho tải hàng loạt để
/// dùng offline. Tải trước ở đây bị giới hạn số tile nhỏ; khi phát hành thật nên
/// chuyển sang nguồn có giấy phép offline — chỉ cần sửa `map_tiles.dart`.
class OfflineMapStore {
  OfflineMapStore._();
  static final instance = OfflineMapStore._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.bytes,
      headers: {'User-Agent': 'com.tripmate.app'},
    ),
  );

  Directory? _dir;

  /// Giới hạn cứng của một lần tải trước (≈ 15KB/tile → tối đa ~12MB).
  static const maxPrefetchTiles = 800;

  Future<Directory> _root() async {
    if (_dir != null) return _dir!;
    final base = await getApplicationSupportDirectory();
    final d = Directory('${base.path}/map_tiles');
    if (!d.existsSync()) d.createSync(recursive: true);
    return _dir = d;
  }

  /// Tên file ổn định cho một URL tile (không cần thư viện băm).
  String _key(String url) {
    var h = 0xcbf29ce484222325;
    for (final c in url.codeUnits) {
      h ^= c;
      h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return h.toRadixString(16);
  }

  Future<File> _file(String url) async =>
      File('${(await _root()).path}/${_key(url)}.tile');

  /// Đúng là ảnh JPEG/PNG/WebP chứ không phải trang lỗi hay file ghi dở.
  ///
  /// Không kiểm thì một lần mạng chập (server trả HTML lỗi kèm mã 200, hoặc
  /// ghi file đứt giữa chừng) sẽ đóng băng ô bản đồ đó mãi mãi: lần sau đọc
  /// cache ra vẫn là rác, giải mã hỏng, ô hiện xám.
  static bool _looksLikeImage(Uint8List b) {
    if (b.length < 12) return false;
    final jpeg = b[0] == 0xFF && b[1] == 0xD8;
    final png = b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47;
    final webp = b[0] == 0x52 && b[1] == 0x49 && b[8] == 0x57 && b[9] == 0x45;
    return jpeg || png || webp;
  }

  /// Lấy tile: có trên máy thì dùng ngay, không thì tải và giữ lại.
  Future<Uint8List> load(String url) async {
    final f = await _file(url);
    if (f.existsSync()) {
      final cached = await f.readAsBytes();
      if (_looksLikeImage(cached)) return cached;
      // Cache hỏng → bỏ đi, tải lại.
      await f.delete().catchError((_) => f);
    }
    final res = await _dio.get<List<int>>(url);
    final bytes = Uint8List.fromList(res.data ?? const []);
    if (_looksLikeImage(bytes)) {
      // Ghi tạm rồi đổi tên: không để lại file ghi dở khi app bị tắt giữa chừng.
      final tmp = File('${f.path}.part');
      tmp
          .writeAsBytes(bytes, flush: true)
          .then((x) => x.rename(f.path))
          .catchError((_) => f);
    }
    return bytes;
  }

  Future<bool> has(String url) async {
    final f = await _file(url);
    if (!f.existsSync()) return false;
    return _looksLikeImage(await f.readAsBytes());
  }

  /// Dung lượng đang dùng (byte).
  Future<int> sizeBytes() async {
    final d = await _root();
    var total = 0;
    for (final e in d.listSync()) {
      if (e is File) total += e.lengthSync();
    }
    return total;
  }

  Future<void> clear() async {
    final d = await _root();
    if (d.existsSync()) d.deleteSync(recursive: true);
    _dir = null;
  }

  /// Toạ độ tile (x, y) chứa một điểm ở mức zoom [z] (Web Mercator).
  static (int, int) tileOf(LatLng p, int z) {
    final n = 1 << z;
    final x = ((p.longitude + 180) / 360 * n).floor();
    final lat = p.latitude * math.pi / 180;
    final y =
        ((1 - math.log(math.tan(lat) + 1 / math.cos(lat)) / math.pi) / 2 * n)
            .floor();
    return (x.clamp(0, n - 1), y.clamp(0, n - 1));
  }

  /// Danh sách URL cần cho vùng [bounds] ở các mức zoom, theo mọi lớp [layers].
  static List<String> urlsFor(
    LatLngBounds bounds,
    List<TileLayer> layers, {
    int minZoom = 11,
    int maxZoom = 15,
  }) {
    final urls = <String>[];
    for (var z = minZoom; z <= maxZoom; z++) {
      final (x0, y0) = tileOf(bounds.northWest, z);
      final (x1, y1) = tileOf(bounds.southEast, z);
      for (var x = x0; x <= x1; x++) {
        for (var y = y0; y <= y1; y++) {
          for (final l in layers) {
            final t = l.urlTemplate;
            if (t == null) continue;
            urls.add(
              t
                  .replaceAll('{z}', '$z')
                  .replaceAll('{x}', '$x')
                  .replaceAll('{y}', '$y')
                  .replaceAll('{r}', ''),
            );
          }
        }
      }
    }
    return urls;
  }

  /// Tải trước các tile còn thiếu. [onProgress] nhận (đã xong, tổng).
  /// Trả số tile tải lỗi (mất mạng giữa chừng...).
  Future<int> prefetch(
    List<String> urls, {
    void Function(int done, int total)? onProgress,
    bool Function()? cancelled,
  }) async {
    var done = 0;
    var failed = 0;
    // 4 luồng song song — đủ nhanh mà không dội máy chủ tile.
    final queue = [...urls];
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        if (cancelled?.call() ?? false) return;
        final url = queue.removeLast();
        try {
          if (!await has(url)) await load(url);
        } catch (_) {
          failed++;
        }
        onProgress?.call(++done, urls.length);
      }
    }

    await Future.wait(List.generate(4, (_) => worker()));
    return failed;
  }
}

/// TileProvider đọc/ghi qua [OfflineMapStore].
class CachedTileProvider extends TileProvider {
  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _CachedTileImage(getTileUrl(coordinates, options));
}

class _CachedTileImage extends ImageProvider<_CachedTileImage> {
  const _CachedTileImage(this.url);
  final String url;

  @override
  Future<_CachedTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _CachedTileImage key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(
    codec: _load(decode),
    scale: 1,
    debugLabel: url,
  );

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await OfflineMapStore.instance.load(url);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is _CachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
