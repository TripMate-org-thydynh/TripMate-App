import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../trips/application/trips_providers.dart';
import '../../trips/domain/trip.dart';
import '../../trips/presentation/create_trip_sheet.dart';
import 'trip_itinerary_screen.dart';

/// Tab "Lịch trình" ở thanh điều hướng.
///
/// Trước đây tab này là `ItineraryScreen` — 1805 dòng UI **không gọi API nào**:
/// một chuyến "Đà Lạt Chill · Oct 12-15 · 3 Collaborators" bịa, cảnh báo mưa
/// bịa, thời tiết cứng "18°C, Cloudy", các mục lịch trình bịa và cả một
/// placeholder chưa thay `{count} spots mapped` lộ ra màn hình.
///
/// Nay tab hiển thị lịch trình THẬT: có nhiều chuyến thì cho chọn, một chuyến
/// thì vào thẳng, chưa có chuyến nào thì mời tạo chuyến đầu tiên.
class ItineraryTab extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const ItineraryTab({super.key, required this.isDarkMode});

  @override
  ConsumerState<ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends ConsumerState<ItineraryTab> {
  /// Chuyến đang xem. `null` = chưa chọn → dùng chuyến đầu danh sách.
  String? _selectedTripId;

  Color get _ink =>
      widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _bg =>
      widget.isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);

    return tripsAsync.when(
      loading: () => Container(
        color: _bg,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => _message(
        icon: Icons.wifi_off_rounded,
        title: 'errors.load_failed'.tr(),
        body: '',
        actionLabel: 'general.retry'.tr(),
        onAction: () => ref.invalidate(tripsProvider),
      ),
      data: (trips) {
        if (trips.isEmpty) {
          return _message(
            icon: Icons.map_outlined,
            title: 'itinerary.no_trip_title'.tr(),
            body: 'itinerary.no_trip_body'.tr(),
            actionLabel: 'trips.create_trip'.tr(),
            onAction: () => CreateTripSheet.show(context, widget.isDarkMode),
          );
        }

        final current = trips.firstWhere(
          (t) => t.id == _selectedTripId,
          orElse: () => trips.first,
        );

        return Column(
          children: [
            if (trips.length > 1) _tripSwitcher(trips, current),
            Expanded(
              child: TripItineraryScreen(
                // Key theo tripId để đổi chuyến là dựng lại nội dung.
                key: ValueKey(current.id),
                tripId: current.id,
                isDarkMode: widget.isDarkMode,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Thanh chọn chuyến khi user có nhiều hơn một chuyến.
  Widget _tripSwitcher(List<Trip> trips, Trip current) {
    return Container(
      height: 52,
      color: _bg,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: GenZTokens.space4,
          vertical: GenZTokens.space2,
        ),
        itemCount: trips.length,
        separatorBuilder: (_, _) => const SizedBox(width: GenZTokens.space2),
        itemBuilder: (context, i) {
          final t = trips[i];
          final selected = t.id == current.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedTripId = t.id),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: GenZTokens.space4,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: selected ? GenZTokens.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                border: Border.all(
                  color: selected ? _ink : _ink.withValues(alpha: 0.3),
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Center(
                child: Text(
                  t.name,
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? GenZTokens.ink : _ink,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String body,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      color: _bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(GenZTokens.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(GenZTokens.space5),
                decoration: BoxDecoration(
                  color: GenZTokens.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: _ink, width: GenZTokens.borderWidth),
                ),
                child: Icon(icon, size: 34, color: GenZTokens.ink),
              ),
              const SizedBox(height: GenZTokens.space5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: GenZTokens.space2),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    fontSize: 14,
                    height: 1.45,
                    color: _ink.withValues(alpha: 0.65),
                  ),
                ),
              ],
              const SizedBox(height: GenZTokens.space5),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GenZTokens.green,
                  foregroundColor: GenZTokens.ink,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: GenZTokens.space6,
                    vertical: GenZTokens.space4,
                  ),
                  side: BorderSide(color: _ink, width: GenZTokens.borderWidth),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: GenZTokens.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
