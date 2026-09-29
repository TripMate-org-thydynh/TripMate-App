import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/network/error_message.dart';

import '../../../core/widgets/gen_z_widgets.dart';
import '../application/trips_providers.dart';
import '../domain/trip.dart';
import '../domain/trip_vibe.dart';
import 'trip_hub_screen.dart';
import 'create_trip_sheet.dart';
import '../../social/presentation/widgets/notification_bell.dart';

/// Vibe đang lọc ở màn "Chuyến của tôi" (null = tất cả).
final tripVibeFilterProvider = StateProvider<String?>((ref) => null);

/// Màn "Chuyến của tôi" — wired thật vào BE qua [tripsProvider].
/// Demo pattern data-layer chuẩn: loading (skeleton) / error (retry) / empty / data.
class MyTripsScreen extends ConsumerWidget {
  final bool isDarkMode;
  const MyTripsScreen({super.key, this.isDarkMode = false});

  Color _bgOf(BuildContext context) =>
      isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;

  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textPri => _ink;
  Color get _textSec =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _surface =>
      isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent => isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      isDarkMode ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _accentSoft =>
      isDarkMode ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color get _danger =>
      isDarkMode ? GenZTokens.dangerDark : GenZTokens.danger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accent,
        foregroundColor: _onAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          CreateTripSheet.show(context, isDarkMode);
        },
        icon: Icon(PhosphorIcons.plus(), color: _onAccent),
        label: Text(
          'trips.new'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: _onAccent,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        elevation: 0,
        title: Text(
          'trips.mine'.tr(),
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _textPri,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          NotificationBell(isDarkMode: isDarkMode, color: _textPri),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: _accent,
        onRefresh: () => ref.read(tripsProvider.notifier).refresh(),
        child: tripsAsync.when(
          loading: () => _buildSkeleton(),
          error: (e, _) => _buildError(context, ref, e),
          data: (trips) =>
              trips.isEmpty ? _buildEmpty(context) : _buildData(context, ref, trips),
        ),
      ),
    );
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, i) => Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _fill,
                  border: Border.all(
                    color: _danger,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.cloudSlash(),
                  color: _danger,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'trips.load_failed'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPri,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  friendlyError(error),
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 13, color: _textSec),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: BorderSide(
                    color: _line,
                    width: GenZTokens.borderWidthThin,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(tripsProvider.notifier).refresh();
                },
                icon: Icon(PhosphorIcons.arrowsClockwise(), size: 16),
                label: Text(
                  'general.retry'.tr(),
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _fill,
                  border: Border.all(
                    color: _line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill),
                  color: _accent,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'trips.empty'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textPri,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'trips.empty_sub'.tr(),
                style: AppFonts.body(fontSize: 14, color: _textSec),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Data + filter theo vibe ────────────────────────────────────────────────
  Widget _buildData(BuildContext context, WidgetRef ref, List<Trip> trips) {
    final selected = ref.watch(tripVibeFilterProvider);
    // Chỉ hiện chip cho các vibe THỰC SỰ có trong danh sách.
    final present = <String>{
      for (final t in trips)
        if (TripVibe.of(t.vibe) != null) t.vibe!.toUpperCase(),
    }.toList();
    final filtered = selected == null
        ? trips
        : trips.where((t) => (t.vibe ?? '').toUpperCase() == selected).toList();

    final chipRow = present.length >= 2
        ? SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              children: [
                _filterChip(
                  context,
                  ref,
                  null,
                  'trips.filter_all'.tr(),
                  null,
                  selected == null,
                ),
                for (final code in present)
                  Builder(
                    builder: (_) {
                      final v = TripVibe.of(code)!;
                      return _filterChip(
                        context,
                        ref,
                        code,
                        v.label,
                        v.icon,
                        selected == code,
                      );
                    },
                  ),
              ],
            ),
          )
        : null;
    return _buildList(filtered, header: chipRow);
  }

  Widget _filterChip(
    BuildContext context,
    WidgetRef ref,
    String? code,
    String label,
    IconData? icon,
    bool selected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(tripVibeFilterProvider.notifier).state = code;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _accentSoft : _fill,
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            border: Border.all(
              color: selected ? _accent : _line,
              width: selected
                  ? GenZTokens.borderWidthFocus
                  : GenZTokens.borderWidthThin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? _accent : _textSec,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _accent : _textSec,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Data list ──────────────────────────────────────────────────────────────
  Widget _buildList(List<Trip> trips, {Widget? header}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length + (header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header;
        final i = header != null ? index - 1 : index;
        final t = trips[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 250 + i * 70),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - v)),
            child: Opacity(opacity: v, child: child),
          ),
          child: _tripCard(context, t),
        );
      },
    );
  }

  Widget _tripCard(BuildContext context, Trip t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PressableCard(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TripHubScreen(trip: t, isDarkMode: isDarkMode),
            ),
          );
        },
        color: _surface,
        radius: GenZTokens.radiusCard,
        borderWidth: GenZTokens.borderWidthThin,
        depth: 1,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                    color: _fill,
                    border: Border.all(
                      color: _line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Icon(
                    PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                    color: _accent,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textPri,
                        ),
                      ),
                      Text(
                        [
                          if (t.destination != null &&
                              t.destination!.isNotEmpty)
                            t.destination!,
                          'trips.days_members'.tr(
                            namedArgs: {
                              'days': '${t.durationDays}',
                              'members': '${t.memberCount}',
                            },
                          ),
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(fontSize: 13, color: _textSec),
                      ),
                      if (TripVibe.of(t.vibe) != null) ...[
                        const SizedBox(height: 6),
                        Builder(
                          builder: (_) {
                            final v = TripVibe.of(t.vibe)!;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: v.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  GenZTokens.radiusPill,
                                ),
                                border: Border.all(
                                  color: v.color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(v.icon, size: 12, color: v.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    v.label,
                                    style: AppFonts.heading(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _textPri,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _fill,
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusPill,
                    ),
                    border: Border.all(
                      color: _line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Text(
                    t.inviteCode,
                    style: AppFonts.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textSec,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
