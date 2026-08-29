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
            title: 'Chia tiền cho chuyến nào?',
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

  @override
  Widget build(BuildContext context) {
    final ink = isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final paper = isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

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
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: ink,
                ),
              ),
              const SizedBox(width: 8),
              PillTag(
                text: 'quick',
                icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                color: GenZTokens.yellow,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Primary 2×2 Spark-style colored cards ────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
          ),
          itemCount: _primaryActions.length,
          itemBuilder: (context, index) {
            final action = _primaryActions[index];
            final type = action['type'] as String;
            // Mỗi ô một khối màu accent đặc — chữ và viền LUÔN là ink
            const cardColors = [
              GenZTokens.yellow,
              GenZTokens.lilac,
              GenZTokens.green,
              GenZTokens.pink,
            ];
            final bgColor = cardColors[index % cardColors.length];

            return PopIn(
              index: index,
              child: PressableCard(
                onTap: () => _handleTap(context, type),
                color: bgColor,
                borderColor: ink,
                shadowColor: ink,
                radius: GenZTokens.radiusButton,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GenZTokens.paper,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GenZTokens.ink,
                            width: GenZTokens.borderWidthThin,
                          ),
                        ),
                        child: Icon(
                          _primaryIcon(type),
                          size: 18,
                          color: GenZTokens.ink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          (action['labelKey'] as String).tr(),
                          style: AppFonts.heading(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: GenZTokens.ink,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // ── Secondary actions horizontal row ─────────────────────────────────
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _secondaryActions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final action = _secondaryActions[index];
              final type = action['type'] as String;

              return PressableCard(
                onTap: () => _handleTap(context, type),
                color: paper,
                borderColor: ink,
                shadowColor: ink,
                borderWidth: GenZTokens.borderWidthThin,
                radius: GenZTokens.radiusPill,
                depth: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_secondaryIcon(type), size: 15, color: ink),
                    const SizedBox(width: 6),
                    Text(
                      (action['labelKey'] as String).tr().toUpperCase(),
                      style: AppFonts.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
