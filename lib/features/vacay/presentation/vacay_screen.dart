import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:tripmate/core/theme/gen_z_tokens.dart';
import 'package:tripmate/core/network/error_message.dart';
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

  bool get _isDark =>
      widget.isDarkMode ||
      (mounted && Theme.of(context).brightness == Brightness.dark);

  Color get _bg => _isDark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _ink => _isDark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textSec => _isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _card => _isDark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _line => _isDark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => _isDark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _accent => _isDark ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      _isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _accentSoft =>
      _isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color get _onAccentSoft =>
      _isDark ? GenZTokens.onAccentSoftDark : GenZTokens.onAccentSoft;

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
              color: _card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border.all(color: _line, width: 1),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textSec.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'vacay.add_title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
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
                          colorScheme:
                              (_isDark
                                      ? const ColorScheme.dark()
                                      : const ColorScheme.light())
                                  .copyWith(
                                    primary: _accent,
                                    onPrimary: _onAccent,
                                    surface: _card,
                                    onSurface: _ink,
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
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _fill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _line, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                          color: _textSec,
                          size: 18,
                        ),
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
                    _typeButton(
                      'trips.hub_leave_days'.tr(),
                      'LEAVE',
                      selectedType == 'LEAVE',
                      () => setModalState(() => selectedType = 'LEAVE'),
                    ),
                    const SizedBox(width: 8),
                    _typeButton(
                      'vacay.holiday'.tr(),
                      'HOLIDAY',
                      selectedType == 'HOLIDAY',
                      () => setModalState(() => selectedType = 'HOLIDAY'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Note
                TextField(
                  controller: noteCtrl,
                  style: AppFonts.body(fontSize: 14, color: _ink),
                  decoration: InputDecoration(
                    hintText: 'vacay.note_hint'.tr(),
                    hintStyle: AppFonts.body(fontSize: 14, color: _textSec),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _line, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _line, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _accent, width: 1),
                    ),
                    filled: true,
                    fillColor: _fill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(selectedDate);
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
                      'vacay.add_short'.tr(),
                      style: AppFonts.heading(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _onAccent,
                      ),
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
    String label,
    String type,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _accentSoft : _fill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? _accent : _line, width: 1),
          ),
          child: Text(
            label,
            style: AppFonts.heading(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? _onAccentSoft : _textSec,
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
          'vacay.title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: _ink),
            onPressed: () {
              ref
                  .read(vacayMyDaysProvider.notifier)
                  .refresh(year: _selectedYear);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          _showAddDialog();
        },
        backgroundColor: _accent,
        foregroundColor: _onAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 0,
        icon: Icon(PhosphorIcons.calendarPlus(), color: _onAccent),
        label: Text(
          'trips.hub_leave_days'.tr(),
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _onAccent,
          ),
        ),
      ),
      body: myDaysAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: _accent)),
        error: (e, _) => Center(
          child: Text(
            'vacay.load_failed'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
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
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _line, width: 1),
                  boxShadow: GenZTokens.hardShadow(_ink, _isDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vacay.overview'.tr(),
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textSec,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryCol(
                          'vacay.taken'.tr(),
                          '${summary.totalLeave}',
                          'common.day_unit'.tr(),
                        ),
                        _summaryCol(
                          'vacay.remaining'.tr(),
                          '${summary.remaining}',
                          'common.day_unit'.tr(),
                        ),
                        _summaryCol(
                          'vacay.holiday_vn'.tr(),
                          '${summary.totalHoliday}',
                          'common.day_unit'.tr(),
                        ),
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
                    'vacay.registered'.tr(),
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  DropdownButton<int>(
                    value: _selectedYear,
                    dropdownColor: _card,
                    underline: const SizedBox.shrink(),
                    icon: Icon(
                      PhosphorIcons.caretDown(),
                      color: _ink,
                      size: 16,
                    ),
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                    items: [2025, 2026, 2027].map((y) {
                      return DropdownMenuItem<int>(value: y, child: Text('$y'));
                    }).toList(),
                    onChanged: (y) {
                      if (y != null) {
                        setState(() => _selectedYear = y);
                        ref.read(vacayMyDaysProvider.notifier).refresh(year: y);
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
                    'vacay.none_in_year'.tr(
                      namedArgs: {'year': '$_selectedYear'},
                    ),
                    style: AppFonts.body(fontSize: 14, color: _textSec),
                  ),
                )
              else
                ...days.map((d) {
                  final formattedDate = DateFormat('dd/MM/yyyy').format(d.date);
                  final isLeave = d.type == 'LEAVE';
                  final badgeBg = isLeave
                      ? (_isDark
                            ? GenZTokens.infoDark.withValues(alpha: 0.15)
                            : GenZTokens.info.withValues(alpha: 0.12))
                      : (_isDark
                            ? GenZTokens.successDark.withValues(alpha: 0.15)
                            : GenZTokens.success.withValues(alpha: 0.12));
                  final badgeColor = isLeave
                      ? (_isDark ? GenZTokens.infoDark : GenZTokens.info)
                      : (_isDark ? GenZTokens.successDark : GenZTokens.success);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _line, width: 1),
                    ),
                    child: ListTile(
                      title: Text(
                        formattedDate,
                        style: AppFonts.heading(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      subtitle: d.note != null
                          ? Text(
                              d.note!,
                              style: AppFonts.body(
                                fontSize: 12,
                                color: _textSec,
                              ),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: badgeColor.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isLeave ? tr('vacay.leave') : tr('vacay.holiday'),
                              style: AppFonts.heading(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              PhosphorIcons.trash(),
                              color: _textSec,
                              size: 18,
                            ),
                            onPressed: () async {
                              final isoStr = DateFormat(
                                'yyyy-MM-dd',
                              ).format(d.date);
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
                'vacay.bridge_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              bridgeAsync.when(
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: _accent),
                  ),
                ),
                error: (e, _) => Text(
                  'vacay.load_suggestions_failed'.tr(
                    namedArgs: {'err': friendlyError(e)},
                  ),
                  style: AppFonts.body(
                    fontSize: 13,
                    color: _isDark ? GenZTokens.dangerDark : GenZTokens.danger,
                  ),
                ),
                data: (suggestions) {
                  if (suggestions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'vacay.bridge_empty'.tr(),
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
                          color: _card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _line, width: 1),
                          boxShadow: GenZTokens.hardShadow(_ink, _isDark),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                              color: _accent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'vacay.bridge_days'.tr(
                                      namedArgs: {'n': '${s.days}'},
                                    ),
                                    style: AppFonts.heading(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'vacay.from_to'.tr(
                                      namedArgs: {'from': s.from, 'to': s.to},
                                    ),
                                    style: AppFonts.body(
                                      fontSize: 12,
                                      color: _textSec,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: s.holidays.map((h) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _fill,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: _line,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          tr('vacay.holidays.$h'),
                                          style: AppFonts.body(
                                            fontSize: 12,
                                            color: _ink,
                                          ),
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
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$label ($unit)',
          style: AppFonts.body(fontSize: 12, color: _textSec),
        ),
      ],
    );
  }
}
