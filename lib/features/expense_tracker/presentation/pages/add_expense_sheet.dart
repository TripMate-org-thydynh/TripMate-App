import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../dashboard/data/home_feed_repository.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../application/expenses_providers.dart';
import '../../data/expenses_repository.dart';
import 'ai_receipt_scanner_screen.dart';

/// Sheet thêm khoản chi — chia đều (EQUAL) cho cả nhóm. Wired BE thật.
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
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      _dark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary =>
      _dark ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
  Color get _textPri => _dark ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      _dark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

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
      _snack('Nhập số tiền hợp lệ', error: true);
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
            content: Text('expense.added_split'.tr()),
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

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: _textSec.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'expense.add_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _textPri,
                ),
              ),
              const SizedBox(height: 18),

              // AI Scan Button
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
                    color: GenZTokens.yellow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GenZTokens.ink, width: 2),
                    boxShadow: GenZTokens.hardShadow(GenZTokens.ink),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: GenZTokens.ink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'expense.scan_receipt_ai'.tr(),
                        style: AppFonts.heading(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: GenZTokens.ink,
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
                    fontWeight: FontWeight.w900,
                    color: _textPri,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppFonts.heading(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _textSec,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Text(
                        'đ',
                        style: AppFonts.heading(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
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
                  style: AppFonts.body(color: _textPri),
                  decoration: InputDecoration(
                    hintText: 'expense.desc_hint'.tr(),
                    hintStyle: AppFonts.body(color: _textSec),
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
                        color: sel ? _primary : _surface,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: sel
                              ? _primary
                              : (_dark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.08)),
                        ),
                      ),
                      child: Text(
                        e.value.tr(),
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _textPri,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'expense.save_split_equally'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
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
    color: _surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: _dark ? Colors.white.withValues(alpha: 0.06) : Colors.black,
      width: 2,
    ),
  );
}
