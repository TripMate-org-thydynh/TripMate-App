import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/network/error_message.dart';

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

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _textPri => isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  static const _dayColors = <Color>[
    Color(0xFFF5822B),
    Color(0xFF3D8BFF),
    Color(0xFF1FA85C),
    Color(0xFF8B4DE8),
    Color(0xFFD6248C),
    Color(0xFF06B6D4),
    Color(0xFFFFB020),
  ];
  Color _dayColor(int day) => _dayColors[(day - 1) % _dayColors.length];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripItineraryProvider(tripId));
    final activeFilter = ref.watch(mapCategoryFilterProvider);

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'trips.map_title'.tr(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.link, color: _textPri),
            tooltip: 'itinerary.map_enter_place'.tr(),
            onPressed: () => _showPlaceImportModal(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _msg('itinerary.load_failed'.tr()),
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
              'Chưa có điểm nào có toạ độ.\nThêm địa điểm từ Khám phá / Ảnh→Map, hoặc đăng moment có vị trí để ghim lên đây.',
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
                      urlTemplate: isDarkMode
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
                            child: GestureDetector(
                              onTap: () => _showMoment(context, m),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6248C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
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
                                    width: 2.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${filteredPoints[i].day}',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
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
              _legend(days, moments.isNotEmpty),
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
      (key: null, label: 'trips.filter_all'.tr(), emoji: '📍'),
      (key: 'FOOD', label: 'Ăn uống', emoji: '🍔'),
      (key: 'ACTIVITIES', label: 'itinerary.map_fun'.tr(), emoji: '🎭'),
      (key: 'ACCOMMODATION', label: 'expense.cat_stay'.tr(), emoji: '🏨'),
      (key: 'COFFEE', label: 'itinerary.map_coffee'.tr(), emoji: '☕'),
      (key: 'OTHER', label: 'expense.cat_other'.tr(), emoji: '📍'),
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = activeFilter == cat.key;
          final inkColor = isDarkMode ? Colors.white : const Color(0xFF141210);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ref.read(mapCategoryFilterProvider.notifier).state = cat.key;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFD84D)
                      : (Theme.of(context).scaffoldBackgroundColor),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: inkColor, width: 2),
                  boxShadow: isSelected
                      ? [BoxShadow(color: inkColor, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: inkColor,
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

  Widget _legend(List<int> days, bool hasMoments) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final d in days) ...[
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _dayColor(d),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Ngày $d',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPri,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (hasMoments) ...[
            const Icon(Icons.camera_alt, size: 13, color: Color(0xFFD6248C)),
            const SizedBox(width: 5),
            Text(
              'checkins.title_short'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPri,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  void _showStop(BuildContext context, ItineraryItem it, int day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode
          ? const Color(0xFF262019)
          : const Color(0xFFFFFDF5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      color: _dayColor(day),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Ngày $day · ${it.startTime}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                it.placeName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textPri,
                ),
              ),
              if (it.placeAddress != null && it.placeAddress!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  it.placeAddress!,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: _textPri.withValues(alpha: 0.6),
                  ),
                ),
              ],
              if (it.notes != null && it.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  it.notes!,
                  style: GoogleFonts.outfit(fontSize: 13, color: _textSec),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode
          ? const Color(0xFF262019)
          : const Color(0xFFFFFDF5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: m.authorAvatar != null
                        ? NetworkImage(m.authorAvatar!)
                        : null,
                    child: m.authorAvatar == null
                        ? Text(m.authorName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.authorName,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textPri,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'checkins.moment_title'.tr(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD6248C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (m.caption != null && m.caption!.isNotEmpty) ...[
                Text(
                  m.caption!,
                  style: GoogleFonts.outfit(fontSize: 14, color: _textPri),
                ),
                const SizedBox(height: 14),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  m.mediaUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _msg(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: _textSec,
          fontWeight: FontWeight.bold,
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
    final borderCol = isDarkMode ? Colors.white : const Color(0xFF141210);
    final cardBgCol = isDarkMode
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBgCol,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'system_phases.import_link_placeholder'.tr(),
                hintStyle: GoogleFonts.outfit(color: _textSec),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderCol, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderCol, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFFFFD84D),
                    width: 2.5,
                  ),
                ),
              ),
              style: GoogleFonts.outfit(color: _textPri),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD84D),
                  foregroundColor: const Color(0xFF141210),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderCol, width: 2),
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
                            notes: 'Nhập tự động từ link bản đồ.',
                            category: place.category,
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
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Lỗi lưu địa điểm: ${friendlyError(e)}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('system_phases.import_error'.tr()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  'system_phases.import_button'.tr(),
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
