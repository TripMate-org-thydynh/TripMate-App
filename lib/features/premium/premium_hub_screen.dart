// Chi lay `tr`: easy_localization re-export intl, va intl cung co
// TextDirection -> va cham voi dart:ui trong SlideGradientTransform.
import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/data/profile_provider.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'pages/subscription_checkout_screen.dart';
import 'pages/billing_history_screen.dart';
import 'pages/subscription_settings_screen.dart';
import 'pages/referral_rewards_screen.dart';
import 'pages/creator_revenue_dashboard_screen.dart';
import 'pages/referral_campaign_screen.dart';

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

    final primaryColor = isDark
        ? const Color(0xFFC9B8FF)
        : const Color(0xFFF5822B);
    // Accent theo theme dang chon: truoc day hai nhanh ternary y het nhau
    // va viet cung accent cua preset *grape*, nen doi theme khong an.
    final secondaryColor = Theme.of(context).colorScheme.primary;
    final tertiaryColor = isDark
        ? const Color(0xFFFFB783)
        : const Color(0xFFF5822B);

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    final textSecondary = isDark
        ? const Color(0xFFB8AE9C)
        : const Color(0xFF4A453E);
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
                          Icons.arrow_back_ios_new,
                          color: textPrimary,
                        ),
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
                                  'trip.mate',
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
                                Icons.workspace_premium,
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
                                      ? const Color(0xFF262019)
                                      : Colors.white,
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
                                      fontSize: 11,
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
                          '✨ Premium Identity',
                          'Stand out with glowing squad tags & gold border highlights.',
                          primaryColor,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          '🗺️ Hidden Travel Spots',
                          'Unlock exclusive geolocated pins & secret local viewpoints.',
                          secondaryColor,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          '💯 Exclusive Reactions',
                          'Express chaos with custom LIT, DEAD, and YASSS emojis.',
                          tertiaryColor,
                          textPrimary,
                          textSecondary,
                        ),
                        _buildFeatureRow(
                          '📦 Infinite High-Res Storage',
                          'Keep original raw frames and cinematic highlights forever.',
                          primaryColor,
                          textPrimary,
                          textSecondary,
                        ),

                        const SizedBox(height: 28),

                        // Shimmering dark metallic Payment/Join button
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
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xFF222222),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 0,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    blurRadius: 0,
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
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
                          'Subscription Settings ⚙',
                          'Manage payment methods & automatic renewals',
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
                          'Invoices History 🧾',
                          'Download PDF invoices of your payments history',
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
                          'Referral Rewards 🎁',
                          'Invite squad mates & receive free premium levels',
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
                          'Referral Campaign 🤝',
                          'Bring the squad & unlock lifetime Elite access',
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
                          'Creative Shop Revenue 🎨',
                          'Dashboard of your custom sticker packages sales',
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: glowColor.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.done, color: glowColor, size: 14),
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
                  style: AppFonts.body(fontSize: 11, color: textSecondary),
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
          style: AppFonts.body(fontSize: 10, color: textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
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
