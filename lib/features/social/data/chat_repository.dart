import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/chat_message.dart';

/// Repository cho Chat — `/trips/:tripId/chat`.
class ChatRepository {
  final ApiClient _client;
  ChatRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/chat';

  /// Lấy lịch sử (cursor pagination). BE trả desc (mới→cũ); ta đảo về tăng dần
  /// (cũ→mới) để hiển thị đúng thứ tự chat. `cursor` = id tin nhắn cũ nhất đang có.
  Future<List<ChatMessage>> fetch(
    String tripId, {
    String? cursor,
    int limit = 30,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      'cursor': ?cursor,
    };
    final data = await _client.getData(
      _base(tripId),
      query: query,
    );
    if (data is List) {
      final list = data
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(e.cast<String, dynamic>()))
          .toList();
      return list.reversed.toList(); // desc → asc
    }
    return const [];
  }

  Future<ChatMessage> send(String tripId, String content) async {
    final data = await _client.postData(_base(tripId), {
      'content': content,
      'type': 'TEXT',
    });
    return ChatMessage.fromJson((data as Map).cast<String, dynamic>());
  }

  /// Gửi một sticker đã sở hữu. BE từ chối 403 nếu chưa mua.
  Future<ChatMessage> sendSticker(String tripId, String stickerId) async {
    final data = await _client.postData(_base(tripId), {
      'content': stickerId,
      'type': 'STICKER',
    });
    return ChatMessage.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> react(String tripId, String messageId, String emoji) => _client
      .postData('${_base(tripId)}/$messageId/reactions', {'emoji': emoji});
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

final tripChatProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  tripId,
) async {
  return ref.watch(chatRepositoryProvider).fetch(tripId);
});
