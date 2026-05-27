import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIRouteOptimizationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIRouteOptimizationScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AIRouteOptimizationScreen> createState() => _AIRouteOptimizationScreenState();
}

class _AIRouteOptimizationScreenState extends State<AIRouteOptimizationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sparkController;
  late Animation<double> _sparkAnimation;

  @override
  void initState() {
    super.initState();
    // Sparkling and pulsing animations for Wander AI
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _sparkAnimation = CurvedAnimation(parent: _sparkController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // HSL Premium colors
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C); // Electric Purple / Coral
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A); // Mint Green / Soft Amber
    final bgColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);

    final cardBg = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
    final textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Ambient Backdrop Glows (Mesh Gradients)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    secondaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom Navigation Header
                _buildHeader(isDark, textPrimary),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3. Wander AI Sparkling optimization card
                          _buildSparklingOptimizationCard(isDark, textPrimary, primaryColor, secondaryColor, cardBg, borderColor, _sparkAnimation),
                          const SizedBox(height: 20),

                          // 4. Interactive Route Optimization Visual Map
                          _buildInteractiveRouteVisual(isDark, textPrimary, textSecondary, primaryColor, secondaryColor, cardBg, borderColor),
                          const SizedBox(height: 20),

                          // 5. Optimization updates section (Traffic & Sunset)
                          Text(
                            'Live Optimization Logs',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Traffic Update card
                          _buildTrafficUpdateCard(isDark, textPrimary, textSecondary, cardBg, borderColor),
                          const SizedBox(height: 12),

                          // Sunset Update card
                          _buildSunsetUpdateCard(isDark, textPrimary, textSecondary, secondaryColor, cardBg, borderColor),
                          const SizedBox(height: 30),

                          // 6. Action buttons
                          _buildApplyButton(isDark, primaryColor),
                          const SizedBox(height: 14),

                          Center(
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Route optimization dismissed 🚶‍♂️'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Dismiss Plan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _buildHeader(bool isDark, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left menu icon button
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.menu, color: textPrimary, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menu clicked 📱'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Glowing Header Title
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF34D399)],
              ).createShader(bounds);
            },
            child: Text(
              'WANDER AI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ),

          // Theme & Notification Icons
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: textPrimary.withValues(alpha: 0.7),
                ),
                onPressed: widget.onThemeToggle,
              ),
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, color: textPrimary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No active Wander AI alerts 🤖'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSparklingOptimizationCard(
    bool isDark,
    Color textPrimary,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color borderColor,
    Animation<double> animation,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ScaleTransition(
                          scale: animation,
                          child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'optimizing the chaos✨',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    ScaleTransition(
                      scale: animation,
                      child: Row(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Icon(
                              Icons.star_purple500,
                              size: 12 + (index * 2.0),
                              color: secondaryColor.withValues(alpha: 0.7),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main headline "Saved your squad 42 mins today"
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Saved your squad '),
                      TextSpan(
                        text: '42 mins',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFFE0533C),
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dotted,
                        ),
                      ),
                      const TextSpan(text: ' today'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plus, we found a scenic shortcut.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: textPrimary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveRouteVisual(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Optimized Routing',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Scenic Path',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Route Visual Timeline Line
          Row(
            children: [
              _buildRouteStop(Icons.local_cafe, 'Start', 'Hidden Cafe', primaryColor),
              _buildRouteConnector(true, secondaryColor),
              _buildRouteStop(Icons.landscape, 'Sunset', 'Viewpoint', secondaryColor),
              _buildRouteConnector(false, Colors.blueAccent),
              _buildRouteStop(Icons.restaurant, 'Dinner', 'Local Grill', Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStop(IconData icon, String label, String stopName, Color stopColor) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stopColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: stopColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(icon, color: stopColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: stopColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stopName,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteConnector(bool isAnimated, Color color) {
    return Container(
      width: 40,
      height: 2.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.2)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTrafficUpdateCard(bool isDark, Color textPrimary, Color textSecondary, Color cardBg, Color borderColor) {
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
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.traffic, color: Colors.redAccent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Traffic detected on QL20',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rerouting to avoid +25 min delay. Highway has extreme squad lag.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.3,
                        ),
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

  Widget _buildSunsetUpdateCard(
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
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wb_twilight, color: Color(0xFFF59E0B), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Better sunset vibes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Arrive at viewpoint by 5:15 PM.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GOLDEN HOUR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: secondaryColor,
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

  Widget _buildApplyButton(bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF8B5CF6), const Color(0xFFDDA6FF)]
              : [const Color(0xFFE0533C), const Color(0xFFFCA5A5)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Applied optimized path successfully! 🛵✨⛰️'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF10B981),
              ),
            );
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.route, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Apply New Route',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
