import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import '../../dashboard/data/home_feed_repository.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/gen_z_tokens.dart';
import '../data/itinerary_repository.dart';
import 'day_route_map_screen.dart';
import 'ride_hail_sheet.dart';
import '../../../core/services/weather_service.dart';
import '../../trips/application/trips_providers.dart';
import '../../itinerary_templates/presentation/publish_template_sheet.dart';
import '../../itinerary_templates/presentation/template_explore_screen.dart';
import '../domain/itinerary_item.dart';
import '../../../core/widgets/offline_banner.dart';

/// Lịch trình chuyến — wired BE thật, gom theo ngày.
class TripItineraryScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;
  const TripItineraryScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  bool _isDark(BuildContext context) =>
      isDarkMode || Theme.of(context).brightness == Brightness.dark;

  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _surfaceOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color _lineOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.fillDark : GenZTokens.fill;
  Color _accentOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color _onAccentOf(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  Color _textPriOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSecOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color _dangerOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.dangerDark : GenZTokens.danger;

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final dayCtrl = TextEditingController(text: '1');
    final timeCtrl = TextEditingController(text: '09:00');
    final placeCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    String selectedCategory = 'OTHER';

    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
          ),
          title: Text(
            'itinerary.add_stop'.tr(),
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPri,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dayCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppFonts.body(fontSize: 15, color: textPri),
                        decoration: InputDecoration(
                          labelText: 'itinerary.day_label'.tr(),
                          labelStyle: AppFonts.body(
                            fontSize: 15,
                            color: textSec,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: timeCtrl,
                        style: AppFonts.body(fontSize: 15, color: textPri),
                        decoration: InputDecoration(
                          labelText: 'itinerary.time_hint'.tr(),
                          labelStyle: AppFonts.body(
                            fontSize: 15,
                            color: textSec,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: placeCtrl,
                  style: AppFonts.body(fontSize: 15, color: textPri),
                  decoration: InputDecoration(
                    hintText: 'itinerary.place_name'.tr(),
                    hintStyle: AppFonts.body(fontSize: 15, color: textSec),
                  ),
                ),
                TextField(
                  controller: addrCtrl,
                  style: AppFonts.body(fontSize: 15, color: textPri),
                  decoration: InputDecoration(
                    hintText: 'itinerary.place_address'.tr(),
                    hintStyle: AppFonts.body(fontSize: 15, color: textSec),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: surface,
                  style: AppFonts.body(fontSize: 15, color: textPri),
                  decoration: InputDecoration(
                    labelText: 'itinerary.category'.tr(),
                    labelStyle: AppFonts.body(fontSize: 15, color: textSec),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'FOOD',
                      child: Text('itinerary.cat_food'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'ACTIVITIES',
                      child: Text('itinerary.cat_fun'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'ACCOMMODATION',
                      child: Text('itinerary.cat_stay'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'COFFEE',
                      child: Text('itinerary.cat_coffee'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'OTHER',
                      child: Text('itinerary.cat_other'.tr()),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setStateDialog(() {
                        selectedCategory = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'general.cancel'.tr(),
                style: AppFonts.body(fontSize: 15, color: textSec),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'packing.add'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: onAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true || placeCtrl.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    await ref
        .read(itineraryRepositoryProvider)
        .create(
          tripId,
          day: int.tryParse(dayCtrl.text.trim()) ?? 1,
          startTime: timeCtrl.text.trim(),
          placeName: placeCtrl.text.trim(),
          placeAddress: addrCtrl.text.trim().isEmpty
              ? null
              : addrCtrl.text.trim(),
          category: selectedCategory,
        );
    ref.invalidate(tripItineraryProvider(tripId));
    invalidateHomeAggregatesFrom(ref);
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    ItineraryItem item,
  ) async {
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final danger = _dangerOf(context);
    final onAccent = _onAccentOf(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
        title: Text(
          'itinerary.delete_stop'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        content: Text(
          'itinerary.delete_stop_confirm'.tr(
            namedArgs: {'name': item.placeName},
          ),
          style: AppFonts.body(fontSize: 15, color: textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(fontSize: 15, color: textSec),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: danger,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'general.delete'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: onAccent,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    HapticFeedback.lightImpact();
    try {
      await ref.read(itineraryRepositoryProvider).delete(tripId, item.id);
      ref.invalidate(tripItineraryProvider(tripId));
      invalidateHomeAggregatesFrom(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('itinerary.deleted_success'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripItineraryProvider(tripId));
    final bg = _bgOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);
    final textPri = _textPriOf(context);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        ),
        onPressed: () => _addItem(context, ref),
        icon: Icon(PhosphorIcons.plus(), size: 20),
        label: Text(
          'itinerary.add_place'.tr(),
          style: AppFonts.heading(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: onAccent,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'itinerary.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'templates.browse'.tr(),
            icon: Icon(PhosphorIcons.books(), color: textPri),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TemplateExploreScreen(isDarkMode: isDarkMode),
              ),
            ),
          ),
          IconButton(
            tooltip: 'templates.publish_action'.tr(),
            icon: Icon(PhosphorIcons.shareNetwork(), color: textPri),
            onPressed: () => PublishTemplateSheet.show(
              context,
              tripId: tripId,
              defaultTitle:
                  ref
                      .read(tripsProvider)
                      .valueOrNull
                      ?.where((t) => t.id == tripId)
                      .firstOrNull
                      ?.name ??
                  '',
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              color: accent,
              onRefresh: () async =>
                  ref.invalidate(tripItineraryProvider(tripId)),
              child: async.when(
                loading: () => _skeleton(context),
                error: (e, _) => _error(context, ref, e),
                data: (grouped) {
                  if (grouped.isEmpty) return _empty(context);
                  final days = grouped.keys.toList()..sort();
                  final weather =
                      ref.watch(itineraryWeatherProvider(tripId)).valueOrNull ??
                      ItineraryWeather.empty;
                  return ListView(
                    // Chừa chỗ cho FAB "Thêm điểm" (BUG-006).
                    padding: const EdgeInsets.all(16).copyWith(bottom: 96),
                    children: [
                      for (final day in days) ...[
                        _dayHeader(context, day, grouped[day]!),
                        if (weather.days[day] case final w? when w.available)
                          _dayWeather(context, w),
                        const SizedBox(height: 12),
                        ...grouped[day]!.map(
                          (it) => _itemCard(
                            context,
                            ref,
                            it,
                            rain: weather.rainAlerts[it.id],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayHeader(BuildContext context, int day, List<ItineraryItem> items) {
    final surface = _surfaceOf(context);
    final fill = _fillOf(context);
    final line = _lineOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            border: Border.all(color: line, width: GenZTokens.borderWidthThin),
          ),
          child: Text(
            'common.day_n'.tr(namedArgs: {'n': '$day'}),
            style: AppFonts.heading(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
          ),
        ),
        const Spacer(),
        // Mở bản đồ lộ trình trong app: mọi điểm của ngày này, đánh số và nối
        // đường theo giờ. Nút Google Maps nằm trong màn đó.
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DayRouteMapScreen(
                tripId: tripId,
                initialDay: day,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
              border: Border.all(
                color: line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                  size: 13,
                  color: textSec,
                ),
                const SizedBox(width: 6),
                Text(
                  'itinerary.directions'.tr(),
                  style: AppFonts.heading(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Dự báo của ngày, ngay dưới tiêu đề ngày.
  Widget _dayWeather(BuildContext context, DayWeather w) {
    final textSec = _textSecOf(context);
    final textPri = _textPriOf(context);
    final m = WeatherService.describe(w.weatherCode ?? -1);
    final rain = w.rainProbability ?? 0;
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 4),
      child: Row(
        children: [
          Icon(m.icon, size: 18, color: textPri),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              [
                m.description,
                if (w.tempMin != null && w.tempMax != null)
                  '${w.tempMin!.round()}–${w.tempMax!.round()}°C',
                if (rain > 0)
                  'itinerary.rain_chance'.tr(namedArgs: {'p': '$rain'}),
              ].join(' · '),
              style: AppFonts.body(fontSize: 13, color: textSec),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(
    BuildContext context,
    WidgetRef ref,
    ItineraryItem it, {
    int? rain,
  }) {
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                it.startTime,
                style: AppFonts.mono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPri,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Container(width: 1.5, height: 40, color: line),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_categoryIcon(it.category), size: 16, color: textSec),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        it.placeName,
                        style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textPri,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(PhosphorIcons.car(), size: 18, color: textSec),
                      tooltip: 'itinerary.ride_title'.tr(),
                      onPressed: () => RideHailSheet.show(
                        context,
                        it,
                        isDark: _isDark(context),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: Icon(
                        PhosphorIcons.trash(),
                        size: 18,
                        color: textSec,
                      ),
                      tooltip: 'general.delete'.tr(),
                      onPressed: () => _deleteItem(context, ref, it),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (it.placeAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      it.placeAddress!,
                      style: AppFonts.body(fontSize: 12, color: textSec),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'itinerary.minutes'.tr(
                      namedArgs: {'n': '${it.durationMinutes}'},
                    ),
                    style: AppFonts.body(fontSize: 12, color: textSec),
                  ),
                ),
                // Điểm ngoài trời vào giờ dễ mưa (BE tính theo dự báo từng giờ).
                if (rain != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _warningOf(context).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.cloudRain(),
                          size: 15,
                          color: _warningOf(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'itinerary.rain_alert'.tr(
                              namedArgs: {'p': '$rain'},
                            ),
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textPri,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _warningOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.warningDark : GenZTokens.warning;

  PhosphorIconData _categoryIcon(String? cat) {
    switch (cat?.toUpperCase()) {
      case 'FOOD':
        return PhosphorIcons.forkKnife();
      case 'ACTIVITIES':
        return PhosphorIcons.ticket();
      case 'ACCOMMODATION':
        return PhosphorIcons.buildings();
      case 'COFFEE':
        return PhosphorIcons.coffee();
      default:
        return PhosphorIcons.mapPin();
    }
  }

  Widget _skeleton(BuildContext context) {
    final fill = _fillOf(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        5,
        (i) => Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          ),
        ),
      ),
    );
  }

  Widget _error(BuildContext context, WidgetRef ref, Object e) {
    final danger = _dangerOf(context);
    final textPri = _textPriOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);

    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(PhosphorIcons.cloudSlash(), color: danger, size: 40),
              const SizedBox(height: 12),
              Text(
                'itinerary.load_failed'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
                onPressed: () => ref.invalidate(tripItineraryProvider(tripId)),
                icon: Icon(PhosphorIcons.arrowsClockwise(), size: 18),
                label: Text(
                  'general.retry'.tr(),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context) {
    final fill = _fillOf(context);
    final line = _lineOf(context);
    final accent = _accentOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    return ListView(
      children: [
        const SizedBox(height: 130),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                  color: accent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'itinerary.empty'.tr(),
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'itinerary.empty_sub'.tr(),
                style: AppFonts.body(fontSize: 15, color: textSec),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
