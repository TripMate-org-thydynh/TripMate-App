import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/api_service.dart';
import '../../../core/services/media_uploader.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/report_sheet.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final String? userId;
  final String? username;

  const PublicProfileScreen({
    super.key,
    required this.userName,
    required this.avatarUrl,
    this.userId,
    this.username,
  });

  String get _handle {
    if (username != null && username!.trim().isNotEmpty) {
      final raw = username!.trim();
      return raw.startsWith('@') ? raw : '@$raw';
    }
    final slug = userName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_.]'), '');
    if (slug.isNotEmpty) return '@$slug';
    if (userId != null && userId!.isNotEmpty) {
      final shortId = userId!.length > 8 ? userId!.substring(0, 8) : userId!;
      return '@user_$shortId';
    }
    return '@user';
  }

  Future<void> _blockUser(BuildContext context, bool isDark) async {
    final isEn = context.locale.languageCode == 'en';
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        ),
        title: Text(
          isEn ? 'Block User?' : 'Chặn người dùng?',
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        content: Text(
          isEn
              ? 'You will no longer see content or messages from $userName.'
              : 'Bạn sẽ không còn thấy nội dung hoặc tin nhắn từ $userName.',
          style: AppFonts.body(fontSize: 13, color: inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: inkSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isEn ? 'Block' : 'Chặn',
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;
    try {
      if (userId != null && userId!.isNotEmpty) {
        await ApiService.post('/users/me/blocks', {'blockedId': userId});
      }
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn ? 'Blocked $userName' : 'Đã chặn $userName',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;
    final isEn = context.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.public_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: ink,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(PhosphorIcons.dotsThreeVertical(), color: ink),
            color: surface,
            onSelected: (val) {
              if (val == 'report') {
                ReportSheet.show(
                  context,
                  target: ReportTarget.user,
                  targetId: (userId != null && userId!.isNotEmpty)
                      ? userId!
                      : userName,
                );
              } else if (val == 'block') {
                _blockUser(context, isDark);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.flag(), size: 18, color: ink),
                    const SizedBox(width: 8),
                    Text(
                      isEn ? 'Report User' : 'Báo cáo người dùng',
                      style: AppFonts.body(fontSize: 14, color: ink),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.prohibit(), size: 18, color: danger),
                    const SizedBox(width: 8),
                    Text(
                      isEn ? 'Block User' : 'Chặn người dùng',
                      style: AppFonts.body(fontSize: 14, color: danger),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(GenZTokens.space4),
        child: Column(
          children: [
            // Center Profile info
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: line, width: GenZTokens.borderWidth),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: fill,
                backgroundImage: avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(
                        MediaUploader.cdnUrlForTier(avatarUrl, CdnTier.avatar),
                        cacheKey: MediaUploader.cdnCacheKey(
                          avatarUrl,
                          tier: CdnTier.avatar,
                        ),
                        maxWidth: CdnTier.avatar.width,
                        maxHeight: CdnTier.avatar.width,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: GenZTokens.space4),
            Text(
              userName,
              style: AppFonts.heading(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _handle,
              style: AppFonts.body(
                color: inkSoft,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: GenZTokens.space5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GenZTokens.space4),
              child: Text(
                'profile.public_no_stats'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  color: inkSoft,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
