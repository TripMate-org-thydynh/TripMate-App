import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/widget_sync.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../data/moments_repository.dart';

/// Màn xem khoảnh khắc mở từ widget màn hình chính.
///
/// Đây là nửa sau của vòng lặp Locket: widget khoe ảnh ngoài màn hình chính,
/// chạm vào thì mở thẳng đến đây để **phản hồi** — chứ không phải mở app rồi bắt
/// người dùng tự đi tìm tấm ảnh vừa nhìn thấy.
///
/// Vuốt dọc để chuyển ảnh (giống Locket), hàng emoji dưới đáy để thả cảm xúc.
class MomentViewerScreen extends ConsumerStatefulWidget {
  /// Mở sẵn ở ảnh nào. Widget luôn khoe ảnh mới nhất nên mặc định là 0.
  final int initialIndex;

  const MomentViewerScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MomentViewerScreen> createState() => _MomentViewerScreenState();
}

class _MomentViewerScreenState extends ConsumerState<MomentViewerScreen> {
  late final PageController _pager = PageController(
    initialPage: widget.initialIndex,
  );

  List<WidgetMoment>? _items;
  String? _error;

  /// Cảm xúc đã thả, theo id khoảnh khắc.
  ///
  /// Giữ ở client để nút phản hồi ngay lập tức; backend `toggleReaction` là
  /// nguồn sự thật, nhưng chờ mạng rồi mới đổi màu thì bấm sẽ thấy "chết".
  final Map<String, String> _reacted = {};

  /// Bộ cảm xúc cố định — đủ để trả lời nhanh, không cần bàn phím.
  static const _emojis = ['❤️', '😂', '😮', '🔥', '🥹', '👏'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await ref.read(widgetSyncProvider).loadFeed();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  Future<void> _react(WidgetMoment m, String emoji) async {
    HapticFeedback.mediumImpact();
    // Bỏ chọn khi bấm lại đúng emoji đang chọn — khớp với `toggleReaction` ở BE.
    final isSame = _reacted[m.id] == emoji;
    setState(() {
      if (isSame) {
        _reacted.remove(m.id);
      } else {
        _reacted[m.id] = emoji;
      }
    });
    if (m.tripId.isEmpty) return;
    try {
      await ref.read(momentsRepositoryProvider).react(m.tripId, m.id, emoji);
    } catch (_) {
      // Thả cảm xúc hỏng thì trả lại trạng thái cũ, không báo lỗi ồn ào:
      // đây là hành động phụ, không phải thao tác chính của người dùng.
      if (!mounted) return;
      setState(() {
        if (isSame) {
          _reacted[m.id] = emoji;
        } else {
          _reacted.remove(m.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final ink = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context, ink),
            Expanded(child: _body(context, isDark, ink)),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Color ink) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
    child: Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Text(
          'moments.viewer_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ],
    ),
  );

  Widget _body(BuildContext context, bool isDark, Color ink) {
    if (_error != null) {
      return _centered(
        icon: Icons.cloud_off_rounded,
        title: 'moments.viewer_failed'.tr(),
        ink: ink,
        onRetry: () {
          setState(() => _error = null);
          _load();
        },
      );
    }
    final items = _items;
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return _centered(
        icon: Icons.photo_camera_outlined,
        title: 'moments.viewer_empty'.tr(),
        ink: ink,
      );
    }
    return PageView.builder(
      controller: _pager,
      // Vuốt dọc: cùng cử chỉ với Locket, và không giành scroll với ảnh.
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      itemBuilder: (_, i) => _slide(items[i], isDark, ink),
    );
  }

  Widget _centered({
    required IconData icon,
    required String title,
    required Color ink,
    VoidCallback? onRetry,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: ink.withValues(alpha: 0.5)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 15,
              color: ink.withValues(alpha: 0.75),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text('common.tap_to_retry'.tr()),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _slide(WidgetMoment m, bool isDark, Color ink) {
    final frame = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          // Khung ảnh vuông viền dày — cùng ngôn ngữ hình ảnh với widget ngoài
          // màn hình chính, để người dùng nhận ra ngay là cùng một tấm.
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: frame,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: ink, width: 2),
                    boxShadow: [
                      BoxShadow(color: ink, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: m.imageUrl.isEmpty
                        ? Container(color: ink.withValues(alpha: 0.08))
                        : CachedNetworkImage(
                            imageUrl: m.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (_, _) => Container(
                              color: ink.withValues(alpha: 0.06),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: ink.withValues(alpha: 0.08),
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: ink.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            m.authorName,
            style: AppFonts.heading(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            m.caption?.isNotEmpty == true ? m.caption! : m.tripName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              fontSize: 13,
              color: ink.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 18),
          _reactionBar(m, isDark, ink),
        ],
      ),
    );
  }

  Widget _reactionBar(WidgetMoment m, bool isDark, Color ink) {
    final picked = _reacted[m.id];
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in _emojis)
            GestureDetector(
              onTap: () => _react(m, e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: picked == e
                      ? accent.withValues(alpha: 0.9)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: picked == e ? 1.18 : 1,
                  child: Text(e, style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
