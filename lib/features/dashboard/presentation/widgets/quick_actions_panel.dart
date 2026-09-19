import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../discovery/presentation/pages/vibe_swipe_deck_screen.dart';
import '../../../moments/presentation/pages/memory_wall_screen.dart';
import '../../../gamification/gamification_screen.dart';
import '../../../profile/profile_screen.dart';
import '../../../ai/ai_hub_screen.dart';
import '../../../premium/premium_hub_screen.dart';
import '../../../expense_tracker/presentation/pages/trip_balances_screen.dart';
import '../../../trips/presentation/pick_trip_sheet.dart';
import '../../../trips/presentation/my_trips_screen.dart';
import '../../../discovery/presentation/pages/photo_location_screen.dart';
import '../../../../core/widgets/gen_z_widgets.dart';

class QuickActionsPanel extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const QuickActionsPanel({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  // ── Primary 4 actions (2×2 Spark-style colored cards) ────────────────────────
  static const List<Map<String, dynamic>> _primaryActions = [
    {'labelKey': 'dashboard.split_money', 'type': 'expense', 'isPrimary': true},
    // Trước đây ô này mở Ghost Cam — một màn "máy ảnh" mà khung ngắm chỉ là
    // ảnh Unsplash và nút chụp chỉ hiện "Captured ... moment!" chứ không chụp
    // hay lưu gì. App chưa có đường tải ảnh lên nên chưa đăng được khoảnh
    // khắc; ô này nay mở Memory Wall để xem kỷ niệm thật.
    {'labelKey': 'dashboard.memories', 'type': 'memories', 'isPrimary': false},
    {'labelKey': 'dashboard.bingo', 'type': 'bingo', 'isPrimary': false},
    {
      'labelKey': 'dashboard.vibe_match',
      'type': 'vibe_match',
      'isPrimary': true,
    },
  ];

  // ── Secondary actions (compact horizontal row) ────────────────────────────────
  static const List<Map<String, dynamic>> _secondaryActions = [
    {'labelKey': 'dashboard.photo_map', 'type': 'photo_loc'},
    {'labelKey': 'dashboard.trips', 'type': 'trips'},
    {'labelKey': 'dashboard.profile', 'type': 'profile'},
    {'labelKey': 'dashboard.matey_ai', 'type': 'ai_hub'},
    {'labelKey': 'dashboard.premium', 'type': 'premium'},
  ];

  IconData _primaryIcon(String type) {
    switch (type) {
      case 'expense':
        return PhosphorIcons.wallet();
      case 'memories':
        return PhosphorIcons.camera();
      case 'bingo':
        return PhosphorIcons.gameController();
      default:
        return PhosphorIcons.heartbeat();
    }
  }

  IconData _secondaryIcon(String type) {
    switch (type) {
      case 'photo_loc':
        return PhosphorIcons.mapPin();
      case 'trips':
        return PhosphorIcons.airplaneTilt();
      case 'profile':
        return PhosphorIcons.user();
      case 'ai_hub':
        return PhosphorIcons.robot();
      default:
        return PhosphorIcons.crown();
    }
  }

  void _handleTap(BuildContext context, String type) {
    HapticFeedback.mediumImpact();
    switch (type) {
      case 'photo_loc':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoLocationScreen(isDarkMode: isDarkMode),
          ),
        );
      case 'trips':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyTripsScreen(isDarkMode: isDarkMode),
          ),
        );
      case 'expense':
        // Chia tiền THẬT: chọn chuyến → màn số dư/quyết toán (wired backend).
        () async {
          final trip = await PickTripSheet.show(
            context,
            isDarkMode,
            title: 'expense.pick_trip_title'.tr(),
          );
          if (trip != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripBalancesScreen(
                  tripId: trip.id,
                  tripName: trip.name,
                  isDarkMode: isDarkMode,
                ),
              ),
            );
          }
        }();
      case 'memories':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemoryWallScreen(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
        );
      case 'bingo':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GamificationScreen()),
        );
      case 'vibe_match':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VibeSwipeDeckScreen(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
        );
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      case 'ai_hub':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiHubScreen()),
        );
      case 'premium':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumHubScreen()),
        );
    }
  }

  Color get _textPri => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textSec =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _surface => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent => isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      isDarkMode ? GenZTokens.onAccentDark : GenZTokens.onAccent;

  void _showAllActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'dashboard.quick_actions'.tr(),
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: _textPri,
                      ),
                    ),
                    IconButton(
                      icon: Icon(PhosphorIcons.x(), color: _textPri, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _secondaryActions.map((action) {
                    final type = action['type'] as String;
                    return PressableCard(
                      onTap: () {
                        Navigator.pop(ctx);
                        _handleTap(context, type);
                      },
                      color: _fill,
                      borderColor: _line,
                      shadowColor: _textPri,
                      borderWidth: GenZTokens.borderWidthThin,
                      radius: GenZTokens.radiusPill,
                      depth: 1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_secondaryIcon(type), size: 16, color: _accent),
                          const SizedBox(width: 8),
                          Text(
                            (action['labelKey'] as String).tr(),
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textPri,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'dashboard.quick_actions'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: -0.5,
                  color: _textPri,
                ),
              ),
              const SizedBox(width: 8),
              PillTag(
                text: 'dashboard.quick_tag'.tr(),
                icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                selected: true,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAllActionsSheet(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'common.more'.tr(),
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textSec,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      PhosphorIcons.caretRight(),
                      size: 14,
                      color: _textSec,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Primary 2×2 Cards ────────────────────────────────────────────────
        GridView.builder(
          // Home không có SafeArea trên → phải tắt padding tự động theo thanh trạng thái.
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemCount: _primaryActions.length,
          itemBuilder: (context, index) {
            final action = _primaryActions[index];
            final type = action['type'] as String;

            // Ô đầu (Chia tiền) là hành động chính → tô màu nhấn.
            final hero = index == 0;
            final bg = hero ? _accent : _surface;
            final fg = hero ? _onAccent : _textPri;
            final fgSoft = hero ? _onAccent.withValues(alpha: 0.8) : _textSec;
            final iconBg = hero
                ? _onAccent.withValues(alpha: 0.16)
                : Theme.of(context).colorScheme.primaryContainer;
            final iconFg = hero
                ? _onAccent
                : Theme.of(context).colorScheme.onPrimaryContainer;

            return PopIn(
              index: index,
              child: PressableCard(
                onTap: () => _handleTap(context, type),
                color: bg,
                borderColor: hero ? bg : _line,
                shadowColor: _textPri,
                borderWidth: GenZTokens.borderWidthThin,
                depth: 1,
                radius: GenZTokens.radiusCard,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(
                                GenZTokens.radiusButton,
                              ),
                            ),
                            child: Icon(
                              _primaryIcon(type),
                              size: 22,
                              color: iconFg,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            PhosphorIcons.arrowUpRight(),
                            size: 18,
                            color: fgSoft,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        (action['labelKey'] as String).tr(),
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${action['labelKey']}_desc'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          color: fgSoft,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
