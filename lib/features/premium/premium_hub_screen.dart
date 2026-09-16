// Chi lay `tr`: easy_localization re-export intl, va intl cung co
// TextDirection -> va cham voi dart:ui trong SlideGradientTransform.
import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/gen_z_tokens.dart';
import '../profile/data/profile_provider.dart';
import 'pages/billing_history_screen.dart';
import 'pages/creator_revenue_dashboard_screen.dart';
import 'pages/referral_campaign_screen.dart';
import 'pages/referral_rewards_screen.dart';
import 'pages/subscription_checkout_screen.dart';
import 'pages/subscription_settings_screen.dart';

class PremiumHubScreen extends StatefulWidget {
  const PremiumHubScreen({super.key});

  @override
  State<PremiumHubScreen> createState() => _PremiumHubScreenState();
}

class _PremiumHubScreenState extends State<PremiumHubScreen> {
  /// Theo đúng chế độ sáng/tối của app thay vì giữ cờ riêng — cờ riêng làm màn
  /// này lệch pha với theme người dùng đã chọn.
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  final List<String> _themes = [
    'Tokyo Neon',
    'Đà Lạt Mist',
    'Beach Chaos',
    'Retro Film',
    'Cyber Night',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;

    final bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final cardBg = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final accentSoft = isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top app bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.arrowLeft(),
                          color: textPrimary,
                        ),
                        tooltip: tr('common.close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        tr('premium.elite_squad'),
                        style: AppFonts.heading(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branding and title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TripMate',
                                  style: AppFonts.heading(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    color: textPrimary,
                                  ),
                                ),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final p = ref
                                        .watch(profileDataProvider)
                                        .profile;
                                    final name =
                                        p?['username'] as String? ??
                                        p?['name'] as String? ??
                                        '';
                                    if (name.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Text(
                                      '@$name',
                                      style: AppFonts.body(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: accent,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentSoft,
                              ),
                              child: Icon(
                                PhosphorIcons.crown(),
                                color: accent,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Text(
                          tr('premium.hero_sub'),
                          style: AppFonts.heading(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Cinematic themes section
                        Text(
                          tr('premium.cinematic_themes'),
                          style: AppFonts.heading(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _themes.length,
                            itemBuilder: (context, index) {
                              final thm = _themes[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                                  border: Border.all(
                                    color: line,
                                    width: GenZTokens.borderWidthThin,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    thm,
                                    style: AppFonts.body(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Feature check rows list
                        _buildFeatureRow(
                          tr('premium.feat_identity_title'),
                          tr('premium.feat_identity_desc'),
                          PhosphorIcons.sparkle(),
                          accent,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          tr('premium.feat_spots_title'),
                          tr('premium.feat_spots_desc'),
                          PhosphorIcons.mapPin(),
                          accent,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          tr('premium.feat_reactions_title'),
                          tr('premium.feat_reactions_desc'),
                          PhosphorIcons.smiley(),
                          accent,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          tr('premium.feat_storage_title'),
                          tr('premium.feat_storage_desc'),
                          PhosphorIcons.cloudArrowUp(),
                          accent,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),

                        const SizedBox(height: 28),

                        // Join button (single accent CTA)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SubscriptionCheckoutScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                              boxShadow: isDark
                                  ? const []
                                  : [
                                      BoxShadow(
                                        color: GenZTokens.ink.withValues(alpha: 0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    tr('premium.join_elite'),
                                    style: AppFonts.heading(
                                      color: onAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    PhosphorIcons.arrowRight(),
                                    color: onAccent,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Secondary Options list
                        Text(
                          tr('premium.services_settings'),
                          style: AppFonts.heading(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildSettingTile(
                          tr('premium.sub_settings_title'),
                          tr('premium.sub_settings_desc'),
                          PhosphorIcons.gear(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SubscriptionSettingsScreen(),
                              ),
                            );
                          },
                          cardBg,
                          line,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),

                        _buildSettingTile(
                          tr('premium.invoices_title'),
                          tr('premium.invoices_desc'),
                          PhosphorIcons.receipt(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BillingHistoryScreen(),
                              ),
                            );
                          },
                          cardBg,
                          line,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),

                        _buildSettingTile(
                          tr('premium.referral_rewards_title'),
                          tr('premium.referral_rewards_desc'),
                          PhosphorIcons.gift(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ReferralRewardsScreen(),
                              ),
                            );
                          },
                          cardBg,
                          line,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),

                        _buildSettingTile(
                          tr('premium.referral_campaign_title'),
                          tr('premium.referral_campaign_desc'),
                          PhosphorIcons.usersThree(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReferralCampaignScreen(
                                  isDarkMode: _isDarkMode,
                                  onThemeToggle: () {},
                                ),
                              ),
                            );
                          },
                          cardBg,
                          line,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),

                        _buildSettingTile(
                          tr('premium.creator_shop_title'),
                          tr('premium.creator_shop_desc'),
                          PhosphorIcons.paintBrush(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreatorRevenueDashboardScreen(),
                              ),
                            );
                          },
                          cardBg,
                          line,
                          fill,
                          textPrimary,
                          textSecondary,
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color iconBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.body(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String desc,
    IconData icon,
    VoidCallback onTap,
    Color cardBg,
    Color line,
    Color fill,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          ),
          child: Icon(icon, size: 18, color: textPrimary),
        ),
        title: Text(
          title,
          style: AppFonts.heading(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        subtitle: Text(
          desc,
          style: AppFonts.body(fontSize: 12, color: textSecondary),
        ),
        trailing: Icon(
          PhosphorIcons.caretRight(),
          size: 16,
          color: textSecondary,
        ),
      ),
    );
  }
}
