import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/gen_z_tokens.dart';
import '../../data/notifications_repository.dart';
import '../pages/notifications_screen.dart';

/// Chuông thông báo + badge số chưa đọc (đọc từ `unreadCountProvider`).
class NotificationBell extends ConsumerWidget {
  final bool isDarkMode;
  final Color? color;
  const NotificationBell({super.key, this.isDarkMode = false, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final unread = ref.watch(unreadCountProvider);
    final iconColor =
        color ?? (isDark ? GenZTokens.inkDark : GenZTokens.ink);

    return Semantics(
      button: true,
      label: unread > 0
          ? 'notifications.unread_label'.tr(namedArgs: {'n': '$unread'})
          : 'notifications.title'.tr(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(PhosphorIcons.bell(), color: iconColor),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(isDarkMode: isDark),
                ),
              );
            },
          ),
          if (unread > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: const BoxDecoration(
                  color: GenZTokens.orange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: AppFonts.heading(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: GenZTokens.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
