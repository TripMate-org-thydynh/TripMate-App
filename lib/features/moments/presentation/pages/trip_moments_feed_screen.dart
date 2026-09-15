import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/gen_z_tokens.dart';
import '../../application/moments_providers.dart';
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
    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'moments.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri(context),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primaryOf(context),
        onRefresh: () async => ref.invalidate(momentsProvider(tripId)),
        child: async.when(
          loading: () => _skeleton(context),
          error: (e, _) => _error(context, ref, e),
          data: (moments) => moments.isEmpty
              ? _empty(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: moments.length,
                  itemBuilder: (context, i) => _card(context, ref, moments[i]),
                ),
        ),
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
          color: (_isDark(context) ? GenZTokens.inkDark : GenZTokens.ink)
              .withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
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
              color: GenZTokens.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'moments.load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri(context),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryOf(context),
                foregroundColor: GenZTokens.ink,
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
                color: _primaryOf(context).withValues(alpha: 0.12),
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
                fontWeight: FontWeight.w900,
                color: _textPri(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'moments.empty_sub'.tr(),
              style: AppFonts.body(fontSize: 14, color: _textSec(context)),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _card(BuildContext context, WidgetRef ref, Moment m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDark(context)
              ? GenZTokens.inkDark.withValues(alpha: 0.12)
              : GenZTokens.ink,
          width: 2,
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
                  backgroundColor: _primaryOf(context).withValues(alpha: 0.15),
                  backgroundImage: m.authorAvatar != null
                      ? NetworkImage(m.authorAvatar!)
                      : null,
                  child: m.authorAvatar == null
                      ? Text(
                          m.authorName.characters.first,
                          style: AppFonts.heading(
                            color: _textPri(context),
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.authorName,
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textPri(context),
                    ),
                  ),
                ),
                if (m.isGhost)
                  Icon(
                    PhosphorIcons.ghost(),
                    size: 18,
                    color: _textSec(context),
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
              placeholder: (c, url) =>
                  Container(color: _primaryOf(context).withValues(alpha: 0.08)),
              errorWidget: (c, url, err) => Container(
                color: _primaryOf(context).withValues(alpha: 0.08),
                child: Icon(
                  PhosphorIcons.image(),
                  color: _primaryOf(context),
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
                        color: _primaryOf(context),
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
                Icon(
                  PhosphorIcons.chatCircle(),
                  color: _textSec(context),
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  '${m.commentCount}',
                  style: AppFonts.body(fontSize: 13, color: _textSec(context)),
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
                  fontSize: 14,
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
