import 'package:easy_localization/easy_localization.dart';
// Model ChatMessage — khớp BE `chat` module.
class ChatMessage {
  final String id;
  final String? content;
  final String? mediaUrl;
  final String type;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    this.content,
    this.mediaUrl,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    final sender = j['sender'];
    return ChatMessage(
      id: j['id'] as String,
      content: j['content'] as String?,
      mediaUrl: j['mediaUrl'] as String?,
      type: j['type'] as String? ?? 'TEXT',
      senderId:
          j['senderId'] as String? ??
          (sender is Map ? sender['id'] as String? ?? '' : ''),
      senderName: sender is Map
          ? (sender['name'] as String? ?? 'common.anonymous'.tr())
          : 'common.anonymous'.tr(),
      senderAvatar: sender is Map ? sender['avatarUrl'] as String? : null,
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
