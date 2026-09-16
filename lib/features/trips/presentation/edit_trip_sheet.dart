import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../application/trips_providers.dart';
import '../domain/trip.dart';

/// Bottom sheet chỉnh sửa chuyến — prefill từ Trip, dùng lại bộ field như tạo mới.
class EditTripSheet extends ConsumerStatefulWidget {
  final Trip trip;
  final bool isDarkMode;
  const EditTripSheet({
    super.key,
    required this.trip,
    required this.isDarkMode,
  });

  static Future<bool?> show(BuildContext context, Trip trip, bool isDarkMode) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GenZTokens.paper.withValues(alpha: 0),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditTripSheet(trip: trip, isDarkMode: isDarkMode),
      ),
    );
  }

  @override
  ConsumerState<EditTripSheet> createState() => _EditTripSheetState();
}

class _EditTripSheetState extends ConsumerState<EditTripSheet> {
  late final TextEditingController _name;
  late final TextEditingController _destination;
  late final TextEditingController _desc;
  late final TextEditingController _budget;
  late DateTimeRange _range;
  late String _currency;
  late bool _isPublic;
  String? _vibe;
  bool _busy = false;

  bool get _dark => widget.isDarkMode;
  Color get _surface => _dark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textPri => _ink;
  Color get _textSec => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _accent => _dark ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent => _dark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _accentSoft =>
      _dark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color get _danger => _dark ? GenZTokens.dangerDark : GenZTokens.danger;

  static const _vibes = <(String, String, IconData)>[
    ('CHILL', 'trips.vibe_chill', PhosphorIconsFill.cloud),
    ('PARTY', 'trips.vibe_party', PhosphorIconsFill.confetti),
    ('ADVENTURE', 'trips.vibe_adventure', PhosphorIconsFill.mountains),
    ('FOODIE', 'trips.vibe_foodie', PhosphorIconsFill.forkKnife),
    ('CULTURE', 'trips.vibe_culture', PhosphorIconsFill.bank),
    ('AESTHETIC', 'trips.vibe_aesthetic', PhosphorIconsFill.cameraPlus),
  ];
  static const _currencies = ['VND', 'USD', 'THB', 'JPY', 'EUR'];

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    _name = TextEditingController(text: t.name);
    _destination = TextEditingController(text: t.destination ?? '');
    _desc = TextEditingController(text: t.description ?? '');
    _budget = TextEditingController(
      text: t.budget == null ? '' : t.budget!.toStringAsFixed(0),
    );
    _range = DateTimeRange(start: t.startDate, end: t.endDate);
    _currency = t.currency;
    _isPublic = t.isPublic;
    _vibe = t.vibe;
  }

  @override
  void dispose() {
    _name.dispose();
    _destination.dispose();
    _desc.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      _snack('trips.name_empty'.tr(), error: true);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    try {
      final budget = double.tryParse(
        _budget.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      await ref
          .read(tripsProvider.notifier)
          .updateTrip(
            widget.trip.id,
            name: _name.text.trim(),
            destination: _destination.text.trim().isEmpty
                ? null
                : _destination.text.trim(),
            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            startDate: _range.start,
            endDate: _range.end,
            currency: _currency,
            budget: budget,
            vibe: _vibe,
            isPublic: _isPublic,
          );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
      setState(() => _busy = false);
    } catch (_) {
      _snack('common.save_failed'.tr(), error: true);
      setState(() => _busy = false);
    }
  }

  Future<void> _deleteTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
        title: Text(
          'trips.delete_trip'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        content: Text(
          'trips.delete_trip_confirm'.tr(),
          style: AppFonts.body(fontSize: 14, color: _textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w600,
                color: _textSec,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor:
                  _dark ? GenZTokens.onAccentDark : GenZTokens.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'general.delete'.tr(),
              style: AppFonts.heading(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(tripsProvider.notifier).deleteTrip(widget.trip.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      _snack(e.message, error: true);
      setState(() => _busy = false);
    } catch (_) {
      _snack('trips.generic_error_retry'.tr(), error: true);
      setState(() => _busy = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: error
                ? (_dark ? GenZTokens.onAccentDark : GenZTokens.onAccent)
                : _ink,
          ),
        ),
        backgroundColor: error ? _danger : _surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(
          top: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
          left: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
          right: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
        boxShadow: GenZTokens.hardShadow(_ink, _dark),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'trips.edit'.tr(),
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(child: SingleChildScrollView(child: _form())),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: _onAccent,
                    disabledBackgroundColor: _line,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  onPressed: _busy ? null : _save,
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
                          'reservations.save_changes'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _onAccent,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: _busy ? null : _deleteTrip,
                  icon: Icon(
                    PhosphorIcons.trash(),
                    color: _danger,
                    size: 18,
                  ),
                  label: Text(
                    'trips.delete_trip'.tr(),
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _danger,
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

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('trips.name_label'.tr()),
        _field(_name, 'trips.name_label'.tr(), PhosphorIcons.airplaneTilt()),
        const SizedBox(height: 14),
        _label('trips.destination'.tr()),
        _field(
          _destination,
          'trips.destination_hint'.tr(),
          PhosphorIcons.mapPin(),
        ),
        const SizedBox(height: 14),
        _label('trips.dates_label'.tr()),
        GestureDetector(
          onTap: _pickDates,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: _boxDeco(),
            child: Row(
              children: [
                Icon(PhosphorIcons.calendarBlank(), color: _textSec, size: 20),
                const SizedBox(width: 10),
                Text(
                  'trips.range_days'.tr(
                    namedArgs: {
                      'from': _fmt(_range.start),
                      'to': _fmt(_range.end),
                      'days':
                          '${_range.end.difference(_range.start).inDays + 1}',
                    },
                  ),
                  style: AppFonts.body(
                    fontSize: 13.5,
                    color: _textPri,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _label('trips.vibe'.tr()),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _vibes.map((v) {
            final sel = _vibe == v.$1;
            return GestureDetector(
              onTap: () => setState(() => _vibe = sel ? null : v.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sel ? _accentSoft : _fill,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                  border: Border.all(
                    color: sel ? _accent : _line,
                    width: sel
                        ? GenZTokens.borderWidth
                        : GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(v.$3, size: 15, color: sel ? _accent : _textSec),
                    const SizedBox(width: 6),
                    Text(
                      v.$2.tr(),
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? _accent : _textPri,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _label('trips.budget_per_head'.tr()),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: _boxDeco(),
                child: TextField(
                  controller: _budget,
                  keyboardType: TextInputType.number,
                  // keyboardType chỉ gợi ý bàn phím — vẫn dán/gõ được chữ nếu không lọc.
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppFonts.body(color: _textPri, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'trips.budget_hint'.tr(),
                    hintStyle: AppFonts.body(color: _textSec),
                    prefixIcon: Icon(
                      PhosphorIcons.wallet(),
                      color: _textSec,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: _boxDeco(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: _currency,
                underline: const SizedBox.shrink(),
                dropdownColor: _surface,
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPri,
                ),
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _currency = v ?? 'VND'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _label('trips.note_or_description'.tr()),
        Container(
          decoration: _boxDeco(),
          child: TextField(
            controller: _desc,
            maxLines: 2,
            style: AppFonts.body(color: _textPri, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'trips.description_hint'.tr(),
              hintStyle: AppFonts.body(color: _textSec),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => setState(() => _isPublic = !_isPublic),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: _boxDeco(),
            child: Row(
              children: [
                Icon(
                  _isPublic ? PhosphorIcons.globe() : PhosphorIcons.lock(),
                  color: _textSec,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isPublic
                        ? 'trips.public_desc'.tr()
                        : 'trips.private_desc'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      color: _textPri,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: _isPublic,
                  activeThumbColor: _accent,
                  activeTrackColor: _accentSoft,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: AppFonts.body(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textSec,
      ),
    ),
  );

  BoxDecoration _boxDeco() => BoxDecoration(
    color: _fill,
    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
    border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
  );

  Widget _field(TextEditingController c, String hint, IconData icon) {
    return Container(
      decoration: _boxDeco(),
      child: TextField(
        controller: c,
        style: AppFonts.body(color: _textPri, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppFonts.body(color: _textSec),
          prefixIcon: Icon(icon, color: _textSec, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
