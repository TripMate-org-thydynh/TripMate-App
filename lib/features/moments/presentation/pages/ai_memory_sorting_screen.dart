import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/services/media_uploader.dart';
import '../../../../core/network/api_exception.dart';
import '../../../premium/presentation/paywall_sheet.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../ai/data/ai_repository.dart';
import '../../../gamification/data/games_repository.dart';
import '../../data/moments_repository.dart';
import '../../domain/moment.dart';

/// AI đặt caption cho những tấm ảnh chưa có chú thích.
///
/// Trước đây màn này hiển thị 2 tấm ảnh Unsplash (đền Kyoto, tô ramen) với
/// caption AI viết sẵn, và nút "Approve Sorting" chỉ lật một cờ trong bộ nhớ
/// rồi hiện snackbar — không có gì được lưu, thoát ra là mất. Nay lấy ảnh THẬT
/// chưa có caption trong chuyến, nhờ AI đặt caption, và "Lưu" ghi thẳng vào
/// khoảnh khắc qua `PATCH /trips/:id/moments/:momentId`.
class AIMemorySortingScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AIMemorySortingScreen({
    super.key,
    required this.isDarkMode,
    this.onThemeToggle,
  });

  @override
  ConsumerState<AIMemorySortingScreen> createState() =>
      _AIMemorySortingScreenState();
}

class _AIMemorySortingScreenState extends ConsumerState<AIMemorySortingScreen> {
  /// Caption AI đề xuất theo id khoảnh khắc.
  final Map<String, String> _suggested = {};

  /// Id đang gọi AI hoặc đang lưu.
  final Set<String> _busy = {};

  /// Id đã lưu xong trong phiên này — để ẩn khỏi danh sách chờ.
  final Set<String> _done = {};

  Future<void> _suggest(String tripId, Moment m) async {
    if (_busy.contains(m.id)) return;
    setState(() => _busy.add(m.id));
    try {
      final text = await ref
          .read(mateyChatProvider)
          .caption(
            prompt: 'Một tấm ảnh du lịch của nhóm bạn trẻ Việt.',
            tripId: tripId,
          );
      if (!mounted) return;
      setState(() {
        _suggested[m.id] = text.trim();
        _busy.remove(m.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy.remove(m.id));
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  Future<void> _save(String tripId, Moment m) async {
    final caption = _suggested[m.id];
    if (caption == null || caption.isEmpty || _busy.contains(m.id)) return;
    setState(() => _busy.add(m.id));
    try {
      await ref
          .read(momentsRepositoryProvider)
          .updateCaption(tripId, m.id, caption);
      if (!mounted) return;
      // Bảng tin và scrapbook đang hiển thị caption cũ — buộc tải lại.
      ref.invalidate(tripMomentsProvider(tripId));
      ref.invalidate(recentMomentsProvider);
      setState(() {
        _busy.remove(m.id);
        _done.add(m.id);
      });
      showGlobalSnack('moments.caption_saved'.tr());
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy.remove(m.id));
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'moments.sorting_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        actions: [
          if (widget.onThemeToggle != null)
            IconButton(
              onPressed: widget.onThemeToggle,
              icon: Icon(
                isDark ? PhosphorIcons.sun() : PhosphorIcons.moon(),
                color: ink,
              ),
              tooltip: isDark
                  ? 'theme.switch_light'.tr()
                  : 'theme.switch_dark'.tr(),
            ),
        ],
      ),
      body: tripId == null
          ? AppEmptyState(
              isDark: isDark,
              icon: PhosphorIcons.sparkle(),
              title: 'games.need_trip_title'.tr(),
              body: 'games.need_trip_body'.tr(),
            )
          : ref
                .watch(tripMomentsProvider(tripId))
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => AppErrorState(
                    isDark: isDark,
                    error: e,
                    onRetry: () => ref.invalidate(tripMomentsProvider(tripId)),
                  ),
                  data: (moments) {
                    // Chỉ những ảnh CHƯA có caption mới cần AI đặt tên.
                    final pending = moments
                        .where(
                          (m) =>
                              (m.caption?.trim().isEmpty ?? true) &&
                              !_done.contains(m.id),
                        )
                        .toList();
                    if (pending.isEmpty) {
                      return AppEmptyState(
                        isDark: isDark,
                        icon: PhosphorIcons.checkCircle(),
                        title: 'moments.sorting_title'.tr(),
                        body: 'moments.sorting_empty'.tr(),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(GenZTokens.space5),
                      itemCount: pending.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: GenZTokens.space4),
                      itemBuilder: (_, i) => _card(isDark, tripId, pending[i]),
                    );
                  },
                ),
    );
  }

  Widget _card(bool isDark, String tripId, Moment m) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final suggestion = _suggested[m.id];
    final busy = _busy.contains(m.id);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: m.mediaUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: posterMedia(m.mediaUrl, m.type, width: 640),
                    fit: BoxFit.cover,
                    placeholder: (_, _) => ColoredBox(color: fill),
                    errorWidget: (_, _, _) => ColoredBox(color: fill),
                  )
                : ColoredBox(color: fill),
          ),
          Padding(
            padding: const EdgeInsets.all(GenZTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.placeName?.isNotEmpty == true
                      ? '${m.authorName} · ${m.placeName}'
                      : m.authorName,
                  style: AppFonts.body(fontSize: 12, color: inkSoft),
                ),
                const SizedBox(height: GenZTokens.space3),
                if (suggestion != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(GenZTokens.space3),
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusInput,
                      ),
                      border: Border.all(
                        color: line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: AppFonts.body(
                        fontSize: 15,
                        color: ink,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  Text(
                    'moments.no_caption'.tr(),
                    style: AppFonts.body(fontSize: 13, color: inkSoft),
                  ),
                const SizedBox(height: GenZTokens.space4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : () => _suggest(tripId, m),
                        icon: busy
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ink,
                                ),
                              )
                            : Icon(
                                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                                size: 16,
                              ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ink,
                          side: BorderSide(
                            color: line,
                            width: GenZTokens.borderWidthThin,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusButton,
                            ),
                          ),
                        ),
                        label: Text(
                          suggestion == null
                              ? 'moments.suggest'.tr()
                              : 'moments.suggest_again'.tr(),
                          style: AppFonts.heading(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: GenZTokens.space3),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: suggestion == null || busy
                            ? null
                            : () => _save(tripId, m),
                        icon: Icon(PhosphorIcons.check(), size: 16),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: onAccent,
                          disabledBackgroundColor: fill,
                          disabledForegroundColor: inkSoft,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusButton,
                            ),
                          ),
                        ),
                        label: Text(
                          'moments.save_caption'.tr(),
                          style: AppFonts.heading(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: suggestion == null || busy
                                ? inkSoft
                                : onAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
