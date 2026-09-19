import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/services/weather_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../trip_planner/presentation/trip_itinerary_screen.dart';
import '../../data/today_brief_repository.dart';

/// Thẻ "Bản tin hôm nay" trên màn chính — chỉ hiện khi chuyến đang diễn ra
/// (`1 <= day` và còn điểm dừng hoặc việc cần làm).
class TodayBriefCard extends ConsumerWidget {
  const TodayBriefCard({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  final String tripId;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todayBriefProvider(tripId));
    return async.maybeWhen(
      data: (brief) {
        if (brief == null) return const SizedBox.shrink();
        if (brief.day < 1) return const SizedBox.shrink();
        if (brief.stops.isEmpty && brief.todos.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildCard(context, brief);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, TodayBrief brief) {
    final dark = isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = dark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = dark ? GenZTokens.fillDark : GenZTokens.fill;
    final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = Theme.of(context).colorScheme.primary;
    final warning = dark ? GenZTokens.warningDark : GenZTokens.warning;
    final info = dark ? GenZTokens.infoDark : GenZTokens.info;

    final wDesc = brief.weather != null
        ? WeatherService.describe(brief.weather!.weatherCode)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TripItineraryScreen(
              tripId: brief.tripId,
              isDarkMode: dark,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(color: line),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: tiêu đề ngày + thông tin thời tiết
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.calendarStar(
                                PhosphorIconsStyle.fill,
                              ),
                              size: 18,
                              color: accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'dashboard.today_brief_title'.tr(
                                namedArgs: {'day': '${brief.day}'},
                              ),
                              style: AppFonts.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                          ],
                        ),
                        if (wDesc != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(wDesc.icon, size: 14, color: wDesc.color),
                              const SizedBox(width: 4),
                              Text(
                                wDesc.description,
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (brief.weather != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusPill,
                        ),
                        border: Border.all(color: line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${brief.weather!.tempMin.round()}°–${brief.weather!.tempMax.round()}°C',
                            style: AppFonts.mono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          if (brief.weather!.rainProbability > 0) ...[
                            const SizedBox(width: 6),
                            Icon(
                              PhosphorIcons.drop(PhosphorIconsStyle.fill),
                              size: 12,
                              color: info,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${brief.weather!.rainProbability}%',
                              style: AppFonts.mono(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: info,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),

              // Lịch trình tiếp theo (tối đa 3 điểm)
              if (brief.stops.isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: line),
                const SizedBox(height: 10),
                Text(
                  'dashboard.today_stops'.tr(),
                  style: AppFonts.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: inkSoft,
                  ),
                ),
                const SizedBox(height: 6),
                for (final stop in brief.stops.take(3)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            stop.startTime,
                            style: AppFonts.mono(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            stop.placeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ),
                        if (stop.rainRisk != null && stop.rainRisk! > 0) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIcons.cloudRain(
                                  PhosphorIconsStyle.fill,
                                ),
                                size: 14,
                                color: warning,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${stop.rainRisk}%',
                                style: AppFonts.mono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],

              // Việc cần làm
              if (brief.todos.isNotEmpty) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: line),
                const SizedBox(height: 10),
                Text(
                  'dashboard.today_todos'.tr(),
                  style: AppFonts.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: inkSoft,
                  ),
                ),
                const SizedBox(height: 6),
                for (final todo in brief.todos.take(3)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.checkSquare(),
                          size: 15,
                          color: inkSoft,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${todo.title} — ${todo.assigneeName != null && todo.assigneeName!.trim().isNotEmpty ? todo.assigneeName! : 'dashboard.unassigned'.tr()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              fontSize: 13,
                              color: ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    ),
  );
  }
}
