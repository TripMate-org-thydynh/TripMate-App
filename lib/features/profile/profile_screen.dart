import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';


import 'data/xp_repository.dart';
import '../moments/presentation/pages/memory_wall_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/gen_z_tokens.dart';
import '../../core/providers/auth_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileDataProvider);
    _userProfile = profileState.profile;
    _userStats = profileState.stats;
    _userBadges = profileState.badges;
    _isLoading = profileState.isLoading;

    final theme = Theme.of(context);
    final isDark = widget.isDarkMode ?? (theme.brightness == Brightness.dark);
    final currentMode = ref.watch(themeProvider);

    final primary = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textPri = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSec = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

    final name = (_userProfile?['name'] ?? 'Traveller') as String;
    final username = (_userProfile?['username'] ?? 'traveller') as String;
    final wallet = ref.watch(xpWalletProvider).valueOrNull;
    final level = wallet?.level ?? 1;
    final xp = wallet?.earned ?? 0;

    final rawAvatar = _userProfile?['avatarUrl'] as String?;
    // Không có avatar thật → avatar chữ-cái-đầu theo tên.
    final avatarUrl = (rawAvatar != null && rawAvatar.isNotEmpty)
        ? rawAvatar
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}'
              '&background=FFD84D&color=141210&bold=true&size=256';
    final bio = (_userProfile?['bio'] ?? 'profile.default_bio'.tr()) as String;

    // Số liệu THẬT (mặc định 0), không dùng số giả.
    final totalTrips = _userStats?['totalTrips']?.toString() ?? '0';
    final distanceKm = (_userStats?['totalDistanceKm'] as num?)?.toInt() ?? 0;
    final placesCount = (_userStats?['totalPlaces'] as num?)?.toInt() ?? 0;

    void push(Widget page) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.spaceMono(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPri,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppFonts.body(fontSize: 12, color: textSec)),
        ],
      ),
    );

    Widget tile({
      required IconData icon,
      required String title,
      String? trailingText,
      Widget? trailing,
      VoidCallback? onTap,
      Color? color,
    }) {
      return Semantics(
        button: onTap != null,
        label: title,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color ?? primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppFonts.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color ?? textPri,
                    ),
                  ),
                ),
                if (trailingText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      trailingText,
                      style: AppFonts.body(fontSize: 13, color: textSec),
                    ),
                  ),
                trailing ??
                    (onTap != null
                        ? Icon(
                            PhosphorIcons.caretRight(),
                            size: 16,
                            color: textSec,
                          )
                        : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      );
    }

    Widget group(String title, List<Widget> tiles) {
      final children = <Widget>[];
      for (var i = 0; i < tiles.length; i++) {
        if (i > 0) {
          children.add(
            Divider(height: 1, thickness: 1, indent: 50, color: line),
          );
        }
        children.add(tiles[i]);
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                title.toUpperCase(),
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textSec,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Column(children: children),
            ),
          ],
        ),
      );
    }

    final isVi = context.locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: () => ref
              .read(profileDataProvider.notifier)
              .loadProfile(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              if (Navigator.canPop(context))
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'common.back'.tr(),
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(PhosphorIcons.arrowLeft(), color: textPri),
                  ),
                ),
              // ── Đầu trang: avatar + tên + chỉ số ─────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: avatarUrl.startsWith('assets/')
                                ? Image.asset(avatarUrl, fit: BoxFit.cover)
                                : CachedNetworkImage(
                                    imageUrl: avatarUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => Icon(
                                      PhosphorIcons.user(),
                                      color: textSec,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.heading(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: textPri,
                                ),
                              ),
                              Text(
                                '@$username · Lv $level',
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: textSec,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'profile.edit_title'.tr(),
                          onPressed: () => push(const EditProfileScreen()),
                          icon: Icon(
                            PhosphorIcons.pencilSimple(),
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          bio,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            fontSize: 14,
                            color: textSec,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(height: 1, color: line),
                    const SizedBox(height: 14),
                    if (_isLoading && _userStats == null)
                      LinearProgressIndicator(color: primary, minHeight: 2)
                    else
                      Row(
                        children: [
                          stat(totalTrips, 'profile.stat_trips'.tr()),
                          stat('$distanceKm km', 'profile.stat_distance'.tr()),
                          stat('$placesCount', 'profile.stat_places'.tr()),
                          stat('$xp', 'XP'),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              group('profile.menu_account'.tr(), [
                tile(
                  icon: PhosphorIcons.userCircle(),
                  title: 'profile.edit_title'.tr(),
                  onTap: () => push(const EditProfileScreen()),
                ),
                tile(
                  icon: PhosphorIcons.eye(),
                  title: 'profile.view_public'.tr(),
                  onTap: () => push(
                    PublicProfileScreen(userName: name, avatarUrl: avatarUrl),
                  ),
                ),
                tile(
                  icon: PhosphorIcons.link(),
                  title: 'profile.social_title'.tr(),
                  onTap: () => push(const SocialLinksManagerScreen()),
                ),
                tile(
                  icon: PhosphorIcons.usersThree(),
                  title: 'profile.friends'.tr(),
                  onTap: () => push(const FriendsListScreen()),
                ),
              ]),

              group('profile.menu_journey'.tr(), [
                tile(
                  icon: PhosphorIcons.clockCounterClockwise(),
                  title: 'profile.trip_history_title'.tr(),
                  onTap: () => push(const SharedTripsHistoryScreen()),
                ),
                tile(
                  icon: PhosphorIcons.globeHemisphereEast(),
                  title: 'profile.travel_atlas_title'.tr(),
                  onTap: () => push(TravelAtlasScreen(isDarkMode: isDark)),
                ),
                tile(
                  icon: PhosphorIcons.chartBar(),
                  title: 'profile.stats_title'.tr(),
                  onTap: () => push(const ProfileStatisticsScreen()),
                ),
                tile(
                  icon: PhosphorIcons.images(),
                  title: 'profile.memories'.tr(),
                  onTap: () => push(MemoryWallScreen(isDarkMode: isDark)),
                ),
              ]),

              group('profile.menu_collection'.tr(), [
                tile(
                  icon: PhosphorIcons.medal(),
                  title: 'profile.achievements'.tr(),
                  trailingText: '${_userBadges.length}',
                  onTap: () => push(const BadgeCollectionScreen()),
                ),
                tile(
                  icon: PhosphorIcons.sticker(),
                  title: 'profile.stickers'.tr(),
                  onTap: () => push(StickerInventoryScreen(isDarkMode: isDark)),
                ),
                tile(
                  icon: PhosphorIcons.coins(),
                  title: 'profile.xp_wallet'.tr(),
                  trailingText: '$xp XP',
                  onTap: () => push(XpWalletScreen(isDarkMode: isDark)),
                ),
                tile(
                  icon: PhosphorIcons.trophy(),
                  title: 'profile.leaderboard'.tr(),
                  onTap: () => push(const SquadLeaderboardScreen()),
                ),
              ]),

              group('profile.menu_app'.tr(), [
                tile(
                  icon: PhosphorIcons.moon(),
                  title: 'profile.dark_mode'.tr(),
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: primary,
                    onChanged: (v) => ref
                        .read(themeProvider.notifier)
                        .setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                  ),
                ),
                tile(
                  icon: PhosphorIcons.translate(),
                  title: 'profile.language'.tr(),
                  trailingText: isVi ? 'Tiếng Việt' : 'English',
                  onTap: () => context.setLocale(
                    isVi ? const Locale('en') : const Locale('vi'),
                  ),
                ),
                tile(
                  icon: PhosphorIcons.shieldCheck(),
                  title: 'profile.privacy_and_account'.tr(),
                  onTap: () => push(AccountPrivacyScreen(isDarkMode: isDark)),
                ),
                tile(
                  icon: PhosphorIcons.cloudArrowDown(),
                  title: 'profile.backup_title'.tr(),
                  onTap: () => push(BackupRestoreScreen(isDarkMode: isDark)),
                ),
                tile(
                  icon: PhosphorIcons.plugs(),
                  title: 'system_phases.mcp_title'.tr(),
                  onTap: () => push(TripmateMcpScreen(isDarkMode: isDark)),
                ),
              ]),

              group('', [
                tile(
                  icon: PhosphorIcons.signOut(),
                  title: 'profile.logout'.tr(),
                  color: danger,
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: surface,
                        title: Text(
                          'profile.logout_title'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.bold,
                            color: textPri,
                          ),
                        ),
                        content: Text(
                          'profile.logout_confirm'.tr(),
                          style: AppFonts.body(color: textSec, height: 1.4),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('general.cancel'.tr()),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: danger,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('profile.logout'.tr()),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref.read(authProvider.notifier).logout();
                    }
                  },
                ),
              ]),
              // Giữ biến currentMode để rebuild khi đổi theme.
              if (currentMode == ThemeMode.system) const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
