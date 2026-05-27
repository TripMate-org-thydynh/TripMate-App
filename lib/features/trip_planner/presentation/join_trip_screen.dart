import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinTripScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const JoinTripScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> with TickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  
  late AnimationController _cardFadeController;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _cardScaleAnimation;

  bool _isDetected = false;
  bool _isJoining = false;
  bool _isJoinedSuccess = false;

  @override
  void initState() {
    super.initState();
    
    // Animate scanning laser line
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scannerAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    // Fade/scale animations for detected card
    _cardFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardFadeAnimation = CurvedAnimation(parent: _cardFadeController, curve: Curves.easeOut);
    _cardScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _cardFadeController, curve: Curves.easeOutBack),
    );

    // Simulate auto QR code detection after 2 seconds
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isDetected = true;
        });
        _cardFadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _cardFadeController.dispose();
    super.dispose();
  }

  void _triggerJoinFlow() {
    setState(() {
      _isJoining = true;
    });

    // Simulate joining flow completion after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isJoining = false;
          _isJoinedSuccess = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the Phu Quoc Chaos squad! 🏝️🔥🍻'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    });
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
          // 1. Mesh Ambient Glow in the background
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    secondaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 2. Camera View / Scan View Simulation
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.22 : 0.12,
              child: Image.network(
                'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&q=80&w=600',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Scanning Overlay Tint
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgColor.withValues(alpha: 0.85),
                    bgColor.withValues(alpha: 0.5),
                    bgColor.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),

          // 3. UI Layer
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom App Bar
                _buildAppBar(isDark, textPrimary),

                // Main Title section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Invite QR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Line up the code to join the chaos.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Scanner Viewport
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isDetected) ...[
                            _buildScannerTarget(isDark, primaryColor, secondaryColor),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Searching for squad QR code...',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // 5. Detected Trip Container (Shows up after simulate time)
                          if (_isDetected)
                            FadeTransition(
                              opacity: _cardFadeAnimation,
                              child: ScaleTransition(
                                scale: _cardScaleAnimation,
                                child: _buildDetectedTripCard(
                                  isDark,
                                  textPrimary,
                                  textSecondary,
                                  primaryColor,
                                  secondaryColor,
                                  cardBg,
                                  borderColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  icon: Icon(Icons.arrow_back, color: textPrimary, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: isDark
                    ? [const Color(0xFFC084FC), const Color(0xFF8B5CF6)]
                    : [const Color(0xFFE0533C), const Color(0xFFF59E0B)],
              ).createShader(bounds);
            },
            child: Text(
              'trip.mate',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -1.2,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: textPrimary.withValues(alpha: 0.7),
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerTarget(bool isDark, Color primaryColor, Color secondaryColor) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Scanner Corners
              Positioned.fill(
                child: CustomPaint(
                  painter: ScannerCornersPainter(
                    color: primaryColor,
                    strokeWidth: 4.5,
                  ),
                ),
              ),

              // Animated Scanning Laser Line
              AnimatedBuilder(
                animation: _scannerAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: _scannerAnimation.value * (MediaQuery.of(context).size.width - 80),
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            secondaryColor.withValues(alpha: 0.01),
                            secondaryColor,
                            secondaryColor.withValues(alpha: 0.01),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryColor.withValues(alpha: 0.8),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Scanner center focus icon
              Center(
                child: Icon(
                  Icons.center_focus_strong,
                  color: Colors.white.withValues(alpha: 0.25),
                  size: 64,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectedTripCard(
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.12),
            blurRadius: 25,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scan tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'QR DETECTED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '98% Chaos Match',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Trip Title
                Text(
                  'Phú Quốc Chaos 🏝️',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Members count and avatars
                Row(
                  children: [
                    Row(
                      children: [
                        _buildSquadAvatar('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100', 0),
                        _buildSquadAvatar('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100', -8),
                        Transform.translate(
                          offset: const Offset(-16, 0),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                              ),
                              border: Border.all(color: isDark ? const Color(0xFF171F33) : Colors.white, width: 1.5),
                            ),
                            child: const Center(
                              child: Text(
                                '+2',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'already inside the chaos',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Interactive States
                if (!_isJoining && !_isJoinedSuccess)
                  GestureDetector(
                    onTap: _triggerJoinFlow,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Join Trip Chaos',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_isJoining)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'joining the chaos...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),

                if (_isJoinedSuccess)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Vibe Synchronized ✨',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10B981),
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

  Widget _buildSquadAvatar(String url, double offset) {
    return Transform.translate(
      offset: Offset(offset, 0),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          border: Border.all(color: widget.isDarkMode ? const Color(0xFF171F33) : Colors.white, width: 1.5),
        ),
      ),
    );
  }
}

// Scanner Target Border Painter
class ScannerCornersPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  ScannerCornersPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 36.0;

    // Top-Left corner
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);

    // Top-Right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
