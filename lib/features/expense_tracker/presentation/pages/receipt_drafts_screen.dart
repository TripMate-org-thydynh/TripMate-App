import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/capabilities_provider.dart';
import '../../../dashboard/data/home_feed_repository.dart';
import '../../../trips/application/trips_providers.dart';
import '../../application/expenses_providers.dart';
import '../../data/expenses_repository.dart';
import 'ai_receipt_scanner_screen.dart';

String _text(BuildContext context, String vi, String en) =>
    context.locale.languageCode == 'vi' ? vi : en;

String _vnd(BuildContext context, num amount) => NumberFormat.currency(
  locale: context.locale.languageCode,
  symbol: '₫',
  decimalDigits: 0,
).format(amount);

List<Map<String, dynamic>> _records(dynamic value) => (value as List? ?? [])
    .map((row) => (row as Map).cast<String, dynamic>())
    .toList();

class ReceiptDraftsScreen extends ConsumerStatefulWidget {
  const ReceiptDraftsScreen({
    super.key,
    required this.tripId,
    required this.isDarkMode,
    this.initialDraftId,
  });

  final String tripId;
  final bool isDarkMode;
  final String? initialDraftId;

  @override
  ConsumerState<ReceiptDraftsScreen> createState() =>
      _ReceiptDraftsScreenState();
}

class _ReceiptDraftsScreenState extends ConsumerState<ReceiptDraftsScreen> {
  late Future<List<Map<String, dynamic>>> _list;

  @override
  void initState() {
    super.initState();
    _list =
        widget.initialDraftId == null &&
            ref.read(capabilityProvider('receiptDrafts')).canRead
        ? _load()
        : Future.value([]);
  }

  Future<List<Map<String, dynamic>>> _load() =>
      ref.read(expensesRepositoryProvider).receiptDrafts(widget.tripId);

  Future<void> _open({String? id}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ReceiptScreen(
          tripId: widget.tripId,
          initialId: id,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
    if (mounted) setState(() => _list = _load());
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(capabilityProvider('receiptDrafts'));
    if (widget.initialDraftId != null && policy.canRead) {
      return _ReceiptScreen(
        initialId: widget.initialDraftId,
        tripId: widget.tripId,
        isDarkMode: widget.isDarkMode,
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('beta.billDrafts'.tr())),
      floatingActionButton: policy.canWrite
          ? FloatingActionButton.extended(
              onPressed: () => _open(),
              icon: const Icon(Icons.add),
              label: Text(_text(context, 'Tạo bill', 'New bill')),
            )
          : null,
      body: policy.canRead
          ? FutureBuilder(
              future: _list,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: TextButton.icon(
                      onPressed: () => setState(() => _list = _load()),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        _text(context, 'Tải lại bill', 'Reload bills'),
                      ),
                    ),
                  );
                }
                final drafts = snapshot.data ?? [];
                if (drafts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('beta.billDraftsInfo'.tr()),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: drafts.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final draft = drafts[index];
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(draft['title'] as String),
                      subtitle: Text(_vnd(context, draft['total'] as num)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _open(id: draft['id'] as String),
                    );
                  },
                );
              },
            )
          : Center(child: Text(policy.label(context))),
    );
  }
}

class _ReceiptScreen extends ConsumerStatefulWidget {
  const _ReceiptScreen({
    required this.tripId,
    required this.initialId,
    required this.isDarkMode,
  });

  final String tripId;
  final String? initialId;
  final bool isDarkMode;

  @override
  ConsumerState<_ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<_ReceiptScreen>
    with WidgetsBindingObserver {
  final _title = TextEditingController();
  final _total = TextEditingController();
  final _tax = TextEditingController();
  final _fee = TextEditingController();
  final _discount = TextEditingController();
  final List<Map<String, dynamic>> _localLines = [];
  final _pending = <String, Map<String, dynamic>>{};
  Timer? _refreshTimer;
  Map<String, dynamic>? _receipt;
  late String _requestId;
  bool _loading = false;
  bool _saving = false;
  bool _foreground = true;
  bool _checking = false;
  String? _error;

  ExpensesRepository get _repo => ref.read(expensesRepositoryProvider);
  String? get _id => _receipt?['id'] as String? ?? widget.initialId;
  String? get _userId => ref.read(authProvider).user?['id'] as String?;
  String? get _storageKey {
    final userId = _userId;
    return userId == null ? null : 'receipt_input_${userId}_${widget.tripId}';
  }

  String? get _pendingKey {
    final key = _storageKey;
    final id = _id;
    return key == null || id == null ? null : '${key}_assignments_$id';
  }

  String _uuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestId = _uuid();
    if (widget.initialId == null) {
      unawaited(_restoreInput());
    } else {
      unawaited(
        _restorePending().then((_) {
          if (mounted) unawaited(_refresh());
        }),
      );
    }
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        unawaited(_refresh());
      }
    });
  }

  Future<void> _restorePending() async {
    final key = _pendingKey;
    if (key == null) return;
    try {
      final saved = (await SharedPreferences.getInstance()).getString(key);
      if (!mounted || saved == null || _pending.isNotEmpty) return;
      final data = jsonDecode(saved) as Map;
      setState(() {
        for (final entry in data.entries) {
          _pending[entry.key as String] = Map<String, dynamic>.from(
            entry.value as Map,
          );
        }
      });
    } catch (_) {
      // The server copy is still available if the local queue is invalid.
    }
  }

  Future<void> _persistPending() async {
    if (!mounted) return;
    final key = _pendingKey;
    if (key == null) return;
    final payload = jsonEncode(_pending);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (payload == '{}') {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, payload);
      }
    } catch (_) {
      // Keep the queued edits in this screen when local storage is unavailable.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    for (final controller in [_title, _total, _tax, _fee, _discount]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _restoreInput() async {
    final key = _storageKey;
    if (key == null) return;
    final saved = (await SharedPreferences.getInstance()).getString(key);
    if (!mounted ||
        saved == null ||
        _title.text.isNotEmpty ||
        _localLines.isNotEmpty) {
      return;
    }
    final input = jsonDecode(saved) as Map;
    setState(() {
      _requestId = input['id'] as String;
      _title.text = input['title'] as String;
      _total.text = input['total'].toString();
      for (final field in {
        'tax': _tax,
        'fee': _fee,
        'discount': _discount,
      }.entries) {
        field.value.text = input[field.key].toString();
      }
      _localLines.addAll(_records(input['lines']));
    });
  }

  String _friendly(Object error) {
    if (error is ApiException) {
      if (error.isNetwork) {
        return _text(
          context,
          'Mất mạng. Dữ liệu đang hiển thị chưa được đồng bộ.',
          'Offline. The displayed data has not synced.',
        );
      }
      if (error.statusCode == 409) {
        return _text(
          context,
          'Bill đã thay đổi. Kiểm tra lại trước khi thử tiếp.',
          'The bill changed. Review it before trying again.',
        );
      }
      return error.message;
    }
    return 'errors.generic_soft'.tr();
  }

  Future<void> _refresh() async {
    final id = _id;
    if (!_foreground ||
        id == null ||
        _loading ||
        _saving ||
        _checking ||
        !ref.read(capabilityProvider('receiptDrafts')).canRead ||
        _receipt?['finalizedAt'] != null) {
      return;
    }
    _checking = true;
    if (_receipt == null) setState(() => _loading = true);
    try {
      final next = await _repo.receiptDraft(widget.tripId, id);
      if (mounted &&
          !_saving &&
          (next['version'] as int) >= (_receipt?['version'] as int? ?? -1)) {
        setState(() {
          _receipt = next;
          _error = null;
        });
        if (_pending.isNotEmpty) unawaited(_sendPending());
      }
    } catch (error) {
      if (mounted) setState(() => _error = _friendly(error));
    } finally {
      _checking = false;
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  Future<void> _write(
    Future<Map<String, dynamic>> Function() run, {
    bool finalize = false,
  }) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final next = await run();
      if (!mounted) return;
      setState(() => _receipt = next);
      if (finalize) {
        ref.invalidate(tripExpensesProvider(widget.tripId));
        ref.invalidate(tripBalancesProvider(widget.tripId));
        invalidateHomeAggregatesFrom(ref);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendly(error));
      if (error is ApiException && error.statusCode == 409 && _id != null) {
        try {
          final latest = await _repo.receiptDraft(widget.tripId, _id!);
          if (mounted) setState(() => _receipt = latest);
        } catch (_) {
          // Keep the last confirmed view and its error.
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AiReceiptScannerScreen(
          tripId: widget.tripId,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _title.text = result['description'] as String;
      _total.text = ((result['printedTotal'] ?? result['amount']) as num)
          .round()
          .toString();
      for (final input in {
        'tax': _tax,
        'fee': _fee,
        'discount': _discount,
      }.entries) {
        input.value.text = ((result[input.key] as num?)?.round().abs() ?? 0)
            .toString();
      }
      _localLines
        ..clear()
        ..addAll(_records(result['lines']));
    });
  }

  Future<void> _editLine({Map<String, dynamic>? existing, int? index}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _LineDialog(existing: existing),
    );
    if (!mounted || result == null) return;
    final id = _id;
    if (id != null) {
      if (existing != null) result['version'] = existing['version'];
      await _write(
        () => _repo.saveReceiptLine(
          widget.tripId,
          id,
          result,
          lineId: existing?['id'] as String?,
        ),
      );
    } else {
      setState(() {
        if (index == null) {
          _localLines.add(result);
        } else {
          _localLines[index] = result;
        }
      });
    }
  }

  Future<void> _create() async {
    final total = int.tryParse(_total.text);
    if (_title.text.trim().isEmpty ||
        total == null ||
        total <= 0 ||
        _localLines.isEmpty) {
      setState(
        () => _error = _text(
          context,
          'Nhập tên, tổng tiền và ít nhất một món.',
          'Enter a title, a total and at least one item.',
        ),
      );
      return;
    }
    final payload = <String, dynamic>{
      'id': _requestId,
      'title': _title.text.trim(),
      'total': total,
      'tax': int.tryParse(_tax.text) ?? 0,
      'fee': int.tryParse(_fee.text) ?? 0,
      'discount': int.tryParse(_discount.text) ?? 0,
      'lines': _localLines
          .map((line) => Map<String, dynamic>.of(line))
          .toList(),
    };
    final key = _storageKey;
    await _write(() async {
      final prefs = await SharedPreferences.getInstance();
      if (key != null) await prefs.setString(key, jsonEncode(payload));
      final created = await _repo.createReceiptDraft(widget.tripId, payload);
      if (key != null) unawaited(prefs.remove(key));
      return created;
    });
  }

  Future<void> _assign(
    Map<String, dynamic> line,
    Map<String, String> members, {
    bool justMe = false,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    final selected = Set<String>.from(line['assigneeIds'] as List);
    final canEditAll =
        _receipt?['creatorId'] == userId ||
        line['assignedById'] == userId ||
        selected.isEmpty;
    final users = justMe
        ? [userId]
        : await showDialog<List<String>>(
            context: context,
            builder: (dialog) => StatefulBuilder(
              builder: (context, change) => AlertDialog(
                title: Text(
                  _text(context, 'Ai dùng món này?', 'Who had this item?'),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final member in members.entries)
                        CheckboxListTile(
                          value: selected.contains(member.key),
                          title: Text(member.value),
                          onChanged: canEditAll || member.key == userId
                              ? (checked) => change(() {
                                  if (checked == true) {
                                    selected.add(member.key);
                                  } else {
                                    selected.remove(member.key);
                                  }
                                })
                              : null,
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialog),
                    child: Text('common.cancel'.tr()),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialog, selected.toList()),
                    child: Text('common.save'.tr()),
                  ),
                ],
              ),
            ),
          );
    if (!mounted || users == null) return;
    setState(
      () => _pending[line['id'] as String] = {
        'version': line['version'] as int,
        'users': users,
      },
    );
    await _persistPending();
    if (mounted) await _sendPending();
  }

  Future<void> _sendPending() async {
    final receipt = _receipt;
    final id = _id;
    if (_saving ||
        _pending.isEmpty ||
        receipt == null ||
        id == null ||
        !ref.read(capabilityProvider('receiptDrafts')).canWrite) {
      return;
    }
    final pending = _pending.entries.first;
    final current = _records(
      receipt['lines'],
    ).where((row) => row['id'] == pending.key).firstOrNull;
    final users = (pending.value['users'] as List).cast<String>();
    if (current?['version'] != pending.value['version'] ||
        receipt['finalizedAt'] != null) {
      final applied = (current?['assigneeIds'] as List? ?? []).toSet();
      setState(() {
        _pending.remove(pending.key);
        if (applied.length != users.length || !applied.containsAll(users)) {
          _error = _text(
            context,
            'Món đã thay đổi. Chọn lại trên bill mới nhất.',
            'The item changed. Select again on the latest bill.',
          );
        }
      });
      await _persistPending();
      return;
    }
    await _write(() async {
      try {
        final next = await _repo.assignReceiptLine(
          widget.tripId,
          id,
          pending.key,
          pending.value['version'] as int,
          users,
        );
        if (mounted) {
          _pending.remove(pending.key);
          await _persistPending();
        }
        return next;
      } catch (error) {
        if (mounted && (error is! ApiException || !error.isNetwork)) {
          _pending.remove(pending.key);
          await _persistPending();
        }
        rethrow;
      }
    });
  }

  Future<void> _editTotals(Map<String, dynamic> receipt) async {
    _title.text = receipt['title'] as String;
    _total.text = receipt['total'].toString();
    _tax.text = receipt['tax'].toString();
    _fee.text = receipt['fee'].toString();
    _discount.text = receipt['discount'].toString();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(
          _text(context, 'Điều chỉnh tổng trên bill', 'Adjust receipt totals'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: _text(context, 'Tên bill', 'Bill name'),
                ),
              ),
              _amountField(
                _total,
                _text(context, 'Tổng trên bill', 'Receipt total'),
              ),
              _amountField(_tax, _text(context, 'Thuế', 'Tax')),
              _amountField(_fee, _text(context, 'Phí', 'Fees')),
              _amountField(_discount, _text(context, 'Giảm giá', 'Discount')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
    if (!mounted || saved != true) return;
    final id = _id;
    final total = int.tryParse(_total.text);
    if (id == null ||
        total == null ||
        total <= 0 ||
        _title.text.trim().isEmpty) {
      setState(
        () => _error = _text(
          context,
          'Nhập tên bill và tổng tiền.',
          'Enter the bill name and total.',
        ),
      );
      return;
    }
    await _write(
      () => _repo.updateReceiptDraft(widget.tripId, id, {
        'version': receipt['version'],
        'title': _title.text.trim(),
        'total': total,
        'tax': int.tryParse(_tax.text) ?? 0,
        'fee': int.tryParse(_fee.text) ?? 0,
        'discount': int.tryParse(_discount.text) ?? 0,
      }),
    );
  }

  Widget _amountField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: label, suffixText: '₫'),
      );

  List<Widget> _createFields() => [
    if (!ref.watch(capabilityProvider('receiptOcr')).hidden)
      FilledButton.tonalIcon(
        onPressed:
            _saving || !ref.watch(capabilityProvider('receiptOcr')).canWrite
            ? null
            : _scan,
        icon: const Icon(Icons.document_scanner),
        label: Text(
          _text(context, 'Chụp hoặc chọn ảnh bill', 'Scan a receipt'),
        ),
      ),
    TextField(
      controller: _title,
      maxLength: 120,
      decoration: InputDecoration(
        labelText: _text(context, 'Tên bill', 'Bill name'),
      ),
    ),
    _amountField(_total, _text(context, 'Tổng trên bill', 'Receipt total')),
    ExpansionTile(
      title: Text(
        _text(context, 'Thuế, phí và giảm giá', 'Tax, fees and discounts'),
      ),
      children: [
        _amountField(_tax, _text(context, 'Thuế', 'Tax')),
        _amountField(_fee, _text(context, 'Phí', 'Fees')),
        _amountField(_discount, _text(context, 'Giảm giá', 'Discount')),
      ],
    ),
    for (var i = 0; i < _localLines.length; i++)
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(_localLines[i]['name'] as String),
        subtitle: Text(_vnd(context, _localLines[i]['amount'] as num)),
        onTap: _saving
            ? null
            : () => _editLine(existing: _localLines[i], index: i),
        trailing: IconButton(
          onPressed: _saving
              ? null
              : () => setState(() => _localLines.removeAt(i)),
          tooltip: _text(context, 'Bỏ món', 'Remove item'),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    OutlinedButton.icon(
      onPressed: _saving ? null : () => _editLine(),
      icon: const Icon(Icons.add),
      label: Text(_text(context, 'Nhập món', 'Add item')),
    ),
    const SizedBox(height: 12),
    FilledButton(
      onPressed: _saving ? null : _create,
      child: Text(
        _text(context, 'Mở bill cho cả nhóm', 'Share bill with the group'),
      ),
    ),
  ];

  List<Widget> _billFields(Map<String, dynamic> bill) {
    final trip = ref.watch(tripDetailProvider(widget.tripId)).valueOrNull;
    final members = <String, String>{
      for (final member in trip?.members ?? []) member.id: member.name,
    };
    final closed = bill['finalizedAt'] != null;
    final owner = bill['creatorId'] == _userId;
    final allocation = (bill['allocation'] as Map).cast<String, dynamic>();
    final editable =
        !closed &&
        !_saving &&
        ref.watch(capabilityProvider('receiptDrafts')).canWrite;
    return [
      Text(
        bill['title'] as String,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Text(_vnd(context, bill['total'] as num)),
      if (editable && owner)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _editTotals(bill),
            child: Text(
              _text(
                context,
                'Sửa tổng, phí hoặc giảm giá',
                'Edit totals, fees or discounts',
              ),
            ),
          ),
        ),
      const SizedBox(height: 14),
      if (closed)
        Text(
          _text(
            context,
            'Đã lưu trong chi phí chuyến đi.',
            'Saved in trip expenses.',
          ),
        ),
      if (!closed)
        Text(
          _text(
            context,
            'Chọn món của bạn hoặc nhập giúp thành viên khác.',
            'Claim your items or assign them for a friend.',
          ),
        ),
      for (final line in _records(bill['lines']))
        Builder(
          builder: (context) {
            final assigned = (line['assigneeIds'] as List).cast<String>();
            final assignedNames = assigned
                .map(
                  (id) => members[id] ?? _text(context, 'Thành viên', 'Member'),
                )
                .join(', ');
            final editor = members[line['assignedById']];
            final canAssign =
                owner ||
                assigned.isEmpty ||
                line['assignedById'] == _userId ||
                assigned.contains(_userId);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${line['name']} · ${_vnd(context, line['amount'] as num)}',
              ),
              subtitle: Text(
                assigned.isEmpty
                    ? _text(context, 'Chưa chọn', 'Unassigned')
                    : editor == null
                    ? assignedNames
                    : '$assignedNames · ${_text(context, 'Gán bởi', 'Assigned by')} $editor',
              ),
              onTap: editable && canAssign && members.isNotEmpty
                  ? () => _assign(line, members)
                  : null,
              trailing: editable && assigned.isEmpty
                  ? Wrap(
                      children: [
                        if (owner)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: _text(context, 'Sửa món', 'Edit item'),
                            onPressed: () => _editLine(existing: line),
                          ),
                        TextButton(
                          onPressed: () => _assign(line, members, justMe: true),
                          child: Text(_text(context, 'Món của tôi', 'Mine')),
                        ),
                      ],
                    )
                  : null,
            );
          },
        ),
      if (editable && owner)
        OutlinedButton.icon(
          onPressed: () => _editLine(),
          icon: const Icon(Icons.add),
          label: Text(_text(context, 'Nhập món', 'Add item')),
        ),
      const Divider(),
      Text(
        _text(context, 'Phần của từng người', 'Per-person totals'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      for (final part in _records(allocation['shares']))
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            members[part['userId']] ?? _text(context, 'Thành viên', 'Member'),
          ),
          trailing: Text(_vnd(context, part['amount'] as num)),
        ),
      if (!closed && (allocation['difference'] as num) != 0)
        Text(
          '${_text(context, 'Chênh lệch cần sửa', 'Difference to resolve')} · ${_vnd(context, allocation['difference'] as num)}',
        ),
      if (!closed && owner)
        FilledButton(
          onPressed: editable && allocation['complete'] == true
              ? () => _write(
                  () => _repo.finalizeReceiptDraft(
                    widget.tripId,
                    _id!,
                    bill['version'] as int,
                  ),
                  finalize: true,
                )
              : null,
          child: Text(
            _text(context, 'Chốt và lưu chi phí', 'Finalize and save'),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    final policy = ref.watch(capabilityProvider('receiptDrafts'));
    return Scaffold(
      appBar: AppBar(title: Text('beta.billDrafts'.tr())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          if (_loading || _saving) const LinearProgressIndicator(),
          if (_pending.isNotEmpty)
            Text(
              _text(
                context,
                '${_pending.length} món chờ đồng bộ.',
                '${_pending.length} item(s) waiting to sync.',
              ),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (!policy.canRead ||
              (!policy.canWrite && widget.initialId == null && receipt == null))
            Text(policy.label(context))
          else if (receipt != null)
            ..._billFields(receipt)
          else if (widget.initialId == null)
            ..._createFields()
          else if (!_loading)
            TextButton(
              onPressed: _refresh,
              child: Text(_text(context, 'Tải lại bill', 'Reload bill')),
            ),
        ],
      ),
    );
  }
}

class _LineDialog extends StatefulWidget {
  const _LineDialog({required this.existing});
  final Map<String, dynamic>? existing;

  @override
  State<_LineDialog> createState() => _LineDialogState();
}

class _LineDialogState extends State<_LineDialog> {
  late final _name = TextEditingController(
    text: widget.existing?['name'] as String?,
  );
  late final _amount = TextEditingController(
    text: widget.existing?['amount']?.toString(),
  );

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_text(context, 'Món trên bill', 'Receipt item')),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          maxLength: 120,
          decoration: InputDecoration(
            labelText: _text(context, 'Tên món', 'Item name'),
          ),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: _text(context, 'Giá món', 'Item price'),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('common.cancel'.tr()),
      ),
      FilledButton(
        onPressed:
            _name.text.trim().isEmpty || (int.tryParse(_amount.text) ?? 0) <= 0
            ? null
            : () => Navigator.pop(context, {
                'name': _name.text.trim(),
                'amount': int.parse(_amount.text),
              }),
        child: Text('common.save'.tr()),
      ),
    ],
  );
}
