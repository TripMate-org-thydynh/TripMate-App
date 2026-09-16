import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/network/error_message.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

import '../data/itinerary_repository.dart';
import '../domain/itinerary_item.dart';
import '../application/place_import_service.dart';
import '../../moments/application/moments_providers.dart';
import '../../moments/domain/moment.dart';

final mapCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Bản đồ chuyến — ghim các điểm lịch trình có toạ độ lên OSM, tô màu theo ngày.
class TripMapScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;
  const TripMapScreen({
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
      _isDark(context) ? GenZTokens.accentDark : GenZTokens.accent;
  Color _onAccentOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color _accentSoftOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color _textPriOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSecOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color _dangerOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.dangerDark : GenZTokens.danger;
  Color _successOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.successDark : GenZTokens.success;

  static const _dayColors = <Color>[
    GenZTokens.chart1,
    GenZTokens.chart2,
    GenZTokens.chart3,
    GenZTokens.chart4,
    GenZTokens.chart5,
    GenZTokens.chart6,
  ];
  Color _dayColor(int day) => _dayColors[(day - 1) % _dayColors.length];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripItineraryProvider(tripId));
    final activeFilter = ref.watch(mapCategoryFilterProvider);
    final textPri = _textPriOf(context);
    final isDark = _isDark(context);

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'trips.map_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.link(), color: textPri),
            tooltip: 'itinerary.map_enter_place'.tr(),
            onPressed: () => _showPlaceImportModal(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _msg(context, 'itinerary.load_failed'.tr()),
        data: (grouped) {
          // Gom mọi item có toạ độ, giữ thông tin ngày.
          final points = <({ItineraryItem item, int day})>[];
          final days = grouped.keys.toList()..sort();
          // Toạ độ theo ngày (đúng thứ tự) để vẽ đường lộ trình.
          final routePerDay = <int, List<LatLng>>{};
          for (final day in days) {
            for (final it in grouped[day]!) {
              if (it.hasCoords) {
                points.add((item: it, day: day));
                if (activeFilter == null ||
                    it.category?.toUpperCase() == activeFilter) {
                  routePerDay
                      .putIfAbsent(day, () => [])
                      .add(LatLng(it.latitude!, it.longitude!));
                }
              }
            }
          }

          // Moment check-in có GPS (ảnh).
          final moments =
              (ref.watch(momentsProvider(tripId)).valueOrNull ??
                      const <Moment>[])
                  .where((m) => m.latitude != null && m.longitude != null)
                  .toList();

          if (points.isEmpty && moments.isEmpty) {
            return _msg(
              context,
              'itinerary.map_empty'.tr(),
            );
          }

          final coords = [
            ...points.map((p) => LatLng(p.item.latitude!, p.item.longitude!)),
            ...moments.map((m) => LatLng(m.latitude!, m.longitude!)),
          ];
          final center = _centroid(coords);

          // Lọc danh sách điểm dừng hiển thị theo Category được chọn
          final filteredPoints = activeFilter == null
              ? points
              : points
                    .where(
                      (p) => p.item.category?.toUpperCase() == activeFilter,
                    )
                    .toList();

          return Column(
            children: [
              _buildFilterChips(context, ref, activeFilter),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: _zoomFor(coords),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: isDark
                          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tripmate.app',
                    ),
                    // Đường lộ trình từng ngày (nối các điểm theo thứ tự).
                    PolylineLayer(
                      polylines: [
                        for (final entry in routePerDay.entries)
                          if (entry.value.length >= 2)
                            Polyline(
                              points: entry.value,
                              strokeWidth: 3.5,
                              color: _dayColor(
                                entry.key,
                              ).withValues(alpha: 0.7),
                            ),
                      ],
                    ),
                    // Moment check-in (ảnh có GPS).
                    MarkerLayer(
                      markers: [
                        for (final m in moments)
                          Marker(
                            point: LatLng(m.latitude!, m.longitude!),
                            width: 34,
                            height: 34,
                            child: Semantics(
                              button: true,
                              label: 'itinerary.map_moment_label'.tr(
                                namedArgs: {'author': m.authorName},
                              ),
                              child: GestureDetector(
                                onTap: () => _showMoment(context, m),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: GenZTokens.chart3,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    PhosphorIcons.camera(
                                      PhosphorIconsStyle.fill,
                                    ),
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        for (var i = 0; i < filteredPoints.length; i++)
                          Marker(
                            point: LatLng(
                              filteredPoints[i].item.latitude!,
                              filteredPoints[i].item.longitude!,
                            ),
                            width: 40,
                            height: 40,
                            child: Semantics(
                              button: true,
                              label: 'itinerary.map_stop_label'.tr(
                                namedArgs: {
                                  'place': filteredPoints[i].item.placeName,
                                },
                              ),
                              child: GestureDetector(
                                onTap: () => _showStop(
                                  context,
                                  filteredPoints[i].item,
                                  filteredPoints[i].day,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _dayColor(filteredPoints[i].day),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDark
                                                ? GenZTokens.inkDark
                                                : GenZTokens.ink)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${filteredPoints[i].day}',
                                    style: AppFonts.mono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              _legend(context, days, moments.isNotEmpty),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    String? activeFilter,
  ) {
    final categories = [
      (key: null, label: 'trips.filter_all'.tr(), icon: PhosphorIcons.mapPin()),
      (key: 'FOOD', label: 'itinerary.cat_food_plain'.tr(), icon: PhosphorIcons.forkKnife()),
      (key: 'ACTIVITIES', label: 'itinerary.map_fun'.tr(), icon: PhosphorIcons.ticket()),
      (key: 'ACCOMMODATION', label: 'expense.cat_stay'.tr(), icon: PhosphorIcons.buildings()),
      (key: 'COFFEE', label: 'itinerary.map_coffee'.tr(), icon: PhosphorIcons.coffee()),
      (key: 'OTHER', label: 'expense.cat_other'.tr(), icon: PhosphorIcons.dotsThreeCircle()),
    ];

    final surface = _surfaceOf(context);
    final fill = _fillOf(context);
    final line = _lineOf(context);
    final accent = _accentOf(context);
    final accentSoft = _accentSoftOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = activeFilter == cat.key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ref.read(mapCategoryFilterProvider.notifier).state = cat.key;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? accentSoft : fill,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: isSelected ? accent : line,
                    width: isSelected
                        ? GenZTokens.borderWidth
                        : GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 14,
                      color: isSelected ? accent : textSec,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accent : textPri,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _legend(BuildContext context, List<int> days, bool hasMoments) {
    final surface = _surfaceOf(context);
    final textPri = _textPriOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final d in days) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _dayColor(d),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'common.day_n'.tr(namedArgs: {'n': '$d'}),
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textPri,
                ),
              ),
              const SizedBox(width: 14),
            ],
            if (hasMoments) ...[
              Icon(
                PhosphorIcons.camera(PhosphorIconsStyle.fill),
                size: 13,
                color: GenZTokens.chart3,
              ),
              const SizedBox(width: 5),
              Text(
                'checkins.title_short'.tr(),
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textPri,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStop(BuildContext context, ItineraryItem it, int day) {
    final surface = _surfaceOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _dayColor(day).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusPill,
                      ),
                    ),
                    child: Text(
                      'itinerary.day_time'.tr(namedArgs: {'n': '$day', 'time': it.startTime}),
                      style: AppFonts.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _dayColor(day),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                it.placeName,
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              if (it.placeAddress != null && it.placeAddress!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  it.placeAddress!,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: textSec,
                  ),
                ),
              ],
              if (it.notes != null && it.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  it.notes!,
                  style: AppFonts.body(fontSize: 13, color: textSec),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoment(BuildContext context, Moment m) {
    final surface = _surfaceOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: CircleAvatar(
                      radius: 14,
                      backgroundImage: m.authorAvatar != null
                          ? NetworkImage(m.authorAvatar!)
                          : null,
                      child: m.authorAvatar == null
                          ? Text(m.authorName[0].toUpperCase())
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.authorName,
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: textPri,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'checkins.moment_title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSec,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (m.caption != null && m.caption!.isNotEmpty) ...[
                Text(
                  m.caption!,
                  style: AppFonts.body(fontSize: 14, color: textPri),
                ),
                const SizedBox(height: 14),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                child: Image.network(
                  m.mediaUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: m.caption != null && m.caption!.isNotEmpty
                      ? 'itinerary.map_moment_caption'.tr(
                          namedArgs: {'caption': m.caption!},
                        )
                      : 'itinerary.map_moment_photo'.tr(
                          namedArgs: {'author': m.authorName},
                        ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _msg(BuildContext context, String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.body(
          fontSize: 14,
          color: _textSecOf(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  LatLng _centroid(List<LatLng> points) {
    double lat = 0.0, lon = 0.0;
    for (final p in points) {
      lat += p.latitude;
      lon += p.longitude;
    }
    return LatLng(lat / points.length, lon / points.length);
  }

  double _zoomFor(List<LatLng> points) {
    if (points.length <= 1) return 14.0;
    double minLat = 90.0, maxLat = -90.0;
    double minLon = 180.0, maxLon = -180.0;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }
    final latDiff = maxLat - minLat;
    final lonDiff = maxLon - minLon;
    final maxDiff = math.max(latDiff, lonDiff);
    if (maxDiff < 0.01) return 14.5;
    if (maxDiff < 0.05) return 13.0;
    if (maxDiff < 0.1) return 12.0;
    if (maxDiff < 0.3) return 10.5;
    return 8.5;
  }

  void _showPlaceImportModal(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    final line = _lineOf(context);
    final cardBgCol = _surfaceOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);
    final success = _successOf(context);
    final danger = _dangerOf(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBgCol,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'system_phases.import_link_title'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPri,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'system_phases.import_link_placeholder'.tr(),
                hintStyle: AppFonts.body(color: textSec, fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                  borderSide: BorderSide(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                  borderSide: BorderSide(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                  borderSide: BorderSide(
                    color: accent,
                    width: GenZTokens.borderWidth,
                  ),
                ),
              ),
              style: AppFonts.body(color: textPri, fontSize: 15),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
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
                onPressed: () async {
                  final url = textController.text.trim();
                  if (url.isEmpty) return;

                  final place = PlaceImportService.parseExternalLink(url);
                  if (place != null) {
                    try {
                      // Save to backend database via repository
                      await ref
                          .read(itineraryRepositoryProvider)
                          .create(
                            tripId,
                            day: 1,
                            startTime: '10:00',
                            placeName: place.name,
                            placeAddress: place.address,
                            notes: 'itinerary.imported_from_link'.tr(),
                            category: place.category,
                            // Toa do doc duoc tu chinh URL — nho no diem moi
                            // ghim duoc len ban do.
                            latitude: place.latitude,
                            longitude: place.longitude,
                          );

                      // Refresh provider to fetch updated database items
                      ref.invalidate(tripItineraryProvider(tripId));

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'system_phases.import_success'.tr(
                                namedArgs: {'name': place.name},
                              ),
                              style: AppFonts.heading(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: onAccent,
                              ),
                            ),
                            backgroundColor: success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'itinerary.save_place_failed'.tr(
                                namedArgs: {'err': friendlyError(e)},
                              ),
                            ),
                            backgroundColor: danger,
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        // Noi ro phai lam gi, thay vi mot cau bao loi chung.
                        content: Text('itinerary.import_no_coords'.tr()),
                        duration: const Duration(seconds: 6),
                        backgroundColor: danger,
                      ),
                    );
                  }
                },
                child: Text(
                  'system_phases.import_button'.tr(),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: onAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
