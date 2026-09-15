import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../application/checkins_providers.dart';
import '../data/checkins_repository.dart';

/// Màn điểm danh theo ngày — mỗi thành viên chọn GOING / MAYBE / OUT cho từng ngày.
class TripCheckinsScreen extends ConsumerWidget {
  final String tripId;
  final int tripDays;
  final bool isDarkMode;

  const TripCheckinsScreen({
    super.key,
    required this.tripId,
    required this.tripDays,
    required this.isDarkMode,
  });

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _ink =>
      isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textSec =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _card =>
      isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

  static const _statusColors = {
    'GOING': GenZTokens.success,
    'MAYBE': GenZTokens.warning,
    'OUT': GenZTokens.danger,
  };

  static PhosphorIconData _statusIcon(String status) {
    switch (status) {
      case 'GOING':
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
      case 'MAYBE':
        return PhosphorIcons.question(PhosphorIconsStyle.bold);
      case 'OUT':
      default:
        return PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
    }
  }

  static const _statusLabel = {
    'GOING': 'checkins.status_going',
    'MAYBE': 'checkins.status_maybe',
    'OUT': 'checkins.status_out',
  };

  Widget _statusChip(String status, bool selected, VoidCallback onTap) {
    final color = _statusColors[status] ?? GenZTokens.inkSoft;
    final textColor = selected
        ? (color.computeLuminance() > 0.5 ? GenZTokens.ink : GenZTokens.paper)
        : color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_statusIcon(status), size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              _statusLabel[status]!.tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkinsAsync = ref.watch(checkinsProvider(tripId));
    final myUserId = ref.watch(authProvider).user?['id'] as String?;

    /// Trạng thái điểm danh của chính mình trong một ngày (null = chưa chọn).
    String? myStatusForDay(List<DayCheckin> dayCheckins) {
      if (myUserId == null) return null;
      for (final c in dayCheckins) {
        if (c.userId == myUserId) return c.status;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: _ink),
        elevation: 0,
        title: Text(
          'checkins.title'.tr(),
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
                ref.read(checkinsProvider(tripId).notifier).refresh(),
          ),
        ],
      ),
      body: checkinsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: GenZTokens.orange),
        ),
        error: (e, _) => Center(
          child: Text(
            'checkins.load_failed'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
        data: (checkins) {
          // Group checkins by day
          final Map<int, List<DayCheckin>> byDay = {};
          for (final c in checkins) {
            byDay.putIfAbsent(c.day, () => []).add(c);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tripDays,
            itemBuilder: (context, index) {
              final day = index + 1;
              final dayCheckins = byDay[day] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _ink.withValues(alpha: 0.12),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: GenZTokens.orange,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: GenZTokens.ink,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'common.day_n'.tr(namedArgs: {'n': '$day'}),
                            style: AppFonts.heading(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: GenZTokens.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Going count
                        Text(
                          'checkins.going_count'.tr(
                            namedArgs: {
                              'n':
                                  '${dayCheckins.where((c) => c.status == 'GOING').length}',
                            },
                          ),
                          style: AppFonts.body(
                            fontSize: 12,
                            color: GenZTokens.success,
                          ),
                        ),
                      ],
                    ),
                    if (dayCheckins.isEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'checkins.empty'.tr(),
                        style: AppFonts.body(fontSize: 13, color: _textSec),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dayCheckins.map((c) {
                          final color =
                              _statusColors[c.status] ?? GenZTokens.inkSoft;
                          return Chip(
                            avatar: c.userAvatarUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      c.userAvatarUrl!,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: color.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: Text(
                                      c.userName.isNotEmpty
                                          ? c.userName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.userName,
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _statusIcon(c.status),
                                  size: 13,
                                  color: color,
                                ),
                              ],
                            ),
                            backgroundColor: color.withValues(alpha: 0.12),
                            side: BorderSide(
                              color: color.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // My checkin buttons
                    Text(
                      'checkins.my_status'.tr(),
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textSec,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['GOING', 'MAYBE', 'OUT'].map((status) {
                        final selected = myStatusForDay(dayCheckins) == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _statusChip(status, selected, () {
                            if (selected) return;
                            HapticFeedback.selectionClick();
                            ref
                                .read(checkinsProvider(tripId).notifier)
                                .upsert(day: day, status: status);
                          }),
                        );
                      }).toList(),
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
