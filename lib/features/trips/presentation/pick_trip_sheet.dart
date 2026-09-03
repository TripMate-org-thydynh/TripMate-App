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

  const PickTripSheet({
    super.key,
    required this.isDarkMode,
    this.title,
  });

  static Future<Trip?> show(
    BuildContext context,
    bool isDarkMode, {
    String? title,
  }) {
    return showModalBottomSheet<Trip>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PickTripSheet(isDarkMode: isDarkMode, title: title),
    );
  }

  Color _bg(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _surface => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _sub => isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: _bg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: _ink, width: 2.5),
          left: BorderSide(color: _ink, width: 2.5),
          right: BorderSide(color: _ink, width: 2.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _sub.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title ?? 'trips.pick_trip'.tr(),
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
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
      radius: 16,
      borderWidth: 2,
      depth: 3,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: GenZTokens.yellow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GenZTokens.ink, width: 2),
            ),
            child: const Icon(
              Icons.airplane_ticket,
              color: GenZTokens.ink,
              size: 22,
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
                    fontWeight: FontWeight.w800,
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
            icon: Icons.add,
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
