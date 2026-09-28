import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../app_messenger.dart';
import '../network/api_client.dart';

/// Thông báo đẩy qua FCM — để bản tin sáng đánh thức được điện thoại khi app
/// đang đóng.
///
/// Chưa có `google-services.json` thì Firebase không khởi động được và lớp này
/// **tự tắt**: không ném lỗi, app chạy bình thường, thông báo vẫn có trong
/// chuông thông báo trong app — chỉ là không đẩy lên máy.
class PushNotifications {
  PushNotifications._();

  static bool _available = false;
  static StreamSubscription<String>? _refreshSub;

  /// Xong khi `init` chạy xong (dù bật hay tắt). `register` chờ cái này:
  /// khôi phục phiên đăng nhập thường nhanh hơn `Firebase.initializeApp`, nếu
  /// không chờ thì `register` thấy "chưa bật" và bỏ qua vĩnh viễn.
  static final Completer<void> _ready = Completer<void>();

  /// Có dùng được FCM không (đã cấu hình Firebase và khởi động thành công).
  static bool get available => _available;

  /// Gọi một lần lúc mở app. Không bao giờ ném lỗi.
  static Future<void> init({required void Function() onOpen}) async {
    try {
      await _init(onOpen);
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  static Future<void> _init(void Function() onOpen) async {
    if (kIsWeb) return; // Web cần cấu hình VAPID riêng — chưa làm.
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      debugPrint('Push tắt: chưa cấu hình Firebase ($e)');
      return;
    }

    // Bấm vào thông báo khi app đang chạy nền.
    FirebaseMessaging.onMessageOpenedApp.listen((_) => onOpen());
    // Bấm vào thông báo làm app mở từ trạng thái tắt hẳn.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) onOpen();

    // Android không tự hiện thông báo khi app đang mở: báo bằng snack.
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null) return;
      showGlobalSnack([n.title, n.body].whereType<String>().join(' · '));
    });
  }

  /// Gửi token của máy lên server. Gọi sau khi đăng nhập.
  static Future<void> register(ApiClient api) async {
    await _ready.future;
    if (!_available) return;
    try {
      final fm = FirebaseMessaging.instance;
      final perm = await fm.requestPermission();
      if (perm.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await fm.getToken();
      if (token != null) await _send(api, token);

      // FCM thay token định kỳ; không cập nhật thì thông báo rơi vào hư vô.
      await _refreshSub?.cancel();
      _refreshSub = fm.onTokenRefresh.listen((t) => _send(api, t));
    } catch (e) {
      debugPrint('Không đăng ký được push: $e');
    }
  }

  /// Gọi khi đăng xuất.
  ///
  /// Lúc này token đăng nhập đã bị xoá nên không gọi API gỡ được. Thay vào đó
  /// huỷ token ngay tại FCM: lần gửi sau FCM báo token chết và server tự gỡ.
  /// Nhờ vậy máy đã đăng xuất không tiếp tục nhận bản tin của người cũ.
  static Future<void> unregister() async {
    await _ready.future;
    if (!_available) return;
    try {
      await _refreshSub?.cancel();
      _refreshSub = null;
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Không huỷ được token push: $e');
    }
  }

  static Future<void> _send(ApiClient api, String token) async {
    try {
      await api.postData('/notifications/devices', {
        'token': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      });
    } catch (e) {
      debugPrint('Gửi token push lỗi: $e');
    }
  }
}
