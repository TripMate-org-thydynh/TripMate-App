import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiFailedCrisisScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AiFailedCrisisScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<AiFailedCrisisScreen> createState() => _AiFailedCrisisScreenState();
}

class _AiFailedCrisisScreenState extends State<AiFailedCrisisScreen> {
  double _rebootProgress = 0.35;
  bool _isRebooting = false;

  void _triggerReboot() {
    if (_isRebooting) return;
    setState(() {
      _isRebooting = true;
    });

    // Simulate progressive reboot loading
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return false;
      setState(() {
        _rebootProgress += 0.15;
        if (_rebootProgress >= 1.0) {
          _rebootProgress = 1.0;
        }
      });
      return _rebootProgress < 1.0;
    }).then((_) {
      if (!mounted) return;
      setState(() {
        _isRebooting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🤖 Matey AI đã hồi phục! Trí thông minh nhân tạo sẵn sàng bứt tốc.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          backgroundColor: TripMateTheme.darkSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    });
  }

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
          // Cyberpunk digital green matrix aura for AI module
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.08),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: textPrimary),
                          onPressed: () => Navigator.pop(context),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.psychology, color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI Mood: Recovering...',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Computer code reboot mockup
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'err_404 reboot.sys',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text('👾', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Linear Progress Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _rebootProgress,
                            backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                            color: secondaryColor,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Memory check: passed',
                              style: GoogleFonts.inter(fontSize: 9, color: textSecondary),
                            ),
                            Text(
                              '${(_rebootProgress * 100).toInt()}%',
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Headline titles
                  Text(
                    'AI had a small\nexistential crisis 😭',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'the robot got emotionally overwhelmed. rebooting the chaos generator...',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: textSecondary,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Reboot Try Again Action Button
                  GestureDetector(
                    onTap: _triggerReboot,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            secondaryColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Center(
                        child: _isRebooting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.refresh, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Try Again',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Fallback Vibes Label
                  Text(
                    'Fallback Vibes',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Clickable card options list
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildFallbackCard(
                          icon: Icons.luggage_outlined,
                          title: 'Check Itinerary',
                          subtitle: 'View saved plans manually',
                          color: primaryColor,
                          surfaceColor: surfaceColor,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildFallbackCard(
                          icon: Icons.forum_outlined,
                          title: 'Squad Chat',
                          subtitle: 'See what the group is saying',
                          color: secondaryColor,
                          surfaceColor: surfaceColor,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildFallbackCard(
                          icon: Icons.explore_outlined,
                          title: 'Explore Gems',
                          subtitle: 'Browse popular spots',
                          color: TripMateTheme.lightSecondary,
                          surfaceColor: surfaceColor,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
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

  Widget _buildFallbackCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color surfaceColor,
    required Color borderCol,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol),
        ),
        child: ListTile(
          onTap: () {},
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
        ),
      ),
    );
  }
}
