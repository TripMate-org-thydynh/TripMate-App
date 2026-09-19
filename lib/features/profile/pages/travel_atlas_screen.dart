import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/theme/gen_z_tokens.dart';
import '../data/bucket_list_repository.dart';
import '../data/travel_atlas_repository.dart';
import '../domain/travel_stats.dart';

class TravelAtlasScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const TravelAtlasScreen({super.key, required this.isDarkMode});

  @override
  ConsumerState<TravelAtlasScreen> createState() => _TravelAtlasScreenState();
}

class _TravelAtlasScreenState extends ConsumerState<TravelAtlasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get _isDark =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _isDark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _bg => _isDark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => _isDark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => _isDark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _isDark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent => _isDark ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent => _isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _accentSoft => _isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color get _textSec => _isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _warning => _isDark ? GenZTokens.warningDark : GenZTokens.warning;
  Color get _danger => _isDark ? GenZTokens.dangerDark : GenZTokens.danger;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  Future<void> _addBucketItem() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
        title: Text(
          'atlas.add_bucket'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            color: _ink,
            fontSize: 17,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 160,
          style: AppFonts.body(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            hintText: 'profile.atlas_bucket_hint'.tr(),
            hintStyle: AppFonts.body(
              fontSize: 13,
              color: _textSec,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _accent, width: GenZTokens.borderWidthFocus),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(
                fontSize: 13,
                color: _textSec,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            onPressed: () => Navigator.pop(dctx, true),
            child: Text('packing.add'.tr()),
          ),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await ref.read(bucketListProvider.notifier).add(ctrl.text.trim());
    }
  }

  Future<void> _confirmDeleteBucket(BucketItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
        title: Text(
          'common.delete_confirm'.tr(namedArgs: {'name': item.title}),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            color: _ink,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(
                fontSize: 13,
                color: _textSec,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: _isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            onPressed: () => Navigator.pop(dctx, true),
            child: Text('general.delete2'.tr()),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(bucketListProvider.notifier).remove(item.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Số liệu + marker THẬT; khi loading/lỗi thì fallback rỗng.
    final atlas =
        ref.watch(travelAtlasProvider).valueOrNull ?? const TravelAtlasData();
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
              backgroundColor: _accent,
              foregroundColor: _onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
              onPressed: _addBucketItem,
              icon: Icon(PhosphorIcons.plus()),
              label: Text(
                'packing.add'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _onAccent,
                ),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'profile.travel_atlas_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: _ink,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _accent,
          unselectedLabelColor: _textSec,
          indicatorColor: _accent,
          indicatorWeight: 2.5,
          labelStyle: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: AppFonts.heading(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: 'profile.tab_map'.tr()),
            Tab(text: 'profile.tab_achievements'.tr()),
            Tab(text: 'profile.bucket_list_tab'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapTab(atlas),
          _buildStatsTab(atlas),
          _buildBucketListTab(),
        ],
      ),
    );
  }

  // ── Tab 1: Map of check-ins ──
  Widget _buildMapTab(TravelAtlasData atlas) {
    final markers = atlas.markers;
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(15.0, 110.0), // Southeast Asia center
            initialZoom: 4.0,
          ),
          children: [
            TileLayer(
              urlTemplate: _isDark
                  ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tripmate.app',
            ),
            MarkerLayer(
              markers: markers.map((place) {
                return Marker(
                  point: place.coords,
                  width: 44,
                  height: 44,
                  child: Tooltip(
                    message: place.name,
                    child: Container(
                      decoration: BoxDecoration(
                        color: place.isCheckIn ? _accent : _surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
                      ),
                      child: Center(
                        child: Icon(
                          place.isCheckIn
                              ? PhosphorIcons.camera(PhosphorIconsStyle.fill)
                              : PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          color: place.isCheckIn ? _onAccent : _accent,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          top: GenZTokens.space4,
          left: GenZTokens.space4,
          right: GenZTokens.space4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: GenZTokens.space4, vertical: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: _line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: _warning, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    markers.isEmpty
                        ? 'atlas.empty'.tr()
                        : 'atlas.pinned_count'.tr(
                            namedArgs: {'n': '${markers.length}'},
                          ),
                    style: AppFonts.body(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Badges & Streak ──
  Widget _buildStatsTab(TravelAtlasData atlas) {
    final badges = atlas.badges;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(GenZTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Streak Flame Card ──
          Container(
            padding: const EdgeInsets.all(GenZTokens.space4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
                  ),
                  child: Icon(
                    PhosphorIcons.fire(PhosphorIconsStyle.fill),
                    color: _accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: GenZTokens.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile.atlas_streak'.tr(),
                        style: AppFonts.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textSec,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        atlas.streakMonths > 0
                            ? 'atlas.streak_months'.tr(
                                namedArgs: {'n': '${atlas.streakMonths}'},
                              )
                            : 'profile.start_streak'.tr(),
                        style: AppFonts.heading(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'atlas.keep_going'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          color: _textSec,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GenZTokens.space4),

          // ── Fast stats row ──
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GenZTokens.space4),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                    border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${atlas.totalTrips}',
                        style: AppFonts.mono(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'atlas.trips'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          color: _textSec,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GenZTokens.space4),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                    border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${atlas.placesExplored}',
                        style: AppFonts.mono(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'profile.atlas_places'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          color: _textSec,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GenZTokens.space5),

          // ── Badges Gallery ──
          Row(
            children: [
              Text(
                'profile.atlas_badges'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const Spacer(),
              if (badges.isNotEmpty)
                Text(
                  '${badges.where((b) => b.isUnlocked).length}/${badges.length}',
                  style: AppFonts.mono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textSec,
                  ),
                ),
            ],
          ),
          const SizedBox(height: GenZTokens.space3),
          if (badges.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GenZTokens.space5),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(
                  color: _line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Text(
                'atlas.badges_empty'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13,
                  color: _textSec,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: GenZTokens.space2),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Container(
                  padding: const EdgeInsets.all(GenZTokens.space4),
                  decoration: BoxDecoration(
                    color: badge.isUnlocked ? _surface : _fill,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                    border: Border.all(
                      color: _line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: badge.isUnlocked ? _accentSoft : _fill,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIcons.medal(PhosphorIconsStyle.fill),
                          color: badge.isUnlocked ? _accent : _textSec,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: GenZTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge.title,
                              style: AppFonts.heading(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: badge.isUnlocked ? _ink : _textSec,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              badge.description,
                              style: AppFonts.body(
                                fontSize: 12,
                                color: _textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!badge.isUnlocked)
                        Icon(
                          PhosphorIcons.lockKey(),
                          size: 16,
                          color: _textSec,
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Tab 3: Bucket List checklist ──
  Widget _buildBucketListTab() {
    final async = ref.watch(bucketListProvider);
    return async.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          color: _accent,
          strokeWidth: 2,
        ),
      ),
      error: (e, _) => _bucketError(),
      data: (items) {
        if (items.isEmpty) return _bucketEmpty();
        return RefreshIndicator(
          color: _accent,
          onRefresh: () async => ref.invalidate(bucketListProvider),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              GenZTokens.space4,
              GenZTokens.space4,
              GenZTokens.space4,
              90,
            ),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: GenZTokens.space2),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () =>
                    ref.read(bucketListProvider.notifier).toggle(item.id),
                onLongPress: () => _confirmDeleteBucket(item),
                child: Container(
                  padding: const EdgeInsets.all(GenZTokens.space4),
                  decoration: BoxDecoration(
                    color: item.isCompleted ? _fill : _surface,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                    border: Border.all(
                      color: _line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: item.isCompleted ? _accent : _fill,
                          border: Border.all(
                            color: item.isCompleted ? _accent : _line,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: item.isCompleted
                            ? Icon(
                                PhosphorIcons.check(PhosphorIconsStyle.bold),
                                size: 14,
                                color: _onAccent,
                              )
                            : null,
                      ),
                      const SizedBox(width: GenZTokens.space3),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppFonts.heading(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: item.isCompleted ? _textSec : _ink,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _bucketEmpty() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(GenZTokens.space5),
    children: [
      const SizedBox(height: 40),
      Icon(PhosphorIcons.listChecks(), size: 56, color: _accent),
      const SizedBox(height: GenZTokens.space4),
      Text(
        'atlas.bucket_empty'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.heading(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: _ink,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'atlas.bucket_empty_sub'.tr(),
        textAlign: TextAlign.center,
        style: AppFonts.body(
          fontSize: 13,
          color: _textSec,
        ),
      ),
    ],
  );

  Widget _bucketError() => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            Icon(
              PhosphorIcons.cloudSlash(),
              color: _danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'atlas.bucket_failed'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
