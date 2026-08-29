import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class TodoAssignee {
  final String id;
  final String name;
  final String? avatarUrl;
  const TodoAssignee({required this.id, required this.name, this.avatarUrl});
  factory TodoAssignee.fromJson(Map<String, dynamic> j) => TodoAssignee(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    avatarUrl: j['avatarUrl'] as String?,
  );
}

class TodoItem {
  final String id;
  final String title;
  final String priority; // LOW / NORMAL / HIGH
  final bool isDone;
  final DateTime? dueDate;
  final TodoAssignee? assignee;

  const TodoItem({
    required this.id,
    required this.title,
    this.priority = 'NORMAL',
    this.isDone = false,
    this.dueDate,
    this.assignee,
  });

  factory TodoItem.fromJson(Map<String, dynamic> j) => TodoItem(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    priority: j['priority'] as String? ?? 'NORMAL',
    isDone: j['isDone'] as bool? ?? false,
    dueDate: DateTime.tryParse(j['dueDate']?.toString() ?? ''),
    assignee: j['assignee'] is Map
        ? TodoAssignee.fromJson((j['assignee'] as Map).cast<String, dynamic>())
        : null,
  );

  TodoItem copyWith({bool? isDone}) => TodoItem(
    id: id,
    title: title,
    priority: priority,
    isDone: isDone ?? this.isDone,
    dueDate: dueDate,
    assignee: assignee,
  );
}

class TodoList {
  final List<TodoItem> items;
  final int total;
  final int done;
  final int percent;
  const TodoList({
    this.items = const [],
    this.total = 0,
    this.done = 0,
    this.percent = 0,
  });

  factory TodoList.fromJson(Map<String, dynamic> j) {
    final raw = j['items'];
    final p = j['progress'];
    final items = raw is List
        ? raw
              .whereType<Map>()
              .map((e) => TodoItem.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <TodoItem>[];
    return TodoList(
      items: items,
      total: (p is Map ? p['total'] as num? : null)?.toInt() ?? items.length,
      done:
          (p is Map ? p['done'] as num? : null)?.toInt() ??
          items.where((i) => i.isDone).length,
      percent: (p is Map ? p['percent'] as num? : null)?.toInt() ?? 0,
    );
  }
}

class TodosRepository {
  final ApiClient _client;
  TodosRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/todos';

  Future<TodoList> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is Map) return TodoList.fromJson(data.cast<String, dynamic>());
    return const TodoList();
  }

  Future<void> add(
    String tripId, {
    required String title,
    String priority = 'NORMAL',
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'priority': priority,
      'assignedTo': ?assignedTo,
      if (dueDate != null) 'dueDate': dueDate.toUtc().toIso8601String(),
    };
    await _client.postData(_base(tripId), body);
  }

  Future<void> toggleDone(String tripId, String itemId, bool isDone) =>
      _client.patchData('${_base(tripId)}/$itemId', {'isDone': isDone});

  Future<void> assign(String tripId, String itemId, String? assignedTo) =>
      _client.patchData('${_base(tripId)}/$itemId', {'assignedTo': assignedTo});

  Future<void> remove(String tripId, String itemId) =>
      _client.deleteData('${_base(tripId)}/$itemId');
}

final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepository(ref.watch(apiClientProvider));
});
