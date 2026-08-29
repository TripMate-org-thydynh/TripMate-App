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
      Theme.of(context).scaffoldBackgroundColor;
  Color get _primary => const Color(0xFFF5822B);
  Color get _ink =>
      isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textPri => _ink;
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _ink, width: 2.5),
          boxShadow: [BoxShadow(color: _ink, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFFFD84D),
          foregroundColor: const Color(0xFF141210),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            CreateTripSheet.show(context, isDarkMode);
          },
          icon: const Icon(Icons.add),
          label: Text(
            'Chuyến mới',
            style: AppFonts.heading(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chuyến của tôi',
          style: AppFonts.heading(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _textPri,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          NotificationBell(isDarkMode: isDarkMode, color: _textPri),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () => ref.read(tripsProvider.notifier).refresh(),
        child: tripsAsync.when(
          loading: () => _buildSkeleton(),
          error: (e, _) => _buildError(context, ref, e),
          data: (trips) =>
              trips.isEmpty ? _buildEmpty() : _buildData(context, ref, trips),
        ),
      ),
    );
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, i) => Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _ink, width: 2),
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD8422B),
                  border: Border.all(color: _ink, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: _ink, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Color(0xFFFFFDF5),
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Không tải được chuyến đi',
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _primary),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(tripsProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: Text('general.retry'.tr()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC9B8FF),
                  border: Border.all(color: _ink, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: _ink, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(
                  PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill),
                  color: const Color(0xFF141210),
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Chưa có chuyến nào',
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _textPri,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tạo chuyến đầu tiên và rủ squad nào!',
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
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
              children: [
                _filterChip(
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _primary
                : (isDarkMode
                      ? const Color(0xFF262019)
                      : const Color(0xFFFFFDF5)),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _ink, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: selected ? Colors.white : _textSec),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : _textPri,
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
      padding: const EdgeInsets.all(20),
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
      padding: const EdgeInsets.only(bottom: 16),
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
        color: isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5),
        radius: 20,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _primary,
                    border: Border.all(
                      color: const Color(0xFF141210),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                    color: const Color(0xFFFFFDF5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textPri,
                        ),
                      ),
                      Text(
                        [
                          if (t.destination != null &&
                              t.destination!.isNotEmpty)
                            t.destination!,
                          '${t.durationDays} ngày · ${t.memberCount} thành viên',
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
                                color: v.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: v.color, width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(v.icon, size: 12, color: v.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    v.label,
                                    style: AppFonts.heading(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
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
                    color: const Color(0xFFFFD84D),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0xFF141210),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    t.inviteCode,
                    style: AppFonts.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF141210),
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
