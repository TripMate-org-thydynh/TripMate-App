import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../core/app_messenger.dart';
class EndTripAwardsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const EndTripAwardsScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<EndTripAwardsScreen> createState() => _EndTripAwardsScreenState();
}

class _EndTripAwardsScreenState extends State<EndTripAwardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  late Animation<double> _shimmerAnim;
  late Animation<double> _floatAnim;

  final List<Map<String, dynamic>> _awards = const [
    {
      'emoji': '🔥',
      'label': 'Most Chaotic',
      'winner': 'Minh Nhật',
      'desc': '"Attempted to pay for Bánh Mì with a crypto wallet 3 times."',
      'color': Color(0xFFFF6B6B),
    },
    {
      'emoji': '📸',
      'label': 'Main Character',
      'winner': 'Thảo Ly',
      'desc': '428 selfies taken',
      'color': Color(0xFFC9B8FF),
    },
    {
      'emoji': '💸',
      'label': 'Biggest Spender',
      'winner': 'Nam Trung',
      'desc': 'Spent 42% of budget on coffee',
      'color': Color(0xFF1FA85C),
    },
    {
      'emoji': '🚕',
      'label': 'Lost Again',
      'winner': 'Hoàng',
      'desc': 'Found in a different district twice',
      'color': Color(0xFFFFC107),
    },
    {
      'emoji': '😭',
      'label': 'Emotional Support',
      'winner': 'Lan',
      'desc': 'Carried the first aid kit and vibes',
      'color': Color(0xFF64B5F6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF0F0FF);
    final surface = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                        isDark: isDark,
                      ),
                      const Spacer(),
                      _buildGlassButton(
                        icon: isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        onTap: widget.onThemeToggle ?? () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // TRIP WRAPPED badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFFC9B8FF,
                              ).withValues(alpha: 0.5),
                            ),
                            color: const Color(
                              0xFFC9B8FF,
                            ).withValues(alpha: isDark ? 0.1 : 0.2),
                          ),
                          child: Text(
                            'TRIP WRAPPED',
                            style: AppFonts.heading(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: const Color(0xFFC9B8FF),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Trophy floating animation
                        AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          ),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFD700),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 0,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🏆', style: TextStyle(fontSize: 44)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'The Phú Quốc Awards',
                          style: AppFonts.heading(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Friendship survived 7 days of financial chaos.',
                          style: AppFonts.body(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // Award cards
                        ...List.generate(_awards.length, (index) {
                          final award = _awards[index];
                          return _buildAwardCard(
                            award: award,
                            surface: surface,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          );
                        }),

                        const SizedBox(height: 24),

                        // Share button
                        AnimatedBuilder(
                          animation: _shimmerAnim,
                          builder: (context, child) => Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color(0xFFC9B8FF),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFC9B8FF,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 0,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () => showGlobalSnack(
                                  'Tính năng đang được hoàn thiện 🚧',
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.share,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Share the Damage',
                                        style: AppFonts.heading(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
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

  Widget _buildAwardCard({
    required Map<String, dynamic> award,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final Color accentColor = award['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.15),
                    border: Border.all(color: accentColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      award['emoji'] as String,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: accentColor.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          award['label'] as String,
                          style: AppFonts.heading(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        award['winner'] as String,
                        style: AppFonts.heading(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        award['desc'] as String,
                        style: AppFonts.body(
                          fontSize: 12,
                          color: textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
    );
  }
}
