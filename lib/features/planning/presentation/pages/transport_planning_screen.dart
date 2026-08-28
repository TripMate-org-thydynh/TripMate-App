import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
class TransportPlanningScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const TransportPlanningScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<TransportPlanningScreen> createState() =>
      _TransportPlanningScreenState();
}

class _TransportPlanningScreenState extends State<TransportPlanningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // HSL-tailored premium colors
    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B); // Electric Purple / Coral
    final secondaryColor = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D); // Mint Green / Soft Amber
    final bgColor = isDark
        ? const Color(0xFF1A1712)
        : const Color(0xFFFDF6D3); // Obsidian Deep Indigo / Warm Ivory

    // Glass styling colors
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.03);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final textPrimary = isDark
        ? const Color(0xFFDAE2FD)
        : const Color(0xFF141210);
    final textSecondary = isDark
        ? const Color(0xFFCBC3D7)
        : const Color(0xFF4A453E);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Ambient Background Mesh Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),

          // Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // AppBar (Custom glassmorphic bar)
                _buildAppBar(isDark, textPrimary, primaryColor),

                // Body content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header title card
                          _buildHeaderCard(
                            isDark,
                            textPrimary,
                            textSecondary,
                            primaryColor,
                            secondaryColor,
                            cardBg,
                            borderColor,
                          ),
                          const SizedBox(height: 20),

                          // Grab Car Card
                          _buildGrabCard(
                            isDark,
                            textPrimary,
                            textSecondary,
                            primaryColor,
                            cardBg,
                            borderColor,
                          ),
                          const SizedBox(height: 16),

                          // Walking Card
                          _buildWalkingCard(
                            isDark,
                            textPrimary,
                            textSecondary,
                            secondaryColor,
                            cardBg,
                            borderColor,
                          ),
                          const SizedBox(height: 16),

                          // Scooter Squad Card
                          _buildScooterCard(
                            isDark,
                            textPrimary,
                            textSecondary,
                            primaryColor,
                            secondaryColor,
                            cardBg,
                            borderColor,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Custom Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(
              isDark,
              textPrimary,
              primaryColor,
              secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color textPrimary, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: textPrimary, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
          ),

          // Glowing Brand Logo
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFFC084FC),
                        const Color(0xFFF5822B),
                        const Color(0xFF60A5FA),
                      ]
                    : [const Color(0xFFF5822B), const Color(0xFFF5822B)],
              ).createShader(bounds);
            },
            child: Text(
              'trip.mate',
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -1.2,
                color: Colors.white,
              ),
            ),
          ),

          // Theme Toggle & Notification Icons
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: textPrimary.withValues(alpha: 0.7),
                  size: 22,
                ),
                onPressed: widget.onThemeToggle,
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_outlined,
                      color: textPrimary,
                      size: 22,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications 🔔'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Active squad avatar indicator
                    Row(
                      children: [
                        _buildSquadAvatar(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=100',
                          0,
                        ),
                        _buildSquadAvatar(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100',
                          -8,
                        ),
                        _buildSquadAvatar(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100',
                          -16,
                        ),
                        Transform.translate(
                          offset: const Offset(-24, 0),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1A1712)
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '+1',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Pulse badge "syncing..."
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: secondaryColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'syncing the squad...',
                            style: AppFonts.heading(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main Heading
                Text(
                  'the squad is moving.',
                  style: AppFonts.heading(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Location Details Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: primaryColor,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hidden Cafe',
                      style: AppFonts.heading(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Vibe: Aesthetic',
                        style: AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Playlist suggestion bar (Pulsing glass element)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(
                      alpha: isDark ? 0.08 : 0.05,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Colors.blueAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Perfect time for a playlist 🎵',
                          style: AppFonts.heading(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 10,
                        color: Colors.blueAccent,
                      ),
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

  Widget _buildSquadAvatar(String url, double offset) {
    return Transform.translate(
      offset: Offset(offset, 0),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          border: Border.all(
            color: widget.isDarkMode ? const Color(0xFF1A1712) : Colors.white,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGrabCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1FA85C,
                            ).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '🚕',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grab Car',
                              style: AppFonts.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '4 mins away',
                              style: AppFonts.body(
                                fontSize: 12,
                                color: const Color(0xFF1FA85C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '45k VND',
                      style: AppFonts.heading(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Split with squad button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Booking request sent. Splitting 45k VND Grab ride with squad! 🚕💸',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFF5822B)
                          : const Color(0xFFF5822B),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.35),
                          blurRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.call_split,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Split with squad',
                          style: AppFonts.heading(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalkingCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color secondaryColor,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🚶', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12 min walk',
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'to Hidden Cafe',
                        style: AppFonts.body(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Active Vibe',
                    style: AppFonts.heading(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScooterCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '🛵',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scooter Squad',
                              style: AppFonts.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Split 2 bikes',
                              style: AppFonts.body(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, color: textPrimary, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Adding squad member to scooter crew! 🛵',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Vy's bike (2/2)",
                          style: AppFonts.body(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'chaos is 8 mins away.',
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF5822B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    bool isDark,
    Color textPrimary,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0x95171F33) : const Color(0xD8FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_outlined,
                  false,
                  'home',
                  isDark,
                  textPrimary,
                  primaryColor,
                  secondaryColor,
                ),
                _buildNavItem(
                  Icons.explore_outlined,
                  true,
                  'explore',
                  isDark,
                  textPrimary,
                  primaryColor,
                  secondaryColor,
                ),
                _buildNavItem(
                  Icons.smart_toy_outlined,
                  false,
                  'smart_toy',
                  isDark,
                  textPrimary,
                  primaryColor,
                  secondaryColor,
                ),
                _buildNavItem(
                  Icons.payments_outlined,
                  false,
                  'payments',
                  isDark,
                  textPrimary,
                  primaryColor,
                  secondaryColor,
                ),
                _buildNavItem(
                  Icons.group_outlined,
                  false,
                  'group',
                  isDark,
                  textPrimary,
                  primaryColor,
                  secondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    bool isActive,
    String tooltip,
    bool isDark,
    Color textPrimary,
    Color primaryColor,
    Color secondaryColor,
  ) {
    if (isActive) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? secondaryColor : secondaryColor,
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withValues(alpha: 0.4),
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? const Color(0xFF1A1712) : Colors.white,
          size: 24,
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: textPrimary.withValues(alpha: 0.55), size: 22),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to $tooltip view 📲'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
