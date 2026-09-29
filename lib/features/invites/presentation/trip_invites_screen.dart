import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
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
  bool _isDark(BuildContext context) =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _cardOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color _lineOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.fillDark : GenZTokens.fill;
  Color _primaryOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentDark : GenZTokens.accent;
  Color _onAccentOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color _accentSoftOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color _inkOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSecOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  void _showCreateDialog() {
    String? selectedExpiry; // null = no expiry, '1h', '24h', '7d'
    int? selectedMaxUses; // null = unlimited, 1, 5, 10
    final textPri = _inkOf(context);
    final textSec = _textSecOf(context);
    final line = _lineOf(context);
    final cardBg = _cardOf(context);
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: line, width: 1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
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
                      color: textSec.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'invites.create_title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'invites.create_sub'.tr(),
                  style: AppFonts.body(fontSize: 13, color: textSec),
                ),
                const SizedBox(height: 20),
                // Expiry options
                Text(
                  'invites.expiry'.tr(),
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSec,
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
                    fontWeight: FontWeight.w600,
                    color: textSec,
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
                      backgroundColor: primary,
                      foregroundColor: onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                        fontWeight: FontWeight.w700,
                        color: onAccent,
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
    final primary = _primaryOf(context);
    final accentSoft = _accentSoftOf(context);
    final fill = _fillOf(context);
    final line = _lineOf(context);
    final textSec = _textSecOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accentSoft : fill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? primary : line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? primary : textSec,
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
    final dark = _isDark(context);
    final textPri = _inkOf(context);
    final textSec = _textSecOf(context);
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);
    final line = _lineOf(context);
    final fill = _fillOf(context);
    final cardBg = _cardOf(context);

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: textPri),
        elevation: 0,
        title: Text(
          'invites.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: textPri),
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
        backgroundColor: primary,
        foregroundColor: onAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: Icon(PhosphorIcons.link(), color: onAccent),
        label: Text(
          'invites.create_short'.tr(),
          style: AppFonts.heading(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: onAccent,
          ),
        ),
      ),
      body: invitesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primary)),
        error: (e, _) => Center(
          child: Text(
            'invites.load_failed'.tr(),
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPri,
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
                    color: textSec.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'invites.empty'.tr(),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'invites.empty_sub'.tr(),
                    style: AppFonts.body(fontSize: 13, color: textSec),
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
                  ? (dark ? GenZTokens.successDark : GenZTokens.success)
                  : (dark ? GenZTokens.dangerDark : GenZTokens.danger);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: line, width: 1),
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
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textPri,
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
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
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
                          Icon(PhosphorIcons.clock(), size: 14, color: textSec),
                          const SizedBox(width: 4),
                          Text(
                            'invites.expires_at'.tr(
                              namedArgs: {
                                'at': DateFormat(
                                  'dd/MM HH:mm',
                                ).format(invite.expiresAt!),
                              },
                            ),
                            style: AppFonts.body(fontSize: 12, color: textSec),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (invite.maxUses != null) ...[
                          Icon(PhosphorIcons.users(), size: 14, color: textSec),
                          const SizedBox(width: 4),
                          Text(
                            'invites.uses_count'.tr(
                              namedArgs: {
                                'used': '${invite.useCount}',
                                'max': '${invite.maxUses}',
                              },
                            ),
                            style: AppFonts.body(fontSize: 12, color: textSec),
                          ),
                        ],
                        if (invite.expiresAt == null && invite.maxUses == null)
                          Text(
                            'common.unlimited'.tr(),
                            style: AppFonts.body(fontSize: 12, color: textSec),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (isValid) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: fill,
                                foregroundColor: textPri,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                side: BorderSide(color: line, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () => _shareInvite(invite),
                              icon: Icon(
                                PhosphorIcons.shareNetwork(),
                                size: 16,
                                color: textPri,
                              ),
                              label: Text(
                                'invites.share'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPri,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              PhosphorIcons.copy(),
                              color: textPri,
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
                            color: dark
                                ? GenZTokens.dangerDark
                                : GenZTokens.danger,
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
