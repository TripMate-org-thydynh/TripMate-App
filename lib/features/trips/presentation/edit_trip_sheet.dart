import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/network/api_exception.dart';
import '../application/trips_providers.dart';
import '../domain/trip.dart';

/// Bottom sheet chỉnh sửa chuyến — prefill từ Trip, dùng lại bộ field như tạo mới.
class EditTripSheet extends ConsumerStatefulWidget {
  final Trip trip;
  final bool isDarkMode;
  const EditTripSheet({super.key, required this.trip, required this.isDarkMode});

  static Future<bool?> show(BuildContext context, Trip trip, bool isDarkMode) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  Color get _bg => _dark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
  Color get _surface =>
      _dark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary => const Color(0xFFF5822B);
  Color get _ink => _dark ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textPri => _ink;
  Color get _textSec =>
      _dark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

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
      _snack('Tên chuyến không được trống', error: true);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    try {
      final budget = double.tryParse(
        _budget.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      await ref.read(tripsProvider.notifier).updateTrip(
            widget.trip.id,
            name: _name.text.trim(),
            destination:
                _destination.text.trim().isEmpty ? null : _destination.text.trim(),
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
      _snack('Không lưu được, thử lại sau', error: true);
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

  String _fmt(DateTime d) => '${d.day}/${d.month}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: _ink, width: 2.5),
          left: BorderSide(color: _ink, width: 2.5),
          right: BorderSide(color: _ink, width: 2.5),
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
                    color: _textSec.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chỉnh sửa chuyến',
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(child: _form()),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _ink, width: 2.5),
                    boxShadow: _busy
                        ? null
                        : [BoxShadow(color: _ink, offset: const Offset(0, 4))],
                  ),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD84D),
                      foregroundColor: const Color(0xFF141210),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    onPressed: _busy ? null : _save,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF141210),
                            ),
                          )
                        : Text(
                            'reservations.save_changes'.tr(),
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
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
        _label('Tên chuyến'),
        _field(_name, 'Tên chuyến', PhosphorIcons.airplaneTilt()),
        const SizedBox(height: 14),
        _label('Điểm đến'),
        _field(_destination, 'vd: Đà Lạt, Lâm Đồng', PhosphorIcons.mapPin()),
        const SizedBox(height: 14),
        _label('Thời gian'),
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
                  '${_fmt(_range.start)} → ${_fmt(_range.end)}  ·  ${_range.end.difference(_range.start).inDays + 1} ngày',
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
        _label('Vibe chuyến đi'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _vibes.map((v) {
            final sel = _vibe == v.$1;
            return GestureDetector(
              onTap: () => setState(() => _vibe = sel ? null : v.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? _primary : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _ink, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(v.$3, size: 15, color: sel ? Colors.white : _textSec),
                    const SizedBox(width: 6),
                    Text(
                      v.$2.tr(),
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: sel ? Colors.white : _textPri,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _label('Ngân sách dự kiến / người'),
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
                    hintText: 'vd: 3000000',
                    hintStyle: AppFonts.body(color: _textSec),
                    prefixIcon:
                        Icon(PhosphorIcons.wallet(), color: _textSec, size: 20),
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
                  fontWeight: FontWeight.w800,
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
              hintText: 'Kế hoạch, lưu ý cho cả nhóm...',
              hintStyle: AppFonts.body(color: _textSec),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        ? 'Công khai · ai có link cũng xem được'
                        : 'Riêng tư · chỉ thành viên squad',
                    style: AppFonts.body(
                      fontSize: 13,
                      color: _textPri,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: _isPublic,
                  activeThumbColor: _primary,
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
            fontWeight: FontWeight.w700,
            color: _textSec,
          ),
        ),
      );

  BoxDecoration _boxDeco() => BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ink, width: 2),
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
