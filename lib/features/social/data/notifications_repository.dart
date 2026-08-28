import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Notification rút gọn.
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'] as String,
    type: j['type'] as String? ?? 'GENERAL',
    title: j['title'] as String? ?? '',
    body: j['body'] as String? ?? '',
    isRead: j['isRead'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

/// Repository cho Notifications — `/notifications` (không nested theo trip).
class NotificationsRepository {
  final ApiClient _client;
  NotificationsRepository(this._client);

  Future<List<AppNotification>> fetch() async {
    final data = await _client.getData('/notifications');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<void> markRead(String id) =>
      _client.patchData('/notifications/$id/read');

  Future<void> markAllRead() => _client.patchData('/notifications/read-all');
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(ref.watch(apiClientProvider));
});

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  return ref.watch(notificationsRepositoryProvider).fetch();
});

final unreadCountProvider = Provider<int>((ref) {
  final async = ref.watch(notificationsProvider);
  return async.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
