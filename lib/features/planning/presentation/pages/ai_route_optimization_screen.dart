import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
class AIRouteOptimizationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIRouteOptimizationScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AIRouteOptimizationScreen> createState() =>
      _AIRouteOptimizationScreenState();
}

class _AIRouteOptimizationScreenState extends State<AIRouteOptimizationScreen>
    with SingleTickerProviderStateMixin {
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
    _sparkAnimation = CurvedAnimation(
      parent: _sparkController,
      curve: Curves.easeInOut,
    );
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
    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B); // Electric Purple / Coral
    final secondaryColor = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D); // Mint Green / Soft Amber
    final bgColor = isDark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);

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
          // 1. Ambient Backdrop Glows (Mesh Gradients)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
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
                color: Colors.transparent,
              ),
            ),
          ),

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
                // Custom Navigation Header
                _buildHeader(isDark, textPrimary),

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
                          // 3. Wander AI Sparkling optimization card
                          _buildSparklingOptimizationCard(
                            isDark,
                            textPrimary,
                            primaryColor,
                            secondaryColor,
                            cardBg,
                            borderColor,
                            _sparkAnimation,
                          ),
                          const SizedBox(height: 20),

                          // 4. Interactive Route Optimization Visual Map
                          _buildInteractiveRouteVisual(
                            isDark,
                            textPrimary,
                            textSecondary,
                            primaryColor,
                            secondaryColor,
                            cardBg,
                            borderColor,
                          ),
                          const SizedBox(height: 20),

                          // 5. Optimization updates section (Traffic & Sunset)
                          Text(
                            'Live Optimization Logs',
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Traffic Update card
                          _buildTrafficUpdateCard(
                            isDark,
                            textPrimary,
                            textSecondary,
                            cardBg,
                            borderColor,
                          ),
                          const SizedBox(height: 12),

                          // Sunset Update card
                          _buildSunsetUpdateCard(
                            isDark,
                            textPrimary,
                            textSecondary,
                            secondaryColor,
                            cardBg,
                            borderColor,
                          ),
                          const SizedBox(height: 30),

                          // 6. Action buttons
                          _buildApplyButton(isDark, primaryColor),
                          const SizedBox(height: 14),

                          Center(
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Route optimization dismissed 🚶‍♂️',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Dismiss Plan',
                                style: AppFonts.heading(
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
                colors: [Color(0xFFF5822B), Color(0xFFF5822B)],
              ).createShader(bounds);
            },
            child: Text(
              'WANDER AI',
              style: AppFonts.heading(
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
                  widget.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: textPrimary.withValues(alpha: 0.7),
                ),
                onPressed: widget.onThemeToggle,
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: textPrimary,
                ),
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
            blurRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
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
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'optimizing the chaos✨',
                          style: AppFonts.heading(
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
                    style: AppFonts.heading(
                      fontSize: 26,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Saved your squad '),
                      TextSpan(
                        text: '42 mins',
                        style: AppFonts.heading(
                          color: isDark
                              ? const Color(0xFF1FA85C)
                              : const Color(0xFFF5822B),
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
                  style: AppFonts.body(
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
                style: AppFonts.heading(
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
                  style: AppFonts.heading(
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
              _buildRouteStop(
                Icons.local_cafe,
                'Start',
                'Hidden Cafe',
                primaryColor,
              ),
              _buildRouteConnector(true, secondaryColor),
              _buildRouteStop(
                Icons.landscape,
                'Sunset',
                'Viewpoint',
                secondaryColor,
              ),
              _buildRouteConnector(false, Colors.blueAccent),
              _buildRouteStop(
                Icons.restaurant,
                'Dinner',
                'Local Grill',
                Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStop(
    IconData icon,
    String label,
    String stopName,
    Color stopColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stopColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: stopColor, width: 2),
            ),
            child: Icon(icon, color: stopColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppFonts.heading(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: stopColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stopName,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 9,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTrafficUpdateCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
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
                  child: const Icon(
                    Icons.traffic,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Traffic detected on QL20',
                        style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rerouting to avoid +25 min delay. Highway has extreme squad lag.',
                        style: AppFonts.body(
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
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5822B).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_twilight,
                    color: Color(0xFFF5822B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Better sunset vibes',
                        style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Arrive at viewpoint by 5:15 PM.',
                        style: AppFonts.body(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GOLDEN HOUR',
                    style: AppFonts.heading(
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
        color: isDark ? const Color(0xFFF5822B) : const Color(0xFFF5822B),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 0,
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
                backgroundColor: Color(0xFF1FA85C),
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
                  style: AppFonts.heading(
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
