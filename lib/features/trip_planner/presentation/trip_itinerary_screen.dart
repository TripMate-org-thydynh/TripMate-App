import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../dashboard/data/home_feed_repository.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/itinerary_repository.dart';
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

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  /// Accent lấy từ theme đang chọn.
  ///
  /// Truoc day la `isDark ? Color(0xFFF5822B) : Color(0xFFF5822B)` — hai
  /// nhanh y het nhau, va 0xFFF5822B chinh la accent cua preset *grape*.
  /// Nguoi dung o mint (vang) van thay man nay mau cam, va doi theme khong
  /// an. Doc tu `colorScheme` de mau di theo lua chon that.
  Color _primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color get _textPri => isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final dayCtrl = TextEditingController(text: '1');
    final timeCtrl = TextEditingController(text: '09:00');
    final placeCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    String selectedCategory = 'OTHER';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'itinerary.add_stop'.tr(),
            style: AppFonts.heading(
              fontWeight: FontWeight.w800,
              color: _textPri,
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
                        // keyboardType chỉ gợi ý bàn phím — vẫn dán/gõ được chữ nếu không lọc.
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppFonts.body(color: _textPri),
                        decoration: InputDecoration(
                          labelText: 'itinerary.day_label'.tr(),
                          labelStyle: AppFonts.body(color: _textSec),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: timeCtrl,
                        style: AppFonts.body(color: _textPri),
                        decoration: InputDecoration(
                          labelText: 'itinerary.time_hint'.tr(),
                          labelStyle: AppFonts.body(color: _textSec),
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: placeCtrl,
                  style: AppFonts.body(color: _textPri),
                  decoration: InputDecoration(
                    hintText: 'itinerary.place_name'.tr(),
                    hintStyle: AppFonts.body(color: _textSec),
                  ),
                ),
                TextField(
                  controller: addrCtrl,
                  style: AppFonts.body(color: _textPri),
                  decoration: InputDecoration(
                    hintText: 'itinerary.place_address'.tr(),
                    hintStyle: AppFonts.body(color: _textSec),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: _surface,
                  style: AppFonts.body(color: _textPri),
                  decoration: InputDecoration(
                    labelText: 'itinerary.category'.tr(),
                    labelStyle: AppFonts.body(color: _textSec),
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
                style: AppFonts.body(color: _textSec),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _primaryOf(context)),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('packing.add'.tr()),
            ),
          ],
        ),
      ),
    );
    if (ok != true || placeCtrl.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripItineraryProvider(tripId));
    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryOf(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => _addItem(context, ref),
        icon: const Icon(Icons.add),
        label: Text(
          'itinerary.add_place'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'itinerary.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              color: _primaryOf(context),
              onRefresh: () async =>
                  ref.invalidate(tripItineraryProvider(tripId)),
              child: async.when(
                loading: () => _skeleton(),
                error: (e, _) => _error(context, ref, e),
                data: (grouped) {
                  if (grouped.isEmpty) return _empty(context);
                  final days = grouped.keys.toList()..sort();
                  return ListView(
                    // Chừa chỗ cho FAB "Thêm điểm" (BUG-006).
                    padding: const EdgeInsets.all(
                      20,
                    ).copyWith(bottom: 96),
                    children: [
                      for (final day in days) ...[
                        _dayHeader(context, day, grouped[day]!),
                        const SizedBox(height: 12),
                        ...grouped[day]!.map((it) => _itemCard(context, it)),
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

  Widget _dayHeader(
    BuildContext context,
    int day,
    List<ItineraryItem> items,
  ) => Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _primaryOf(context),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          'common.day_n'.tr(namedArgs: {'n': '$day'}),
          style: AppFonts.heading(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            // Nen la accent: dung `onPrimary` cua preset thay vi trang cung,
            // vi accent mint la vang thi chu trang chim han.
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      const Spacer(),
      // Mở lộ trình ngày này trên Google Maps (chuỗi điểm dừng theo thứ tự).
      GestureDetector(
        onTap: () => _openDayInMaps(context, items),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _textPri.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                size: 13,
                color: _primaryOf(context),
              ),
              const SizedBox(width: 6),
              Text(
                'itinerary.directions'.tr(),
                style: AppFonts.heading(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _textPri,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  /// Ghép các điểm dừng trong ngày thành 1 URL chỉ đường Google Maps.
  /// Nếu tất cả điểm đều có toạ độ → tự tối ưu thứ tự (nearest-neighbor).
  Future<void> _openDayInMaps(
    BuildContext context,
    List<ItineraryItem> items,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    // Tối ưu thứ tự khi mọi điểm đều có toạ độ và đủ để đáng tối ưu.
    var ordered = items;
    var optimized = false;
    if (items.length >= 3 && items.every((i) => i.hasCoords)) {
      ordered = _nearestNeighborOrder(items);
      optimized = true;
    }

    final stops = ordered
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
        SnackBar(
          content: Text('itinerary.need_two_stops'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    final path = stops.map(Uri.encodeComponent).join('/');
    final uri = Uri.parse('https://www.google.com/maps/dir/$path');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('itinerary.maps_failed'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (optimized) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('itinerary.optimized'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Sắp lại thứ tự điểm dừng bằng nearest-neighbor, giữ điểm đầu làm khởi hành.
  List<ItineraryItem> _nearestNeighborOrder(List<ItineraryItem> items) {
    final remaining = [...items];
    final route = <ItineraryItem>[remaining.removeAt(0)];
    while (remaining.isNotEmpty) {
      final last = route.last;
      var bestIdx = 0;
      var bestDist = double.infinity;
      for (var i = 0; i < remaining.length; i++) {
        final d = _haversine(
          last.latitude!,
          last.longitude!,
          remaining[i].latitude!,
          remaining[i].longitude!,
        );
        if (d < bestDist) {
          bestDist = d;
          bestIdx = i;
        }
      }
      route.add(remaining.removeAt(bestIdx));
    }
    return route;
  }

  /// Khoảng cách great-circle (km) — đủ chính xác để so sánh thứ tự.
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    double toRad(double d) => d * (math.pi / 180.0);
    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  Widget _itemCard(BuildContext context, ItineraryItem it) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black,
          width: 2,
        ),
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
                  fontWeight: FontWeight.w700,
                  // Khong dung accent lam mau chu tren nen sang: accent mint la
                  // vang, doc gan nhu khong ra. Diem nhan mau da nam o vach doc
                  // ben canh (accent alpha 0.2).
                  color: _textPri,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Container(
            width: 2,
            height: 40,
            color: _primaryOf(context).withValues(alpha: 0.2),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_categoryEmoji(it.category)} ${it.placeName}',
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                  ),
                ),
                if (it.placeAddress != null)
                  Text(
                    it.placeAddress!,
                    style: AppFonts.body(fontSize: 12, color: _textSec),
                  ),
                Text(
                  'itinerary.minutes'.tr(
                    namedArgs: {'n': '${it.durationMinutes}'},
                  ),
                  style: AppFonts.body(fontSize: 11, color: _textSec),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(String? cat) {
    switch (cat?.toUpperCase()) {
      case 'FOOD':
        return '🍔';
      case 'ACTIVITIES':
        return '🎭';
      case 'ACCOMMODATION':
        return '🏨';
      case 'COFFEE':
        return '☕';
      default:
        return '📍';
    }
  }

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      5,
      (i) => Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  Widget _error(BuildContext context, WidgetRef ref, Object e) => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'itinerary.load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _primaryOf(context)),
              onPressed: () => ref.invalidate(tripItineraryProvider(tripId)),
              icon: const Icon(Icons.refresh),
              label: Text('general.retry'.tr()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _empty(BuildContext context) => ListView(
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
                color: _primaryOf(context).withValues(alpha: 0.12),
              ),
              child: Icon(
                PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                color: _primaryOf(context),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'itinerary.empty'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'itinerary.empty_sub'.tr(),
              style: AppFonts.body(fontSize: 14, color: _textSec),
            ),
          ],
        ),
      ),
    ],
  );
}
