import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/badges_repository.dart';
import 'badge_detail_screen.dart';

/// Bộ sưu tập danh hiệu.
///
/// Trước đây khi `/users/me/badges` lỗi, màn này âm thầm rơi về `_mockBadges` —
/// 3 danh hiệu in cứng, hai cái đầu luôn ở trạng thái "đã mở khoá" — nên mất
/// mạng là người dùng tưởng mình đã đạt được chúng. Nay hỏng thì báo hỏng.
class BadgeCollectionScreen extends ConsumerWidget {
  final bool isDarkMode;

  const BadgeCollectionScreen({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark =
        isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'games.badges_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: ink),
            onPressed: () => ref.invalidate(badgesProvider),
          ),
        ],
      ),
      body: ref
          .watch(badgesProvider)
          .when(
            loading: () =>
                Center(child: CircularProgressIndicator(color: accent, strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(badgesProvider),
            ),
            data: (badges) {
              if (badges.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: PhosphorIcons.trophy(),
                  title: 'games.badges_title'.tr(),
                  body: 'games.badges_empty'.tr(),
                );
              }
              return RefreshIndicator(
                color: accent,
                onRefresh: () async => ref.invalidate(badgesProvider),
                child: GridView.builder(
                  padding: const EdgeInsets.all(GenZTokens.space4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: GenZTokens.space3,
                    mainAxisSpacing: GenZTokens.space3,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, i) =>
                      _tile(context, isDark, badges[i]),
                ),
              );
            },
          ),
    );
  }

  Widget _tile(BuildContext context, bool isDark, TripBadge b) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final warning = isDark ? GenZTokens.warningDark : GenZTokens.warning;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BadgeDetailScreen(badge: b, isDarkMode: isDark),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(GenZTokens.space4),
        decoration: BoxDecoration(
          color: b.unlocked ? surface : fill,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: line,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              b.unlocked
                  ? PhosphorIcons.trophy(PhosphorIconsStyle.fill)
                  : PhosphorIcons.lockKey(),
              size: 26,
              color: b.unlocked ? warning : inkSoft,
            ),
            const Spacer(),
            Text(
              b.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.heading(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: b.unlocked ? ink : inkSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${b.current} / ${b.target}',
              style: AppFonts.body(
                fontSize: 12,
                color: inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
