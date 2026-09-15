import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final String? userId;

  const PublicProfileScreen({
    super.key,
    required this.userName,
    required this.avatarUrl,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.public_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Center Profile info
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ink, width: 2.5),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: GenZTokens.yellow,
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: AppFonts.heading(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@tripmate_buddy',
              style: AppFonts.body(
                color: inkSoft,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
