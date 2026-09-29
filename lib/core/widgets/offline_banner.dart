import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_provider.dart';
import '../theme/gen_z_tokens.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineProvider);
    if (!isOffline) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final warning = isDark ? GenZTokens.warningDark : GenZTokens.warning;
    final bg = isDark ? const Color(0xFF28231C) : const Color(0xFFFBF6ED);
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: warning.withValues(alpha: isDark ? 0.4 : 0.3),
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.wifiSlash(), color: warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'errors.viewing_offline'.tr(),
                  style: AppFonts.heading(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
                Text(
                  'errors.offline_cache'.tr(),
                  style: AppFonts.body(
                    color: inkSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
