import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GhostCamScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const GhostCamScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<GhostCamScreen> createState() => _GhostCamScreenState();
}

class _GhostCamScreenState extends State<GhostCamScreen> with TickerProviderStateMixin {
  late AnimationController _badgeAnimationController;
  late AnimationController _scannerAnimationController;
  bool _isCapturing = false;
  int _ghostPingsCount = 3;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _badgeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _badgeAnimationController.dispose();
    _scannerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    
    // Theme Colors according to the guidelines
    final bgGradStart = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF171F33) : const Color(0xFFF3EFE9);
    final primary = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondary = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);
    final surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;

    // Glowing/Special UI Colors
    final mintColor = const Color(0xFF34D399);
    final neonPink = const Color(0xFFFF2E93);
    final neonAmber = const Color(0xFFFFB300);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradStart, bgGradEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: surfaceColor.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: textPrimary.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Ghost Cam 👻',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        // Theme Switcher Button
                        GestureDetector(
                          onTap: widget.onThemeToggle,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: surfaceColor.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: textPrimary.withValues(alpha: 0.1),
                                  width: 1),
                            ),
                            child: Icon(
                              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                              color: textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Advices info banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: surfaceColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Catch surprise candid ghost moments of your active squad.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Interactive live camera box
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark ? primary.withValues(alpha: 0.4) : primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: isDark ? 0.25 : 0.1),
                            blurRadius: 24,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final h = constraints.maxHeight;
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // Camera viewfinder simulation
                                Image.network(
                                  'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800',
                                  fit: BoxFit.cover,
                                ),

                                // Scanline laser animation
                                AnimatedBuilder(
                                  animation: _scannerAnimationController,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: _scannerAnimationController.value * h,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              mintColor.withValues(alpha: 0.0),
                                              mintColor.withValues(alpha: 0.8),
                                              mintColor.withValues(alpha: 0.0),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: mintColor.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Visual Corner Focus Brackets
                                _buildFocusBracket(top: 20, left: 20, isTop: true, isLeft: true, color: secondary),
                                _buildFocusBracket(top: 20, right: 20, isTop: true, isLeft: false, color: secondary),
                                _buildFocusBracket(bottom: 20, left: 20, isTop: false, isLeft: true, color: secondary),
                                _buildFocusBracket(bottom: 20, right: 20, isTop: false, isLeft: false, color: secondary),

                                // Pulsing green dot and status message in the center top inside viewfinder
                                Positioned(
                                  top: 20,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildPulseDot(),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Nam Trung is watching",
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Floating Location Sticker: "Hội An Ancient Town"
                                Positioned(
                                  top: 90,
                                  right: 20,
                                  child: Transform.rotate(
                                    angle: 0.04,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: mintColor.withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: mintColor, width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: mintColor.withValues(alpha: 0.15),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.location_on, color: Color(0xFF34D399), size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Hội An Ancient Town",
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Surprise flashing badge
                                Positioned(
                                  top: h * 0.35,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: AnimatedBuilder(
                                      animation: _badgeAnimationController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: 0.95 + (_badgeAnimationController.value * 0.1),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444).withValues(alpha: 0.85 + (_badgeAnimationController.value * 0.15)),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFEF4444).withValues(alpha: 0.4 * _badgeAnimationController.value),
                                                  blurRadius: 15,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              "Surprise! 📸",
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // Live Nearby Alert Banner (at the lower top)
                                Positioned(
                                  bottom: 110,
                                  left: 16,
                                  right: 16,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: neonAmber.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text('👻', style: TextStyle(fontSize: 22)),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Active Ghost Ping detected!',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Minh Nhật is active nearby at Kyoto Station!',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 10,
                                                      color: Colors.white.withValues(alpha: 0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.redAccent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Camera Flash/Captured White Overlay effect
                                if (_isCapturing)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    color: Colors.white,
                                  ),

                                // Shutter Button, Mode Selector, Flash & Pings controls row at the bottom of the camera box
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Column(
                                    children: [
                                      // Sliding Modes
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildModeText("PHOTO", false, mintColor),
                                            const SizedBox(width: 20),
                                            _buildModeText("GHOST CAM", true, mintColor),
                                            const SizedBox(width: 20),
                                            _buildModeText("VIDEO", false, mintColor),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Shutter and Flash controls
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Ping meter
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 14),
                                                const SizedBox(width: 4),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '$_ghostPingsCount',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        height: 1.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Pings left',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 8,
                                                        color: Colors.white.withValues(alpha: 0.6),
                                                        height: 1.1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Center big shutter button
                                          GestureDetector(
                                            onTap: () {
                                              final messenger = ScaffoldMessenger.of(context);
                                              setState(() {
                                                _isCapturing = true;
                                              });
                                              Future.delayed(const Duration(milliseconds: 150), () {
                                                if (mounted) {
                                                  setState(() {
                                                    _isCapturing = false;
                                                    if (_ghostPingsCount > 0) _ghostPingsCount--;
                                                  });
                                                  messenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Captured Surprise candid Ghost Boomerang moment! 📸⚡',
                                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                                      ),
                                                      backgroundColor: neonPink,
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              });
                                            },
                                            child: Container(
                                              width: 72,
                                              height: 72,
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 4),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: neonPink,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: neonPink.withValues(alpha: 0.5),
                                                      blurRadius: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Flash toggle button
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isFlashOn = !_isFlashOn;
                                              });
                                            },
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: _isFlashOn ? primary : Colors.black.withValues(alpha: 0.5),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: _isFlashOn ? primary : Colors.white.withValues(alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(
                                                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bracket painters for viewfinder
  Widget _buildFocusBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: color, width: 2.5) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: color, width: 2.5) : BorderSide.none,
            left: isLeft ? BorderSide(color: color, width: 2.5) : BorderSide.none,
            right: !isLeft ? BorderSide(color: color, width: 2.5) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Pulsing Dot Widget
  Widget _buildPulseDot() {
    return AnimatedBuilder(
      animation: _badgeAnimationController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF34D399),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF34D399).withValues(alpha: 0.5 + (_badgeAnimationController.value * 0.5)),
                blurRadius: 4 + (_badgeAnimationController.value * 6),
                spreadRadius: 1 + (_badgeAnimationController.value * 2),
              ),
            ],
          ),
        );
      },
    );
  }

  // Mode Text Helper
  Widget _buildModeText(String text, bool isSelected, Color activeColor) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.6),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.5,
        shadows: isSelected
            ? [
                Shadow(
                  color: activeColor.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
