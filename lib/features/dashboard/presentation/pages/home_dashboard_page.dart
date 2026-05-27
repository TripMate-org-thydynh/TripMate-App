import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/theme.dart';

import '../widgets/social_chaos_marquee.dart';
import '../widgets/friend_presence_panel.dart';
import '../widgets/squad_mood_widget.dart';
import '../widgets/emergency_sos_widget.dart';
import '../widgets/daily_recap_widget.dart';
import '../widgets/quick_actions_panel.dart';
import '../../../discovery/presentation/pages/explore_discoveries_screen.dart';
import '../../../moments/presentation/pages/memory_wall_screen.dart';

class HomeDashboardPage extends StatelessWidget {
  final VoidCallback onNavigateToLiveMode;
  final VoidCallback onNavigateToActivityHub;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeDashboardPage({
    super.key,
    required this.onNavigateToLiveMode,
    required this.onNavigateToActivityHub,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  // ─── Color helpers ───────────────────────────────────────────────────────────

  Color get _primary =>
      isDarkMode ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;

  Color get _secondary =>
      isDarkMode ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;



  Color get _bg =>
      isDarkMode ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;

  Color get _textPrimary =>
      isDarkMode ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;

  Color get _textSecondary =>
      isDarkMode ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. HEADER ──
          _buildHeader(context),

          // ── 2. SOCIAL CHAOS MARQUEE ──
          const SocialChaosMarquee(),
          const SizedBox(height: 20),

          // ── 3. TRIP COVER CARD ──
          _buildTripCoverCard(context),
          const SizedBox(height: 24),

          // ── 4. QUICK ACTIONS 2×2 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: QuickActionsPanel(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
          const SizedBox(height: 24),

          // ── 5. SQUAD FRIEND PRESENCE ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FriendPresencePanel(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
          const SizedBox(height: 24),

          // ── 6. CINEMATIC WEATHER & UP NEXT GRID ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildWeatherAndUpNextGrid(context),
          ),
          const SizedBox(height: 24),

          // ── 7. THE ROAST PANEL ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildRoastPanel(context),
          ),
          const SizedBox(height: 24),

          // ── 7. SQUAD MOOD ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const SquadMoodWidget(),
          ),
          const SizedBox(height: 24),

          // ── 8. EMERGENCY SOS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const EmergencySosWidget(),
          ),
          const SizedBox(height: 24),

          // ── 9. DAILY RECAP ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const DailyRecapWidget(),
          ),
          const SizedBox(height: 24),

          // ── 10. SCRAPBOOK SECTION ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildScrapbookSection(context),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── WEATHER & UP NEXT ────────────────────────────────────────────────────

  Widget _buildWeatherAndUpNextGrid(BuildContext context) {
    final cardBg = isDarkMode ? const Color(0xFF1A2340) : Colors.white;
    final borderCol = isDarkMode
        ? _primary.withValues(alpha: 0.18)
        : _primary.withValues(alpha: 0.22);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Weather Card ──
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg.withValues(alpha: isDarkMode ? 0.45 : 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Da Lat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Icon(Icons.water_drop_outlined,
                            color: _primary, size: 28),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.psychology_outlined,
                            color: _primary, size: 12),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'rain detected. saving the vibe ☔',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: _primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _miniChip('🌂 Rain in 40 mins', _primary),
                    const SizedBox(height: 6),
                    _miniChip('🧥 perfect cafe weather', _secondary),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ── Up Next Card ──
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg.withValues(alpha: isDarkMode ? 0.45 : 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _secondary.withValues(alpha: 0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Up Next',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.08,
                            color: _secondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB4AB).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFFFB4AB)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '18 MINS',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFB4AB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Night Market Chaos',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: (isDarkMode
                                ? const Color(0xFF171F33)
                                : Colors.grey.shade100)
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_taxi_outlined,
                              color: _tertiary, size: 14),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Uber XL arriving soon',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB4AB),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB4AB)
                                    .withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Nam not ready 😭',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: const Color(0xFFFFB4AB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color get _tertiary =>
      isDarkMode ? const Color(0xFFFFB783) : const Color(0xFFD97722);

  // ─── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand name with gradient
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isDarkMode
                    ? [TripMateTheme.darkPrimary, TripMateTheme.darkSecondary]
                    : [TripMateTheme.lightPrimary, TripMateTheme.lightSecondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                'trip.mate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Squad avatar cluster (+2 overflow)
          _buildSquadCluster(),
          const SizedBox(width: 12),

          // Language toggle button – glass circle
          GestureDetector(
            onTap: () {
              final newLocale = context.locale.languageCode == 'vi'
                  ? const Locale('en')
                  : const Locale('vi');
              context.setLocale(newLocale);
            },
            child: _GlassCircleButton(
              isDarkMode: isDarkMode,
              child: Center(
                child: Text(
                  context.locale.languageCode == 'vi' ? 'EN' : 'VI',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Notification bell – glass circle
          GestureDetector(
            onTap: onNavigateToActivityHub,
            child: _GlassCircleButton(
              isDarkMode: isDarkMode,
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: _textPrimary,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? TripMateTheme.darkTertiary
                            : TripMateTheme.lightPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquadCluster() {
    final avatars = [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB60ii0WkYusRAogyP7WxQ6KtCLjpi-fZazA3b7Hw_63SE76TTaTSYBlGn5gz8shuvpPAQIiS1UiyYmdWSciccncnq4y_m76yf0y7FTRLIYWSFqV6rjgfiwk7yPJT1DP-0RIcQ92w1a_TJZ281zFnle8zoP2y4vSggh1V1sYoi_mp4oIvRRWKhZeqIQ3rx4KJ2qUyQyZPN_fPGpu7_5Uv7xWk9Msa1Q5oU5bN8eEMtm6hEIIOo4lp4ye_DjDeIhgchKeWqQODMJtOT3',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB244M5yGCCxo4CnE1QbSwnOgbUvLW0EYlAQHgrIJaM_f_Nu4zoOioIRa_1hxA549ndJTO19XGaIGmsMVvXB0qfI2kQ28fTEAlImfIqK-8BkfrCrvA2yNCnpVqf2-SXr9-knPAtaoF5QKwxyZNaeD4lf569BT6Q0m_UTmBtw1Guj-hcrK4fYFSKLtDslymGQQxRESbhDogyXt8YneAyg--MnXiqhJBPMkTnWhIvNgcEeaN34P8fdWHmc1QttIe7PZi7wg0fbzf29Wq-',
      'https://lh3.googleusercontent.com/aida-public/ADBb0ug71LcHZqevGgvQItUs3SyvwMN3xfSE1IVyp1j6KTWw5IJkFW5J79XpBMZVv0nXfPCbbN-VhyNK_CgQ5K3d_gVAOXSqJI5lFREzgSlT9yFpbr_nSzlV5N7MnhY6-u-xG_R5s_hCAvhQfmMajGRNBJw1I6HJcJWyZSibifRjsN7FdON-JkGS_E7h2Y07K-KVANpbLq9GJFvWz4C3AMEjvyGr3bX4_0nD4CqWXzF-cX_bJqmJyiUe7gNXXxw0rqQ',
    ];

    return SizedBox(
      width: 72,
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < 2; i++)
            Positioned(
              left: i * 20.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _bg,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: avatars[i],
                    fit: BoxFit.cover,
                    placeholder: (context2, url) => Container(
                      color: _bg,
                      child: const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                    ),
                    errorWidget: (context2, url, error) => Container(
                      color: _primary.withValues(alpha: 0.4),
                      child: Icon(Icons.person, size: 16, color: _textPrimary),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 40,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? TripMateTheme.darkSurfaceHigh
                    : const Color(0xFFE8E4DE),
                border: Border.all(color: _bg, width: 2),
              ),
              child: Center(
                child: Text(
                  '+2',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TRIP COVER CARD ─────────────────────────────────────────────────────────

  Widget _buildTripCoverCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExploreDiscoveriesScreen(
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                CachedNetworkImage(
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/ADBb0ug71LcHZqevGgvQItUs3SyvwMN3xfSE1IVyp1j6KTWw5IJkFW5J79XpBMZVv0nXfPCbbN-VhyNK_CgQ5K3d_gVAOXSqJI5lFREzgSlT9yFpbr_nSzlV5N7MnhY6-u-xG_R5s_hCAvhQfmMajGRNBJw1I6HJcJWyZSibifRjsN7FdON-JkGS_E7h2Y07K-KVANpbLq9GJFvWz4C3AMEjvyGr3bX4_0nD4CqWXzF-cX_bJqmJyiUe7gNXXxw0rqQ',
                  fit: BoxFit.cover,
                  placeholder: (context2, url) => Container(
                    color: isDarkMode ? const Color(0xFF171F33) : const Color(0xFFE8E4DE),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context2, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _primary.withValues(alpha: 0.8),
                          _secondary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Cinematic gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top-left pill badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '"6 idiots. 1 unforgettable trip."',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom content overlay
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status chips row
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.schedule_rounded,
                            label: '3 days left',
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.thermostat_rounded,
                            label: '22°C',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Trip title
                      Text(
                        'Đà Lạt Chill 🌲',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Avatar overlap "3 editing" indicator
                      _buildEditingIndicator(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditingIndicator() {
    return Row(
      children: [
        SizedBox(
          width: 68,
          height: 24,
          child: Stack(
            children: List.generate(3, (i) {
              final colors = [
                const Color(0xFF8B5CF6),
                const Color(0xFF34D399),
                const Color(0xFFFB923C),
              ];
              return Positioned(
                left: i * 18.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[i],
                    border: Border.all(color: Colors.black38, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      ['M', 'T', 'P'][i],
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '3 editing',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  // ─── QUICK ACTIONS 2×2 GRID ──────────────────────────────────────────────────

  // ─── ROAST PANEL ─────────────────────────────────────────────────────────────

  Widget _buildRoastPanel(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? TripMateTheme.darkSurface.withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: isDarkMode ? 0.12 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: title + Total badge
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: isDarkMode
                        ? TripMateTheme.darkTertiary
                        : TripMateTheme.lightPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'The Roast 🔥',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Total badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDarkMode
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFDC2626))
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: (isDarkMode
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFDC2626))
                            .withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Total: 500k',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Roast quote
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? TripMateTheme.darkSurfaceHigh.withValues(alpha: 0.6)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(
                      color: isDarkMode
                          ? TripMateTheme.darkTertiary
                          : TripMateTheme.lightPrimary,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  '"Phú Khang: main character energy nhưng chưa trả 420k 😭"',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Group Progress',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                  Text(
                    '80% Paid',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode
                          ? TripMateTheme.darkSecondary
                          : TripMateTheme.lightSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0.8,
                  minHeight: 8,
                  backgroundColor: isDarkMode
                      ? TripMateTheme.darkSurfaceHighest
                      : const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode
                        ? TripMateTheme.darkSecondary
                        : TripMateTheme.lightSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SCRAPBOOK SECTION ───────────────────────────────────────────────────────

  Widget _buildScrapbookSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Row(
          children: [
            Text(
              'dashboard.scrapbook'.tr(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: 8),
            Text('📷', style: const TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Transform.rotate(
                angle: -0.06,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoryWallScreen(
                        isDarkMode: isDarkMode,
                        onThemeToggle: onThemeToggle,
                      ),
                    ),
                  ),
                  child: _buildPolaroidCard(
                    context: context,
                    title: 'Chợ Đêm Vibe 🍢',
                    author: '- Phú Khang -',
                    location: '📍 Da Lat Night Market',
                    gradient: const [Color(0xFFE29587), Color(0xFFD66D75)],
                    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Transform.rotate(
                angle: 0.05,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoryWallScreen(
                        isDarkMode: isDarkMode,
                        onThemeToggle: onThemeToggle,
                      ),
                    ),
                  ),
                  child: _buildPolaroidCard(
                    context: context,
                    title: 'Chạy booooo! 🛵💨',
                    author: '- Thảo Ly -',
                    location: '📍 Đồi Đa Phú',
                    gradient: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
                    imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPolaroidCard({
    required BuildContext context,
    required String title,
    required String author,
    required String location,
    required List<Color> gradient,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? TripMateTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.white54,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.caveat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            author,
            style: GoogleFonts.caveat(
              fontSize: 14,
              color: isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 10, color: Colors.redAccent),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 8,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── HELPER WIDGETS ──────────────────────────────────────────────────────────

class _GlassCircleButton extends StatelessWidget {
  final bool isDarkMode;
  final Widget child;

  const _GlassCircleButton({
    required this.isDarkMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
