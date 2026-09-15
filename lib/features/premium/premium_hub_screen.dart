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

class _PremiumHubScreenState extends State<PremiumHubScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

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
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;

    final primaryColor = isDark ? GenZTokens.lilac : GenZTokens.purple;
    final secondaryColor = isDark ? GenZTokens.yellow : GenZTokens.orange;
    final tertiaryColor = isDark ? GenZTokens.orange : GenZTokens.yellow;

    final bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final cardBg = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary =
        isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final glassBorder = textPrimary; // viền ink brutalist

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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    color: textPrimary,
                                  ),
                                ),
                                // Username THẬT của user.
                                //
                                // Trước đây in cứng '@adventure_seeker' nên ai
                                // mở màn Premium cũng thấy tên tài khoản của
                                // một người không tồn tại.
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
                                        fontWeight: FontWeight.bold,
                                        color: tertiaryColor,
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
                                color: tertiaryColor.withValues(alpha: 0.15),
                              ),
                              child: Icon(
                                PhosphorIcons.crown(),
                                color: tertiaryColor,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Text(
                          tr('premium.hero_sub'),
                          style: AppFonts.heading(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Cinematic themes section
                        Text(
                          tr('premium.cinematic_themes'),
                          style: AppFonts.heading(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
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
                              final isNeon = thm == 'Tokyo Neon';
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? GenZTokens.paperDark
                                      : GenZTokens.paper,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                    color: isNeon
                                        ? secondaryColor
                                        : glassBorder,
                                    width: isNeon ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isNeon
                                      ? [
                                          BoxShadow(
                                            color: secondaryColor.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    thm,
                                    style: AppFonts.heading(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isNeon
                                          ? secondaryColor
                                          : textPrimary,
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
                          primaryColor,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          tr('premium.feat_spots_title'),
                          tr('premium.feat_spots_desc'),
                          PhosphorIcons.mapPin(),
                          secondaryColor,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          tr('premium.feat_reactions_title'),
                          tr('premium.feat_reactions_desc'),
                          PhosphorIcons.smiley(),
                          tertiaryColor,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          tr('premium.feat_storage_title'),
                          tr('premium.feat_storage_desc'),
                          PhosphorIcons.cloudArrowUp(),
                          primaryColor,
                          textPrimary,
                          textSecondary,
                        ),

                        const SizedBox(height: 28),

                        // Shimmering payment/join button (GenZ style with yellow accent)
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.9),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                  stops: const [0.35, 0.5, 0.65],
                                  transform: SlideGradientTransform(
                                    percent: _shimmerController.value,
                                  ),
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: child,
                            );
                          },
                          child: GestureDetector(
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
                              height: 56,
                              decoration: BoxDecoration(
                                color: GenZTokens.yellow,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: textPrimary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: textPrimary,
                                    blurRadius: 0,
                                    offset: const Offset(0, 4),
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
                                        color: GenZTokens.ink,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      PhosphorIcons.arrowRight(),
                                      color: GenZTokens.ink,
                                      size: 20,
                                    ),
                                  ],
                                ),
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
                            fontWeight: FontWeight.bold,
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
                          glassBorder,
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
                          glassBorder,
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
                          glassBorder,
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
                          glassBorder,
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
                          glassBorder,
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
    Color glowColor,
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
              color: glowColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: glowColor, size: 16),
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
                    fontWeight: FontWeight.bold,
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
    Color glassBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder, width: 2),
        boxShadow: [BoxShadow(color: glassBorder, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: textPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: textPrimary),
        ),
        title: Text(
          title,
          style: AppFonts.heading(
            fontSize: 13,
            fontWeight: FontWeight.bold,
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

class SlideGradientTransform extends GradientTransform {
  final double percent;
  const SlideGradientTransform({required this.percent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double dx = bounds.width * (percent * 2.0 - 1.0);
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}
