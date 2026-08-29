import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider lưu trạng thái xem dữ liệu ngoại tuyến (được đọc từ local cache do mất mạng).
///
/// Được set từ hai nguồn:
/// 1. [connectivityWatcherProvider] — thay đổi kết nối ở tầng OS.
/// 2. Các repository có cache — khi request fail và phải fallback về cache.
///
/// Nguồn (2) vẫn cần thiết vì "có wifi" không đồng nghĩa "gọi được API"
/// (captive portal, server chết, DNS hỏng).
final offlineProvider = StateProvider<bool>((ref) => false);

/// Theo dõi kết nối mạng ở tầng hệ điều hành và đẩy vào [offlineProvider].
///
/// Phải được `watch` ở gốc cây widget (dashboard shell) để stream sống suốt
/// vòng đời app.
final connectivityWatcherProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  bool isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  // Provider có thể bị dispose trước khi checkConnectivity() trả về —
  // ghi state sau khi dispose sẽ ném lỗi.
  var disposed = false;
  ref.onDispose(() => disposed = true);

  // Đọc trạng thái ban đầu — stream chỉ phát khi CÓ thay đổi.
  unawaited(
    connectivity
        .checkConnectivity()
        .then((results) {
          if (disposed) return;
          ref.read(offlineProvider.notifier).state = isOffline(results);
        })
        .catchError((_) {
          // Nền tảng không hỗ trợ → coi như online, để repository tự phát hiện.
        }),
  );

  return connectivity.onConnectivityChanged.map((results) {
    final offline = isOffline(results);
    ref.read(offlineProvider.notifier).state = offline;
    return offline;
  });
});
