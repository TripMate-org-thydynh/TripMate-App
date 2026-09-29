import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/gen_z_tokens.dart';

import '../../data/notifications_repository.dart';

final pushNotificationsEnabledProvider = StateProvider<bool>((ref) => true);
final smsNotificationsEnabledProvider = StateProvider<bool>((ref) => false);
final emailNotificationsEnabledProvider = StateProvider<bool>((ref) => false);

/// Trung tâm thông báo — wired BE thật (`/notifications`).
class NotificationsScreen extends ConsumerWidget {
  final bool isDarkMode;
  const NotificationsScreen({super.key, this.isDarkMode = false});

  Color _bgOf(BuildContext context, bool isDark) =>
      isDark ? GenZTokens.creamDark : GenZTokens.cream;
  Color _surfaceOf(bool isDark) =>
      isDark ? GenZTokens.paperDark : GenZTokens.paper;
  Color _primaryOf(bool isDark) =>
      isDark ? GenZTokens.accentDark : GenZTokens.accent;
  Color _onAccentOf(bool isDark) =>
      isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color _inkOf(bool isDark) => isDark ? GenZTokens.inkDark : GenZTokens.ink;
  Color _inkSoftOf(bool isDark) =>
      isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color _lineOf(bool isDark) => isDark ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(bool isDark) => isDark ? GenZTokens.fillDark : GenZTokens.fill;

  IconData _iconFor(String type) {
    switch (type) {
      case 'EXPENSE':
      case 'PAYMENT':
        return PhosphorIcons.wallet();
      case 'CHAT':
      case 'MESSAGE':
        return PhosphorIcons.chatCircle();
      case 'TRIP':
      case 'INVITE':
        return PhosphorIcons.airplaneTilt();
      case 'POLL':
        return PhosphorIcons.chartBar();
      default:
        return PhosphorIcons.bell();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark =
        isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(notificationsProvider);
    final textPri = _inkOf(isDark);
    final textSec = _inkSoftOf(isDark);

    return Scaffold(
      backgroundColor: _bgOf(context, isDark),
      appBar: AppBar(
        backgroundColor: _bgOf(context, isDark),
        elevation: 0,
        title: Text(
          'notifications.title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.slidersHorizontal(), color: textPri),
            tooltip: 'notifications.settings_title'.tr(),
            onPressed: () =>
                _showNotificationSettingsModal(context, ref, isDark),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.selectionClick();
              await ref.read(notificationsRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
            },
            child: Text(
              'general.mark_all_read'.tr(),
              style: AppFonts.body(
                color: _primaryOf(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryOf(isDark),
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: async.when(
          loading: () => _skeleton(isDark),
          error: (e, _) => _error(context, ref, e, isDark),
          data: (list) => list.isEmpty
              ? _empty(isDark, textPri, textSec)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, i) =>
                      _tile(context, ref, list[i], isDark),
                ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
    bool isDark,
  ) {
    final textPri = _inkOf(isDark);
    final textSec = _inkSoftOf(isDark);
    final unreadBg = isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    return GestureDetector(
      onTap: () {
        if (!n.isRead) {
          ref.read(notificationsRepositoryProvider).markRead(n.id);
          ref.invalidate(notificationsProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? _surfaceOf(isDark) : unreadBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: n.isRead ? _lineOf(isDark) : _primaryOf(isDark),
            width: n.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _primaryOf(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconFor(n.type),
                color: _onAccentOf(isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.body,
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textSec,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4, left: 6),
                decoration: BoxDecoration(
                  color: isDark ? GenZTokens.dangerDark : GenZTokens.danger,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _skeleton(bool isDark) => ListView(
    padding: const EdgeInsets.all(16),
    children: List.generate(
      6,
      (i) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surfaceOf(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _lineOf(isDark), width: 1),
        ),
      ),
    ),
  );

  Widget _error(BuildContext context, WidgetRef ref, Object e, bool isDark) =>
      ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(
                  PhosphorIcons.cloudSlash(),
                  color: isDark ? GenZTokens.dangerDark : GenZTokens.danger,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'notifications.load_failed'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _inkOf(isDark),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryOf(isDark),
                    foregroundColor: _onAccentOf(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => ref.invalidate(notificationsProvider),
                  icon: Icon(PhosphorIcons.arrowsClockwise()),
                  label: Text('general.retry'.tr()),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _empty(bool isDark, Color textPri, Color textSec) => ListView(
    children: [
      const SizedBox(height: 130),
      Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _fillOf(isDark),
                border: Border.all(color: _lineOf(isDark), width: 1),
              ),
              child: Icon(
                PhosphorIcons.bellSlash(PhosphorIconsStyle.fill),
                color: _primaryOf(isDark),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'notifications.empty'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPri,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'notifications.empty_sub'.tr(),
              style: AppFonts.body(fontSize: 13, color: textSec),
            ),
          ],
        ),
      ),
    ],
  );

  void _showNotificationSettingsModal(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final borderCol = _lineOf(isDark);
    final cardBgCol = _surfaceOf(isDark);
    final textPri = _inkOf(isDark);
    final textSec = _inkSoftOf(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBgCol,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final pushEnabled = ref.watch(pushNotificationsEnabledProvider);
          final smsEnabled = ref.watch(smsNotificationsEnabledProvider);
          final emailEnabled = ref.watch(emailNotificationsEnabledProvider);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'system_phases.notif_settings_title'.tr(),
                        style: AppFonts.heading(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPri,
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.x(), color: textPri),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'system_phases.notif_settings_desc'.tr(),
                    style: AppFonts.body(fontSize: 13, color: textSec),
                  ),
                  const SizedBox(height: 20),

                  // Push Notif Switch
                  _buildSwitchTile(
                    context: context,
                    title: 'system_phases.push_notif'.tr(),
                    value: pushEnabled,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      ref
                              .read(pushNotificationsEnabledProvider.notifier)
                              .state =
                          val;
                    },
                    borderCol: borderCol,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // SMS Notif Switch
                  _buildSwitchTile(
                    context: context,
                    title: 'system_phases.sms_notif'.tr(),
                    value: smsEnabled,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      ref.read(smsNotificationsEnabledProvider.notifier).state =
                          val;
                      debugPrint('SMS notification simulation set to: $val');
                    },
                    borderCol: borderCol,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Email Notif Switch
                  _buildSwitchTile(
                    context: context,
                    title: 'system_phases.email_notif'.tr(),
                    value: emailEnabled,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      ref
                              .read(emailNotificationsEnabledProvider.notifier)
                              .state =
                          val;
                      debugPrint('Email notification simulation set to: $val');
                    },
                    borderCol: borderCol,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color borderCol,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceOf(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _inkOf(isDark),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _onAccentOf(isDark),
            activeTrackColor: _primaryOf(isDark),
            inactiveThumbColor: _inkSoftOf(isDark),
            inactiveTrackColor: _fillOf(isDark),
          ),
        ],
      ),
    );
  }
}
