import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../trips/application/trips_providers.dart';
import '../../trips/data/trips_repository.dart';
import '../../trips/presentation/trip_hub_screen.dart';
import '../domain/itinerary_template.dart';

/// Một điểm dừng trong bản AI đề xuất.
class _AiStop {
  _AiStop.fromJson(Map<String, dynamic> j)
    : day = (j['day'] as num).toInt(),
      startTime = j['startTime'] as String,
      placeName = j['placeName'] as String,
      placeAddress = j['placeAddress'] as String?,
      durationMinutes = (j['durationMinutes'] as num?)?.toInt() ?? 60,
      category = j['category'] as String? ?? 'OTHER',
      estimatedCost = (j['estimatedCost'] as num?)?.toInt(),
      note = j['note'] as String?,
      fromTemplate = j['fromTemplate'] as bool? ?? false;

  final int day;
  final String startTime;
  final String placeName;
  final String? placeAddress;
  final int durationMinutes;
  final String category;
  final int? estimatedCost;
  final String? note;

  /// Điểm giữ nguyên từ mẫu (true) hay AI mới thêm (false).
  final bool fromTemplate;

  Map<String, dynamic> toItem() => {
    'day': day,
    'startTime': startTime,
    'placeName': placeName,
    if (placeAddress != null && placeAddress!.isNotEmpty)
      'placeAddress': placeAddress,
    'durationMinutes': durationMinutes,
    'category': category,
    if (note != null && note!.isNotEmpty) 'notes': note,
  };
}

/// AI chỉnh một lịch trình mẫu cho hợp nhóm: số người, ngân sách, số ngày, gu.
///
/// Hai bước, không ghi gì cho tới bước cuối:
/// 1. Nhập yêu cầu → `POST /itinerary-templates/:id/customize` trả bản xem trước
///    (tính vào hạn mức AI/tháng).
/// 2. Xem trước, ưng thì "Tạo chuyến từ bản này" → `duplicate` kèm `items`.
class AiCustomizeScreen extends ConsumerStatefulWidget {
  const AiCustomizeScreen({
    super.key,
    required this.template,
    this.isDarkMode = false,
  });

  final ItineraryTemplate template;
  final bool isDarkMode;

  @override
  ConsumerState<AiCustomizeScreen> createState() => _AiCustomizeScreenState();
}

class _AiCustomizeScreenState extends ConsumerState<AiCustomizeScreen> {
  final _request = TextEditingController();
  final _group = TextEditingController(text: '4');
  final _budget = TextEditingController();
  late int _days = widget.template.dayCount.clamp(1, 14);
  DateTime _start = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 7)),
  );

  bool _thinking = false;
  bool _creating = false;
  String? _summary;
  int? _total;
  List<_AiStop>? _stops;

  @override
  void dispose() {
    _request.dispose();
    _group.dispose();
    _budget.dispose();
    super.dispose();
  }

  bool get _dark =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => _dark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _accent => Theme.of(context).colorScheme.primary;

  static final _money = NumberFormat.decimalPattern('vi');

  /// Số tiền người dùng gõ: bỏ dấu chấm/phẩy/chữ. "3tr", "3 triệu" → 3.000.000.
  int? _parseBudget(String raw) {
    final t = raw.toLowerCase().replaceAll(' ', '');
    final m = RegExp(
      r'^(\d+(?:[.,]\d+)?)(tr|triệu|trieu|k|nghìn|ngàn)?$',
    ).firstMatch(t);
    if (m == null) {
      final digits = t.replaceAll(RegExp(r'[^0-9]'), '');
      return digits.isEmpty ? null : int.tryParse(digits);
    }
    final n = double.parse(m.group(1)!.replaceAll(',', '.'));
    final unit = m.group(2);
    if (unit == null) return n >= 1000 ? n.round() : (n * 1000000).round();
    if (unit.startsWith('t')) return (n * 1000000).round();
    return (n * 1000).round();
  }

  Future<void> _ask() async {
    final req = _request.text.trim();
    if (req.isEmpty) {
      showGlobalSnack('templates.ai_need_request'.tr(), isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _thinking = true;
      _stops = null;
    });
    try {
      final data = await ref
          .read(apiClientProvider)
          .postData('/itinerary-templates/${widget.template.id}/customize', {
            'request': req,
            'groupSize': ?int.tryParse(_group.text.trim()),
            'budget': ?_parseBudget(_budget.text),
            'days': _days,
          });
      final m = (data as Map).cast<String, dynamic>();
      if (!mounted) return;
      setState(() {
        _summary = m['summary'] as String?;
        _total = (m['estimatedTotal'] as num?)?.toInt();
        _stops = (m['items'] as List)
            .whereType<Map>()
            .map((e) => _AiStop.fromJson(e.cast<String, dynamic>()))
            .toList();
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
  }

  Future<void> _create() async {
    final stops = _stops;
    if (stops == null || stops.isEmpty) return;
    setState(() => _creating = true);
    final nav = Navigator.of(context);
    try {
      final data = await ref.read(apiClientProvider).postData(
        '/itinerary-templates/${widget.template.id}/duplicate',
        {
          'name': widget.template.title,
          'startDate': _start.toIso8601String().substring(0, 10),
          'items': [for (final s in stops) s.toItem()],
        },
      );
      final tripId = (data as Map)['tripId'] as String;
      ref.invalidate(tripsProvider);
      final trip = await ref.read(tripsRepositoryProvider).fetchTrip(tripId);
      showGlobalSnack(
        'templates.copied'.tr(
          namedArgs: {'n': '${stops.length}', 'trip': trip.name},
        ),
      );
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              TripHubScreen(trip: trip, isDarkMode: widget.isDarkMode),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _creating = false);
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  InputDecoration _input(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: AppFonts.body(fontSize: 13, color: _inkSoft),
    hintStyle: AppFonts.body(fontSize: 14, color: _inkSoft),
    filled: true,
    fillColor: _fill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
      borderSide: BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
      borderSide: BorderSide(color: _line),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final stops = _stops;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'templates.ai_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'templates.ai_hint'.tr(namedArgs: {'title': widget.template.title}),
            style: AppFonts.body(fontSize: 13, color: _inkSoft, height: 1.4),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _request,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            style: AppFonts.body(fontSize: 15, color: _ink),
            decoration: _input(
              'templates.ai_request'.tr(),
              hint: 'templates.ai_request_hint'.tr(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _group,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppFonts.body(fontSize: 15, color: _ink),
                  decoration: _input('templates.ai_group'.tr()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _budget,
                  style: AppFonts.body(fontSize: 15, color: _ink),
                  decoration: _input('templates.ai_budget'.tr(), hint: '3tr'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'templates.ai_days'.tr(),
                style: AppFonts.body(fontSize: 14, color: _ink),
              ),
              const Spacer(),
              IconButton(
                onPressed: _days > 1 ? () => setState(() => _days--) : null,
                icon: Icon(PhosphorIcons.minusCircle(), color: _ink),
              ),
              Text(
                '$_days',
                style: AppFonts.mono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              IconButton(
                onPressed: _days < 14 ? () => setState(() => _days++) : null,
                icon: Icon(PhosphorIcons.plusCircle(), color: _ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _thinking ? null : _ask,
            icon: _thinking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(PhosphorIcons.sparkle(), size: 18),
            label: Text(
              _thinking
                  ? 'templates.ai_thinking'.tr()
                  : (stops == null
                        ? 'templates.ai_go'.tr()
                        : 'templates.ai_again'.tr()),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
          ),
          if (_thinking)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'templates.ai_wait'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 12, color: _inkSoft),
              ),
            ),
          if (stops != null) ..._preview(stops),
        ],
      ),
    );
  }

  List<Widget> _preview(List<_AiStop> stops) {
    final days = <int, List<_AiStop>>{};
    for (final s in stops) {
      days.putIfAbsent(s.day, () => []).add(s);
    }
    final keptCount = stops.where((s) => s.fromTemplate).length;
    return [
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_summary?.isNotEmpty ?? false)
              Text(
                _summary!,
                style: AppFonts.body(fontSize: 14, color: _ink, height: 1.4),
              ),
            const SizedBox(height: 8),
            Text(
              [
                'templates.ai_stats'.tr(
                  namedArgs: {
                    'n': '${stops.length}',
                    'kept': '$keptCount',
                    'added': '${stops.length - keptCount}',
                  },
                ),
                if (_total != null)
                  'templates.ai_total'.tr(
                    namedArgs: {'v': _money.format(_total)},
                  ),
              ].join(' · '),
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
      for (final d in (days.keys.toList()..sort())) ...[
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(
            'common.day_n'.tr(namedArgs: {'n': '$d'}),
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
        for (final s in days[d]!)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: _line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    s.startTime,
                    style: AppFonts.mono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.placeName,
                              style: AppFonts.heading(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _ink,
                              ),
                            ),
                          ),
                          if (!s.fromTemplate)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  GenZTokens.radiusPill,
                                ),
                                border: Border.all(color: _accent),
                              ),
                              child: Text(
                                'templates.ai_new'.tr(),
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: _accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (s.note?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            s.note!,
                            style: AppFonts.body(
                              fontSize: 12,
                              color: _inkSoft,
                              height: 1.35,
                            ),
                          ),
                        ),
                      if (s.estimatedCost != null && s.estimatedCost! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '~${_money.format(s.estimatedCost)} đ',
                            style: AppFonts.mono(fontSize: 12, color: _inkSoft),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
      const SizedBox(height: 16),
      InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: _start,
            firstDate: DateUtils.dateOnly(DateTime.now()),
            lastDate: DateTime.now().add(const Duration(days: 730)),
          );
          if (d != null) setState(() => _start = d);
        },
        child: InputDecorator(
          decoration: _input('templates.start_date'.tr()),
          child: Text(
            DateFormat('dd/MM/yyyy').format(_start),
            style: AppFonts.mono(fontSize: 14, color: _ink),
          ),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _creating ? null : _create,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          ),
        ),
        child: _creating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text('templates.ai_create'.tr()),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'templates.ai_disclaimer'.tr(),
          textAlign: TextAlign.center,
          style: AppFonts.body(fontSize: 12, color: _inkSoft),
        ),
      ),
    ];
  }
}
