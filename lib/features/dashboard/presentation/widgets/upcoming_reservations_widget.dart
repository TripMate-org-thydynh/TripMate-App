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
  Color get _surface => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent => isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;

  static const _icons = <ReservationType, IconData>{
    ReservationType.flight: PhosphorIconsFill.airplaneTilt,
    ReservationType.train: PhosphorIconsFill.train,
    ReservationType.bus: PhosphorIconsFill.bus,
    ReservationType.hotel: PhosphorIconsFill.buildings,
    ReservationType.restaurant: PhosphorIconsFill.forkKnife,
    ReservationType.car: PhosphorIconsFill.car,
    ReservationType.event: PhosphorIconsFill.ticket,
    ReservationType.attraction: PhosphorIconsFill.mapPin,
    ReservationType.other: PhosphorIconsFill.bookmarkSimple,
  };

  Color _typeColor(ReservationType t) {
    switch (t) {
      case ReservationType.flight:
        return GenZTokens.chart4;
      case ReservationType.train:
        return isDarkMode ? GenZTokens.infoDark : GenZTokens.info;
      case ReservationType.bus:
        return GenZTokens.chart1;
      case ReservationType.hotel:
        return GenZTokens.chart5;
      case ReservationType.restaurant:
        return GenZTokens.chart3;
      case ReservationType.car:
        return GenZTokens.chart6;
      case ReservationType.event:
        return isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
      case ReservationType.attraction:
        return GenZTokens.chart2;
      case ReservationType.other:
        return isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    }
  }

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
            Icon(PhosphorIconsFill.ticket, size: 20, color: _accent),
            const SizedBox(width: 8),
            Text(
              'general.upcoming_tickets'.tr(),
              style: AppFonts.heading(
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
    final icon = _icons[r.type] ?? PhosphorIconsFill.bookmarkSimple;
    final color = _typeColor(r.type);
    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
        boxShadow: GenZTokens.hardShadow(_ink, isDarkMode),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _fill,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                  border: Border.all(
                    color: _line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              if (r.startTime != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _fill,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                    border: Border.all(
                      color: _line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Text(
                    _countdown(r.startTime!.toLocal()),
                    style: AppFonts.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
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
              fontWeight: FontWeight.w700,
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
              fontWeight: FontWeight.w400,
              color: _inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
