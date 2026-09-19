import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/itinerary_repository.dart';
import '../domain/itinerary_item.dart';
import '../../../core/map/map_tiles.dart';

/// Bản đồ lộ trình: mọi điểm dừng trong timeline, đánh số theo giờ, nối bằng
/// đường theo đúng thứ tự đi.
///
/// Mở từ nút "Đường đi" của một ngày ([initialDay]); chip trên cùng đổi sang
/// ngày khác hoặc "Tất cả" để xem cả chuyến. Điểm chưa có toạ độ được backend
/// tự tìm (`POST .../itinerary/geocode`) ngay khi mở màn.
class DayRouteMapScreen extends ConsumerStatefulWidget {
  const DayRouteMapScreen({
    super.key,
    required this.tripId,
    this.initialDay,
    this.isDarkMode = false,
  });

  final String tripId;

  /// Ngày được chọn sẵn. `null` = cả chuyến.
  final int? initialDay;
  final bool isDarkMode;

  @override
  ConsumerState<DayRouteMapScreen> createState() => _DayRouteMapScreenState();
}

class _DayRouteMapScreenState extends ConsumerState<DayRouteMapScreen> {
  final _map = MapController();
  int? _day;
  bool _geocoding = false;
  String? _selectedId;

  /// Khung đã canh cho (ngày, số điểm có toạ độ) nào — chỉ canh lại khi đổi.
  String? _fittedKey;

  @override
  void initState() {
    super.initState();
    _day = widget.initialDay;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillMissingCoords());
  }

  bool get _dark =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => _dark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _accent => Theme.of(context).colorScheme.primary;
  Color get _onAccent => Theme.of(context).colorScheme.onPrimary;

  /// Nhờ backend bù toạ độ cho các điểm chỉ có tên/địa chỉ, rồi nạp lại.
  Future<void> _fillMissingCoords() async {
    final grouped = await ref.read(tripItineraryProvider(widget.tripId).future);
    final hasMissing = grouped.values.expand((e) => e).any((i) => !i.hasCoords);
    if (!hasMissing || !mounted) return;
    setState(() => _geocoding = true);
    try {
      await ApiService.post('/trips/${widget.tripId}/itinerary/geocode', {});
      ref.invalidate(tripItineraryProvider(widget.tripId));
    } catch (_) {
      // Không tìm được thì vẫn vẽ những điểm đã có toạ độ.
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  List<ItineraryItem> _visible(Map<int, List<ItineraryItem>> grouped) {
    final days = grouped.keys.toList()..sort();
    return [
      for (final d in days)
        if (_day == null || _day == d) ...grouped[d]!,
    ];
  }

  void _fit(List<LatLng> pts) {
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      _map.move(pts.first, 15);
      return;
    }
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: pts,
        padding: const EdgeInsets.all(56),
      ),
    );
  }

  Future<void> _openGoogleMaps(List<ItineraryItem> items) async {
    final messenger = ScaffoldMessenger.of(context);
    final stops = items
        .map(
          (it) => it.hasCoords
              ? '${it.latitude},${it.longitude}'
              : (it.placeAddress?.trim().isNotEmpty ?? false)
              ? it.placeAddress!.trim()
              : it.placeName.trim(),
        )
        .where((s) => s.isNotEmpty)
        .toList();
    if (stops.length < 2) {
      messenger.showSnackBar(
        SnackBar(content: Text('itinerary.need_two_stops'.tr())),
      );
      return;
    }
    HapticFeedback.lightImpact();
    final path = stops.map(Uri.encodeComponent).join('/');
    final uri = Uri.parse('https://www.google.com/maps/dir/$path');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      messenger.showSnackBar(
        SnackBar(content: Text('itinerary.maps_failed'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tripItineraryProvider(widget.tripId));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'itinerary.route_map_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'itinerary.load_failed'.tr(),
            style: AppFonts.body(color: _inkSoft),
          ),
        ),
        data: (grouped) {
          final days = grouped.keys.toList()..sort();
          final items = _visible(grouped);
          final located = items.where((i) => i.hasCoords).toList();
          final pts = [
            for (final i in located) LatLng(i.latitude!, i.longitude!),
          ];

          // Canh khung vừa mọi điểm khi mở màn / đổi ngày / có toạ độ mới.
          final fitKey = '$_day|${pts.length}';
          if (_fittedKey != fitKey) {
            _fittedKey = fitKey;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fit(pts);
            });
          }

          return Column(
            children: [
              _dayChips(days),
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _map,
                      options: MapOptions(
                        initialCenter: pts.isNotEmpty
                            ? pts.first
                            : const LatLng(11.9404, 108.4583),
                        initialZoom: 13,
                      ),
                      children: [
                        ...mapTileLayers(dark: _dark),
                        PolylineLayer(
                          polylines: [
                            // Mỗi ngày một đường riêng — không nối ngày 1 sang ngày 2.
                            for (final d in days)
                              if (_day == null || _day == d)
                                Polyline(
                                  points: [
                                    for (final i in grouped[d]!)
                                      if (i.hasCoords)
                                        LatLng(i.latitude!, i.longitude!),
                                  ],
                                  strokeWidth: 4,
                                  color: _accent.withValues(alpha: 0.75),
                                ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            for (final (n, i) in located.indexed)
                              Marker(
                                point: LatLng(i.latitude!, i.longitude!),
                                width: 34,
                                height: 34,
                                child: _pin(n + 1, i.id == _selectedId),
                              ),
                          ],
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(kMapAttribution),
                          ],
                        ),
                      ],
                    ),
                    if (_geocoding)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: _banner(
                          PhosphorIcons.magnifyingGlass(),
                          'itinerary.route_locating'.tr(),
                        ),
                      )
                    else if (located.length < items.length)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: _banner(
                          PhosphorIcons.warningCircle(),
                          'itinerary.route_missing'.tr(
                            namedArgs: {
                              'n': '${items.length - located.length}',
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(flex: 2, child: _stopList(items, located)),
            ],
          );
        },
      ),
    );
  }

  Widget _dayChips(List<int> days) {
    Widget chip(String label, int? day) {
      final on = _day == day;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: on,
          showCheckmark: false,
          onSelected: (_) => setState(() {
            _day = day;
            _selectedId = null;
          }),
          labelStyle: AppFonts.body(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: on ? _onAccent : _ink,
          ),
          selectedColor: _accent,
          backgroundColor: _surface,
          side: BorderSide(color: on ? _accent : _line),
          shape: const StadiumBorder(),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        children: [
          chip('itinerary.route_all_days'.tr(), null),
          for (final d in days)
            chip('common.day_n'.tr(namedArgs: {'n': '$d'}), d),
        ],
      ),
    );
  }

  Widget _pin(int n, bool selected) => AnimatedScale(
    scale: selected ? 1.25 : 1,
    duration: const Duration(milliseconds: 180),
    child: Container(
      decoration: BoxDecoration(
        color: _accent,
        shape: BoxShape.circle,
        border: Border.all(color: _surface, width: 2.5),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6)],
      ),
      alignment: Alignment.center,
      child: Text(
        '$n',
        style: AppFonts.mono(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _onAccent,
        ),
      ),
    ),
  );

  Widget _banner(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _surface.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: _inkSoft),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppFonts.body(fontSize: 12, color: _ink)),
        ),
      ],
    ),
  );

  Widget _stopList(List<ItineraryItem> items, List<ItineraryItem> located) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => Divider(color: _line, height: 1),
              itemBuilder: (_, idx) {
                final it = items[idx];
                final n = located.indexOf(it);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onTap: it.hasCoords
                      ? () {
                          setState(() => _selectedId = it.id);
                          _map.move(LatLng(it.latitude!, it.longitude!), 16);
                        }
                      : null,
                  leading: n >= 0
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          child: _pin(n + 1, false),
                        )
                      : Icon(PhosphorIcons.mapPin(), color: _inkSoft),
                  title: Text(
                    it.placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  subtitle: Text(
                    [
                      if (_day == null)
                        'common.day_n'.tr(namedArgs: {'n': '${it.day}'}),
                      it.startTime,
                      if (!it.hasCoords) 'itinerary.route_no_location'.tr(),
                    ].join(' · '),
                    style: AppFonts.body(fontSize: 12, color: _inkSoft),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openGoogleMaps(items),
                  icon: Icon(PhosphorIcons.arrowSquareOut(), size: 18),
                  label: Text('itinerary.route_open_google'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: BorderSide(color: _line),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
