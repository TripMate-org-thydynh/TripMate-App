import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_exception.dart';
import '../application/trips_providers.dart';

/// Bottom sheet: Tạo chuyến mới hoặc Tham gia bằng mã mời — wired vào BE thật.
class CreateTripSheet extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const CreateTripSheet({super.key, required this.isDarkMode});

  static Future<void> show(BuildContext context, bool isDarkMode) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateTripSheet(isDarkMode: isDarkMode),
      ),
    );
  }

  @override
  ConsumerState<CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends ConsumerState<CreateTripSheet> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _destination = TextEditingController();
  final _desc = TextEditingController();
  final _budget = TextEditingController();
  DateTimeRange? _range;
  bool _busy = false;
  int _tab = 0; // 0 = tạo mới, 1 = tham gia

  String _coverId = 'cover-1';
  String? _vibe;
  String _currency = 'VND';
  bool _isPublic = false;

  // Cover mood (dùng chung với màn onboarding tạo chuyến).
  static const _covers = <Map<String, String>>[
    {'id': 'cover-1', 'title': 'tokyo drift', 'image': 'assets/images/cover_tokyo_drift.webp'},
    {'id': 'cover-2', 'title': 'island time', 'image': 'assets/images/cover_island_time.webp'},
    {'id': 'cover-3', 'title': 'alpine glow', 'image': 'assets/images/cover_alpine_glow.webp'},
  ];

  // Vibe chuyến đi (lưu code chữ hoa vào BE).
  static const _vibes = <(String, String, IconData)>[
    ('CHILL', 'trips.vibe_chill', PhosphorIconsFill.cloud),
    ('PARTY', 'trips.vibe_party', PhosphorIconsFill.confetti),
    ('ADVENTURE', 'trips.vibe_adventure', PhosphorIconsFill.mountains),
    ('FOODIE', 'trips.vibe_foodie', PhosphorIconsFill.forkKnife),
    ('CULTURE', 'trips.vibe_culture', PhosphorIconsFill.bank),
    ('AESTHETIC', 'trips.vibe_aesthetic', PhosphorIconsFill.cameraPlus),
  ];

  static const _currencies = ['VND', 'USD', 'THB', 'JPY', 'EUR'];

  bool get _dark => widget.isDarkMode;
  Color get _bg => _dark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
  Color get _surface =>
      _dark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary => const Color(0xFFF5822B);
  Color get _ink => _dark ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textPri => _ink;
  Color get _textSec =>
      _dark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _destination.dispose();
    _desc.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    try {
      if (_tab == 0) {
        if (_name.text.trim().isEmpty || _range == null) {
          _snack('Nhập tên chuyến và chọn ngày nhé', error: true);
          setState(() => _busy = false);
          return;
        }
        final cover = _covers.firstWhere(
          (c) => c['id'] == _coverId,
          orElse: () => _covers.first,
        );
        final budget = double.tryParse(
          _budget.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        final trip = await ref
            .read(tripsProvider.notifier)
            .create(
              name: _name.text.trim(),
              destination: _destination.text.trim().isEmpty
                  ? null
                  : _destination.text.trim(),
              description:
                  _desc.text.trim().isEmpty ? null : _desc.text.trim(),
              startDate: _range!.start,
              endDate: _range!.end,
              coverImage: cover['image'],
              currency: _currency,
              budget: budget,
              vibe: _vibe,
              isPublic: _isPublic,
            );
        if (mounted) Navigator.pop(context);
        // Mời squad ngay: chia sẻ mã mời chuyến vừa tạo.
        await Share.share(
          'Tham gia chuyến "${trip.name}" của tụi mình trên TripMate nha! '
          'Mã mời: ${trip.inviteCode} ✈️',
          subject: 'TripMate — Mời tham gia ${trip.name}',
        );
      } else {
        if (_code.text.trim().isEmpty) {
          _snack('Nhập mã mời nhé', error: true);
          setState(() => _busy = false);
          return;
        }
        await ref
            .read(tripsProvider.notifier)
            .join(_code.text.trim().toUpperCase());
        if (mounted) Navigator.pop(context);
      }
    } on ApiException catch (e) {
      _snack(e.message, error: true);
      setState(() => _busy = false);
    } catch (e) {
      _snack('trips.generic_error_retry'.tr(), error: true);
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
              const SizedBox(height: 18),

              // Tabs
              Row(
                children: [
                  _tabBtn('Tạo chuyến', 0),
                  const SizedBox(width: 10),
                  _tabBtn('Tham gia', 1),
                ],
              ),
              const SizedBox(height: 20),

              Flexible(
                child: SingleChildScrollView(
                  child: _tab == 0 ? _buildCreateForm() : _buildJoinForm(),
                ),
              ),

              const SizedBox(height: 20),
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
                    onPressed: _busy ? null : _submit,
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
                            _tab == 0 ? 'Tạo chuyến' : 'Tham gia',
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

  // ── Số đêm giữa 2 mốc, hiển thị "X ngày Y đêm" ──
  String get _durationLabel {
    if (_range == null) return 'Chọn ngày đi & về';
    final nights = _range!.end.difference(_range!.start).inDays;
    final days = nights + 1;
    return '${_fmt(_range!.start)} → ${_fmt(_range!.end)}  ·  $days ngày $nights đêm';
  }

  Widget _buildJoinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('trips.invite_code_label'.tr()),
        _field(_code, 'vd: ABC123', PhosphorIcons.ticket(), caps: true),
        const SizedBox(height: 6),
        Text(
          'Xin mã từ người tạo chuyến nha',
          style: AppFonts.body(fontSize: 12, color: _textSec),
        ),
      ],
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Tên chuyến'),
        _field(_name, 'trips.name_hint'.tr(), PhosphorIcons.airplaneTilt()),
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
                Expanded(
                  child: Text(
                    _durationLabel,
                    style: AppFonts.body(
                      fontSize: 13.5,
                      color: _range == null ? _textSec : _textPri,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        _label('Ảnh bìa (mood)'),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _covers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final c = _covers[i];
              final sel = c['id'] == _coverId;
              return GestureDetector(
                onTap: () => setState(() => _coverId = c['id']!),
                child: Container(
                  width: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? _primary : _ink,
                      width: sel ? 3 : 2,
                    ),
                    image: DecorationImage(
                      image: AssetImage(c['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(11),
                      ),
                    ),
                    child: Text(
                      c['title']!,
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sel ? _primary : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _ink, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(v.$3,
                        size: 15, color: sel ? Colors.white : _textSec),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Visibility
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

  Widget _tabBtn(String label, int idx) {
    final sel = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFFFFD84D) : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _ink, width: 2),
            boxShadow: sel
                ? [BoxShadow(color: _ink, offset: const Offset(0, 3))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: sel ? const Color(0xFF141210) : _textSec,
              ),
            ),
          ),
        ),
      ),
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

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool caps = false,
  }) {
    return Container(
      decoration: _boxDeco(),
      child: TextField(
        controller: c,
        textCapitalization: caps
            ? TextCapitalization.characters
            : TextCapitalization.sentences,
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

  String _fmt(DateTime d) => '${d.day}/${d.month}';
}
