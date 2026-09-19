import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final tripsAsync = ref.watch(tripsProvider);

    return tripsAsync.when(
      loading: () => Container(
        color: bg,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => _message(
        isDark: isDark,
        icon: PhosphorIcons.wifiSlash(),
        title: 'errors.load_failed'.tr(),
        body: '',
        actionLabel: 'general.retry'.tr(),
        onAction: () => ref.invalidate(tripsProvider),
      ),
      data: (trips) {
        if (trips.isEmpty) {
          return _message(
            isDark: isDark,
            icon: PhosphorIcons.mapTrifold(),
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
            if (trips.length > 1) _tripSwitcher(context, isDark, trips, current),
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
  Widget _tripSwitcher(BuildContext context, bool isDark, List<Trip> trips, Trip current) {
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = Theme.of(context).colorScheme.primary;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    return Container(
      height: 52,
      color: bg,
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
                color: selected ? accentSoft : fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                border: Border.all(
                  color: selected ? accent : line,
                  width: selected
                      ? GenZTokens.borderWidth
                      : GenZTokens.borderWidthThin,
                ),
              ),
              child: Center(
                child: Text(
                  t.name,
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? accent : inkSoft,
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
    required bool isDark,
    required IconData icon,
    required String title,
    required String body,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    return Container(
      color: bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(GenZTokens.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(GenZTokens.space5),
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(icon, size: 34, color: accent),
              ),
              const SizedBox(height: GenZTokens.space5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ink,
                  letterSpacing: -0.2,
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: GenZTokens.space2),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    fontSize: 15,
                    height: 1.45,
                    color: inkSoft,
                  ),
                ),
              ],
              const SizedBox(height: GenZTokens.space5),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: GenZTokens.space6,
                    vertical: GenZTokens.space4,
                  ),
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
                    fontWeight: FontWeight.w600,
                    color: onAccent,
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
