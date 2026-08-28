import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Người được gán mang món đồ (subset của User).
class PackingAssignee {
  final String id;
  final String name;
  final String? avatarUrl;

  const PackingAssignee({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory PackingAssignee.fromJson(Map<String, dynamic> j) => PackingAssignee(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    avatarUrl: j['avatarUrl'] as String?,
  );
}

/// Một món đồ trong packing list — BE `packing` module.
class PackingItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final bool isPacked;
  final PackingAssignee? assignee;

  const PackingItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isPacked = false,
    this.assignee,
  });

  factory PackingItem.fromJson(Map<String, dynamic> j) => PackingItem(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    category: j['category'] as String? ?? 'OTHER',
    quantity: (j['quantity'] as num?)?.toInt() ?? 1,
    isPacked: j['isPacked'] as bool? ?? false,
    assignee: j['assignee'] is Map
        ? PackingAssignee.fromJson(
            (j['assignee'] as Map).cast<String, dynamic>(),
          )
        : null,
  );

  PackingItem copyWith({bool? isPacked}) => PackingItem(
    id: id,
    name: name,
    category: category,
    quantity: quantity,
    isPacked: isPacked ?? this.isPacked,
    assignee: assignee,
  );
}

/// Kết quả list kèm tiến độ (BE trả `{ items, progress }`).
class PackingList {
  final List<PackingItem> items;
  final int total;
  final int packed;
  final int percent;

  const PackingList({
    this.items = const [],
    this.total = 0,
    this.packed = 0,
    this.percent = 0,
  });

  factory PackingList.fromJson(Map<String, dynamic> j) {
    final rawItems = j['items'];
    final progress = j['progress'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => PackingItem.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <PackingItem>[];
    return PackingList(
      items: items,
      total: (progress is Map ? progress['total'] as num? : null)?.toInt() ??
          items.length,
      packed: (progress is Map ? progress['packed'] as num? : null)?.toInt() ??
          items.where((i) => i.isPacked).length,
      percent:
          (progress is Map ? progress['percent'] as num? : null)?.toInt() ?? 0,
    );
  }
}

/// Repository cho Packing List — `/trips/:tripId/packing`.
class PackingRepository {
  final ApiClient _client;
  PackingRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/packing';

  Future<PackingList> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is Map) {
      return PackingList.fromJson(data.cast<String, dynamic>());
    }
    return const PackingList();
  }

  Future<void> add(
    String tripId, {
    required String name,
    String category = 'OTHER',
    int quantity = 1,
    String? assignedTo,
  }) async {
    await _client.postData(_base(tripId), {
      'name': name,
      'category': category,
      'quantity': quantity,
      'assignedTo': ?assignedTo,
    });
  }

  Future<void> togglePacked(String tripId, String itemId, bool isPacked) =>
      _client.patchData('${_base(tripId)}/$itemId', {'isPacked': isPacked});

  Future<void> assign(String tripId, String itemId, String? assignedTo) =>
      _client.patchData('${_base(tripId)}/$itemId', {'assignedTo': assignedTo});

  Future<void> remove(String tripId, String itemId) =>
      _client.deleteData('${_base(tripId)}/$itemId');

  Future<void> applyTemplate(String tripId, String template) =>
      _client.postData('${_base(tripId)}/template', {'template': template});
}

final packingRepositoryProvider = Provider<PackingRepository>((ref) {
  return PackingRepository(ref.watch(apiClientProvider));
});
