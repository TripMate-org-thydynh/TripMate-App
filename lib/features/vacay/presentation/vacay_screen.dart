import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/network/error_message.dart';
import '../application/vacay_providers.dart';

/// Trang quản lý ngày nghỉ phép cá nhân & tối ưu hoá ngày nghỉ bắc cầu (VN holidays).
class VacayScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const VacayScreen({super.key, required this.isDarkMode});

  @override
  ConsumerState<VacayScreen> createState() => _VacayScreenState();
}

class _VacayScreenState extends ConsumerState<VacayScreen> {
  int _selectedYear = 2026;

  Color get _bg =>
      widget.isDarkMode ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
  Color get _card =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);

  void _showAddDialog() {
    DateTime selectedDate = DateTime.now();
    String selectedType = 'LEAVE';
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: _bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: _ink.withValues(alpha: 0.12)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textSec.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Thêm ngày nghỉ 🗓️',
                  style: AppFonts.heading(
                      fontSize: 20, fontWeight: FontWeight.w900, color: _ink),
                ),
                const SizedBox(height: 16),
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2028),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFFF5822B),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setModalState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _ink.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            PhosphorIcons.calendarBlank(
                                PhosphorIconsStyle.fill),
                            color: const Color(0xFFF5822B),
                            size: 18),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: AppFonts.body(fontSize: 14, color: _ink),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Type selector
                Row(
                  children: [
                    _typeButton('trips.hub_leave_days'.tr(), 'LEAVE', selectedType == 'LEAVE',
                        () => setModalState(() => selectedType = 'LEAVE')),
                    const SizedBox(width: 8),
                    _typeButton('vacay.holiday'.tr(), 'HOLIDAY', selectedType == 'HOLIDAY',
                        () => setModalState(() => selectedType = 'HOLIDAY')),
                  ],
                ),
                const SizedBox(height: 12),
                // Note
                TextField(
                  controller: noteCtrl,
                  style: AppFonts.body(fontSize: 14, color: _ink),
                  decoration: InputDecoration(
                    hintText: 'Ghi chú (đi Đà Lạt, nghỉ ốm...)',
                    hintStyle: AppFonts.body(fontSize: 14, color: _textSec),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFF5822B), width: 2),
                    ),
                    filled: true,
                    fillColor: _card,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5822B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                            color: Color(0xFF141210), width: 2),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final formattedDate =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                      await ref
                          .read(vacayMyDaysProvider.notifier)
                          .addDay(
                            date: formattedDate,
                            type: selectedType,
                            note: noteCtrl.text.trim().isEmpty
                                ? null
                                : noteCtrl.text.trim(),
                          );
                    },
                    child: Text(
                      'Thêm ngày',
                      style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _typeButton(
      String label, String type, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFF5822B)
                : const Color(0xFFF5822B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF5822B)
                  : const Color(0xFFF5822B).withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? Colors.white : const Color(0xFFF5822B),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myDaysAsync = ref.watch(vacayMyDaysProvider);
    final bridgeAsync = ref.watch(bridgeSuggestionsProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        iconTheme: IconThemeData(color: _ink),
        elevation: 0,
        title: Text(
          'Nghỉ phép thông minh 🏖️',
          style: AppFonts.heading(
              fontSize: 18, fontWeight: FontWeight.w900, color: _ink),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: _ink),
            onPressed: () {
              ref.read(vacayMyDaysProvider.notifier).refresh(year: _selectedYear);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          _showAddDialog();
        },
        backgroundColor: const Color(0xFFF5822B),
        foregroundColor: Colors.white,
        icon: Icon(PhosphorIcons.calendarPlus()),
        label: Text(
          'trips.hub_leave_days'.tr(),
          style: AppFonts.heading(
              fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: myDaysAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(
                color: const Color(0xFFF5822B))),
        error: (e, _) => Center(
          child: Text('Lỗi tải ngày nghỉ',
              style: AppFonts.heading(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
        ),
        data: (res) {
          final days = res.days;
          final summary = res.summary;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5822B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF141210), width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xFF141210),
                        offset: Offset(4, 4),
                        blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vacay.overview'.tr(),
                      style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryCol('Đã nghỉ', '${summary.totalLeave}', 'ngày'),
                        _summaryCol(
                            'Còn lại', '${summary.remaining}', 'ngày'),
                        _summaryCol('vacay.holiday_vn'.tr(), '${summary.totalHoliday}', 'ngày'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Year selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày đã đăng ký',
                    style: AppFonts.heading(
                        fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
                  ),
                  DropdownButton<int>(
                    value: _selectedYear,
                    dropdownColor: _card,
                    style: AppFonts.heading(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _ink),
                    items: [2025, 2026, 2027].map((y) {
                      return DropdownMenuItem<int>(
                        value: y,
                        child: Text('$y'),
                      );
                    }).toList(),
                    onChanged: (y) {
                      if (y != null) {
                        setState(() => _selectedYear = y);
                        ref
                            .read(vacayMyDaysProvider.notifier)
                            .refresh(year: y);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (days.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: Text(
                    'Chưa đăng ký ngày nghỉ nào trong năm $_selectedYear',
                    style: AppFonts.body(fontSize: 14, color: _textSec),
                  ),
                )
              else
                ...days.map((d) {
                  final formattedDate =
                      DateFormat('dd/MM/yyyy').format(d.date);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _ink.withValues(alpha: 0.12), width: 1.5),
                    ),
                    child: ListTile(
                      title: Text(
                        formattedDate,
                        style: AppFonts.heading(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _ink),
                      ),
                      subtitle: d.note != null
                          ? Text(d.note!,
                              style: AppFonts.body(
                                  fontSize: 12, color: _textSec))
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: d.type == 'LEAVE'
                                  ? const Color(0xFF3D8BFF).withValues(alpha: 0.1)
                                  : const Color(0xFF1FA85C).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              d.type == 'LEAVE' ? tr('vacay.leave') : tr('vacay.holiday'),
                              style: AppFonts.heading(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: d.type == 'LEAVE'
                                    ? const Color(0xFF3D8BFF)
                                    : const Color(0xFF1FA85C),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(PhosphorIcons.trash(),
                                color: Colors.red, size: 18),
                            onPressed: () async {
                              final isoStr =
                                  DateFormat('yyyy-MM-dd').format(d.date);
                              await ref
                                  .read(vacayMyDaysProvider.notifier)
                                  .removeDay(isoStr);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              // Holiday suggestions
              Text(
                'Gợi ý nghỉ bắc cầu (VN 2026) 💡',
                style: AppFonts.heading(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
              ),
              const SizedBox(height: 12),
              bridgeAsync.when(
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )),
                error: (e, _) => Text('Lỗi tải gợi ý: ${friendlyError(e)}',
                    style: AppFonts.body(fontSize: 13, color: Colors.red)),
                data: (suggestions) {
                  if (suggestions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Không có gợi ý nghỉ cầu nào sắp tới.',
                        style: AppFonts.body(fontSize: 13, color: _textSec),
                      ),
                    );
                  }
                  return Column(
                    children: suggestions.map((s) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCF9FFF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFCF9FFF), width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                                color: const Color(0xFF8B4DE8), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nghỉ bắc cầu: Xin nghỉ ${s.days} ngày',
                                    style: AppFonts.heading(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _ink),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Từ ${s.from} đến ${s.to} để có kỳ nghỉ dài!',
                                    style: AppFonts.body(
                                        fontSize: 12, color: _textSec),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: s.holidays.map((h) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF141210)
                                              .withValues(alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tr('vacay.holidays.$h'),
                                          style: AppFonts.body(
                                              fontSize: 10, color: _ink),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCol(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.heading(
              fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        Text(
          '$label ($unit)',
          style: AppFonts.body(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}
