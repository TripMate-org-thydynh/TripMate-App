import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../application/invites_providers.dart';
import '../data/invites_repository.dart';

/// Màn quản lý invite links có hạn / dùng 1 lần.
class TripInvitesScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String tripName;
  final bool isDarkMode;

  const TripInvitesScreen({
    super.key,
    required this.tripId,
    required this.tripName,
    required this.isDarkMode,
  });

  @override
  ConsumerState<TripInvitesScreen> createState() => _TripInvitesScreenState();
}

class _TripInvitesScreenState extends ConsumerState<TripInvitesScreen> {
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
  Color get _card =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);

  void _showCreateDialog() {
    String? selectedExpiry; // null = no expiry, '1h', '24h', '7d'
    int? selectedMaxUses; // null = unlimited, 1, 5, 10

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: _bgOf(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: _ink.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textSec.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'invites.create_title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'invites.create_sub'.tr(),
                  style: AppFonts.body(fontSize: 13, color: _textSec),
                ),
                const SizedBox(height: 20),
                // Expiry options
                Text(
                  'invites.expiry'.tr(),
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textSec,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _optionChip(
                      'common.unlimited'.tr(),
                      null == selectedExpiry,
                      () => setModalState(() => selectedExpiry = null),
                    ),
                    _optionChip(
                      'invites.expiry_1h'.tr(),
                      selectedExpiry == '1h',
                      () => setModalState(() => selectedExpiry = '1h'),
                    ),
                    _optionChip(
                      'invites.expiry_24h'.tr(),
                      selectedExpiry == '24h',
                      () => setModalState(() => selectedExpiry = '24h'),
                    ),
                    _optionChip(
                      'invites.days_7'.tr(),
                      selectedExpiry == '7d',
                      () => setModalState(() => selectedExpiry = '7d'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Max uses options
                Text(
                  'invites.uses'.tr(),
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textSec,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _optionChip(
                      'common.unlimited'.tr(),
                      null == selectedMaxUses,
                      () => setModalState(() => selectedMaxUses = null),
                    ),
                    _optionChip(
                      'invites.uses_1'.tr(),
                      selectedMaxUses == 1,
                      () => setModalState(() => selectedMaxUses = 1),
                    ),
                    _optionChip(
                      'invites.uses_5'.tr(),
                      selectedMaxUses == 5,
                      () => setModalState(() => selectedMaxUses = 5),
                    ),
                    _optionChip(
                      'invites.uses_10'.tr(),
                      selectedMaxUses == 10,
                      () => setModalState(() => selectedMaxUses = 10),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5822B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: Color(0xFF141210),
                          width: 2,
                        ),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      String? expiresAt;
                      if (selectedExpiry != null) {
                        final now = DateTime.now();
                        if (selectedExpiry == '1h') {
                          expiresAt = now
                              .add(const Duration(hours: 1))
                              .toIso8601String();
                        } else if (selectedExpiry == '24h') {
                          expiresAt = now
                              .add(const Duration(hours: 24))
                              .toIso8601String();
                        } else if (selectedExpiry == '7d') {
                          expiresAt = now
                              .add(const Duration(days: 7))
                              .toIso8601String();
                        }
                      }
                      final invite = await ref
                          .read(invitesProvider(widget.tripId).notifier)
                          .create(
                            expiresAt: expiresAt,
                            maxUses: selectedMaxUses,
                          );
                      if (context.mounted) {
                        _shareInvite(invite);
                      }
                    },
                    child: Text(
                      'invites.create_share'.tr(),
                      style: AppFonts.heading(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _optionChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF5822B)
              : const Color(0xFFF5822B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? const Color(0xFFF5822B)
                : const Color(0xFFF5822B).withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFFF5822B),
          ),
        ),
      ),
    );
  }

  void _shareInvite(TripInvite invite) {
    final code = invite.code;
    Share.share(
      'invites.share_body'.tr(
        namedArgs: {'name': widget.tripName, 'code': code},
      ),
      subject: 'invites.share_subject'.tr(namedArgs: {'trip': widget.tripName}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invitesAsync = ref.watch(invitesProvider(widget.tripId));

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: _ink),
        elevation: 0,
        title: Text(
          'invites.title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: _ink),
            onPressed: () =>
                ref.read(invitesProvider(widget.tripId).notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          _showCreateDialog();
        },
        backgroundColor: const Color(0xFFF5822B),
        foregroundColor: Colors.white,
        icon: Icon(PhosphorIcons.link()),
        label: Text(
          'invites.create_short'.tr(),
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: invitesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: const Color(0xFFF5822B)),
        ),
        error: (e, _) => Center(
          child: Text(
            'invites.load_failed'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
        data: (invites) {
          if (invites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.linkSimple(PhosphorIconsStyle.fill),
                    size: 72,
                    color: _textSec.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'invites.empty'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textSec,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'invites.empty_sub'.tr(),
                    style: AppFonts.body(fontSize: 14, color: _textSec),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invites.length,
            itemBuilder: (context, i) {
              final invite = invites[i];
              final isValid =
                  invite.isActive && !invite.isExpired && !invite.isExhausted;
              final statusColor = isValid
                  ? const Color(0xFF1FA85C)
                  : Colors.red;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Code display
                        Expanded(
                          child: Text(
                            invite.code,
                            style: AppFonts.mono(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF5822B),
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            invite.statusLabel,
                            style: AppFonts.heading(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (invite.expiresAt != null) ...[
                          Icon(
                            PhosphorIcons.clock(),
                            size: 13,
                            color: _textSec,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'invites.expires_at'.tr(
                              namedArgs: {
                                'at': DateFormat(
                                  'dd/MM HH:mm',
                                ).format(invite.expiresAt!),
                              },
                            ),
                            style: AppFonts.body(fontSize: 12, color: _textSec),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (invite.maxUses != null) ...[
                          Icon(
                            PhosphorIcons.users(),
                            size: 13,
                            color: _textSec,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'invites.uses_count'.tr(
                              namedArgs: {
                                'used': '${invite.useCount}',
                                'max': '${invite.maxUses}',
                              },
                            ),
                            style: AppFonts.body(fontSize: 12, color: _textSec),
                          ),
                        ],
                        if (invite.expiresAt == null && invite.maxUses == null)
                          Text(
                            'common.unlimited'.tr(),
                            style: AppFonts.body(fontSize: 12, color: _textSec),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (isValid) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5822B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Color(0xFF141210),
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () => _shareInvite(invite),
                              icon: Icon(
                                PhosphorIcons.shareNetwork(),
                                size: 16,
                              ),
                              label: Text(
                                'invites.share'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              PhosphorIcons.copy(),
                              color: _ink,
                              size: 20,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: invite.code),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('invites.copied'.tr()),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                        IconButton(
                          icon: Icon(
                            PhosphorIcons.trash(),
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () async {
                            await ref
                                .read(invitesProvider(widget.tripId).notifier)
                                .deactivate(invite.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
