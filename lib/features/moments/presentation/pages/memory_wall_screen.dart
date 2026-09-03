import 'dart:math';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../data/moments_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';

import 'ai_memory_sorting_screen.dart';
import '../../../ai/pages/ai_caption_generator_screen.dart';
import 'post_moment_screen.dart';
import 'squad_cam_screen.dart';
import 'trip_recap_reel_screen.dart';
import '../../../discovery/presentation/pages/photo_map_screen.dart';
import '../../../gamification/data/games_repository.dart';
import '../../../trips/application/trips_providers.dart';

class MemoryWallScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MemoryWallScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  ConsumerState<MemoryWallScreen> createState() => _MemoryWallScreenState();
}

class _MemoryWallScreenState extends ConsumerState<MemoryWallScreen> {
  final List<Widget> _floatingEmojis = [];

  void _addFloatingEmoji(String emoji, double startX) {
    final key = UniqueKey();
    setState(() {
      _floatingEmojis.add(
        FloatingEmojiWidget(
          key: key,
          emoji: emoji,
          startX: startX,
          onFinished: () {
            setState(() {
              _floatingEmojis.removeWhere((w) => w.key == key);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // TripMate color tokens
    final bgGradStart = Theme.of(context).scaffoldBackgroundColor;
    final primary = isDark ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
    final textPrimary = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    final textSecondary = isDark
        ? const Color(0xFFB8AE9C)
        : const Color(0xFF4A453E);
    final surfaceColor = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);

    final mintColor = const Color(0xFF1FA85C);

    return Scaffold(
      // Nút đăng khoảnh khắc — trước đây app KHÔNG có đường nào đưa ảnh lên,
      // nên Memory Wall chỉ đọc được dữ liệu do script kiểm thử đẩy vào.
      floatingActionButton: Row(
        // Bắt buộc: ô đặt FAB không giới hạn chiều rộng, Row mặc định cố giãn
        // hết cỡ nên ném "RenderFlex children have non-zero flex but incoming
        // width constraints are unbounded" và cả màn trắng xoá.
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Chọn từ thư viện — đường chậm hơn, cho ảnh đã chụp sẵn.
          FloatingActionButton(
            heroTag: 'pick',
            onPressed: () => _openWithTrip(
              context,
              (tripId) => PostMomentScreen(tripId: tripId, isDarkMode: isDark),
              pop: false,
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF141210),
            child: const Icon(Icons.photo_library_outlined),
          ),
          const SizedBox(width: 12),
          // Squad Cam — đường nhanh: mở là khung ngắm đã chạy.
          FloatingActionButton.extended(
            heroTag: 'cam',
            onPressed: () => _openWithTrip(
              context,
              (tripId) => SquadCamScreen(tripId: tripId, isDarkMode: isDark),
              pop: false,
            ),
            backgroundColor: const Color(0xFF1FA85C),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.camera_alt_rounded),
            label: Text(
              'moments.cam_title'.tr(),
              style: AppFonts.heading(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: bgGradStart),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Scrapbook Content Layout
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Expanded: Row trong nằm giữa `spaceBetween` nên không
                        // có chiều rộng xác định; thiếu nó thì `Expanded` của
                        // tên chuyến bên trong ném lỗi layout và cả màn trắng.
                        Expanded(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: textPrimary,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: textPrimary,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Tên chuyến THẬT đang mở.
                              //
                              // Trước đây in cứng "Hà Giang Loop 🏍️" và
                              // "Oct 14, 2023 • Squad Album" nên ai mở Memory
                              // Wall cũng thấy album của một chuyến không có.
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final tripId = ref.watch(
                                      activeTripIdProvider,
                                    );
                                    final trip = ref
                                        .watch(tripsProvider)
                                        .maybeWhen(
                                          data: (trips) => trips
                                              .where((t) => t.id == tripId)
                                              .firstOrNull,
                                          orElse: () => null,
                                        );
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trip?.name ?? 'moments.wall'.tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFonts.body(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          trip == null
                                              ? 'moments.wall_sub'.tr()
                                              : '${DateFormat.yMMMd().format(trip.startDate)} • ${'moments.wall_sub'.tr()}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFonts.heading(
                                            fontSize: 11,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dark/Light Theme Toggle
                        GestureDetector(
                          onTap: widget.onThemeToggle,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: textPrimary, width: 2),
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              color: textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Canvas scrapbook — hiển thị KỶ NIỆM THẬT của user.
                  //
                  // Trước đây đây là 3 tấm polaroid cứng (ảnh Unsplash, caption và
                  // tên người bịa) kèm thẻ "Route Progress: 120 / 350 km" — giống
                  // hệt nhau cho mọi tài khoản, kể cả người chưa đăng gì.
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final async = ref.watch(recentMomentsProvider);
                        return async.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (e, _) => _wallMessage(
                            context,
                            tr('errors.load_failed'),
                            onRetry: () =>
                                ref.invalidate(recentMomentsProvider),
                          ),
                          data: (moments) {
                            if (moments.isEmpty) {
                              return _wallMessage(
                                context,
                                tr('moments.wall_empty'),
                              );
                            }
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                96,
                              ),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 20,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (var i = 0; i < moments.length; i++)
                                    _buildPolaroid(
                                      context: context,
                                      imageUrl: moments[i].posterUrl,
                                      isVideo: moments[i].isVideo,
                                      time: moments[i].authorName,
                                      caption: moments[i].title,
                                      rotation: i.isEven ? -0.04 : 0.035,
                                      onTap: () =>
                                          _openReactions(context, moments[i]),
                                      badge: _buildStickerBadge(
                                        moments[i].location,
                                        i.isEven ? mintColor : Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Floating Emojis overlay stack
              ..._floatingEmojis,

              // Bottom floating reaction pill & Menu Hub button
              // bottom: 96 chu khong phai 24 — hang FAB (Squad Cam) nam o 24 va
              // truoc day de len pill nay, che mat cac nut ben trong.
              Positioned(
                bottom: 96,
                left: 24,
                right: 24,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: textPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tha cam xuc nay nam o tung tam polaroid (co
                          // moment de gui len server), khong con o day.
                          GestureDetector(
                            onTap: () => _showHubMenu(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primary, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_mosaic_outlined,
                                    color: primary,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'moments.hub_menu'.tr(),
                                    style: AppFonts.body(
                                      color: primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating reaction spawner
  /// Thông báo giữa canvas (chưa có kỷ niệm / tải lỗi).
  Widget _wallMessage(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white70 : Colors.black54;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 14, color: color, height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr('general.retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tha cam xuc THAT len mot khoanh khac: POST /trips/:id/moments/:id/reactions.
  ///
  /// Truoc day day chi ban mot emoji bay len roi thoi — khong ai khac thay duoc,
  /// va backend da co san endpoint nay.
  Future<void> _react(
    BuildContext context,
    RecentMoment moment,
    String emoji,
  ) async {
    final width = MediaQuery.of(context).size.width;
    _addFloatingEmoji(
      emoji,
      (width * 0.1) + (Random().nextDouble() * (width * 0.7)),
    );
    try {
      await ref
          .read(momentsRepositoryProvider)
          .react(moment.tripId, moment.id, emoji);
      if (!mounted) return;
      showGlobalSnack('moments.reacted'.tr(args: [emoji]));
    } catch (e) {
      if (!mounted) return;
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  /// Bang chon cam xuc cho dung tam anh vua cham.
  void _openReactions(BuildContext context, RecentMoment moment) {
    final isDark = widget.isDarkMode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                moment.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFFFDF6D3)
                      : const Color(0xFF141210),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final emoji in const ['🔥', '😂', '💀', '💯', '😍'])
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _react(context, moment, emoji);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Location sticker inside a polaroid or canvas
  Widget _buildStickerBadge(String label, Color color) {
    return Transform.rotate(
      angle: 0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 0,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: color, size: 10),
            const SizedBox(width: 2),
            Text(
              label.replaceAll("location_on ", ""),
              style: AppFonts.heading(
                color: Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom physical polaroid builder
  Widget _buildPolaroid({
    required BuildContext context,
    required String imageUrl,
    required String time,
    required String caption,
    double rotation = 0.0,
    Widget? badge,
    bool isVideo = false,
    String? videoDuration,
    VoidCallback? onTap,
  }) {
    final isDark = widget.isDarkMode;
    final frameColor = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);
    final textColor = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);

    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 172,
              // Chừa chỗ cho FAB "Squad Cam" và nút Hub (BUG-006).
              padding: const EdgeInsets.all(8).copyWith(bottom: 110),
              decoration: BoxDecoration(
                color: frameColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
                    blurRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inner Image box
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          imageUrl,
                          height: 156,
                          width: 156,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 156,
                              width: 156,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF262019)
                                    : const Color(0xFFE2E8F0),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFFB8AE9C),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "general.load_image_failed".tr(),
                                      style: AppFonts.heading(
                                        color: isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFFB8AE9C),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 156,
                              width: 156,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(
                                        0xFF262019,
                                      ).withValues(alpha: 0.5)
                                    : const Color(0xFFFDF6D3),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? const Color(0xFFF5822B)
                                          : const Color(0xFFF5822B),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Video player overlay
                      if (isVideo) ...[
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.2),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // REC badge
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD8422B,
                              ).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  videoDuration == null
                                      ? "REC"
                                      : "REC $videoDuration",
                                  style: GoogleFonts.shareTechMono(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      // Date timestamp tag inside the photo
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            time,
                            style: GoogleFonts.shareTechMono(
                              color: const Color(0xFFFFB300),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Caption title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      caption,
                      style: GoogleFonts.caveat(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Sticker badge positioned on top
            if (badge != null) Positioned(top: -8, right: -8, child: badge),
          ],
        ),
      ),
    );
  }

  // Frosted AI memory card

  // Realistic Quote Sticky note

  // Telemetry Progress Card builder

  // Frosted bottom sheet Hub menu
  void _showHubMenu(BuildContext context) {
    final isDark = widget.isDarkMode;
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: Container(
            color: surface.withValues(alpha: 0.9),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ).copyWith(bottom: 24 + MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: textPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'moments.wall_hub'.tr(),
                  style: AppFonts.body(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                // ── Trip Wrapped hero banner ────────────────────────────────
                GestureDetector(
                  onTap: () => _openWithTrip(
                    context,
                    (tripId) =>
                        TripRecapReelScreen(isDarkMode: isDark, tripId: tripId),
                    pop: false,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFF8B4DE8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF5822B).withValues(alpha: 0.3),
                          blurRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'games.trip_wrapped_title'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'moments.recap_entry'.tr(),
                                style: AppFonts.body(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.0,
                  children: [
                    _buildFeatureTile(
                      context,
                      icon: Icons.auto_awesome_outlined,
                      title: 'AI Caption Studio',
                      desc: 'Witty quote roasts',
                      color: const Color(0xFFFFB300),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => AICaptionGeneratorScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureTile(
                      context,
                      icon: Icons.auto_mode_outlined,
                      title: 'AI Auto-Sorter',
                      desc: 'Tag & organize chaos',
                      color: Colors.tealAccent,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => AIMemorySortingScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureTile(
                      context,
                      icon: Icons.map_outlined,
                      title: 'Photo Map',
                      desc: 'Moments on map',
                      color: Colors.orangeAccent,
                      // Trước đây mở Photo Map bằng id bịa
                      // 'hagiang-loop-123' — chuyến không tồn tại nên màn
                      // bản đồ luôn trắng/lỗi.
                      onTap: () => _openWithTrip(
                        context,
                        (tripId) =>
                            PhotoMapScreen(tripId: tripId, isDarkMode: isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mở màn cần một chuyến cụ thể.
  ///
  /// Chưa có chuyến nào thì báo cho người dùng biết thay vì mở màn trắng.
  void _openWithTrip(
    BuildContext context,
    Widget Function(String tripId) builder, {
    bool pop = true,
  }) {
    final container = ProviderScope.containerOf(context, listen: false);
    final activeId = container.read(activeTripIdProvider);
    final trips = container.read(tripsProvider).maybeWhen(
      data: (list) => list,
      orElse: () => const [],
    );
    final tripId = activeId ?? (trips.isNotEmpty ? trips.first.id : null);
    if (tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trips.none_yet_cta'.tr()),
        ),
      );
      return;
    }
    if (pop) Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => builder(tripId)));
  }

  // Feature menu grid builder
  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    final textSecondary = isDark
        ? const Color(0xFFB8AE9C)
        : const Color(0xFF4A453E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.02), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 16,
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: AppFonts.heading(fontSize: 8, color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Micro-animated Floating Emoji Reaction
class FloatingEmojiWidget extends StatefulWidget {
  final String emoji;
  final double startX;
  final VoidCallback onFinished;

  const FloatingEmojiWidget({
    super.key,
    required this.emoji,
    required this.startX,
    required this.onFinished,
  });

  @override
  State<FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late double _swayOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _yAnimation = Tween<double>(
      begin: 0.0,
      end: -300.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Random slight swaying values
    _swayOffset = (DateTime.now().millisecond % 50) - 25;

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double sway = sin(_controller.value * pi * 3.5) * _swayOffset;
        return Positioned(
          bottom: 100 - _yAnimation.value,
          left: widget.startX + sway,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
        );
      },
    );
  }
}
