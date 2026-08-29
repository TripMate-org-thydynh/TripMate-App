import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/services/media_uploader.dart';
import '../../../../core/network/api_exception.dart';
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
          .ask(
            prompt:
                'Viết 1 caption ngắn, vui, kiểu Gen Z Việt cho một tấm ảnh du '
                'lịch. Chỉ trả về đúng câu caption, không giải thích.',
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
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'moments.sorting_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: tripId == null
          ? AppEmptyState(
              isDark: isDark,
              icon: Icons.auto_awesome_outlined,
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
                        icon: Icons.check_circle_outline,
                        title: 'moments.sorting_title'.tr(),
                        body: 'moments.sorting_empty'.tr(),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(GenZTokens.space5),
                      itemCount: pending.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: GenZTokens.space4),
                      itemBuilder: (_, i) =>
                          _card(isDark, tripId, pending[i]),
                    );
                  },
                ),
    );
  }

  Widget _card(bool isDark, String tripId, Moment m) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final suggestion = _suggested[m.id];
    final busy = _busy.contains(m.id);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: m.mediaUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: optimizedMedia(m.mediaUrl, width: 640),
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: GenZTokens.lilac),
                    errorWidget: (_, _, _) =>
                        const ColoredBox(color: GenZTokens.lilac),
                  )
                : const ColoredBox(color: GenZTokens.lilac),
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
                  style: AppFonts.body(fontSize: 12.5, color: inkSoft),
                ),
                const SizedBox(height: GenZTokens.space3),
                if (suggestion != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(GenZTokens.space3),
                    decoration: BoxDecoration(
                      color: GenZTokens.yellow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GenZTokens.ink,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: AppFonts.body(
                        fontSize: 14,
                        color: GenZTokens.ink,
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
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 16),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ink,
                          side: BorderSide(
                            color: ink,
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
                        icon: const Icon(Icons.check, size: 16),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GenZTokens.green,
                          foregroundColor: GenZTokens.ink,
                          elevation: 0,
                          side: BorderSide(
                            color: ink,
                            width: GenZTokens.borderWidthThin,
                          ),
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
                            color: GenZTokens.ink,
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
