import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ProfileSetupScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _usernameController = TextEditingController(text: 'WandererX');
  
  // Selected state variables
  int _selectedAvatarIndex = 0;
  String _selectedVibe = '🔥 chaos squad';
  String _selectedAesthetic = 'Tokyo Neon';

  // Default gorgeous preset avatars with gradients
  final List<Map<String, dynamic>> _presetAvatars = [
    {'emoji': '✈️', 'title': 'Pilot Alter', 'gradient': [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]},
    {'emoji': '☕', 'title': 'Cozy Cafe', 'gradient': [const Color(0xFFF59E0B), const Color(0xFFEF4444)]},
    {'emoji': '🥲', 'title': 'Lmao Chaos', 'gradient': [const Color(0xFF10B981), const Color(0xFF3B82F6)]},
    {'emoji': '🦊', 'title': 'Swift Fox', 'gradient': [const Color(0xFFEC4899), const Color(0xFFF43F5E)]},
  ];

  final List<String> _vibes = [
    '🌿 chill traveler',
    '🔥 chaos squad',
    '📸 photo hunter',
    '🍜 foodie energy'
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Theme responsive color assignments
    final Color bg = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final Color surface = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final Color primary = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final Color secondary = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final Color textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final Color textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Background Glow Blobs ─────────────────────────────────────────────
          if (isDark) ...[
            Positioned(
              top: -120,
              left: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary.withValues(alpha: 0.1),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ],

          // ── Scrollable Layout ──────────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Minimal Header with Back Button and Theme Toggle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 22,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        if (widget.onThemeToggle != null)
                          GestureDetector(
                            onTap: widget.onThemeToggle,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                              ),
                              child: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                size: 20,
                                color: textSecondary,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 42),
                      ],
                    ),
                  ),
                ),

                // Main form scroll content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Heading 1 & Paragraph
                      Text(
                        'build your travel\nalter ego.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.15,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your squad identity starts here.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: textSecondary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Avatar Pick Section ─────────────────────────────────────
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing Ring under Selected Avatar
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _presetAvatars[_selectedAvatarIndex]['gradient'],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_presetAvatars[_selectedAvatarIndex]['gradient'][0] as Color).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bg,
                              ),
                            ),
                            // Current selected Avatar display
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _presetAvatars[_selectedAvatarIndex]['gradient'],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _presetAvatars[_selectedAvatarIndex]['emoji'],
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ),
                            // Upload overlay button
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // Mock upload trigger with feedback
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '📸 Opening system image gallery...',
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary,
                                    border: Border.all(color: bg, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Avatar Presets Selector Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_presetAvatars.length, (index) {
                          final isSelected = _selectedAvatarIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatarIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: surface.withValues(alpha: isDark ? 0.35 : 0.75),
                                border: Border.all(
                                  color: isSelected ? primary : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  _presetAvatars[index]['emoji'],
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Username Input Field
                      Text(
                        'ALTER EGO HANDLE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: surface.withValues(alpha: isDark ? 0.25 : 0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.18),
                            width: 1.2,
                          ),
                        ),
                        child: TextField(
                          controller: _usernameController,
                          style: GoogleFonts.inter(fontSize: 16, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'e.g. ChaosKing',
                            hintStyle: GoogleFonts.inter(color: textSecondary.withValues(alpha: 0.5)),
                            prefixIcon: Icon(Icons.alternate_email_rounded, color: primary, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Vibe Chips Section ─────────────────────────────────────
                      Text(
                        'SELECT YOUR ENERGY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _vibes.map((vibe) {
                          final isSelected = _selectedVibe == vibe;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedVibe = vibe;
                              });
                            },
                            child: AnimatedScale(
                              scale: isSelected ? 1.04 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primary.withValues(alpha: isDark ? 0.18 : 0.1)
                                      : surface.withValues(alpha: isDark ? 0.35 : 0.7),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: isSelected ? primary : textSecondary.withValues(alpha: 0.2),
                                    width: isSelected ? 1.8 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primary.withValues(alpha: 0.18),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  vibe,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? primary : textPrimary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      // ── Aesthetic Selection Cards ──────────────────────────────
                      Text(
                        'AESTHETIC',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Tokyo Neon Card
                          Expanded(
                            child: _aestheticCard(
                              title: 'Tokyo Neon',
                              desc: 'Electric cyber vibes',
                              gradient: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                              isActive: _selectedAesthetic == 'Tokyo Neon',
                              isDark: isDark,
                              surfaceColor: surface,
                              textColor: textPrimary,
                              onTap: () {
                                setState(() {
                                  _selectedAesthetic = 'Tokyo Neon';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Đà Lạt Mist Card
                          Expanded(
                            child: _aestheticCard(
                              title: 'Đà Lạt Mist',
                              desc: 'Emerald forest fog',
                              gradient: [const Color(0xFF10B981), const Color(0xFF047857)],
                              isActive: _selectedAesthetic == 'Đà Lạt Mist',
                              isDark: isDark,
                              surfaceColor: surface,
                              textColor: textPrimary,
                              onTap: () {
                                setState(() {
                                  _selectedAesthetic = 'Đà Lạt Mist';
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // ── Join The Club Button ────────────────────────────────────
                      GestureDetector(
                        onTap: () {
                          // Complete profile setup feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              content: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF34D399).withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF34D399).withValues(alpha: 0.4),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('👑', style: TextStyle(fontSize: 20)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Welcome to TripMate, ${_usernameController.text}! Alter ego activated.',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: LinearGradient(
                              colors: _selectedAesthetic == 'Tokyo Neon'
                                  ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
                                  : [const Color(0xFF10B981), const Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_selectedAesthetic == 'Tokyo Neon'
                                        ? const Color(0xFFEC4899)
                                        : const Color(0xFF10B981))
                                    .withValues(alpha: 0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Join the Club',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aestheticCard({
    required String title,
    required String desc,
    required List<Color> gradient,
    required bool isActive,
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? gradient[0].withValues(alpha: isDark ? 0.22 : 0.12)
                  : surfaceColor.withValues(alpha: isDark ? 0.35 : 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? gradient[0] : textColor.withValues(alpha: 0.12),
                width: isActive ? 2.0 : 1.2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small preview pill
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isActive ? Icons.check_rounded : Icons.blur_on_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
