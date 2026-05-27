import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'pages/badge_collection_screen.dart';
import 'pages/edit_profile_screen.dart';
import 'pages/friends_list_screen.dart';
import 'pages/profile_statistics_screen.dart';
import 'pages/public_profile_screen.dart';
import 'pages/shared_trips_history_screen.dart';
import 'pages/social_links_manager_screen.dart';
import 'pages/squad_reputation_screen.dart';
import 'pages/sticker_store_screen.dart';
import 'pages/theme_marketplace_screen.dart';
import '../../core/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool? isDarkMode;
  final VoidCallback? onThemeToggle;

  const ProfileScreen({
    super.key,
    this.isDarkMode,
    this.onThemeToggle,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
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
    
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final profile = await ApiService.get('/users/me');
      final stats = await ApiService.get('/users/me/stats');
      final badges = await ApiService.get('/users/me/badges');
      
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _userStats = stats;
          if (badges is List) {
            _userBadges = badges;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      // Fallback grace if API service errors out
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? surfaceColor.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: child,
        ),
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
    required String reputation,
  }) {
    final int fillFlex = (xp / 100).clamp(1, 100).toInt();
    final int emptyFlex = 100 - fillFlex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x332D3449) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
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
                  Icon(Icons.military_tech, color: tertiaryColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Lvl $level',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tertiaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Global Nomad',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textSecondaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                '${xp.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} / 10,000 XP',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Custom Glowing Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF060E20) : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: fillFlex,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [secondaryColor, secondaryColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: secondaryColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                              )
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
                MaterialPageRoute(builder: (context) => const SquadReputationScreen()),
              );
            },
            child: Row(
              children: [
                Icon(Icons.group, color: primaryColor, size: 16),
                const SizedBox(width: 6),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor),
                    children: [
                      const TextSpan(text: 'Squad Rep: '),
                      TextSpan(
                        text: reputation,
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
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

  Widget _buildActiveBadgeChip(String label, Color accent, bool isDark, Color surface) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? surface.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? accent : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label, bool isDark, Color textPrimaryColor, Color primaryColor) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: primaryColor,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.transparent
              : (isRare
                  ? const Color(0x44FFB783).withValues(alpha: 0.1)
                  : const Color(0xFF171F33).withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? Colors.white24
                : (isRare ? const Color(0xFFFFDCC5).withValues(alpha: 0.4) : Colors.white12),
            style: isLocked ? BorderStyle.none : BorderStyle.solid,
            width: 1.5,
          ),
          boxShadow: isRare
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB783).withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLocked
                ? const Icon(Icons.lock, color: Colors.white30, size: 30)
                : Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.white30 : const Color(0xFFFFB783),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tier,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isLocked ? Colors.white24 : Colors.white54,
              ),
            ),
          ],
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
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
                child: CachedNetworkImage(
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
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? surfaceColor.withValues(alpha: 0.8) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0B1326) : Colors.black.withValues(alpha: 0.03),
                  border: Border.all(color: accentColor, width: 1.5),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                          )
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
                        style: GoogleFonts.inter(fontSize: 13.5, color: textPrimaryColor, height: 1.4),
                        children: [
                          const TextSpan(text: 'Booked a chaotic weekend trip to '),
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
                      style: GoogleFonts.inter(
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
                          MaterialPageRoute(builder: (context) => const FriendsListScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32.0 * friendAvatars.length - 12.0 * (friendAvatars.length - 1),
                            child: Stack(
                              children: List.generate(friendAvatars.length, (idx) {
                                return Positioned(
                                  left: idx * 20.0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF171F33), width: 2.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: CachedNetworkImage(
                                        imageUrl: friendAvatars[idx],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.black.withValues(alpha: 0.1),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.person, size: 16),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B1326) : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF45DFA4).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '+$extraFriends',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF45DFA4)),
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? surfaceColor.withValues(alpha: 0.8) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0B1326) : Colors.black.withValues(alpha: 0.03),
                  border: Border.all(color: accentColor, width: 2.0),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                          )
                        ]
                      : null,
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 13.5, color: textPrimaryColor, height: 1.4),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode ?? (theme.brightness == Brightness.dark);

    // standard design tokens
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final tertiaryColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFEBA83A);
    final backgroundColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;
    final textPrimaryColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);

    // dynamic variables
    final name = _userProfile?['name'] ?? 'Minh Nhật';
    final username = _userProfile?['username'] ?? 'mnhat_travels';
    final level = _userProfile?['travelScore'] != null ? (_userProfile!['travelScore'] ~/ 500) + 1 : 24;
    final xp = _userProfile?['travelScore'] != null ? _userProfile!['travelScore'] % 500 : 8420;
    
    final avatarUrl = _userProfile?['avatarUrl'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuDLEui7EjvkHqpOtxT75qvmlSCJ9wccTxZHFnkqbQ7m--E6HGrhKnsJtrL2GDihf2FhhrrhdSQNucxZbDJAO6aLatXSt85bB-l6x9IM5ATjoFNpWUBr8XexKHp-UAg1uq87dPwg4PWZ5YNCMSEEHcd0e_x7apUYsHB94fhhpnv3cua0_DqPuc2VvBOglqhzvDWgph7OzMrHd71mBP4_IYyAJES--uo8nLNq161e_1nhMmkf9ZNHQheEn4QZJGsbcFzUQrlWbUYmDTLA';
    final bio = _userProfile?['bio'] ?? 'Planning Seoul';
    
    final totalTrips = _userStats?['totalTrips']?.toString() ?? '24';
    final totalDistance = _userStats?['totalDistanceKm'] != null 
        ? '${(_userStats!['totalDistanceKm'] as num).toInt()} km' 
        : '8.4k';
    final reputationScore = _userStats?['squadReputationScore'] != null
        ? (_userStats!['squadReputationScore'] >= 90 ? 'Legendary' : 'Reliable')
        : 'Legendary';
    final countriesCount = _userStats?['chaosScore']?.toString() ?? '15';

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
                imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDfg2dp9ry6aHIrv4JHeegtgAeoKxtfPqfps3NrOjR23AqjuVwWWroH0bqiv280TXdhXdJ6kB0LvDLTXAHaaimh1S7KlUIhGd0KH64hjwwX15BOvanpGufgafC7FB3a5RqoRobYB_cO3EHjkZO2dKGhAbC-RiERcZrxNnY2T63yYzxFfttbVN2AoteXwtO-Ul1cg-NF51y5Dry-f1CDCxMUxXaf-iHp1Zzr49wnjlQV7lJug_glX_gJU8UFFwEFT4sSARQ-TscJrRdB',
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(),
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            ),
          ),

          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
              ),
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
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: CachedNetworkImage(
                                imageUrl: avatarUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.black.withValues(alpha: 0.1)),
                                errorWidget: (context, url, error) => const Icon(Icons.person),
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [primaryColor, secondaryColor],
                              ).createShader(bounds);
                            },
                            child: Text(
                              'trip.mate',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                fontSize: 26,
                                letterSpacing: -1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              final newLocale = context.locale.languageCode == 'vi'
                                  ? const Locale('en')
                                  : const Locale('vi');
                              context.setLocale(newLocale);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark 
                                    ? Colors.white.withValues(alpha: 0.08) 
                                    : Colors.black.withValues(alpha: 0.05),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  context.locale.languageCode == 'vi' ? 'EN' : 'VI',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.onThemeToggle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: IconButton(
                              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: primaryColor),
                              onPressed: widget.onThemeToggle,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 12.0),
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.palette_outlined, color: primaryColor, size: 26),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ThemeMarketplaceScreen()),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, top: 12.0),
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.add_reaction_outlined, color: primaryColor, size: 26),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const StickerStoreScreen()),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Main Canvas body list
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                                    padding: const EdgeInsets.only(top: 72.0, left: 16, right: 16, bottom: 24),
                                    child: Column(
                                      children: [
                                        // User name glow text
                                        Text(
                                          name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimaryColor,
                                            shadows: isDark
                                                ? [
                                                    Shadow(
                                                      color: Colors.white.withValues(alpha: 0.3),
                                                      blurRadius: 10,
                                                    )
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const SocialLinksManagerScreen()),
                                                );
                                              },
                                              child: Icon(
                                                Icons.link,
                                                color: primaryColor.withValues(alpha: 0.6),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '@$username',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        // Level progression box
                                        _buildLevelBox(
                                          context: context,
                                          isDark: isDark,
                                          primaryColor: primaryColor,
                                          secondaryColor: secondaryColor,
                                          tertiaryColor: tertiaryColor,
                                          textPrimaryColor: textPrimaryColor,
                                          textSecondaryColor: textSecondaryColor,
                                          level: level,
                                          xp: xp,
                                          reputation: reputationScore,
                                        ),
                                        const SizedBox(height: 20),

                                        // Badges row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _buildActiveBadgeChip('Chaos Planner 🔥', const Color(0xFFFF9E80), isDark, surfaceColor),
                                            const SizedBox(width: 12),
                                            _buildActiveBadgeChip('MVP Payer 💸', secondaryColor, isDark, surfaceColor),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        const Divider(color: Colors.white12, height: 1),
                                        const SizedBox(height: 20),

                                        // Core Stats Row
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const ProfileStatisticsScreen()),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildStatItem(totalTrips, 'Trips', isDark, textPrimaryColor, primaryColor),
                                              _buildStatItem(totalDistance, 'Distance', isDark, textPrimaryColor, primaryColor),
                                              _buildStatItem(countriesCount, 'Countries', isDark, textPrimaryColor, primaryColor),
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
                                              builder: (context) => PublicProfileScreen(
                                                userName: name,
                                                avatarUrl: avatarUrl,
                                              ),
                                            ),
                                          );
                                        },
                                        child: AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            final glowVal = 20.0 + (_pulseController.value * 20.0);
                                            return Container(
                                              width: 128,
                                              height: 128,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: backgroundColor, width: 4.0),
                                                boxShadow: isDark
                                                    ? [
                                                        BoxShadow(
                                                          color: primaryColor.withValues(alpha: 0.5),
                                                          blurRadius: glowVal,
                                                          spreadRadius: 2,
                                                        )
                                                      ]
                                                    : [
                                                        BoxShadow(
                                                          color: primaryColor.withValues(alpha: 0.15),
                                                          blurRadius: 10,
                                                          spreadRadius: 1,
                                                        )
                                                      ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(99),
                                                child: CachedNetworkImage(
                                                  imageUrl: avatarUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Container(color: Colors.black.withValues(alpha: 0.1)),
                                                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 40),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // Status Planning Seoul Capsule
                                      Positioned(
                                        bottom: -8,
                                        left: -20,
                                        right: -20,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF0B1326) : Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: isDark ? Colors.white24 : Colors.black12, 
                                                  width: 1.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.2),
                                                  blurRadius: 10,
                                                )
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('✈️', style: TextStyle(fontSize: 12)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  bio,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: textPrimaryColor,
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
                                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF171F33).withValues(alpha: 0.6) : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Icon(Icons.edit, color: primaryColor, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),

                          // Achievements Showcase Section
                          Row(
                            children: [
                              Icon(Icons.workspace_premium, color: tertiaryColor, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'profile.achievements'.tr(),
                                style: GoogleFonts.plusJakartaSans(
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
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeCollectionScreen())),
                                        primaryColor: primaryColor,
                                      ),
                                      _buildBadgeCard(
                                        emoji: '📸',
                                        title: 'Pro Paparazzi',
                                        tier: 'Silver Tier',
                                        isRare: false,
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeCollectionScreen())),
                                        primaryColor: primaryColor,
                                      ),
                                      _buildBadgeCard(
                                        emoji: '🍜',
                                        title: 'Street Food Legend',
                                        tier: 'Rare Tier',
                                        isRare: true,
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeCollectionScreen())),
                                        primaryColor: primaryColor,
                                      ),
                                      _buildBadgeCard(
                                        emoji: '🔒',
                                        title: 'Locked Badge',
                                        tier: 'Locked',
                                        isRare: false,
                                        isLocked: true,
                                        onTap: () {},
                                        primaryColor: primaryColor,
                                      ),
                                    ]
                                  : _userBadges.map<Widget>((badge) {
                                      final isLocked = badge['unlockedAt'] == null;
                                      final title = badge['title'] ?? 'Danh hiệu';
                                      
                                      String emoji = '🏆';
                                      String cleanTitle = title;
                                      
                                      final RegExp emojiRegExp = RegExp(r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]', unicode: true);
                                      final match = emojiRegExp.firstMatch(title);
                                      if (match != null) {
                                        emoji = match.group(0) ?? '🏆';
                                        cleanTitle = title.replaceAll(emoji, '').trim();
                                      }
                                      
                                      return _buildBadgeCard(
                                        emoji: emoji,
                                        title: cleanTitle,
                                        tier: isLocked ? 'Locked' : (badge['id'] == 'b1' ? 'Gold Tier' : 'Silver Tier'),
                                        isRare: badge['id'] == 'b1' || badge['id'] == 'b3',
                                        isLocked: isLocked,
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeCollectionScreen()));
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
                                  Icon(Icons.auto_awesome, color: primaryColor, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'profile.memories'.tr(),
                                    style: GoogleFonts.plusJakartaSans(
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
                                    MaterialPageRoute(builder: (context) => const SharedTripsHistoryScreen()),
                                  );
                                },
                                child: Text(
                                  'profile.view_gallery'.tr(),
                                  style: GoogleFonts.inter(
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

                          // Row showing two beautiful tilted polaroids
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Transform.rotate(
                                  angle: -0.04, // -2 degrees
                                  child: _buildPolaroidCard(
                                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD3GMXqvkv7uLzBEwA053VHefaRGTOBFv9pTiz4bGlwT3SitTC9LRaYcpcJyK9XvjTKlEwUO-HvGCy2RDEf8M6dn73NUnHiLBwHGLxd4UbzSIEYhZdeh_fpkxVnYibFtDcEsR3wv0XBn28SgESBBx4kMdBaxUpfQ8L9xvwOEvavloSBYj-cDYHYkHe9VeWkXgwWFNAqhRfYL42Z5Kg-btcNzHP-Th7tZinynYg64EpjYgPKaPNKWXrfexUy8vkEAtLTm5_zGCTYzd3L',
                                    caption: 'BKK Night out 🇹🇭',
                                    onTap: () {},
                                    surfaceColor: surfaceColor,
                                    textPrimary: textPrimaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Transform.rotate(
                                  angle: 0.05, // 3 degrees
                                  child: _buildPolaroidCard(
                                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAZqibfx7smwKzO4mXEfKGVEiX_kK0-wy5TgllNKWMgkxqqjeLrzctDOKWIW3k8iEM85WecgzRsWFOuIoU9vrPjTPJ7vf3zDZjT64e-dtMNGzl8CLi2mCtGn5ApWuYstm9__T6C8P4mq7HLfZ1OXH-MNKYlrtoIzWyDs_oTUcK6uLUHRXLFYaKNfz7Xe0Sl-rVBDhNScWn9i5usx4yH8CAQbpd66Etuz7AeEkKa4awoEEQNZh8wScKz1d3Cd-H8ZefRd-DDLlsyreO-',
                                    caption: 'Seoul Searching 🇰🇷',
                                    onTap: () {},
                                    surfaceColor: surfaceColor,
                                    textPrimary: textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),

                          // Recent Activity Quest Log (Recent Chaos Log)
                          Row(
                            children: [
                              Icon(Icons.history, color: secondaryColor, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'profile.recent_log'.tr(),
                                style: GoogleFonts.plusJakartaSans(
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
                            description: 'Booked a chaotic weekend trip to Taipei with 4 others.',
                            time: '2 hours ago',
                            isDark: isDark,
                            primaryColor: primaryColor,
                            textPrimaryColor: textPrimaryColor,
                            friendAvatars: const [
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuA1y6WvPiLYsHKlTRB6MQXUdfofDAc6F6zA_OUoxVJ44xDMfI-glkYPZlhkMe2pxgJGVzJNChT9ruLNSBIKZ1NmCuetbHgdFy8sWorqus-9PkpGJ5BYvl3O-EVPgkLrcPFiJ7Hg9oceWMywnHH2uxQIAYIhQn4jDPWvWZkrFHEZHk_sGAKdq0Jh_yzObuSjDut4SF7nrJ954zT44Qu_b9IKZ3XeeSTrUNwNvlYgjg4CKACygqOdPERGR8T1emC-4a3PtkSegIqbYqzj',
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCjU3P9uI6vdJX8NmKFk1eCTAp1BznSiyFHQEsD4THJT-rmb9aYBo5zD7LuoTwnWk0SlnFaET0ARhhgcFuupzG3C24xoArHCnc_-VKF-KE7Z5877UM99Qu5BICeXj3_elnHXeue7zM4_uDLNjYpeUGCs7P3QZKCfH5YaIv1zfBhHk4GyNX4J4vK9KShs9rvLp_q9dDM6bLfrhlwX7LGjEa2arXGi5pn3TRkajwn6bsUYTWUQ6ITLMQa3IWiZjKXJOCg2FZqzHMKLMlM'
                            ],
                            extraFriends: 2,
                            surfaceColor: surfaceColor,
                          ),
                          const SizedBox(height: 12),

                          _buildChaosSettlementCard(
                            icon: Icons.account_balance_wallet,
                            accentColor: secondaryColor,
                            description: 'Settled up \$420 for the Tokyo bender.',
                            isDark: isDark,
                            primaryColor: primaryColor,
                            textPrimaryColor: textPrimaryColor,
                            surfaceColor: surfaceColor,
                          ),

                          const SizedBox(height: 36),
                          Row(
                            children: [
                              Icon(Icons.settings_outlined, color: primaryColor, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'general.settings'.tr(),
                                style: GoogleFonts.plusJakartaSans(
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
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isDark ? surfaceColor.withValues(alpha: 0.8) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark ? const Color(0xFF0B1326) : Colors.black.withValues(alpha: 0.03),
                                        border: Border.all(color: primaryColor, width: 1.5),
                                      ),
                                      child: Icon(Icons.language_rounded, color: primaryColor, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'profile.lang_label'.tr(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'profile.lang_sub'.tr(),
                                            style: GoogleFonts.inter(
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
                                          isSelected: context.locale.languageCode == 'vi',
                                          onTap: () => context.setLocale(const Locale('vi')),
                                          isDark: isDark,
                                          primaryColor: primaryColor,
                                          surfaceColor: surfaceColor,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildLangOption(
                                          label: 'English',
                                          isSelected: context.locale.languageCode == 'en',
                                          onTap: () => context.setLocale(const Locale('en')),
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
          style: GoogleFonts.outfit(
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
