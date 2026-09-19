import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../trip_planner/data/itinerary_repository.dart';
import '../../trips/application/trips_providers.dart';
import '../../trips/data/trips_repository.dart';
import '../../trips/domain/trip.dart';
import '../../trips/presentation/pick_trip_sheet.dart';
import '../../trips/presentation/trip_hub_screen.dart';
import '../data/itinerary_templates_repository.dart';
import '../domain/itinerary_template.dart';
import 'ai_customize_screen.dart';

/// Nhân bản một lịch trình mẫu: tạo chuyến mới, hoặc chép vào chuyến đang có.
///
/// Bản chép là của riêng người dùng — sửa/xoá điểm nào cũng không ảnh hưởng mẫu.
class UseTemplateSheet extends ConsumerStatefulWidget {
  const UseTemplateSheet({
    super.key,
    required this.template,
    required this.isDarkMode,
  });

  final ItineraryTemplate template;
  final bool isDarkMode;

  static Future<void> show(
    BuildContext context,
    ItineraryTemplate template, {
    bool isDarkMode = false,
  }) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        UseTemplateSheet(template: template, isDarkMode: isDarkMode),
  );

  @override
  ConsumerState<UseTemplateSheet> createState() => _UseTemplateSheetState();
}

class _UseTemplateSheetState extends ConsumerState<UseTemplateSheet> {
  late final _name = TextEditingController(text: widget.template.title);
  DateTime _start = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 7)),
  );
  bool _newTrip = true;
  Trip? _target;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _dark =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color get _surface => _dark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Future<void> _submit() async {
    final nav = Navigator.of(context);
    if (!_newTrip && _target == null) {
      await _pickTrip();
      if (_target == null) return;
    }
    setState(() => _busy = true);
    try {
      final tripId = await ref
          .read(itineraryTemplatesRepositoryProvider)
          .duplicate(
            widget.template.id,
            intoTripId: _newTrip ? null : _target!.id,
            name: _newTrip ? _name.text : null,
            startDate: _newTrip ? _start : null,
          );
      HapticFeedback.mediumImpact();
      ref.invalidate(tripsProvider);
      ref.invalidate(tripItineraryProvider(tripId));
      ref.invalidate(templateDetailProvider(widget.template.id));
      final trip = await ref.read(tripsRepositoryProvider).fetchTrip(tripId);
      showGlobalSnack(
        'templates.copied'.tr(
          namedArgs: {'n': '${widget.template.stopCount}', 'trip': trip.name},
        ),
      );
      nav.pop();
      nav.push(
        MaterialPageRoute(
          builder: (_) =>
              TripHubScreen(trip: trip, isDarkMode: widget.isDarkMode),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  Future<void> _pickTrip() async {
    final t = await PickTripSheet.show(
      context,
      widget.isDarkMode,
      title: 'templates.pick_trip'.tr(),
    );
    if (t != null && mounted) setState(() => _target = t);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (d != null) setState(() => _start = d);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final end = _start.add(Duration(days: t.dayCount - 1));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(GenZTokens.radiusCard),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'templates.use_this'.tr(),
                  style: AppFonts.heading(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'templates.use_hint'.tr(),
                  style: AppFonts.body(fontSize: 13, color: _inkSoft),
                ),
                const SizedBox(height: 16),
                _option(
                  selected: _newTrip,
                  icon: PhosphorIcons.plusCircle(),
                  title: 'templates.as_new_trip'.tr(),
                  subtitle: 'templates.as_new_trip_hint'.tr(
                    namedArgs: {'n': '${t.dayCount}'},
                  ),
                  onTap: () => setState(() => _newTrip = true),
                ),
                const SizedBox(height: 10),
                _option(
                  selected: false,
                  icon: PhosphorIcons.sparkle(),
                  title: 'templates.ai_option'.tr(),
                  subtitle: 'templates.ai_option_hint'.tr(),
                  onTap: () {
                    final nav = Navigator.of(context);
                    nav.pop();
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => AiCustomizeScreen(
                          template: widget.template,
                          isDarkMode: widget.isDarkMode,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _option(
                  selected: !_newTrip,
                  icon: PhosphorIcons.arrowSquareIn(),
                  title: 'templates.into_existing'.tr(),
                  subtitle:
                      _target?.name ?? 'templates.into_existing_hint'.tr(),
                  onTap: () {
                    setState(() => _newTrip = false);
                    _pickTrip();
                  },
                ),
                if (_newTrip) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _name,
                    style: AppFonts.body(fontSize: 15, color: _ink),
                    decoration: _input('templates.trip_name'.tr()),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                    child: InputDecorator(
                      decoration: _input('templates.start_date'.tr()),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.calendarBlank(),
                            size: 18,
                            color: _inkSoft,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_fmt(_start)} → ${_fmt(end)}',
                            style: AppFonts.mono(fontSize: 14, color: _ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'templates.copy_stops'.tr(
                              namedArgs: {'n': '${t.stopCount}'},
                            ),
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    labelStyle: AppFonts.body(fontSize: 13, color: _inkSoft),
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

  Widget _option({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final accent = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : _surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: selected ? accent : _line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? accent : _inkSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.body(fontSize: 12, color: _inkSoft),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? PhosphorIcons.radioButton(PhosphorIconsStyle.fill)
                  : PhosphorIcons.circle(),
              color: selected ? accent : _inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}
