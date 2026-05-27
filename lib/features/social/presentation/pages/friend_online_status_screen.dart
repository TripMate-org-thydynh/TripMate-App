import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendOnlineStatusScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const FriendOnlineStatusScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<FriendOnlineStatusScreen> createState() =>
      _FriendOnlineStatusScreenState();
}

class _FriendOnlineStatusScreenState extends State<FriendOnlineStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Color system
    const darkBg = Color(0xFF0B1326);
    const darkSurface = Color(0xFF171F33);
    const primary = Color(0xFFD0BCFF);
    const primaryLight = Color(0xFF6D3BD7);
    const secondary = Color(0xFF45DFA4);
    const secondaryLight = Color(0xFF059669);
    const errorColor = Color(0xFFFFB4AB);
    const lightBg = Color(0xFFFCFAF6);

    final bgColor = isDark ? darkBg : lightBg;
    final surfaceColor = isDark ? darkSurface : Colors.white;
    final primaryColor = isDark ? primary : primaryLight;
    final secondaryColor = isDark ? secondary : secondaryLight;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? Colors.white60 : const Color(0xFF6B7280);

    final List<_SquadMember> members = [
      _SquadMember(
        name: 'Minh Nhật',
        initial: 'M',
        avatarColor: isDark ? const Color(0xFF7C3AED) : const Color(0xFF8B5CF6),
        ringColor: secondaryColor,
        ringActive: true,
        status: '☕ getting coffee',
        badgeEmoji: '☕',
        isDebt: false,
      ),
      _SquadMember(
        name: 'Thảo Ly',
        initial: 'T',
        avatarColor: isDark ? const Color(0xFFEC4899) : const Color(0xFFF472B6),
        ringColor: primaryColor,
        ringActive: true,
        status: '📸 3 moments',
        badgeEmoji: '📸 3',
        isDebt: false,
      ),
      _SquadMember(
        name: 'Nam Trung',
        initial: 'N',
        avatarColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        ringColor: Colors.grey,
        ringActive: false,
        status: '🚕 5 mins away',
        badgeEmoji: '🚕',
        isDebt: false,
      ),
      _SquadMember(
        name: 'Phú Khang',
        initial: 'P',
        avatarColor: isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316),
        ringColor: errorColor,
        ringActive: true,
        status: '😭 owes 420k',
        badgeEmoji: '420k đ',
        isDebt: true,
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [primaryColor, secondaryColor],
          ).createShader(bounds),
          child: Text(
            'Squad Presence',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: errorColor.withValues(
                        alpha: 0.4 + 0.6 * _blinkController.value,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: errorColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: textPrimary,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Bar
            _buildGlassPanel(
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '4 members · 3 active',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: secondaryColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '⚡ squad is live',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section Header
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: secondaryColor, size: 22),
                const SizedBox(width: 6),
                Text(
                  'the chaos squad is active ⚡',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Squad Member Cards
            ...members.map((member) => _buildMemberCard(
                  member: member,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  errorColor: errorColor,
                )),

            const SizedBox(height: 8),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          secondaryColor,
                          secondaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: secondaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Opening squad chat 💬')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Squad Chat 💬',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF0B1326) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pinging all squad members 🔔')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? primary : primaryLight,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Ping All 🔔',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? primary : primaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required _SquadMember member,
    required bool isDark,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color errorColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildGlassPanel(
        isDark: isDark,
        surfaceColor: surfaceColor,
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Animated Avatar Ring
            AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                final borderWidth = member.ringActive
                    ? 2.0 + 1.5 * _breathController.value
                    : 2.0;
                final ringOpacity = member.ringActive ? 0.8 : 0.3;

                return Container(
                  width: 72,
                  height: 72,
                  padding: EdgeInsets.all(borderWidth),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: member.ringActive
                        ? RadialGradient(
                            colors: [
                              member.ringColor.withValues(alpha: ringOpacity),
                              member.ringColor.withValues(alpha: 0.2),
                            ],
                          )
                        : null,
                    border: Border.all(
                      color: member.ringColor.withValues(alpha: ringOpacity),
                      width: borderWidth,
                    ),
                    boxShadow: member.ringActive
                        ? [
                            BoxShadow(
                              color: member.ringColor.withValues(
                                alpha: 0.3 +
                                    0.2 * _breathController.value,
                              ),
                              blurRadius:
                                  8 + 8 * _breathController.value,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: member.avatarColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  member.initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Name + Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.status,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: member.isDebt
                    ? errorColor.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.circular(20),
                border: member.isDebt
                    ? Border.all(
                        color: errorColor.withValues(alpha: 0.5),
                        width: 1,
                      )
                    : null,
              ),
              child: Text(
                member.badgeEmoji,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: member.isDebt ? errorColor : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassPanel({
    required bool isDark,
    required Color surfaceColor,
    required double borderRadius,
    required EdgeInsets padding,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: isDark ? 0.55 : 0.85),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SquadMember {
  final String name;
  final String initial;
  final Color avatarColor;
  final Color ringColor;
  final bool ringActive;
  final String status;
  final String badgeEmoji;
  final bool isDebt;

  const _SquadMember({
    required this.name,
    required this.initial,
    required this.avatarColor,
    required this.ringColor,
    required this.ringActive,
    required this.status,
    required this.badgeEmoji,
    required this.isDebt,
  });
}
