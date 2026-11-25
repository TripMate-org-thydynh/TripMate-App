import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Sticker cá nhân — người dùng tự làm từ ảnh của mình (`/xp/stickers/custom`).
class CustomSticker {
  final String id;
  final String mediaUrl;
  final String? label;

  const CustomSticker({required this.id, required this.mediaUrl, this.label});

  /// Nội dung tin nhắn khi gửi sticker này — BE tự tra ra ảnh.
  String get wire => 'custom:$id';

  factory CustomSticker.fromJson(Map<String, dynamic> j) => CustomSticker(
    id: j['id'] as String,
    mediaUrl: j['mediaUrl'] as String? ?? '',
    label: j['label'] as String?,
  );
}

class CustomStickersRepository {
  final ApiClient _client;
  CustomStickersRepository(this._client);

  static const _base = '/xp/stickers/custom';

  Future<List<CustomSticker>> fetch() async {
    final data = await _client.getData(_base);
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => CustomSticker.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<CustomSticker> create(String mediaUrl, {String? label}) async {
    final res = await _client.postData(_base, {
      'mediaUrl': mediaUrl,
      'label': ?label,
    });
    return CustomSticker.fromJson((res as Map).cast<String, dynamic>());
  }

  Future<void> delete(String id) => _client.deleteData('$_base/$id');
}

final customStickersRepositoryProvider = Provider<CustomStickersRepository>(
  (ref) => CustomStickersRepository(ref.watch(apiClientProvider)),
);

final customStickersProvider = FutureProvider.autoDispose<List<CustomSticker>>(
  (ref) => ref.watch(customStickersRepositoryProvider).fetch(),
);
