import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final isDark = isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'games.badges_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ink),
            onPressed: () => ref.invalidate(badgesProvider),
          ),
        ],
      ),
      body: ref
          .watch(badgesProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(badgesProvider),
            ),
            data: (badges) {
              if (badges.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.emoji_events_outlined,
                  title: 'games.badges_title'.tr(),
                  body: 'games.badges_empty'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(badgesProvider),
                child: GridView.builder(
                  padding: const EdgeInsets.all(GenZTokens.space5),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: GenZTokens.space4,
                        mainAxisSpacing: GenZTokens.space4,
                        childAspectRatio: 0.92,
                      ),
                  itemCount: badges.length,
                  itemBuilder: (context, i) => _tile(context, isDark, badges[i]),
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
          color: b.unlocked ? GenZTokens.yellow : surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: ink,
            width: b.unlocked
                ? GenZTokens.borderWidth
                : GenZTokens.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              b.unlocked ? Icons.emoji_events : Icons.lock_outline,
              size: 26,
              color: b.unlocked ? GenZTokens.ink : inkSoft,
            ),
            const Spacer(),
            Text(
              b.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: b.unlocked ? GenZTokens.ink : ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${b.current} / ${b.target}',
              style: AppFonts.body(
                fontSize: 12,
                color: b.unlocked ? GenZTokens.ink : inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
