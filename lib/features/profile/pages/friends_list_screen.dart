import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'profile.buddies_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ink),
            onPressed: () => ref.invalidate(travelBuddiesProvider),
          ),
        ],
      ),
      body: ref
          .watch(travelBuddiesProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(travelBuddiesProvider),
            ),
            data: (buddies) {
              if (buddies.isEmpty) {
                return AppEmptyState(
                  isDark: isDark,
                  icon: Icons.group_outlined,
                  title: 'profile.buddies_empty_title'.tr(),
                  body: 'profile.buddies_empty_body'.tr(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(travelBuddiesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(GenZTokens.space5),
                  itemCount: buddies.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GenZTokens.space3),
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
    final avatar = b.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: GenZTokens.lilac,
              shape: BoxShape.circle,
              border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
            ),
            child: avatar != null && avatar.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: avatar,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _initial(b.name),
                    placeholder: (_, _) => _initial(b.name),
                  )
                : _initial(b.name),
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
                    fontWeight: FontWeight.w800,
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
                  style: AppFonts.body(fontSize: 12.5, color: inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initial(String name) => Center(
    child: Text(
      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
      style: AppFonts.heading(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: GenZTokens.ink,
      ),
    ),
  );
}
