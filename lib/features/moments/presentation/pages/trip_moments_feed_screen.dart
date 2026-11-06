import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/widgets/report_sheet.dart';
import '../../../profile/data/profile_provider.dart';
import '../../application/moments_providers.dart';
import '../../data/moments_repository.dart';
import '../../domain/moment.dart';

/// Feed khoảnh khắc của chuyến — wired BE thật (`/trips/:tripId/moments`).
class TripMomentsFeedScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;
  const TripMomentsFeedScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  bool _isDark(BuildContext context) =>
      isDarkMode || Theme.of(context).brightness == Brightness.dark;

  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _surfaceOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color _primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color _onPrimaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  Color _lineOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.fillDark : GenZTokens.fill;
  Color _textPri(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSec(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  void _react(WidgetRef ref, String momentId) {
    HapticFeedback.mediumImpact();
    ref.read(momentsProvider(tripId).notifier).react(momentId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(momentsProvider(tripId));
    final bg = _bgOf(context);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'moments.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPri(context),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primaryOf(context),
        onRefresh: () async {
          ref.invalidate(momentsProvider(tripId));
          ref.invalidate(ghostStatusProvider(tripId));
        },
        child: async.when(
          loading: () => _skeleton(context),
          error: (e, _) => _error(context, ref, e),
          data: (moments) => moments.isEmpty
              ? _empty(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  // Mục đầu là banner Ghost Cam (rỗng khi không có ảnh chờ).
                  itemCount: moments.length + 1,
                  itemBuilder: (context, i) => i == 0
                      ? _ghostBanner(context, ref)
                      : _card(context, ref, moments[i - 1]),
                ),
        ),
      ),
    );
  }

  /// "N ảnh đang tráng" — chỉ đếm ảnh của người khác (ảnh của mình đã hiện
  /// trong feed với nhãn riêng). Không dùng màu nhấn: màn này đã có nút tim.
  Widget _ghostBanner(BuildContext context, WidgetRef ref) {
    final status = ref.watch(ghostStatusProvider(tripId)).valueOrNull;
    if (status == null || status.revealed || status.hidden <= 0) {
      return const SizedBox.shrink();
    }
    final when = status.revealAt == null
        ? ''
        : DateFormat('dd/MM', context.locale.languageCode)
              .format(status.revealAt!);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _fillOf(context),
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _lineOf(context)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.ghost(), size: 22, color: _textSec(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'moments.ghost_banner'.tr(
                namedArgs: {'count': '${status.hidden}', 'date': when},
              ),
              style: AppFonts.body(fontSize: 13, color: _textPri(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: List.generate(
      3,
      (i) => Container(
        height: 280,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _fillOf(context),
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        ),
      ),
    ),
  );

  Widget _error(BuildContext context, WidgetRef ref, Object e) => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            Icon(
              PhosphorIcons.cloudSlash(),
              color: _isDark(context)
                  ? GenZTokens.dangerDark
                  : GenZTokens.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'moments.load_failed'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textPri(context),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryOf(context),
                foregroundColor: _onPrimaryOf(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              onPressed: () => ref.invalidate(momentsProvider(tripId)),
              icon: Icon(PhosphorIcons.arrowsClockwise()),
              label: Text('general.retry'.tr()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _empty(BuildContext context) => ListView(
    children: [
      const SizedBox(height: 130),
      Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _fillOf(context),
              ),
              child: Icon(
                PhosphorIcons.camera(PhosphorIconsStyle.fill),
                color: _primaryOf(context),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'moments.empty'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textPri(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'moments.empty_sub'.tr(),
              style: AppFonts.body(fontSize: 15, color: _textSec(context)),
            ),
          ],
        ),
      ),
    ],
  );

  /// Nhãn cho ảnh ghost của chính mình: chỉ mình thấy cho tới ngày tráng.
  Widget _developingPill(BuildContext context, Moment m) {
    final when = m.revealAt == null
        ? ''
        : DateFormat('dd/MM', context.locale.languageCode).format(m.revealAt!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _fillOf(context),
        borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
        border: Border.all(color: _lineOf(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.ghost(), size: 14, color: _textSec(context)),
          const SizedBox(width: 4),
          Text(
            'moments.ghost_developing'.tr(namedArgs: {'date': when}),
            style: AppFonts.body(fontSize: 12, color: _textSec(context)),
          ),
        ],
      ),
    );
  }

  void _openCommentsSheet(BuildContext context, WidgetRef ref, Moment m) {
    final isDark = _isDark(context);
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final fill = _fillOf(context);
    final textPri = _textPri(context);
    final textSec = _textSec(context);
    final primary = _primaryOf(context);
    final onPrimary = _onPrimaryOf(context);
    final ctrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        var sending = false;
        return StatefulBuilder(
          builder: (sheetCtx, setModalState) {
            final latestList = ref.watch(momentsProvider(tripId)).valueOrNull;
            final current =
                latestList?.where((x) => x.id == m.id).firstOrNull ?? m;
            final bottomInset = MediaQuery.viewInsetsOf(sheetCtx).bottom;
            final safeBottom = MediaQuery.paddingOf(sheetCtx).bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: (bottomInset > safeBottom ? bottomInset : safeBottom) + 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: line,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${'moments.comment_action'.tr()} (${current.commentCount})',
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: current.comments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                isDark
                                    ? 'Chưa có bình luận nào. Hãy mở lời trước nhé!'
                                    : 'Chưa có bình luận nào. Hãy mở lời trước nhé!',
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: textSec,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: current.comments.length,
                            separatorBuilder: (_, _) =>
                                Divider(height: 14, color: line),
                            itemBuilder: (_, idx) {
                              final c = current.comments[idx];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: fill,
                                    backgroundImage: c.authorAvatar != null &&
                                            c.authorAvatar!.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            c.authorAvatar!,
                                          )
                                        : null,
                                    child: c.authorAvatar == null ||
                                            c.authorAvatar!.isEmpty
                                        ? Text(
                                            c.authorName.isNotEmpty
                                                ? c.authorName.characters.first
                                                : '?',
                                            style: AppFonts.heading(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: textPri,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.authorName,
                                          style: AppFonts.heading(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: textPri,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          c.content,
                                          style: AppFonts.body(
                                            fontSize: 14,
                                            color: textPri,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          style: AppFonts.body(fontSize: 14, color: textPri),
                          decoration: InputDecoration(
                            hintText: 'Viết bình luận cho khoảnh khắc này...',
                            hintStyle: AppFonts.body(
                              fontSize: 13,
                              color: textSec,
                            ),
                            filled: true,
                            fillColor: fill,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                GenZTokens.radiusPill,
                              ),
                              borderSide: BorderSide(color: line),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                GenZTokens.radiusPill,
                              ),
                              borderSide: BorderSide(color: line),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                        ),
                        onPressed: sending
                            ? null
                            : () async {
                                final text = ctrl.text.trim();
                                if (text.isEmpty) return;
                                setModalState(() => sending = true);
                                try {
                                  await ref
                                      .read(momentsProvider(tripId).notifier)
                                      .addComment(m.id, text);
                                  ctrl.clear();
                                } finally {
                                  if (sheetCtx.mounted) {
                                    setModalState(() => sending = false);
                                  }
                                }
                              },
                        icon: Icon(
                          PhosphorIcons.paperPlaneRight(
                            PhosphorIconsStyle.fill,
                          ),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(ctrl.dispose);
  }

  Widget _card(BuildContext context, WidgetRef ref, Moment m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surfaceOf(context),
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: _lineOf(context),
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _fillOf(context),
                  backgroundImage:
                      m.authorAvatar != null && m.authorAvatar!.isNotEmpty
                      ? CachedNetworkImageProvider(m.authorAvatar!)
                      : null,
                  child: m.authorAvatar == null || m.authorAvatar!.isEmpty
                      ? Text(
                          m.authorName.isNotEmpty
                              ? m.authorName.characters.first
                              : '?',
                          style: AppFonts.heading(
                            color: _textPri(context),
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.authorName,
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPri(context),
                    ),
                  ),
                ),
                if (m.developing)
                  _developingPill(context, m)
                else if (m.isGhost)
                  Icon(
                    PhosphorIcons.ghost(),
                    size: 18,
                    color: _textSec(context),
                  ),
                if (m.authorId != null &&
                    m.authorId != ref.watch(profileDataProvider).profile?['id'])
                  IconButton(
                    tooltip: 'report.title'.tr(),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      PhosphorIcons.flag(),
                      size: 18,
                      color: _textSec(context),
                    ),
                    onPressed: () => ReportSheet.show(
                      context,
                      target: ReportTarget.moment,
                      targetId: m.id,
                    ),
                  ),
              ],
            ),
          ),
          // Media
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: m.mediaUrl,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              placeholder: (c, url) => Container(color: _fillOf(context)),
              errorWidget: (c, url, err) => Container(
                color: _fillOf(context),
                child: Icon(
                  PhosphorIcons.image(),
                  color: _textSec(context),
                  size: 40,
                ),
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _react(ref, m.id),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        color: m.reactionCount > 0
                            ? _primaryOf(context)
                            : _textSec(context),
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${m.reactionCount}',
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPri(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openCommentsSheet(context, ref, m),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.chatCircle(),
                          color: _textSec(context),
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${m.commentCount}',
                          style: AppFonts.body(
                            fontSize: 13,
                            color: _textSec(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (m.caption != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Text(
                m.caption!,
                style: AppFonts.body(
                  fontSize: 15,
                  color: _textPri(context),
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
