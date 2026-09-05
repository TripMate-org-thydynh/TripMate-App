import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/badges_repository.dart';

/// Chi tiết một danh hiệu.
///
/// Trước đây màn này chỉ nhận tên danh hiệu rồi tự bịa phần còn lại: danh sách
/// điều kiện ("Spend 10m+ on midnight snacks", "Trigger 5+ unplanned detours")
/// và một dòng thời gian thăng cấp qua các chuyến không tồn tại ("Berlin
/// Weekend Bender", "Roadtrip to Nowhere"), cùng 3 nút chỉ hiện "Tính năng đang
/// được hoàn thiện". Nay hiển thị đúng điều kiện và tiến độ thật của danh hiệu.
class BadgeDetailScreen extends StatelessWidget {
  final TripBadge badge;
  final bool isDarkMode;

  const BadgeDetailScreen({
    super.key,
    required this.badge,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final remaining = badge.target - badge.current;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GenZTokens.space5),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: badge.unlocked ? GenZTokens.yellow : surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: ink, width: GenZTokens.borderWidth),
            ),
            child: Column(
              children: [
                Icon(
                  badge.unlocked ? Icons.emoji_events : Icons.lock_outline,
                  size: 56,
                  color: badge.unlocked ? GenZTokens.ink : inkSoft,
                ),
                const SizedBox(height: GenZTokens.space4),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GenZTokens.space5,
                  ),
                  child: Text(
                    badge.title,
                    textAlign: TextAlign.center,
                    style: AppFonts.heading(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: badge.unlocked ? GenZTokens.ink : ink,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.unlocked
                      ? 'profile.badge_unlocked'.tr()
                      : 'profile.badge_locked'.tr(),
                  style: AppFonts.body(
                    fontSize: 13,
                    color: badge.unlocked ? GenZTokens.ink : inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GenZTokens.space5),
          Container(
            padding: const EdgeInsets.all(GenZTokens.space5),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile.badge_condition'.tr(),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.desc,
                  style: AppFonts.body(
                    fontSize: 14,
                    color: inkSoft,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: GenZTokens.space5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: badge.percent / 100,
                    minHeight: 10,
                    backgroundColor: inkSoft.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      badge.unlocked ? GenZTokens.success : GenZTokens.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${badge.current} / ${badge.target}',
                      style: AppFonts.heading(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    if (!badge.unlocked && remaining > 0)
                      Text(
                        'profile.badge_remaining'.plural(remaining),
                        style: AppFonts.body(fontSize: 13, color: inkSoft),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
