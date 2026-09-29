import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../dashboard/data/home_feed_repository.dart';
import '../../application/expenses_providers.dart';
import '../../data/expenses_repository.dart';

/// Nhập chi tiêu bằng lời: gõ một đoạn kiểu "Cường trả xe 3tr, cà phê
/// 15k/người…" → AI hỏi lại chỗ mơ hồ (kèm lựa chọn) → danh sách nháp sửa
/// từng dòng → "Lưu tất cả". AI không bao giờ tự lưu.
class AiExpenseParseScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;
  const AiExpenseParseScreen({
    super.key,
    required this.tripId,
    required this.isDarkMode,
  });

  @override
  ConsumerState<AiExpenseParseScreen> createState() =>
      _AiExpenseParseScreenState();
}

class _Draft {
  final TextEditingController desc;
  final TextEditingController amount;
  final String category;
  final String paidById;
  final String paidByName;
  final List<String> participantIds;
  final List<String> participantNames;

  _Draft(Map<String, dynamic> j)
    : desc = TextEditingController(text: j['description'] as String? ?? ''),
      amount = TextEditingController(
        text: ((j['amount'] as num?) ?? 0).round().toString(),
      ),
      category = j['category'] as String? ?? 'OTHER',
      paidById = j['paidById'] as String,
      paidByName = j['paidByName'] as String? ?? '',
      participantIds = List<String>.from(j['participantIds'] as List),
      participantNames = List<String>.from(j['participantNames'] as List);

  void dispose() {
    desc.dispose();
    amount.dispose();
  }
}

class _AiExpenseParseScreenState extends ConsumerState<AiExpenseParseScreen> {
  final _text = TextEditingController();
  final List<Map<String, String>> _answers = [];
  List<Map<String, dynamic>> _questions = [];
  final Map<String, String> _picked = {};
  final Map<String, TextEditingController> _other = {};
  List<_Draft> _drafts = [];
  bool _busy = false;

  bool get _dark => widget.isDarkMode;
  Color get _bg => _dark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => _dark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _onAccent => Theme.of(context).colorScheme.onPrimary;
  Color get _accentSoft =>
      _dark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color get _textPri => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textSec => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  @override
  void dispose() {
    _text.dispose();
    for (final c in _other.values) {
      c.dispose();
    }
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  String _answerFor(String qid) {
    final other = _other[qid]?.text.trim() ?? '';
    return other.isNotEmpty ? other : (_picked[qid] ?? '');
  }

  bool get _allAnswered =>
      _questions.every((q) => _answerFor(q['id'] as String).isNotEmpty);

  Future<void> _analyze({bool restart = false}) async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    if (restart) _answers.clear();
    // Gom câu trả lời của lượt hỏi hiện tại trước khi gọi lại.
    for (final q in _questions) {
      _answers.add({
        'question': q['text'] as String,
        'answer': _answerFor(q['id'] as String),
      });
    }
    setState(() => _busy = true);
    try {
      final r = await ref
          .read(expensesRepositoryProvider)
          .aiParse(widget.tripId, text, _answers);
      if (!mounted) return;
      for (final c in _other.values) {
        c.dispose();
      }
      _other.clear();
      _picked.clear();
      for (final d in _drafts) {
        d.dispose();
      }
      setState(() {
        if (r['status'] == 'draft') {
          _questions = [];
          _drafts = (r['expenses'] as List)
              .map((e) => _Draft((e as Map).cast<String, dynamic>()))
              .toList();
        } else {
          _drafts = [];
          _questions = (r['questions'] as List)
              .map((q) => (q as Map).cast<String, dynamic>())
              .toList();
        }
      });
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } catch (_) {
      _snack('expense.ai_parse_error'.tr(), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveAll() async {
    if (_drafts.isEmpty) return;
    final invalid = _drafts.any(
      (d) => (double.tryParse(d.amount.text.trim()) ?? 0) <= 0,
    );
    if (invalid) {
      _snack('expense.invalid_amount'.tr(), error: true);
      return;
    }
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    final repo = ref.read(expensesRepositoryProvider);
    var saved = 0;
    try {
      // Lưu tuần tự; khoản đã lưu được gỡ khỏi nháp để lỗi giữa chừng không
      // khiến bấm lại bị ghi trùng.
      while (_drafts.isNotEmpty) {
        final d = _drafts.first;
        await repo.createExpense(
          widget.tripId,
          amount: double.parse(d.amount.text.trim()),
          category: d.category,
          description: d.desc.text.trim().isEmpty ? null : d.desc.text.trim(),
          splitType: 'EQUAL',
          paidById: d.paidById,
          participantIds: d.participantIds,
        );
        saved++;
        setState(() => _drafts.removeAt(0));
        d.dispose();
      }
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } catch (_) {
      _snack('expense.ai_parse_error'.tr(), error: true);
    } finally {
      if (saved > 0) {
        ref.invalidate(tripBalancesProvider(widget.tripId));
        ref.invalidate(tripExpensesProvider(widget.tripId));
        invalidateHomeAggregatesFrom(ref);
      }
      if (mounted) setState(() => _busy = false);
    }
    if (mounted && _drafts.isEmpty && saved > 0) {
      _snack('expense.ai_saved'.tr(args: ['$saved']));
      Navigator.pop(context);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(color: error ? Colors.white : _onAccent),
        ),
        backgroundColor: error ? GenZTokens.danger : _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _money(num v) => '${NumberFormat.decimalPattern('vi').format(v)}đ';

  @override
  Widget build(BuildContext context) {
    final total = _drafts.fold<double>(
      0,
      (s, d) => s + (double.tryParse(d.amount.text.trim()) ?? 0),
    );
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _textPri),
        title: Text(
          'expense.ai_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPri,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'expense.ai_hint'.tr(),
                    style: AppFonts.body(fontSize: 13, color: _textSec),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _text,
                    minLines: 5,
                    maxLines: 12,
                    maxLength: 4000,
                    enabled: !_busy,
                    style: AppFonts.body(fontSize: 14, color: _textPri),
                    decoration: _inputDeco('expense.ai_placeholder'.tr()),
                  ),
                  const SizedBox(height: 8),
                  _button(
                    label: _questions.isEmpty && _drafts.isEmpty
                        ? 'expense.ai_analyze'.tr()
                        : 'expense.ai_reanalyze'.tr(),
                    icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                    onTap: () => _analyze(restart: true),
                    filled: _questions.isEmpty && _drafts.isEmpty,
                  ),
                ],
              ),
            ),
            if (_busy)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: _primary),
                ),
              ),
            if (!_busy && _questions.isNotEmpty) ..._buildQuestions(),
            if (_drafts.isNotEmpty) ..._buildDrafts(total),
          ],
        ),
      ),
      bottomNavigationBar: _drafts.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _button(
                  label: 'expense.ai_save_all'.tr(
                    args: ['${_drafts.length}', _money(total)],
                  ),
                  icon: PhosphorIcons.checks(),
                  onTap: _busy ? null : _saveAll,
                  filled: true,
                ),
              ),
            ),
    );
  }

  List<Widget> _buildQuestions() => [
    const SizedBox(height: 16),
    _sectionTitle('expense.ai_questions'.tr()),
    for (final q in _questions) _questionCard(q),
    const SizedBox(height: 4),
    _button(
      label: 'expense.ai_continue'.tr(),
      icon: PhosphorIcons.arrowRight(),
      onTap: _allAnswered ? () => _analyze() : null,
      filled: true,
    ),
  ];

  Widget _questionCard(Map<String, dynamic> q) {
    final id = q['id'] as String;
    final options = (q['options'] as List)
        .map((o) => (o as Map).cast<String, dynamic>())
        .toList();
    final other = _other.putIfAbsent(id, TextEditingController.new);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q['text'] as String,
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in options)
                  _optionChip(id, o['label'] as String, o['description']),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: other,
              onChanged: (_) => setState(() {}),
              style: AppFonts.body(fontSize: 14, color: _textPri),
              decoration: _inputDeco('expense.ai_other'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionChip(String qid, String label, Object? description) {
    final selected =
        _picked[qid] == label && (_other[qid]?.text.trim().isEmpty ?? true);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _picked[qid] = label;
          _other[qid]?.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _accentSoft : _fill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _primary : _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? _primary : _textPri,
              ),
            ),
            if (description is String && description.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  description,
                  style: AppFonts.body(fontSize: 12, color: _textSec),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrafts(double total) => [
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: _sectionTitle(
            'expense.ai_drafts'.tr(args: ['${_drafts.length}']),
          ),
        ),
        Text(
          _money(total),
          style: AppFonts.heading(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPri,
          ),
        ),
      ],
    ),
    for (final d in List.of(_drafts)) _draftCard(d),
  ];

  Widget _draftCard(_Draft d) {
    final n = d.participantNames.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: d.desc,
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPri,
                    ),
                    decoration: _inputDeco('expense.ai_desc'.tr()),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: d.amount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    textAlign: TextAlign.right,
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPri,
                    ),
                    decoration: _inputDeco('đ'),
                  ),
                ),
                IconButton(
                  tooltip: 'expense.ai_delete'.tr(),
                  icon: Icon(PhosphorIcons.trash(), color: _textSec, size: 20),
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _drafts.remove(d);
                          d.dispose();
                        }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'expense.ai_paid_by'.tr(args: [d.paidByName]),
              style: AppFonts.body(fontSize: 13, color: _textSec),
            ),
            const SizedBox(height: 2),
            // Liệt kê đủ tên, không rút gọn — để người dùng soát ai bị sót.
            Text(
              'expense.ai_split_among'.tr(
                args: ['$n', d.participantNames.join(', ')],
              ),
              style: AppFonts.body(fontSize: 13, color: _textPri),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: AppFonts.heading(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _textSec,
      ),
    ),
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
      border: Border.all(color: _line),
    ),
    child: child,
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppFonts.body(fontSize: 14, color: _textSec),
    isDense: true,
    filled: true,
    fillColor: _fill,
    counterStyle: AppFonts.body(fontSize: 11, color: _textSec),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _primary),
    ),
  );

  Widget _button({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required bool filled,
  }) {
    final fg = filled ? _onAccent : _primary;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: filled
          ? FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: fg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              onPressed: _busy ? null : onTap,
              icon: Icon(icon, size: 18),
              label: Text(
                label,
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            )
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: fg,
                side: BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              onPressed: _busy ? null : onTap,
              icon: Icon(icon, size: 18),
              label: Text(
                label,
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
    );
  }
}
