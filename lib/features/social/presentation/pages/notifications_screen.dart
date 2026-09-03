import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/notifications_repository.dart';

final pushNotificationsEnabledProvider = StateProvider<bool>((ref) => true);
final smsNotificationsEnabledProvider = StateProvider<bool>((ref) => false);
final emailNotificationsEnabledProvider = StateProvider<bool>((ref) => false);

/// Trung tâm thông báo — wired BE thật (`/notifications`).
class NotificationsScreen extends ConsumerWidget {
  final bool isDarkMode;
  const NotificationsScreen({super.key, this.isDarkMode = false});

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary => const Color(0xFFF5822B);
  Color get _ink =>
      isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textPri => _ink;
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

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
    final async = ref.watch(notificationsProvider);
    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'notifications.title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: _textPri),
            tooltip: 'notifications.settings_title'.tr(),
            onPressed: () => _showNotificationSettingsModal(context, ref),
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
                color: _primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: async.when(
          loading: () => _skeleton(),
          error: (e, _) => _error(context, ref, e),
          data: (list) => list.isEmpty
              ? _empty()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _tile(ref, list[i]),
                ),
        ),
      ),
    );
  }

  Widget _tile(WidgetRef ref, AppNotification n) {
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
          color: n.isRead ? _surface : const Color(0xFFFFD84D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ink, width: 2),
          boxShadow: n.isRead
              ? null
              : [BoxShadow(color: _ink, offset: const Offset(0, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF141210), width: 2),
              ),
              child: Icon(
                _iconFor(n.type),
                color: const Color(0xFFFFFDF5),
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
                      color: n.isRead ? _textPri : const Color(0xFF141210),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.body,
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: n.isRead ? _textSec : const Color(0xFF4A453E),
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
                  color: const Color(0xFFD8422B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF141210),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.all(16),
    children: List.generate(
      6,
      (i) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ink, width: 2),
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
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'notifications.load_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _primary),
              onPressed: () => ref.invalidate(notificationsProvider),
              icon: const Icon(Icons.refresh),
              label: Text('general.retry'.tr()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _empty() => ListView(
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
                color: const Color(0xFFC9B8FF),
                border: Border.all(color: _ink, width: 2.5),
                boxShadow: [BoxShadow(color: _ink, offset: const Offset(0, 4))],
              ),
              child: Icon(
                PhosphorIcons.bellSlash(PhosphorIconsStyle.fill),
                color: const Color(0xFF141210),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'notifications.empty'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'notifications.empty_sub'.tr(),
              style: AppFonts.body(fontSize: 14, color: _textSec),
            ),
          ],
        ),
      ),
    ],
  );

  void _showNotificationSettingsModal(BuildContext context, WidgetRef ref) {
    final borderCol = isDarkMode ? Colors.white : const Color(0xFF141210);
    final cardBgCol = isDarkMode
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBgCol,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          fontWeight: FontWeight.w900,
                          color: _textPri,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: _textPri),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'system_phases.notif_settings_desc'.tr(),
                    style: AppFonts.body(fontSize: 13, color: _textSec),
                  ),
                  const SizedBox(height: 20),

                  // Push Notif Switch
                  _buildSwitchTile(
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
                  ),
                  const SizedBox(height: 12),

                  // SMS Notif Switch
                  _buildSwitchTile(
                    title: 'system_phases.sms_notif'.tr(),
                    value: smsEnabled,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      ref.read(smsNotificationsEnabledProvider.notifier).state =
                          val;
                      debugPrint('SMS notification simulation set to: $val');
                    },
                    borderCol: borderCol,
                  ),
                  const SizedBox(height: 12),

                  // Email Notif Switch
                  _buildSwitchTile(
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
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color borderCol,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 2),
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
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFFD84D),
            activeTrackColor: _primary.withValues(alpha: 0.3),
            inactiveThumbColor: _textSec,
            inactiveTrackColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
