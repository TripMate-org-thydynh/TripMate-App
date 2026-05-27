import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumLandingScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const PremiumLandingScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<PremiumLandingScreen> createState() => _PremiumLandingScreenState();
}

class _PremiumLandingScreenState extends State<PremiumLandingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final bgColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Radial aura backgrounds
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.12),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Premium Top Bar Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: textPrimary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ).createShader(bounds),
                            child: Text(
                              'trip.mate',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                              color: primaryColor,
                            ),
                            onPressed: widget.onThemeToggle,
                          ),
                          const SizedBox(width: 8),
                          // "Get Access" Mini Pill
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              color: secondaryColor.withValues(alpha: 0.15),
                              border: Border.all(color: secondaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(99),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  child: Text(
                                    'Get Access',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Majestic Slogans
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              color: textPrimary,
                            ),
                            children: [
                              const TextSpan(text: 'plan chill.\nchia tiền ez.\n'),
                              TextSpan(
                                text: 'lưu moment.',
                                style: TextStyle(color: secondaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'The ultimate lifestyle club for the chaotic squad. AI-powered planning, social splitting, and memories that last forever.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Bento Features Layout
                        Text(
                          'MEMBER PERKS 🎒',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bento Card 1: Bill splitting detail
                        _buildBentoCard(
                          icon: Icons.account_balance_wallet,
                          iconCol: secondaryColor,
                          title: 'Damage report, simplified.',
                          desc: 'No more awkward math. Split bills with one tap.',
                          surfaceColor: surfaceColor,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          extraWidget: Container(
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: secondaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: secondaryColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('👩🏽‍💻', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Linh paid for Dinner',
                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$45.00',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: secondaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bento Card 2: AI Planner
                        _buildBentoCard(
                          icon: Icons.smart_toy,
                          iconCol: primaryColor,
                          title: 'Matey handles the chaos.',
                          desc: 'Drop your ideas in the chat. Our AI turns scattered thoughts into a master itinerary instantly.',
                          surfaceColor: surfaceColor,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 12),

                        // Bento Card 3: Ghost Cam
                        _buildBentoCard(
                          icon: Icons.camera,
                          iconCol: TripMateTheme.lightSecondary,
                          title: 'Ghost Cam & Memory Wall.',
                          desc: 'Capture the unexpected. Disposable camera vibes for the digital age.',
                          surfaceColor: surfaceColor,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 12),

                        // Bento Card 4: Live Trip Mode
                        _buildBentoCard(
                          icon: Icons.near_me,
                          iconCol: secondaryColor,
                          title: 'Real-time squad energy.',
                          desc: 'Track locations, broadcast status updates, and keep the whole crew synced when wandering.',
                          surfaceColor: surfaceColor,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),

                        const SizedBox(height: 48),

                        // Action Panel Join the Squad
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🎟️ Welcom to the Elite club! Squad invitation sent.',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: primaryColor,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  isDark ? primaryColor : const Color(0xFF4F46E5),
                                  secondaryColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Join the Squad',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Manifesto link footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFooterLink('Manifesto', primaryColor),
                            _buildFooterLink('Expeditions', primaryColor),
                            _buildFooterLink('Safety', primaryColor),
                            _buildFooterLink('Join the Club', primaryColor),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            '© 2024 trip.mate. Adventure awaits.',
                            style: GoogleFonts.inter(fontSize: 10, color: textSecondary),
                          ),
                        ),
                        const SizedBox(height: 20),
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

  Widget _buildBentoCard({
    required IconData icon,
    required Color iconCol,
    required String title,
    required String desc,
    required Color surfaceColor,
    required Color borderCol,
    required Color textPrimary,
    required Color textSecondary,
    Widget? extraWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconCol.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: iconCol, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          ?extraWidget,
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
