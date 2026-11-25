import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../network/api_client.dart';
import 'widget_pin.dart';

/// Một mục hiển thị trên widget màn hình chính.
class WidgetMoment {
  final String id;

  /// Cần cho việc thả cảm xúc: endpoint reaction nằm dưới trip
  /// (`/trips/:tripId/moments/:id/reactions`). Backend vẫn luôn trả trường này
  /// trong `widget-feed`, trước đây client chỉ bỏ qua nó.
  final String tripId;
  final String imageUrl;
  final String authorName;
  final String tripName;
  final String? caption;
  final bool isMine;
  final DateTime? createdAt;

  const WidgetMoment({
    required this.id,
    required this.tripId,
    required this.imageUrl,
    required this.authorName,
    required this.tripName,
    this.caption,
    this.isMine = false,
    this.createdAt,
  });

  factory WidgetMoment.fromJson(Map<String, dynamic> j) => WidgetMoment(
    id: j['id'] as String? ?? '',
    tripId: j['tripId'] as String? ?? '',
    imageUrl: (j['imageUrl'] ?? j['mediaUrl']) as String? ?? '',
    authorName: j['authorName'] as String? ?? '',
    tripName: j['tripName'] as String? ?? '',
    caption: j['caption'] as String?,
    isMine: j['isMine'] as bool? ?? false,
    createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'imageUrl': imageUrl,
    'authorName': authorName,
    'tripName': tripName,
    'caption': caption,
    'isMine': isMine,
    'createdAt': createdAt?.toIso8601String(),
  };
}

/// Đẩy khoảnh khắc mới nhất của squad ra widget màn hình chính (Flutter -> Native).
///
/// Đây là mảnh làm nên Locket: ảnh bạn gửi hiện ngay giữa các icon trên máy bạn
/// bè, **không cần mở app**. Vòng lặp trở thành: gửi → thấy trên home → gửi lại.
///
/// Flutter ghi dữ liệu vào vùng nhớ chung qua `home_widget` và `WidgetPin`;
/// phần vẽ ngoài màn hình khóa/chính do từng hệ điều hành đảm nhận:
///   * Android — `AppWidgetProvider` đọc SharedPreferences
///   * iOS — WidgetKit đọc UserDefaults của App Group
class WidgetSync {
  final ApiClient _client;
  WidgetSync(this._client);

  /// Tên nhóm widget phải khớp với khai báo ở hai nền tảng.
  static const String androidWidgetName = 'TripMateWidgetProvider';
  static const String iOSWidgetName = 'TripMateWidget';

  /// App Group mặc định của iOS — widget và app dùng chung vùng lưu này.
  static const String appGroupId = 'group.com.tripmate.app';

  /// Khoá dữ liệu, dùng chung cho cả hai nền tảng.
  static const String keyLatestJson = 'tm_latest_moment';
  static const String keyFeedJson = 'tm_feed';
  static const String keyUpdatedAt = 'tm_updated_at';

  bool _configured = false;
  String? _inMemoryFeedJson;

  static bool get _isFlutterTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> _ensureConfigured() async {
    if (_configured || _isFlutterTest) {
      _configured = true;
      return;
    }
    try {
      final groups = await WidgetPin.getIosAppGroups();
      final primaryGroup = groups.isNotEmpty ? groups.first : appGroupId;
      await HomeWidget.setAppGroupId(primaryGroup).timeout(
        const Duration(milliseconds: 600),
        onTimeout: () => false,
      );
      _configured = true;
    } catch (_) {
      // Safe fallback in widget tests where MethodChannel is mocked/absent.
      _configured = true;
    }
  }

  /// Tải feed mới nhất từ API rồi ghi sang widget (có hỗ trợ `fallbackItems`
  /// từ chuyến đi hiện tại nếu `/users/me/widget-feed` chưa có dữ liệu).
  Future<List<WidgetMoment>> refresh({
    List<WidgetMoment>? fallbackItems,
  }) async {
    try {
      await _ensureConfigured();
      List<WidgetMoment> items = const <WidgetMoment>[];
      try {
        final data = await _client.getData('/users/me/widget-feed');
        items =
            ((data as Map?)?['items'] as List?)
                ?.whereType<Map>()
                .map((e) => WidgetMoment.fromJson(e.cast<String, dynamic>()))
                .toList() ??
            const <WidgetMoment>[];
      } catch (e) {
        debugPrint('Widget feed API fallback: $e');
      }

      if (items.isEmpty && fallbackItems != null && fallbackItems.isNotEmpty) {
        items = fallbackItems;
      }

      await syncItems(items);
      return items;
    } catch (e) {
      debugPrint('Cập nhật widget thất bại: $e');
      return fallbackItems ?? const <WidgetMoment>[];
    }
  }

  /// Ghi trực tiếp danh sách [WidgetMoment] từ Flutter xuống Widget của cả
  /// Android (`HomeWidget`) và iOS (`HomeWidget` + multi-AppGroup `WidgetPin`).
  Future<void> syncItems(List<WidgetMoment> items) async {
    try {
      await _ensureConfigured();
      final latestJson = items.isEmpty ? '' : jsonEncode(items.first.toJson());
      final feedJson = jsonEncode(items.map((e) => e.toJson()).toList());
      final updatedAt = DateTime.now().toIso8601String();
      _inMemoryFeedJson = feedJson;
      if (_isFlutterTest) return;

      final imageUrls = items
          .take(3)
          .map((e) => e.imageUrl.trim())
          .where((u) => u.isNotEmpty)
          .toList();

      const timeout = Duration(milliseconds: 600);
      await HomeWidget.saveWidgetData<String>(keyLatestJson, latestJson)
          .timeout(timeout, onTimeout: () => false);
      await HomeWidget.saveWidgetData<String>(keyFeedJson, feedJson)
          .timeout(timeout, onTimeout: () => false);
      await HomeWidget.saveWidgetData<String>(keyUpdatedAt, updatedAt)
          .timeout(timeout, onTimeout: () => false);

      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      ).timeout(timeout, onTimeout: () => false);

      // Đồng bộ thêm qua cầu nối iOS để ghi vào mọi App Group (bao gồm cả
      // ALTAppGroups khi cài qua iloader-cli) và tải trước ảnh thumbnail.
      await WidgetPin.syncNativeIosWidget(
        latestJson: latestJson,
        feedJson: feedJson,
        updatedAt: updatedAt,
        imageUrls: imageUrls,
      );
    } catch (e) {
      debugPrint('Widget syncItems failed: $e');
    }
  }

  /// Đọc lại feed đã lưu cho widget.
  ///
  /// Màn xem khoảnh khắc mở từ widget dùng **đúng dữ liệu widget đang hiện**,
  /// không gọi lại mạng: người dùng vừa nhìn thấy tấm nào thì mở ra phải là
  /// tấm đó. Rỗng thì mới lấy từ server.
  Future<List<WidgetMoment>> loadFeed() async {
    await _ensureConfigured();
    if (_inMemoryFeedJson != null) {
      final parsed = _decodeFeed(_inMemoryFeedJson);
      if (parsed.isNotEmpty) return parsed;
    }
    if (!_isFlutterTest) {
      try {
        final raw = await HomeWidget.getWidgetData<String>(keyFeedJson);
        final parsed = _decodeFeed(raw);
        if (parsed.isNotEmpty) return parsed;
      } catch (_) {}
    }

    return refresh();
  }

  List<WidgetMoment> _decodeFeed(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => WidgetMoment.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Xoá dữ liệu widget khi đăng xuất — không để ảnh của squad cũ nằm lại trên
  /// màn hình chính của người dùng tiếp theo.
  Future<void> clear() async {
    try {
      await _ensureConfigured();
      await HomeWidget.saveWidgetData<String>(keyLatestJson, '');
      await HomeWidget.saveWidgetData<String>(keyFeedJson, '[]');
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
      await WidgetPin.clearNativeIosWidget();
    } catch (e) {
      debugPrint('Widget clear failed: $e');
    }
  }
}

final widgetSyncProvider = Provider<WidgetSync>(
  (ref) => WidgetSync(ref.watch(apiClientProvider)),
);
