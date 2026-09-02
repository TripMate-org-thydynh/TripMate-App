import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';

import 'data/xp_repository.dart';
import '../moments/data/moments_repository.dart';
import '../moments/presentation/pages/memory_wall_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_messenger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/gen_z_tokens.dart';
import 'data/profile_provider.dart';

import 'pages/badge_collection_screen.dart';
import 'pages/edit_profile_screen.dart';
import 'pages/friends_list_screen.dart';
import 'pages/profile_statistics_screen.dart';
import 'pages/public_profile_screen.dart';
import 'pages/shared_trips_history_screen.dart';
import 'pages/social_links_manager_screen.dart';
import '../gamification/pages/squad_leaderboard_screen.dart';
import 'pages/sticker_inventory_screen.dart';
import 'pages/xp_wallet_screen.dart';
import 'pages/theme_marketplace_screen.dart';
import 'pages/travel_atlas_screen.dart';
import 'pages/backup_restore_screen.dart';
import 'pages/tripmate_mcp_screen.dart';
import '../settings/presentation/account_privacy_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool? isDarkMode;
  final ValueChanged<Offset>? onThemeToggleWithPosition;

  const ProfileScreen({
    super.key,
    this.isDarkMode,
    this.onThemeToggleWithPosition,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  // Real-time backend databases loaded state
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _userStats;
  List<dynamic> _userBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Silently fetch fresh profile data in the background on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileDataProvider.notifier).loadProfile(forceRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildGlassCard({
    required Widget child,
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark ? const Color(0xFFFDF6D3) : const Color(0xFF141210),
            width: 2.5,
          ),
          // Hard shadow brutalist (đặc, không blur).
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : const Color(0xFF141210),
              blurRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildLevelBox({
    required BuildContext context,
    required bool isDark,
    required Color primaryColor,
    required Color secondaryColor,
    required Color tertiaryColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required int level,
    required int xp,
    required int xpPerLevel,
    required String reputation,
  }) {
    final int fillFlex = ((xp % xpPerLevel) / xpPerLevel * 100)
        .clamp(1, 100)
        .toInt();
    final int emptyFlex = 100 - fillFlex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x332D3449)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.military_tech, color: textPrimaryColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Lvl $level',
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'profile.nomad_tag'.tr(),
                    style: AppFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textSecondaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                '${xp % xpPerLevel} / $xpPerLevel XP',
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Custom Glowing Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF060E20)
                  : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: fillFlex,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.5),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
                Expanded(flex: emptyFlex, child: const SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Clickable Squad Reputation line
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Trỏ sang bảng xếp hạng THẬT. Màn "Squad Reputation" cũ là
                  // một báo cáo tính cách bịa hoàn toàn (MVP mang tên người
                  // không có trong nhóm, "Over-Caffeination Risk 85%"...) và
                  // không có nguồn dữ liệu nào ở backend.
                  builder: (context) => const SquadLeaderboardScreen(),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.group, color: primaryColor, size: 16),
                const SizedBox(width: 6),
                RichText(
                  text: TextSpan(
                    style: AppFonts.body(
                      fontSize: 12,
                      color: textSecondaryColor,
                    ),
                    children: [
                      const TextSpan(text: 'Squad Rep: '),
                      TextSpan(
                        text: reputation,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.verified, color: primaryColor, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadgeChip(
    String label,
    Color accent,
    bool isDark,
    Color surface,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? surface.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 0),
        ],
      ),
      child: Text(
        label,
        style: AppFonts.body(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? accent : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String val,
    String label,
    bool isDark,
    Color textPrimaryColor,
    Color primaryColor,
  ) {
    return Column(
      children: [
        Text(
          val,
          style: AppFonts.heading(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppFonts.body(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: textPrimaryColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required String emoji,
    required String title,
    required String tier,
    required bool isRare,
    bool isLocked = false,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    // Theme-aware để không bị chìm trên nền kem (trước đây chỉ hợp nền tối).
    final isDark = widget.isDarkMode ?? false;
    final ink = isDark ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
    final sub = isDark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ink, width: 2),
          // Hard shadow brutalist cho card đã mở khoá.
          boxShadow: isLocked
              ? null
              : [
                  BoxShadow(
                    color: ink,
                    blurRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Opacity(
          opacity: isLocked ? 0.55 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLocked
                  ? Icon(Icons.lock, color: sub, size: 30)
                  : Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tier,
                style: AppFonts.body(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolaroidCard({
    required String imageUrl,
    required String caption,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: imageUrl.startsWith('assets/')
                    ? Image.asset(imageUrl, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.black.withValues(alpha: 0.1),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: AppFonts.heading(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaosFeedCard({
    required IconData icon,
    required Color accentColor,
    required String description,
    required String time,
    required bool isDark,
    required Color primaryColor,
    required Color textPrimaryColor,
    required List<String> friendAvatars,
    required int extraFriends,
    required Color surfaceColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? surfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF1A1712)
                    : Colors.black.withValues(alpha: 0.03),
                border: Border.all(color: accentColor, width: 1.5),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppFonts.body(
                        fontSize: 13.5,
                        color: textPrimaryColor,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Booked a chaotic weekend trip to ',
                        ),
                        TextSpan(
                          text: 'Taipei',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const TextSpan(text: ' with 4 others.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time.toUpperCase(),
                    style: AppFonts.body(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: primaryColor.withValues(alpha: 0.6),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Overlapping Avatar Stack of Friends
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FriendsListScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 32,
                          width:
                              32.0 * friendAvatars.length -
                              12.0 * (friendAvatars.length - 1),
                          child: Stack(
                            children: List.generate(friendAvatars.length, (
                              idx,
                            ) {
                              return Positioned(
                                left: idx * 20.0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF262019),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child:
                                        friendAvatars[idx].startsWith('assets/')
                                        ? Image.asset(
                                            friendAvatars[idx],
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: friendAvatars[idx],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.person,
                                                      size: 16,
                                                    ),
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1712)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1FA85C),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '+$extraFriends',
                            style: AppFonts.body(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1FA85C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaosSettlementCard({
    required IconData icon,
    required Color accentColor,
    required String description,
    required bool isDark,
    required Color primaryColor,
    required Color textPrimaryColor,
    required Color surfaceColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? surfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF1A1712)
                    : Colors.black.withValues(alpha: 0.03),
                border: Border.all(color: accentColor, width: 2.0),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppFonts.body(
                    fontSize: 13.5,
                    color: textPrimaryColor,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Settled up '),
                    TextSpan(
                      text: '\$420',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const TextSpan(text: ' for the Tokyo bender.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileDataProvider);
    _userProfile = profileState.profile;
    _userStats = profileState.stats;
    _userBadges = profileState.badges;
    _isLoading = profileState.isLoading;

    final theme = Theme.of(context);
    final isDark = widget.isDarkMode ?? (theme.brightness == Brightness.dark);
    final currentAccent = ref.watch(accentProvider);
    final currentMode = ref.watch(themeProvider);

    // standard design tokens — driven by selected accent
    final primaryColor = currentAccent.accent;
    final secondaryColor = currentAccent.lightSoft;
    final tertiaryColor = currentAccent.accent;
    final backgroundColor = isDark
        ? const Color(0xFF1A1712)
        : currentAccent.lightBackground;
    final surfaceColor = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);
    final textPrimaryColor = isDark
        ? const Color(0xFFFFFDF5)
        : const Color(0xFF141210);
    final textSecondaryColor = isDark
        ? const Color(0xFFB8AE9C)
        : const Color(0xFF4A453E);

    // dynamic variables
    final name = _userProfile?['name'] ?? 'Traveller';
    final username = _userProfile?['username'] ?? 'traveller';
    // Cấp và XP lấy từ ví THẬT.
    //
    // Trước đây tính từ `travelScore` — một cột trong bảng users mà KHÔNG dòng
    // nào trong backend cộng vào, nên luôn hiện "Lvl 1 · 0 / 10,000 XP" dù
    // người dùng đã kiếm được bao nhiêu.
    final wallet = ref.watch(xpWalletProvider).valueOrNull;
    final level = wallet?.level ?? 1;
    final xp = wallet?.earned ?? 0;
    final xpPerLevel = wallet?.xpPerLevel ?? 500;

    final rawAvatar = _userProfile?['avatarUrl'] as String?;
    // Không có avatar thật → sinh avatar chữ-cái-đầu theo tên (màu brand),
    // mỗi user 1 avatar riêng thay vì cùng 1 ảnh stock giả.
    final avatarUrl = (rawAvatar != null && rawAvatar.isNotEmpty)
        ? rawAvatar
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}'
              '&background=FFD84D&color=141210&bold=true&size=256';
    final bio = _userProfile?['bio'] ?? 'Sẵn sàng lên đường ✈️';

    // Hiển thị số liệu THẬT (mặc định 0 khi backend chưa có), không dùng số giả.
    final totalTrips = _userStats?['totalTrips']?.toString() ?? '0';
    final totalDistance = _userStats?['totalDistanceKm'] != null
        ? '${(_userStats!['totalDistanceKm'] as num).toInt()} km'
        : '0 km';
    final repScore = _userStats?['squadReputationScore'] as num?;
    final reputationScore = repScore == null || repScore < 30
        ? 'New'
        : (repScore >= 90 ? 'Legendary' : 'Reliable');
    final countriesCount = _userStats?['chaosScore']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. Ambient Background Layer (Mesh Gradients)
          if (isDark) ...[
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, -0.6),
                  radius: 1.2,
                  colors: [
                    Color(0x3D8B5CF6), // Soft Stitch Purple mesh glow
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, 0.2),
                  radius: 1.5,
                  colors: [
                    Color(0x2834D399), // Soft Stitch Mint mesh glow
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, -0.6),
                  radius: 1.2,
                  colors: [
                    Color(0x1CE0533C), // Soft Stitch Coral glow
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, 0.2),
                  radius: 1.5,
                  colors: [
                    Color(0x0BEBA83A), // Soft Stitch Gold glow
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],

          // 2. Cinematic Karst Landscape Backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CachedNetworkImage(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDfg2dp9ry6aHIrv4JHeegtgAeoKxtfPqfps3NrOjR23AqjuVwWWroH0bqiv280TXdhXdJ6kB0LvDLTXAHaaimh1S7KlUIhGd0KH64hjwwX15BOvanpGufgafC7FB3a5RqoRobYB_cO3EHjkZO2dKGhAbC-RiERcZrxNnY2T63yYzxFfttbVN2AoteXwtO-Ul1cg-NF51y5Dry-f1CDCxMUxXaf-iHp1Zzr49wnjlQV7lJug_glX_gJU8UFFwEFT4sSARQ-TscJrRdB',
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(),
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            ),
          ),

          // Blur overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            ),
          ),

          // 3. Scrollable Content
          _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top Custom App Bar
                    SliverAppBar(
                      expandedHeight: 88.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: backgroundColor.withValues(alpha: 0.5),
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(color: Colors.transparent),
                      ),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                        child: Center(
                          // Nếu màn được push (có thể pop) → nút Back để quay lại;
                          // nếu là tab (không pop được) → avatar như cũ.
                          child: Navigator.canPop(context)
                              ? GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: surfaceColor,
                                      border: Border.all(
                                        color: textPrimaryColor,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      color: textPrimaryColor,
                                      size: 22,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: textPrimaryColor,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: CachedNetworkImage(
                                      imageUrl: avatarUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.person),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Center(
                          child: Text(
                            'trip.mate',
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                              letterSpacing: -1.5,
                              color: textPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              final newLocale =
                                  context.locale.languageCode == 'vi'
                                  ? const Locale('en')
                                  : const Locale('vi');
                              context.setLocale(newLocale);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: surfaceColor,
                                border: Border.all(
                                  color: textPrimaryColor,
                                  width: 2.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  context.locale.languageCode.toUpperCase(),
                                  style: AppFonts.body(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.onThemeToggleWithPosition != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: GestureDetector(
                              onTapDown: (details) {
                                widget.onThemeToggleWithPosition!(
                                  details.globalPosition,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  isDark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 12.0),
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.palette_outlined,
                                color: textPrimaryColor,
                                size: 26,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ThemeMarketplaceScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 16.0,
                            top: 12.0,
                          ),
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.add_reaction_outlined,
                                color: textPrimaryColor,
                                size: 26,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StickerInventoryScreen(
                                          isDarkMode: isDark,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Main Canvas body list
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 24),

                          // Gamer Profile Hero Section
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Glassmorphic main panel card
                              Padding(
                                padding: const EdgeInsets.only(top: 64.0),
                                child: _buildGlassCard(
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                  surfaceColor: surfaceColor,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 72.0,
                                      left: 16,
                                      right: 16,
                                      bottom: 24,
                                    ),
                                    child: Column(
                                      children: [
                                        // User name glow text
                                        Text(
                                          name,
                                          style: AppFonts.heading(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimaryColor,
                                            shadows: isDark
                                                ? [
                                                    Shadow(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      blurRadius: 0,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SocialLinksManagerScreen(),
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.link,
                                                color: primaryColor.withValues(
                                                  alpha: 0.6,
                                                ),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '@$username',
                                              style: AppFonts.body(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        // Chạm vào thanh cấp để mở ví XP
                                        // (số dư + sổ cái từng lần cộng/trừ).
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => XpWalletScreen(
                                                isDarkMode: isDark,
                                              ),
                                            ),
                                          ),
                                          child: _buildLevelBox(
                                            context: context,
                                            isDark: isDark,
                                            primaryColor: primaryColor,
                                            secondaryColor: secondaryColor,
                                            tertiaryColor: tertiaryColor,
                                            textPrimaryColor: textPrimaryColor,
                                            textSecondaryColor:
                                                textSecondaryColor,
                                            level: level,
                                            xp: xp,
                                            xpPerLevel: xpPerLevel,
                                            reputation: reputationScore,
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Badges row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildActiveBadgeChip(
                                              totalTrips == '0'
                                                  ? 'Tân binh ✨'
                                                  : 'Chaos Planner 🔥',
                                              const Color(0xFFFF9E80),
                                              isDark,
                                              surfaceColor,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildActiveBadgeChip(
                                              reputationScore == 'Legendary'
                                                  ? 'MVP Payer 💸'
                                                  : (reputationScore ==
                                                            'Reliable'
                                                        ? 'Đáng tin 🤝'
                                                        : 'Thành viên mới 🎒'),
                                              secondaryColor,
                                              isDark,
                                              surfaceColor,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        const Divider(
                                          color: Colors.white12,
                                          height: 1,
                                        ),
                                        const SizedBox(height: 20),

                                        // Travel Atlas Button
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TravelAtlasScreen(
                                                      isDarkMode: isDark,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: GenZTokens.yellow,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: GenZTokens.ink,
                                                width: 2,
                                              ),
                                              boxShadow: GenZTokens.hardShadow(
                                                GenZTokens.ink,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.explore_outlined,
                                                  color: GenZTokens.ink,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'profile.open_travel_atlas'
                                                      .tr(),
                                                  style: AppFonts.heading(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 12,
                                                    color: GenZTokens.ink,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Core Stats Row
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ProfileStatisticsScreen(),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildStatItem(
                                                totalTrips,
                                                'Trips',
                                                isDark,
                                                textPrimaryColor,
                                                primaryColor,
                                              ),
                                              _buildStatItem(
                                                totalDistance,
                                                'Distance',
                                                isDark,
                                                textPrimaryColor,
                                                primaryColor,
                                              ),
                                              _buildStatItem(
                                                countriesCount,
                                                'Countries',
                                                isDark,
                                                textPrimaryColor,
                                                primaryColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Floating Avatar situated overlapping top edge
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Glowing avatar container
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PublicProfileScreen(
                                                    userName: name,
                                                    avatarUrl: avatarUrl,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            final glowVal =
                                                20.0 +
                                                (_pulseController.value * 20.0);
                                            return Container(
                                              width: 128,
                                              height: 128,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: backgroundColor,
                                                  width: 4.0,
                                                ),
                                                boxShadow: isDark
                                                    ? [
                                                        BoxShadow(
                                                          color: primaryColor
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                          blurRadius: glowVal,
                                                          spreadRadius: 2,
                                                        ),
                                                      ]
                                                    : [
                                                        BoxShadow(
                                                          color: primaryColor
                                                              .withValues(
                                                                alpha: 0.15,
                                                              ),
                                                          blurRadius: 0,
                                                          spreadRadius: 1,
                                                        ),
                                                      ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(99),
                                                child: CachedNetworkImage(
                                                  imageUrl: avatarUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                            Icons.person,
                                                            size: 40,
                                                          ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // Status Planning Seoul Capsule
                                      Positioned(
                                        bottom: -8,
                                        left: -100,
                                        right: -100,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1A1712)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.white24
                                                    : Colors.black12,
                                                width: 1.0,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  '✈️',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    bio,
                                                    style: AppFonts.body(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textPrimaryColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Edit Button on Top Right (Mobile-friendly layout)
                              Positioned(
                                top: 80,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(
                                              0xFF262019,
                                            ).withValues(alpha: 0.6)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: primaryColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),

                          // Achievements Showcase Section
                          Row(
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                color: tertiaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'profile.achievements'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Horizontal Scrolling Achievement Badges list
                          SizedBox(
                            height: 116,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: _userBadges.isEmpty
                                  ? [
                                      _buildBadgeCard(
                                        emoji: '🔥',
                                        title: 'Chaos King',
                                        tier: 'Gold Tier',
                                        isRare: true,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BadgeCollectionScreen(),
                                          ),
                                        ),
                                        primaryColor: primaryColor,
                                      ),
                                      _buildBadgeCard(
                                        emoji: '📸',
                                        title: 'Pro Paparazzi',
                                        tier: 'Silver Tier',
                                        isRare: false,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BadgeCollectionScreen(),
                                          ),
                                        ),
                                        primaryColor: primaryColor,
                                      ),
                                      _buildBadgeCard(
                                        emoji: '🍜',
                                        title: 'Street Food Legend',
                                        tier: 'Rare Tier',
                                        isRare: true,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BadgeCollectionScreen(),
                                          ),
                                        ),
                                        primaryColor: primaryColor,
                                      ),
                                      _buildBadgeCard(
                                        emoji: '🔒',
                                        title: 'Locked Badge',
                                        tier: 'Locked',
                                        isRare: false,
                                        isLocked: true,
                                        onTap: () => showGlobalSnack(
                                          'Tính năng đang được hoàn thiện 🚧',
                                        ),
                                        primaryColor: primaryColor,
                                      ),
                                    ]
                                  : _userBadges.map<Widget>((badge) {
                                      final isLocked =
                                          badge['unlockedAt'] == null;
                                      final title =
                                          badge['title'] ?? 'Danh hiệu';

                                      String emoji = '🏆';
                                      String cleanTitle = title;

                                      final RegExp emojiRegExp = RegExp(
                                        r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]',
                                        unicode: true,
                                      );
                                      final match = emojiRegExp.firstMatch(
                                        title,
                                      );
                                      if (match != null) {
                                        emoji = match.group(0) ?? '🏆';
                                        cleanTitle = title
                                            .replaceAll(emoji, '')
                                            .trim();
                                      }

                                      return _buildBadgeCard(
                                        emoji: emoji,
                                        title: cleanTitle,
                                        tier: isLocked
                                            ? 'Locked'
                                            : (badge['id'] == 'b1'
                                                  ? 'Gold Tier'
                                                  : 'Silver Tier'),
                                        isRare:
                                            badge['id'] == 'b1' ||
                                            badge['id'] == 'b3',
                                        isLocked: isLocked,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const BadgeCollectionScreen(),
                                            ),
                                          );
                                        },
                                        primaryColor: primaryColor,
                                      );
                                    }).toList(),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Chaotic Memories (Tilted Polaroid Grid)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'profile.memories'.tr(),
                                    style: AppFonts.heading(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SharedTripsHistoryScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'profile.view_gallery'.tr(),
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Kỷ niệm THẬT của user.
                          //
                          // Trước đây đây là 2 tấm polaroid cứng ("BKK Night
                          // out 🇹🇭", "Seoul Searching 🇰🇷") kèm ảnh asset —
                          // ai mở profile cũng thấy mình từng đi Bangkok và
                          // Seoul — và chạm vào chỉ hiện "đang hoàn thiện".
                          Consumer(
                            builder: (context, ref, _) {
                              final moments = ref
                                  .watch(recentMomentsProvider)
                                  .maybeWhen(
                                    data: (m) => m.take(2).toList(),
                                    orElse: () => const <RecentMoment>[],
                                  );
                              if (moments.isEmpty) {
                                return Text(
                                  'profile.memories_empty'.tr(),
                                  style: AppFonts.body(
                                    fontSize: 13,
                                    color: textSecondaryColor,
                                  ),
                                );
                              }
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  for (var i = 0; i < moments.length; i++) ...[
                                    if (i > 0) const SizedBox(width: 16),
                                    Expanded(
                                      child: Transform.rotate(
                                        angle: i.isEven ? -0.04 : 0.05,
                                        child: _buildPolaroidCard(
                                          imageUrl: moments[i].mediaUrl,
                                          caption: moments[i].title,
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MemoryWallScreen(
                                                isDarkMode: isDark,
                                                onThemeToggle: () {},
                                              ),
                                            ),
                                          ),
                                          surfaceColor: surfaceColor,
                                          textPrimary: textPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 36),

                          // Recent Activity Quest Log (Recent Chaos Log)
                          Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: secondaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'profile.recent_log'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Chaos feeds
                          _buildChaosFeedCard(
                            icon: Icons.flight_takeoff,
                            accentColor: primaryColor,
                            description:
                                'Booked a chaotic weekend trip to Taipei with 4 others.',
                            time: '2 hours ago',
                            isDark: isDark,
                            primaryColor: primaryColor,
                            textPrimaryColor: textPrimaryColor,
                            friendAvatars: const [
                              'assets/images/avatar_minh_nhat.webp',
                              'assets/images/avatar_thao_ly.webp',
                            ],
                            extraFriends: 2,
                            surfaceColor: surfaceColor,
                          ),
                          const SizedBox(height: 12),

                          _buildChaosSettlementCard(
                            icon: Icons.account_balance_wallet,
                            accentColor: secondaryColor,
                            description:
                                'Settled up \$420 for the Tokyo bender.',
                            isDark: isDark,
                            primaryColor: primaryColor,
                            textPrimaryColor: textPrimaryColor,
                            surfaceColor: surfaceColor,
                          ),

                          const SizedBox(height: 36),

                          // ── Giao diện app ─────────────────────────────────
                          _buildThemePicker(
                            isDark: isDark,
                            primaryColor: primaryColor,
                            surfaceColor: surfaceColor,
                            textPrimaryColor: textPrimaryColor,
                            textSecondaryColor: textSecondaryColor,
                            currentAccent: currentAccent,
                            currentMode: currentMode,
                          ),

                          const SizedBox(height: 36),
                          Row(
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                color: primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'general.settings'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isDark ? surfaceColor : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1A1712)
                                          : Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.language_rounded,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'profile.lang_label'.tr(),
                                          style: AppFonts.heading(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'profile.lang_sub'.tr(),
                                          style: AppFonts.body(
                                            fontSize: 11,
                                            color: textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Toggle option buttons
                                  Row(
                                    children: [
                                      _buildLangOption(
                                        label: 'Tiếng Việt',
                                        isSelected:
                                            context.locale.languageCode == 'vi',
                                        onTap: () => context.setLocale(
                                          const Locale('vi'),
                                        ),
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        surfaceColor: surfaceColor,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildLangOption(
                                        label: 'English',
                                        isSelected:
                                            context.locale.languageCode == 'en',
                                        onTap: () => context.setLocale(
                                          const Locale('en'),
                                        ),
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        surfaceColor: surfaceColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          // Quyền riêng tư & Tài khoản (PDPD)
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AccountPrivacyScreen(isDarkMode: isDark),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isDark ? surfaceColor : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1A1712)
                                          : Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.shield_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'profile.privacy_and_account'.tr(),
                                          style: AppFonts.heading(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'profile.privacy_sub'.tr(),
                                          style: AppFonts.body(
                                            fontSize: 11,
                                            color: textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: textSecondaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          // Sao lưu & Khôi phục Offline
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BackupRestoreScreen(isDarkMode: isDark),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isDark ? surfaceColor : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1A1712)
                                          : Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.backup_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'system_phases.backup_title'.tr(),
                                          style: AppFonts.heading(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'profile.backup_title'.tr(),
                                          style: AppFonts.body(
                                            fontSize: 11,
                                            color: textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: textSecondaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          // MCP AI Connection Setting
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TripmateMcpScreen(isDarkMode: isDark),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isDark ? surfaceColor : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1A1712)
                                          : Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.smart_toy_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'system_phases.mcp_title'.tr(),
                                          style: AppFonts.heading(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'profile.mcp_title'.tr(),
                                          style: AppFonts.body(
                                            fontSize: 11,
                                            color: textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: textSecondaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),
                        ]),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildThemePicker({
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required AppAccent currentAccent,
    required ThemeMode currentMode,
  }) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final currentFont = ref.watch(fontProvider);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          boxShadow: GenZTokens.hardShadow(ink),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF1A1712)
                        : Colors.black.withValues(alpha: 0.03),
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile.app_interface'.tr(),
                        style: AppFonts.heading(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'profile.theme_and_color'.tr(),
                        style: AppFonts.body(
                          fontSize: 11,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sáng / Tối toggle
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeBtn(
                        icon: Icons.light_mode_outlined,
                        label: 'profile.theme_light_short'.tr(),
                        selected: currentMode == ThemeMode.light,
                        primaryColor: primaryColor,
                        isDark: isDark,
                        textPrimaryColor: textPrimaryColor,
                        onTap: (position) {
                          if (currentMode != ThemeMode.light) {
                            if (widget.onThemeToggleWithPosition != null) {
                              widget.onThemeToggleWithPosition!(position);
                            } else {
                              ref
                                  .read(themeProvider.notifier)
                                  .setThemeMode(ThemeMode.light);
                            }
                          }
                        },
                      ),
                      _buildModeBtn(
                        icon: Icons.dark_mode_outlined,
                        label: 'profile.theme_dark_short'.tr(),
                        selected: currentMode == ThemeMode.dark,
                        primaryColor: primaryColor,
                        isDark: isDark,
                        textPrimaryColor: textPrimaryColor,
                        onTap: (position) {
                          if (currentMode != ThemeMode.dark) {
                            if (widget.onThemeToggleWithPosition != null) {
                              widget.onThemeToggleWithPosition!(position);
                            } else {
                              ref
                                  .read(themeProvider.notifier)
                                  .setThemeMode(ThemeMode.dark);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bảng màu: 4 accent miễn phí + 3 accent đổi bằng XP.
            //
            // Accent premium chưa mua thì KHÓA — bấm vào mở thẳng chợ thay vì
            // đổi màu, để không ai dùng được thứ chưa trả XP.
            Builder(
              builder: (context) {
                final ownedThemeIds = ref
                    .watch(themeStoreProvider)
                    .maybeWhen(
                      data: (items) =>
                          items.where((t) => t.owned).map((t) => t.id).toSet(),
                      orElse: () => <String>{},
                    );
                bool unlocked(AppAccent a) =>
                    !kPremiumAccents.contains(a) ||
                    ownedThemeIds.contains(kAccentThemeId[a]);

                return Row(
                  children: AppAccent.values.map((accent) {
                    final selected = accent == currentAccent;
                    final isUnlocked = unlocked(accent);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isUnlocked) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ThemeMarketplaceScreen(isDarkMode: isDark),
                              ),
                            );
                            return;
                          }
                          ref.read(accentProvider.notifier).setAccent(accent);
                        },
                        child: Column(
                          children: [
                            // Swatch cặp màu preset (accent trên, pair dưới),
                            // viền ink + hard shadow khi được chọn
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 44,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ink,
                                  width: selected
                                      ? GenZTokens.borderWidth
                                      : 1.5,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: ink,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: accent.accent,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(color: accent.pair),
                                        ),
                                      ],
                                    ),
                                    if (selected)
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: GenZTokens.paper,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: GenZTokens.ink,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            color: GenZTokens.ink,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              accent.label,
                              style: AppFonts.body(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? primaryColor
                                    : textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 16),
            Divider(color: ink, thickness: 1.5),
            const SizedBox(height: 16),

            Text(
              'profile.font_style'.tr(),
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),

            Column(
              children: AppFontOption.values.map((fontOpt) {
                final isSelected = fontOpt == currentFont;

                final textColor = isSelected
                    ? currentAccent.onAccent
                    : textPrimaryColor;
                final textSecColor = isSelected
                    ? currentAccent.onAccent.withValues(alpha: 0.7)
                    : textSecondaryColor;

                // Preview styles for each font option
                TextStyle previewHeading;
                TextStyle previewBody;

                switch (fontOpt) {
                  case AppFontOption.playful:
                    previewHeading = GoogleFonts.baloo2(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textColor,
                    );
                    previewBody = GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: textSecColor,
                    );
                    break;
                  case AppFontOption.curly:
                    previewHeading = GoogleFonts.grandstander(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textColor,
                    );
                    previewBody = GoogleFonts.comfortaa(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: textSecColor,
                    );
                    break;
                  case AppFontOption.handwriting:
                    previewHeading = GoogleFonts.sriracha(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textColor,
                    );
                    previewBody = GoogleFonts.patrickHand(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: textSecColor,
                    );
                    break;
                  case AppFontOption.modern:
                    previewHeading = GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textColor,
                    );
                    previewBody = GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: textSecColor,
                    );
                    break;
                  case AppFontOption.brutalist:
                    previewHeading = GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textColor,
                    );
                    previewBody = GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: textSecColor,
                    );
                    break;
                  case AppFontOption.clean:
                    previewHeading = GoogleFonts.quicksand(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textColor,
                    );
                    previewBody = GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: textSecColor,
                    );
                    break;
                }

                return GestureDetector(
                  onTap: () =>
                      ref.read(fontProvider.notifier).setFontOption(fontOpt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : ink.withValues(alpha: 0.2),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: ink,
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fontOpt.label, style: previewHeading),
                              const SizedBox(height: 2),
                              Text(fontOpt.description, style: previewBody),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ink,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: primaryColor,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeBtn({
    required IconData icon,
    required String label,
    required bool selected,
    required Color primaryColor,
    required bool isDark,
    required Color textPrimaryColor,
    required ValueChanged<Offset> onTap,
  }) {
    Offset tapPosition = Offset.zero;
    return GestureDetector(
      onTapDown: (details) {
        tapPosition = details.globalPosition;
      },
      onTap: () => onTap(tapPosition),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected
                  ? primaryColor
                  : textPrimaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? primaryColor
                    : textPrimaryColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white24 : Colors.black12),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: AppFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
