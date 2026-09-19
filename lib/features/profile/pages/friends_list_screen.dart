import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/buddies_repository.dart';

/// Những người đã đi chung chuyến với mình.
///
/// Trước đây màn này liệt kê 3 người không tồn tại kèm nút "Nhắn tin" chỉ hiện
/// snackbar giả. Nay lấy đồng đội THẬT từ `/users/me/buddies`; muốn nhắn tin
/// thì vào Squad Chat của chuyến, nên bỏ hẳn nút giả đó.
class FriendsListScreen extends ConsumerWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          'profile.buddies_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: ink),
            onPressed: () => ref.invalidate(travelBuddiesProvider),
          ),
        ],
      ),
      body: ref
          .watch(travelBuddiesProvider)
          .when(
            loading: () =>
                Center(child: CircularProgressIndicator(color: accent, strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(travelBuddiesProvider),
            ),
            data: (buddies) {
              if (buddies.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: PhosphorIcons.users(),
                  title: 'profile.buddies_empty_title'.tr(),
                  body: 'profile.buddies_empty_body'.tr(),
                );
              }
              return RefreshIndicator(
                color: accent,
                onRefresh: () async => ref.invalidate(travelBuddiesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(GenZTokens.space4),
                  itemCount: buddies.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GenZTokens.space2),
                  itemBuilder: (_, i) => _tile(isDark, buddies[i]),
                ),
              );
            },
          ),
    );
  }

  Widget _tile(bool isDark, TravelBuddy b) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final avatar = b.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(color: line, width: GenZTokens.borderWidthThin),
            ),
            child: avatar != null && avatar.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: avatar,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _initial(b.name, ink),
                    placeholder: (_, _) => _initial(b.name, ink),
                  )
                : _initial(b.name, ink),
          ),
          const SizedBox(width: GenZTokens.space4),
          // Flexible để tên dài không tràn khi máy hẹp / chữ phóng to.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  b.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  b.lastTripName.isEmpty
                       ? 'profile.buddies_shared'.plural(b.sharedTrips)
                      : '${'profile.buddies_shared'.plural(b.sharedTrips)} · ${b.lastTripName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 12, color: inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initial(String name, Color ink) => Center(
    child: Text(
      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
      style: AppFonts.heading(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
  );
}
