import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/moment.dart';

/// Repository cho Moments — `/trips/:tripId/moments`.
/// Tích hợp 2 tầng Local Snapshot Cache (L1 RAM + L2 SharedPreferences)
/// kết hợp với Shared Redis Board Cache ở Backend để bảng kỷ niệm mở tức thì.
class MomentsRepository {
  final ApiClient _client;
  MomentsRepository(this._client);

  static final Map<String, List<Moment>> _l1SnapshotCache =
      <String, List<Moment>>{};

  static String _prefsKey(String tripId) => 'board_snapshot_v1_$tripId';

  String _base(String tripId) => '/trips/$tripId/moments';

  /// Đọc nhanh snapshot đã lưu trong RAM hoặc SharedPreferences (nếu có).
  static List<Moment>? peekMemorySnapshot(String tripId) {
    final hit = _l1SnapshotCache[tripId];
    return hit != null ? List<Moment>.unmodifiable(hit) : null;
  }

  Future<List<Moment>?> loadCachedSnapshot(String tripId) async {
    final l1 = _l1SnapshotCache[tripId];
    if (l1 != null && l1.isNotEmpty) {
      return List<Moment>.from(l1);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey(tripId));
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final list = decoded
            .whereType<Map>()
            .map((e) => Moment.fromJson(e.cast<String, dynamic>()))
            .toList();
        _l1SnapshotCache[tripId] = list;
        return List<Moment>.from(list);
      }
    } catch (_) {
      // Ignore corrupt local cache
    }
    return null;
  }

  Future<void> _saveSnapshot(
    String tripId,
    List<Moment> moments, {
    List<Map<String, dynamic>>? rawJsonList,
  }) async {
    _l1SnapshotCache[tripId] = List<Moment>.from(moments);
    if (rawJsonList != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey(tripId), jsonEncode(rawJsonList));
      } catch (_) {
        // Ignore storage write errors in restricted environments
      }
    }
  }

  Future<List<Moment>> fetch(String tripId) async {
    try {
      final data = await _client.getData(_base(tripId));
      if (data is List) {
        final rawMaps = data
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        final list = rawMaps.map(Moment.fromJson).toList();
        await _saveSnapshot(tripId, list, rawJsonList: rawMaps);
        return list;
      }
      return const [];
    } catch (e) {
      final cached = await loadCachedSnapshot(tripId);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<({List<Moment> items, String? nextCursor})> gallery(
    String tripId, {
    String? cursor,
  }) async {
    try {
      final data =
          await _client.getData(
                '${_base(tripId)}/gallery',
                query: {'cursor': ?cursor},
              )
              as Map;
      final items = (data['items'] as List)
          .whereType<Map>()
          .map((item) => Moment.fromJson(item.cast<String, dynamic>()))
          .toList();
      return (items: items, nextCursor: data['nextCursor'] as String?);
    } on ApiException catch (error) {
      if (cursor != null || ![400, 404].contains(error.statusCode)) rethrow;
      // The previous server routes /gallery through its moment-details route.
      final data = await _client.getData(_base(tripId)) as List;
      final items = data
          .whereType<Map>()
          .map((item) => Moment.fromJson(item.cast<String, dynamic>()))
          .toList();
      return (items: items, nextCursor: null);
    }
  }

  /// Kỷ niệm mới nhất trên MỌI chuyến của user — dùng cho scrapbook màn Home.
  Future<List<RecentMoment>> fetchRecent() async {
    final data = await _client.getData('/users/me/moments/recent');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => RecentMoment.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<void> react(String tripId, String momentId, String emoji) => _client
      .postData('${_base(tripId)}/$momentId/reactions', {'emoji': emoji});

  Future<MomentComment?> comment(
    String tripId,
    String momentId,
    String text,
  ) async {
    final res = await _client.postData('${_base(tripId)}/$momentId/comments', {
      'content': text,
    });
    if (res is Map) {
      return MomentComment.fromJson(res.cast<String, dynamic>());
    }
    return null;
  }

  /// Đặt lại caption cho khoảnh khắc (chỉ tác giả sửa được).
  Future<void> updateCaption(String tripId, String momentId, String caption) =>
      _client.patchData('${_base(tripId)}/$momentId', {'caption': caption});

  /// Cập nhật vị trí, góc xoay, bộ lọc màu, ghim hoặc yêu thích trên Shared Memory Photo Board.
  Future<Moment?> updateBoardLayout(
    String tripId,
    String momentId, {
    double? boardX,
    double? boardY,
    double? boardRotation,
    double? boardScale,
    String? boardFilter,
    String? noteColor,
    bool? isPinned,
    bool? isFavorite,
    String? caption,
  }) async {
    final payload = <String, dynamic>{
      'boardX': ?boardX,
      'boardY': ?boardY,
      'boardRotation': ?boardRotation,
      'boardScale': ?boardScale,
      'boardFilter': ?boardFilter,
      'noteColor': ?noteColor,
      'isPinned': ?isPinned,
      'isFavorite': ?isFavorite,
      'caption': ?caption,
    };
    final res = await _client.patchData(
      '${_base(tripId)}/$momentId/layout',
      payload,
    );
    if (res is Map) {
      final updated = Moment.fromJson(res.cast<String, dynamic>());
      final existing = _l1SnapshotCache[tripId];
      if (existing != null) {
        final idx = existing.indexWhere((m) => m.id == momentId);
        if (idx != -1) {
          existing[idx] = updated;
        }
      }
      return updated;
    }
    return null;
  }

  /// Bật/tắt yêu thích trên bảng ảnh kỷ niệm.
  Future<void> setFavorite(
    String tripId,
    String momentId,
    bool isFavorite,
  ) async {
    try {
      await _client.putData('${_base(tripId)}/$momentId/favorite', {
        'isFavorite': isFavorite,
      });
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      await updateBoardLayout(tripId, momentId, isFavorite: isFavorite);
    }
  }

  /// Ghost Cam: bao nhiêu ảnh đang chờ tráng và tráng lúc nào.
  Future<GhostStatus> developing(String tripId) async {
    final data = await _client.getData('${_base(tripId)}/developing');
    return GhostStatus.fromJson(
      data is Map ? data.cast<String, dynamic>() : const {},
    );
  }

  Future<void> delete(String tripId, String momentId) async {
    await _client.deleteData('${_base(tripId)}/$momentId');
    _l1SnapshotCache[tripId]?.removeWhere((m) => m.id == momentId);
  }

  /// Tạo khoảnh khắc mới.
  ///
  /// KHÔNG gửi `placeName`: DTO của backend bật whitelist nên trường lạ làm cả
  /// request bị từ chối 400, kể cả khi giá trị là null. Bảng `moments` cũng
  /// không có cột này — vị trí lưu ở `latitude`/`longitude`.
  Future<Moment> create({
    required String tripId,
    required String mediaUrl,
    required String type,
    String? caption,
    double? latitude,
    double? longitude,
    bool isGhost = false,
    double? boardX,
    double? boardY,
    double? boardRotation,
    String? boardFilter,
    String? noteColor,
    bool? isPinned,
    bool? isFavorite,
  }) async {
    final res = await _client.postData(_base(tripId), {
      'mediaUrl': mediaUrl,
      'type': type,
      // Chỉ gửi trường CÓ giá trị: whitelist của BE từ chối trường lạ, và gửi
      // null vô ích chỉ làm payload to thêm.
      'caption': ?caption,
      'latitude': ?latitude,
      'longitude': ?longitude,
      if (isGhost) 'isGhost': true,
      'boardX': ?boardX,
      'boardY': ?boardY,
      'boardRotation': ?boardRotation,
      'boardFilter': ?boardFilter,
      'noteColor': ?noteColor,
      'isPinned': ?isPinned,
      'isFavorite': ?isFavorite,
    });
    final created = Moment.fromJson(res as Map<String, dynamic>);
    final existing = _l1SnapshotCache[tripId];
    if (existing != null) {
      _l1SnapshotCache[tripId] = [created, ...existing];
    }
    return created;
  }
}

final momentsRepositoryProvider = Provider<MomentsRepository>((ref) {
  return MomentsRepository(ref.watch(apiClientProvider));
});

final tripMomentsProvider = FutureProvider.family<List<Moment>, String>((
  ref,
  tripId,
) async {
  return ref.watch(momentsRepositoryProvider).fetch(tripId);
});

/// Trạng thái Ghost Cam của một chuyến.
class GhostStatus {
  final int total;
  final int mine;
  final DateTime? revealAt;
  final bool revealed;

  const GhostStatus({
    this.total = 0,
    this.mine = 0,
    this.revealAt,
    this.revealed = true,
  });

  /// Số ảnh của người khác đang chờ — người xem chưa thấy được.
  int get hidden => total - mine;

  factory GhostStatus.fromJson(Map<String, dynamic> j) => GhostStatus(
    total: j['total'] as int? ?? 0,
    mine: j['mine'] as int? ?? 0,
    revealAt: DateTime.tryParse(j['revealAt']?.toString() ?? '')?.toLocal(),
    revealed: j['revealed'] as bool? ?? true,
  );
}

final ghostStatusProvider = FutureProvider.autoDispose
    .family<GhostStatus, String>((ref, tripId) {
      return ref.watch(momentsRepositoryProvider).developing(tripId);
    });

/// Kỷ niệm rút gọn cho scrapbook màn Home (gộp từ nhiều chuyến).
class RecentMoment {
  final String id;
  final String tripId;
  final String tripName;
  final String mediaUrl;

  /// Anh bia — voi VIDEO day la frame dau (.jpg) do backend suy ra.
  final String posterUrl;
  final String type;
  final String? caption;
  final String authorName;
  final String location;

  const RecentMoment({
    required this.id,
    required this.tripId,
    required this.tripName,
    required this.mediaUrl,
    required this.posterUrl,
    this.type = 'PHOTO',
    this.caption,
    required this.authorName,
    required this.location,
  });

  factory RecentMoment.fromJson(Map<String, dynamic> j) => RecentMoment(
    id: j['id'] as String? ?? '',
    tripId: j['tripId'] as String? ?? '',
    tripName: j['tripName'] as String? ?? '',
    mediaUrl: j['mediaUrl'] as String? ?? '',
    posterUrl: j['posterUrl'] as String? ?? j['mediaUrl'] as String? ?? '',
    type: j['type'] as String? ?? 'PHOTO',
    caption: j['caption'] as String?,
    authorName: j['authorName'] as String? ?? '',
    location: j['location'] as String? ?? '',
  );

  /// Tiêu đề hiển thị trên tấm polaroid.
  bool get isVideo => type == 'VIDEO';

  String get title =>
      (caption?.trim().isNotEmpty ?? false) ? caption!.trim() : tripName;
}

/// Provider cho scrapbook màn Home.
final recentMomentsProvider = FutureProvider<List<RecentMoment>>((ref) {
  return ref.watch(momentsRepositoryProvider).fetchRecent();
});
