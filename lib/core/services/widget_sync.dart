import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../network/api_client.dart';

/// Một mục hiển thị trên widget màn hình chính.
class WidgetMoment {
  final String id;
  final String imageUrl;
  final String authorName;
  final String tripName;
  final String? caption;
  final bool isMine;
  final DateTime? createdAt;

  const WidgetMoment({
    required this.id,
    required this.imageUrl,
    required this.authorName,
    required this.tripName,
    this.caption,
    this.isMine = false,
    this.createdAt,
  });

  factory WidgetMoment.fromJson(Map<String, dynamic> j) => WidgetMoment(
    id: j['id'] as String? ?? '',
    imageUrl: j['imageUrl'] as String? ?? '',
    authorName: j['authorName'] as String? ?? '',
    tripName: j['tripName'] as String? ?? '',
    caption: j['caption'] as String?,
    isMine: j['isMine'] as bool? ?? false,
    createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'authorName': authorName,
    'tripName': tripName,
    'caption': caption,
    'isMine': isMine,
    'createdAt': createdAt?.toIso8601String(),
  };
}

/// Đẩy khoảnh khắc mới nhất của squad ra widget màn hình chính.
///
/// Đây là mảnh làm nên Locket: ảnh bạn gửi hiện ngay giữa các icon trên máy bạn
/// bè, **không cần mở app**. Vòng lặp trở thành: gửi → thấy trên home → gửi lại.
///
/// Flutter chỉ ghi dữ liệu vào vùng nhớ chung; phần vẽ do từng nền tảng lo:
///   * Android — `AppWidgetProvider` đọc SharedPreferences
///   * iOS — WidgetKit đọc UserDefaults của App Group
class WidgetSync {
  final ApiClient _client;
  WidgetSync(this._client);

  /// Tên nhóm widget phải khớp với khai báo ở hai nền tảng.
  static const String androidWidgetName = 'TripMateWidgetProvider';
  static const String iOSWidgetName = 'TripMateWidget';

  /// App Group của iOS — widget và app dùng chung vùng lưu này.
  static const String appGroupId = 'group.com.tripmate.app';

  /// Khoá dữ liệu, dùng chung cho cả hai nền tảng.
  static const String keyLatestJson = 'tm_latest_moment';
  static const String keyFeedJson = 'tm_feed';
  static const String keyUpdatedAt = 'tm_updated_at';

  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await HomeWidget.setAppGroupId(appGroupId);
    _configured = true;
  }

  /// Tải feed mới nhất rồi ghi sang widget.
  ///
  /// Nuốt lỗi có chủ đích: widget là thứ phụ trợ, hỏng thì không được làm hỏng
  /// hành động chính (vừa gửi ảnh xong chẳng hạn).
  Future<void> refresh() async {
    try {
      await _ensureConfigured();
      final data = await _client.getData('/users/me/widget-feed');
      final items =
          ((data as Map?)?['items'] as List?)
              ?.whereType<Map>()
              .map((e) => WidgetMoment.fromJson(e.cast<String, dynamic>()))
              .toList() ??
          const <WidgetMoment>[];

      await HomeWidget.saveWidgetData<String>(
        keyLatestJson,
        items.isEmpty ? '' : jsonEncode(items.first.toJson()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyFeedJson,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyUpdatedAt,
        DateTime.now().toIso8601String(),
      );

      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Cập nhật widget thất bại: $e');
    }
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
    } catch (e) {
      debugPrint('Xoá dữ liệu widget thất bại: $e');
    }
  }
}

final widgetSyncProvider = Provider<WidgetSync>(
  (ref) => WidgetSync(ref.watch(apiClientProvider)),
);
