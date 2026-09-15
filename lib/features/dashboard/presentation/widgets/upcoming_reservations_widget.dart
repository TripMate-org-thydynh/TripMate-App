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
  Color get _inkSoft =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _paper => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

  static const _meta = <ReservationType, (IconData, Color)>{
    ReservationType.flight: (PhosphorIconsFill.airplaneTilt, GenZTokens.blue),
    ReservationType.train: (PhosphorIconsFill.train, GenZTokens.info),
    ReservationType.bus: (PhosphorIconsFill.bus, GenZTokens.green),
    ReservationType.hotel: (PhosphorIconsFill.buildings, GenZTokens.purple),
    ReservationType.restaurant: (
      PhosphorIconsFill.forkKnife,
      GenZTokens.orange,
    ),
    ReservationType.car: (PhosphorIconsFill.car, GenZTokens.magenta),
    ReservationType.event: (PhosphorIconsFill.ticket, GenZTokens.yellow),
    ReservationType.attraction: (PhosphorIconsFill.mapPin, GenZTokens.red),
    ReservationType.other: (
      PhosphorIconsFill.bookmarkSimple,
      GenZTokens.lilac,
    ),
  };

  (IconData, Color) _typeMeta(ReservationType t) =>
      _meta[t] ?? _meta[ReservationType.other]!;

  String _countdown(DateTime d) {
    final diff = d.difference(DateTime.now());
    if (diff.inDays >= 1) {
      return 'reservations.in_days'.tr(namedArgs: {'n': '${diff.inDays}'});
    }
    if (diff.inHours >= 1) {
      return 'reservations.in_hours'.tr(namedArgs: {'n': '${diff.inHours}'});
    }
    if (diff.inMinutes >= 1) {
      return 'reservations.in_minutes'.tr(namedArgs: {'n': '${diff.inMinutes}'});
    }
    return 'reservations.upcoming'.tr();
  }

  String _fmt(BuildContext context, DateTime d) {
    return DateFormat('d MMM · HH:mm', context.locale.languageCode).format(d);
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
            itemBuilder: (context, i) => _card(context, items[i]),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, Reservation r) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: meta.$2,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _countdown(r.startTime!.toLocal()),
                    style: AppFonts.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GenZTokens.ink,
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
              if (r.startTime != null) _fmt(context, r.startTime!.toLocal()),
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
