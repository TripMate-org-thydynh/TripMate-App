import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/services/widget_pin.dart';
import 'dart:math';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:tripmate/core/theme/gen_z_tokens.dart';
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
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    return Scaffold(
      backgroundColor: bg,
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
            tooltip: 'moments.pick_from_gallery'.tr(),
            onPressed: () => _openWithTrip(
              context,
              (tripId) => PostMomentScreen(tripId: tripId, isDarkMode: isDark),
              pop: false,
            ),
            backgroundColor: surfaceColor,
            foregroundColor: textPrimary,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
            ),
            child: Icon(PhosphorIcons.image()),
          ),
          const SizedBox(width: 12),
          // Squad Cam — đường nhanh: mở là khung ngắm đã chạy.
          FloatingActionButton.extended(
            heroTag: 'cam',
            tooltip: 'moments.cam_title'.tr(),
            onPressed: () => _openWithTrip(
              context,
              (tripId) => SquadCamScreen(tripId: tripId, isDarkMode: isDark),
              pop: false,
            ),
            backgroundColor: accent,
            foregroundColor: onAccent,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Icon(
              PhosphorIcons.camera(PhosphorIconsStyle.fill),
              color: onAccent,
            ),
            label: Text(
              'moments.cam_title'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w700,
                color: onAccent,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: bg,
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
                              Semantics(
                                button: true,
                                label: 'common.back'.tr(),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: surfaceColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: line,
                                        width: GenZTokens.borderWidthThin,
                                      ),
                                    ),
                                    child: Icon(
                                      PhosphorIcons.caretLeft(),
                                      color: textPrimary,
                                      size: 16,
                                    ),
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
                                            fontSize: 12,
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
                        // Nut mo Hub menu.
                        //
                        // Truoc day nut nay noi giua luoi anh (`Positioned`),
                        // nen cuon den dau la de len caption den do. Menu thuoc
                        // ve thanh dieu huong tren cung, khong phai vat noi giua
                        // noi dung.
                        Semantics(
                          button: true,
                          label: 'moments.menu_features'.tr(),
                          child: GestureDetector(
                            onTap: () => _showHubMenu(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: line,
                                  width: GenZTokens.borderWidthThin,
                                ),
                              ),
                              child: Icon(
                                PhosphorIcons.squaresFour(),
                                color: textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Dark/Light Theme Toggle
                        Semantics(
                          button: true,
                          label: isDark
                              ? 'theme.switch_light'.tr()
                              : 'theme.switch_dark'.tr(),
                          child: GestureDetector(
                            onTap: widget.onThemeToggle,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: line,
                                  width: GenZTokens.borderWidthThin,
                                ),
                              ),
                              child: Icon(
                                isDark
                                    ? PhosphorIcons.sun()
                                    : PhosphorIcons.moon(),
                                color: textPrimary,
                                size: 20,
                              ),
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
                              // Chua cho FAB "Squad Cam" va nut Hub noi ben tren
                              // luoi (BUG-006). Padding phai nam o VUNG CUON,
                              // khong phai o tung khung polaroid — dat vao the
                              // thi moi anh thua mot mang trang 110px.
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                120,
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
                                        line,
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
    final color = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.camera(), size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 15, color: color, height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(PhosphorIcons.arrowsClockwise(), size: 18),
                label: Text('common.retry'.tr()),
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
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
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
  Widget _buildStickerBadge(String label, Color borderColor) {
    final isDark = widget.isDarkMode;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final text = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSec = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    return Transform.rotate(
      angle: 0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
              color: textSec,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              label.replaceAll("location_on ", ""),
              style: AppFonts.heading(
                color: text,
                fontSize: 12,
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
    final frameColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 172,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: frameColor,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
                boxShadow: GenZTokens.hardShadow(textColor, isDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inner Image box
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ExcludeSemantics(
                          child: Image.network(
                            imageUrl,
                            height: 156,
                            width: 156,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 156,
                                width: 156,
                                decoration: BoxDecoration(color: fill),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        PhosphorIcons.imageBroken(),
                                        color: isDark
                                            ? GenZTokens.inkSoftDark
                                            : GenZTokens.inkSoft,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "general.load_image_failed".tr(),
                                        style: AppFonts.heading(
                                          color: isDark
                                              ? GenZTokens.inkSoftDark
                                              : GenZTokens.inkSoft,
                                          fontSize: 12,
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
                                decoration: BoxDecoration(color: fill),
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
                                            ? GenZTokens.accentDark
                                            : GenZTokens.accent,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Video player overlay
                      if (isVideo) ...[
                        Positioned.fill(
                          child: Container(
                            color: GenZTokens.ink.withValues(alpha: 0.2),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: GenZTokens.ink.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  PhosphorIcons.playCircle(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  color: GenZTokens.onAccent,
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
                              color:
                                  (isDark
                                          ? GenZTokens.dangerDark
                                          : GenZTokens.danger)
                                      .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: GenZTokens.onAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  videoDuration == null
                                      ? "REC"
                                      : "REC $videoDuration",
                                  style: GoogleFonts.shareTechMono(
                                    color: GenZTokens.onAccent,
                                    fontSize: 12,
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
                            color: GenZTokens.ink.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            time,
                            style: GoogleFonts.shareTechMono(
                              color: isDark
                                  ? GenZTokens.warningDark
                                  : GenZTokens.warning,
                              fontSize: 12,
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
                        fontSize: 15,
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

  // Frosted bottom sheet Hub menu
  void _showHubMenu(BuildContext context) {
    final isDark = widget.isDarkMode;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final accentSoft = isDark
        ? GenZTokens.accentSoftDark
        : GenZTokens.accentSoft;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      barrierColor: (isDark ? GenZTokens.inkDark : GenZTokens.ink).withValues(
        alpha: 0.4,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
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
                      color: textSecondary.withValues(alpha: 0.3),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusCard,
                      ),
                      color: accentSoft,
                      border: Border.all(
                        color: line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                            color: onAccent,
                            size: 22,
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
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'moments.recap_entry'.tr(),
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIcons.arrowRight(),
                          color: textSecondary,
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
                      icon: PhosphorIcons.sparkle(),
                      title: 'moments.caption_studio'.tr(),
                      desc: 'moments.caption_studio_sub'.tr(),
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
                      icon: PhosphorIcons.magicWand(),
                      title: 'moments.auto_sorter'.tr(),
                      desc: 'moments.auto_sorter_sub'.tr(),
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
                      icon: PhosphorIcons.mapTrifold(),
                      title: 'moments.photo_map'.tr(),
                      desc: 'moments.photo_map_sub'.tr(),
                      onTap: () => _openWithTrip(
                        context,
                        (tripId) =>
                            PhotoMapScreen(tripId: tripId, isDarkMode: isDark),
                      ),
                    ),
                    _buildFeatureTile(
                      context,
                      icon: PhosphorIcons.appWindow(),
                      title: 'moments.pin_widget'.tr(),
                      desc: 'moments.pin_widget_sub'.tr(),
                      onTap: () => _pinWidget(context),
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

  /// Mở hộp thoại ghim widget của hệ thống.
  ///
  /// Launcher nào không hỗ trợ thì nói rõ cách làm thủ công, thay vì bấm xong
  /// không thấy gì xảy ra.
  Future<void> _pinWidget(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    final ok = await WidgetPin.isSupported() && await WidgetPin.request();
    if (!mounted) return;
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('moments.pin_widget_manual'.tr()),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    final trips = container
        .read(tripsProvider)
        .maybeWhen(data: (list) => list, orElse: () => const []);
    final tripId = activeId ?? (trips.isNotEmpty ? trips.first.id : null);
    if (tripId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('trips.none_yet_cta'.tr())));
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
    required VoidCallback onTap,
  }) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: fill,
              radius: 16,
              child: Icon(icon, color: textPrimary, size: 16),
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: AppFonts.heading(fontSize: 12, color: textSecondary),
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
