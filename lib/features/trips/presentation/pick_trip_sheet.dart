import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/gen_z_widgets.dart';
import '../application/trips_providers.dart';
import '../domain/trip.dart';
import 'create_trip_sheet.dart';

/// Bottom sheet chọn 1 chuyến đi để thao tác (chia tiền / bình chọn / khoảnh khắc...).
/// Dùng chung cho mọi entry-point cần tripId. Trả về [Trip] đã chọn (null nếu huỷ).
class PickTripSheet extends ConsumerWidget {
  final bool isDarkMode;

  /// Bo trong thi dung tieu de mac dinh (chi doc duoc o runtime).
  final String? title;

  const PickTripSheet({super.key, required this.isDarkMode, this.title});

  static Future<Trip?> show(
    BuildContext context,
    bool isDarkMode, {
    String? title,
  }) {
    return showModalBottomSheet<Trip>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GenZTokens.paper.withValues(alpha: 0),
      builder: (_) => PickTripSheet(isDarkMode: isDarkMode, title: title),
    );
  }

  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _surface => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _sub => isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(
          top: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
          left: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
          right: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
        boxShadow: GenZTokens.hardShadow(_ink, isDarkMode),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _sub.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title ?? 'trips.pick_trip'.tr(),
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: tripsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) =>
                      _empty(context, 'trips.load_list_failed'.tr()),
                  data: (trips) => trips.isEmpty
                      ? _empty(context, 'trips.empty_pick'.tr())
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: trips.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) =>
                              _tripRow(context, trips[i]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripRow(BuildContext context, Trip t) {
    return PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context, t);
      },
      color: _surface,
      radius: GenZTokens.radiusCard,
      borderWidth: GenZTokens.borderWidthThin,
      depth: 1,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? GenZTokens.fillDark : GenZTokens.fill,
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
            ),
            child: Icon(
              PhosphorIcons.ticket(PhosphorIconsStyle.fill),
              color: isDarkMode ? GenZTokens.accentDark : GenZTokens.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                Text(
                  'trips.days_members'.tr(
                    namedArgs: {
                      'days': '${t.durationDays}',
                      'members': '${t.memberCount}',
                    },
                  ),
                  style: AppFonts.body(fontSize: 12, color: _sub),
                ),
              ],
            ),
          ),
          Icon(PhosphorIcons.caretRight(), size: 18, color: _sub),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            msg,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _sub,
            ),
          ),
          const SizedBox(height: 16),
          ChunkyButton(
            icon: PhosphorIcons.plus(),
            onPressed: () {
              Navigator.pop(context);
              CreateTripSheet.show(context, isDarkMode);
            },
            child: Text('trips.create_new'.tr()),
          ),
        ],
      ),
    );
  }
}
