import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/widgets/gen_z_widgets.dart';
import '../data/travel_atlas_repository.dart';
import '../data/bucket_list_repository.dart';
import '../domain/travel_stats.dart';

class TravelAtlasScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const TravelAtlasScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<TravelAtlasScreen> createState() => _TravelAtlasScreenState();
}

class _TravelAtlasScreenState extends ConsumerState<TravelAtlasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _bg => widget.isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Thêm điều muốn làm',
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            color: _ink,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 160,
          style: AppFonts.body(color: _ink),
          decoration: InputDecoration(
            hintText: 'profile.atlas_bucket_hint'.tr(),
            hintStyle: AppFonts.body(
              color: widget.isDarkMode
                  ? GenZTokens.inkSoftDark
                  : GenZTokens.inkSoft,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(
                color: widget.isDarkMode
                    ? GenZTokens.inkSoftDark
                    : GenZTokens.inkSoft,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GenZTokens.green),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xoá "${item.title}"?',
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            color: _ink,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(
                color: widget.isDarkMode
                    ? GenZTokens.inkSoftDark
                    : GenZTokens.inkSoft,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GenZTokens.red),
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
              backgroundColor: GenZTokens.green,
              foregroundColor: Colors.white,
              onPressed: _addBucketItem,
              icon: const Icon(Icons.add),
              label: Text(
                'packing.add'.tr(),
                style: AppFonts.heading(fontWeight: FontWeight.w800),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'Travel Atlas 🌍✨',
          style: AppFonts.heading(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: _ink,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _ink,
          unselectedLabelColor: widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
          indicatorColor: GenZTokens.yellow,
          indicatorWeight: 4,
          labelStyle: AppFonts.heading(fontWeight: FontWeight.w800, fontSize: 14),
          tabs: const [
            Tab(text: 'Bản Đồ 🗺️'),
            Tab(text: 'Thành Tích 🏆'),
            Tab(text: 'Bucket List 📝'),
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
              urlTemplate: widget.isDarkMode
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
                        color: place.isCheckIn
                            ? GenZTokens.pink
                            : GenZTokens.yellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: _ink, width: 2),
                        boxShadow: GenZTokens.hardShadow(_ink),
                      ),
                      child: Center(
                        child: Icon(
                          place.isCheckIn
                              ? Icons.camera_alt
                              : Icons.location_on,
                          color: GenZTokens.red,
                          size: 22,
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
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: _ink, width: GenZTokens.borderWidthThin),
              boxShadow: GenZTokens.hardShadow(_ink),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: GenZTokens.yellow, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    markers.isEmpty
                        ? 'Chưa có địa điểm nào — thêm lịch trình hoặc đăng moment có vị trí để ghim lên bản đồ!'
                        : 'Bạn đã ghim ${markers.length} địa điểm trong hành trình của mình!',
                    style: AppFonts.body(
                      fontWeight: FontWeight.w700,
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
    // Huy hiệu do BE tính từ số liệu thật (số chuyến, địa điểm, check-in,
    // streak). Trước đây danh sách rỗng thì rơi về một bộ huy hiệu mock —
    // tài khoản mới tinh lại thấy mình đã mở khoá vài huy hiệu.
    final badges = atlas.badges;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Streak Flame Card ──
          HardShadowBox(
            color: GenZTokens.yellow,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 44),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile.atlas_streak'.tr(),
                        style: AppFonts.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GenZTokens.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        atlas.streakMonths > 0
                            ? '${atlas.streakMonths} tháng liên tục!'
                            : 'Bắt đầu chuỗi ngay!',
                        style: AppFonts.heading(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GenZTokens.ink,
                        ),
                      ),
                      Text(
                        'Duy trì ngọn lửa xê dịch này nhé!',
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: GenZTokens.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Fast stats row ──
          Row(
            children: [
              Expanded(
                child: HardShadowBox(
                  color: GenZTokens.lilac,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${atlas.totalTrips}',
                        style: AppFonts.mono(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: GenZTokens.ink,
                        ),
                      ),
                      Text(
                        'Chuyến Đi',
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: GenZTokens.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: HardShadowBox(
                  color: GenZTokens.pink,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${atlas.placesExplored}',
                        style: AppFonts.mono(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: GenZTokens.ink,
                        ),
                      ),
                      Text(
                        'profile.atlas_places'.tr(),
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: GenZTokens.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Badges Gallery ──
          // Danh sách gồm cả huy hiệu chưa mở khoá (hiện mờ) nên tiêu đề phải
          // là "Huy hiệu", kèm số đã đạt — không phải "Đã mở khoá".
          Row(
            children: [
              Text(
                'profile.atlas_badges'.tr(),
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
                    color: _ink.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (badges.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(color: _ink.withValues(alpha: 0.2), width: 2),
              ),
              child: Text(
                'Chưa có huy hiệu nào. Đi chuyến đầu tiên để mở khoá nhé!',
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13,
                  color: _ink.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: badge.isUnlocked ? _surface : _surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  border: Border.all(
                    color: badge.isUnlocked ? _ink : _ink.withValues(alpha: 0.3),
                    width: GenZTokens.borderWidthThin,
                  ),
                  boxShadow: badge.isUnlocked ? GenZTokens.hardShadow(_ink) : null,
                ),
                child: Row(
                  children: [
                    Opacity(
                      opacity: badge.isUnlocked ? 1.0 : 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: badge.isUnlocked ? GenZTokens.yellow : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.military_tech, color: GenZTokens.ink, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.title,
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: badge.isUnlocked ? _ink : _ink.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            badge.description,
                            style: AppFonts.body(
                              fontSize: 12,
                              color: badge.isUnlocked
                                  ? (widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!badge.isUnlocked)
                      const Icon(Icons.lock, size: 16, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Bucket List checklist (wired BE thật) ──
  Widget _buildBucketListTab() {
    final async = ref.watch(bucketListProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _bucketError(),
      data: (items) {
        if (items.isEmpty) return _bucketEmpty();
        return RefreshIndicator(
          color: GenZTokens.green,
          onRefresh: () async => ref.invalidate(bucketListProvider),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () =>
                    ref.read(bucketListProvider.notifier).toggle(item.id),
                onLongPress: () => _confirmDeleteBucket(item),
                child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: item.isCompleted ? GenZTokens.green.withValues(alpha: 0.15) : _surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: _ink, width: GenZTokens.borderWidthThin),
              boxShadow: GenZTokens.hardShadow(_ink),
            ),
            child: Row(
              children: [
                // Brutalist tick box
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.isCompleted ? GenZTokens.green : Colors.transparent,
                    border: Border.all(color: _ink, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: item.isCompleted
                      ? const Icon(Icons.check, size: 16, color: GenZTokens.ink)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.title,
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _ink,
                      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
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
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.checklist_rtl, size: 60, color: GenZTokens.green),
          const SizedBox(height: 16),
          Text(
            'Bucket list còn trống',
            textAlign: TextAlign.center,
            style: AppFonts.heading(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Thêm những điều bạn muốn làm trên đường đi — rồi tick khi hoàn thành!',
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 14,
              color: widget.isDarkMode
                  ? GenZTokens.inkSoftDark
                  : GenZTokens.inkSoft,
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
                const Icon(Icons.cloud_off_rounded,
                    color: Colors.redAccent, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Không tải được bucket list',
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
