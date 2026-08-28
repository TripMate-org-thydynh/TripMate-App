import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/gen_z_tokens.dart';
import '../../../reservations/data/reservations_repository.dart';

/// Widget dashboard "Vé sắp tới" — feed liên chuyến (giống TREK). Ẩn khi rỗng.
class UpcomingReservationsWidget extends ConsumerWidget {
  final bool isDarkMode;
  const UpcomingReservationsWidget({super.key, required this.isDarkMode});

  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _paper => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

  static const _meta = <ReservationType, (IconData, Color)>{
    ReservationType.flight: (PhosphorIconsFill.airplaneTilt, Color(0xFF3D8BFF)),
    ReservationType.train: (PhosphorIconsFill.train, Color(0xFF06B6D4)),
    ReservationType.bus: (PhosphorIconsFill.bus, Color(0xFF1FA85C)),
    ReservationType.hotel: (PhosphorIconsFill.buildings, Color(0xFF8B4DE8)),
    ReservationType.restaurant: (PhosphorIconsFill.forkKnife, Color(0xFFF5822B)),
    ReservationType.car: (PhosphorIconsFill.car, Color(0xFFD6248C)),
    ReservationType.event: (PhosphorIconsFill.ticket, Color(0xFFFFB020)),
    ReservationType.attraction: (PhosphorIconsFill.mapPin, Color(0xFFEF4444)),
    ReservationType.other: (PhosphorIconsFill.bookmarkSimple, Color(0xFF64748B)),
  };

  (IconData, Color) _typeMeta(ReservationType t) =>
      _meta[t] ?? _meta[ReservationType.other]!;

  static const _months = 'Th1 Th2 Th3 Th4 Th5 Th6 Th7 Th8 Th9 Th10 Th11 Th12';
  String _countdown(DateTime d) {
    final diff = d.difference(DateTime.now());
    if (diff.inDays >= 1) return 'còn ${diff.inDays} ngày';
    if (diff.inHours >= 1) return 'còn ${diff.inHours} giờ';
    if (diff.inMinutes >= 1) return 'còn ${diff.inMinutes} phút';
    return 'sắp diễn ra';
  }

  String _fmt(DateTime d) {
    final m = _months.split(' ')[d.month - 1];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$m ${d.day} · $hh:$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingReservationsProvider);
    final items = async.valueOrNull ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsFill.ticket, size: 20, color: _ink),
            const SizedBox(width: 8),
            Text(
              'general.upcoming_tickets'.tr(),
              style: AppFonts.heading(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _card(items[i]),
          ),
        ),
      ],
    );
  }

  Widget _card(Reservation r) {
    final meta = _typeMeta(r.type);
    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ink.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: meta.$2.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(meta.$1, color: meta.$2, size: 18),
              ),
              const Spacer(),
              if (r.startTime != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: meta.$2,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _countdown(r.startTime!.toLocal()),
                    style: AppFonts.mono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (r.startTime != null) _fmt(r.startTime!.toLocal()),
              if (r.tripName != null && r.tripName!.isNotEmpty) r.tripName!,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
