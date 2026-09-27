import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../dashboard/data/home_feed_repository.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../application/expenses_providers.dart';
import '../../data/expenses_repository.dart';
import 'ai_receipt_scanner_screen.dart';

/// Sheet thêm khoản chi — chia đều, mặc định cả nhóm nhưng cho chọn
/// riêng ai tham gia (cáp treo, vé vào cổng... đâu phải ai cũng đi).
class AddExpenseSheet extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;
  const AddExpenseSheet({
    super.key,
    required this.tripId,
    required this.isDarkMode,
  });

  static Future<void> show(
    BuildContext context,
    String tripId,
    bool isDarkMode,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddExpenseSheet(tripId: tripId, isDarkMode: isDarkMode),
      ),
    );
  }

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'FOOD';
  bool _busy = false;

  /// Ai cùng chịu khoản này. `null` = chưa đụng tới → chia cả nhóm.
  Set<String>? _participants;

  static const _categories = {
    'FOOD': 'expense.cat_food',
    'ACCOMMODATION': 'expense.cat_stay',
    'TRANSPORT': 'expense.cat_transport',
    'ACTIVITIES': 'expense.cat_activities',
    'SHOPPING': 'expense.cat_shopping',
    'ENTERTAINMENT': 'expense.cat_fun',
    'OTHER': 'expense.cat_other',
  };

  bool get _dark => widget.isDarkMode;
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
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(
      _amount.text.trim().replaceAll('.', '').replaceAll(',', ''),
    );
    if (amount == null || amount <= 0) {
      _snack('expense.invalid_amount'.tr(), error: true);
      return;
    }
    final paidById = ref.read(authProvider).user?['id'] as String?;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    try {
      await ref
          .read(expensesRepositoryProvider)
          .createExpense(
            widget.tripId,
            amount: amount,
            category: _category,
            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            splitType: 'EQUAL',
            paidById: paidById,
            participantIds: _participants?.toList(),
          );
      // Làm mới số dư + danh sách chi.
      ref.invalidate(tripBalancesProvider(widget.tripId));
      ref.invalidate(tripExpensesProvider(widget.tripId));
      // Khối "The Roast" và feed hoạt động ở Home lấy từ tổng hợp chi tiêu.
      invalidateHomeAggregatesFrom(ref);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'expense.added_split'.tr(),
              style: TextStyle(color: _onAccent),
            ),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ApiException catch (e) {
      _snack(e.message, error: true);
      setState(() => _busy = false);
    }
  }

  /// Chọn ai cùng chia. Lấy danh sách người từ bảng số dư (đã có sẵn,
  /// khỏi gọi thêm API). Mặc định chọn hết = giữ nguyên hành vi cũ.
  Widget _participantPicker() {
    final async = ref.watch(tripBalancesProvider(widget.tripId));
    final people = async.valueOrNull?.balances ?? const [];
    if (people.length < 2) return const SizedBox.shrink();

    final chosen = _participants ?? people.map((p) => p.user.id).toSet();
    final all = chosen.length == people.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'expense.who_joined'.tr(),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textSec,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(
                () => _participants = all
                    ? <String>{}
                    : people.map((p) => p.user.id).toSet(),
              ),
              child: Text(
                (all ? 'expense.clear_all' : 'expense.select_all').tr(),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          all
              ? 'expense.split_whole_group'.tr()
              : 'expense.split_subset'.tr(
                  namedArgs: {'n': '${chosen.length}'},
                ),
          style: AppFonts.body(fontSize: 12, color: _textSec),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: people.map((p) {
            final sel = chosen.contains(p.user.id);
            return GestureDetector(
              onTap: () => setState(() {
                final next = {...chosen};
                sel ? next.remove(p.user.id) : next.add(p.user.id);
                _participants = next;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sel ? _accentSoft : _fill,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: sel ? _primary : _line,
                    width: sel
                        ? GenZTokens.borderWidth
                        : GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sel
                          ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                          : PhosphorIcons.circle(),
                      size: 15,
                      color: sel ? _primary : _textSec,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.user.name,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? _primary : _textSec,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: error
                ? (_dark ? GenZTokens.paperDark : GenZTokens.paper)
                : _onAccent,
          ),
        ),
        backgroundColor: error
            ? (_dark ? GenZTokens.dangerDark : GenZTokens.danger)
            : _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'expense.add_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textPri,
                ),
              ),
              const SizedBox(height: 18),

              // AI Scan Button (nút phụ, không tranh chấp điểm nhấn)
              GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiReceiptScannerScreen(
                        tripId: widget.tripId,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      final double amount = result['amount'] as double;
                      final String description =
                          result['description'] as String;
                      _amount.text = amount.toStringAsFixed(0);
                      _desc.text = description;
                      _category = 'FOOD';
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _fill,
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                    border: Border.all(
                      color: _line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.qrCode(), color: _primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'expense.scan_receipt_ai'.tr(),
                        style: AppFonts.body(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _textPri,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Số tiền
              Container(
                decoration: _deco(),
                child: TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  // `keyboardType` chỉ GỢI Ý bàn phím số — người dùng vẫn gõ
                  // được chữ (bàn phím vật lý, dán, bộ gõ khác). Không lọc thì
                  // số tiền như "2500003LauGaLaE" lọt vào và parse ra null.
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppFonts.heading(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppFonts.heading(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textSec,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Text(
                        'common.currency_suffix'.tr(),
                        style: AppFonts.heading(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Mô tả
              Container(
                decoration: _deco(),
                child: TextField(
                  controller: _desc,
                  style: AppFonts.body(color: _textPri, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'expense.desc_hint'.tr(),
                    hintStyle: AppFonts.body(color: _textSec, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category chips
              Text(
                'expense.category_label'.tr(),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textSec,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.entries.map((e) {
                  final sel = _category == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _category = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? _accentSoft : _fill,
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusPill,
                        ),
                        border: Border.all(
                          color: sel ? _primary : _line,
                          width: sel
                              ? GenZTokens.borderWidth
                              : GenZTokens.borderWidthThin,
                        ),
                      ),
                      child: Text(
                        e.value.tr(),
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? _primary : _textSec,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _participantPicker(),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: _onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _onAccent,
                          ),
                        )
                      : Text(
                          'expense.save_split_equally'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _onAccent,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _deco() => BoxDecoration(
    color: _fill,
    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
    border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
  );
}
