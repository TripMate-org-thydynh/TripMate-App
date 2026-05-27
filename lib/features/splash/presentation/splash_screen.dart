import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../dashboard/presentation/auth_flow_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const SplashScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final List<ParticleModel> _particles = [];

  @override
  void initState() {
    super.initState();

    // Fade-in animation for content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Floating logo animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Particle background animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _fadeController.forward();
    _generateParticles();

    // Navigate to Onboarding Auth Flow after 4 seconds
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AuthFlowScreen(
              isDarkMode: widget.isDarkMode,
              onThemeToggle: widget.onThemeToggle,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      _particles.add(
        ParticleModel(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 6 + 2,
          speed: random.nextDouble() * 0.05 + 0.02,
          opacity: random.nextDouble() * 0.4 + 0.1,
          angle: random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryColor = widget.isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final tertiaryColor = widget.isDarkMode ? const Color(0xFFFB923C) : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6),
      body: Stack(
        children: [
          // 1. Ambient Background Layer (Mesh Gradients)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, -0.6),
                    radius: 1.2,
                    colors: widget.isDarkMode
                        ? [
                            const Color(0x3D8B5CF6), // Soft Stitch Purple mesh glow
                            Colors.transparent,
                          ]
                        : [
                            const Color(0x24E0533C), // Soft Coral mesh glow
                            Colors.transparent,
                          ],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.8, 0.2),
                    radius: 1.5,
                    colors: widget.isDarkMode
                        ? [
                            const Color(0x2834D399), // Soft Stitch Mint mesh glow
                            Colors.transparent,
                          ]
                        : [
                            const Color(0x24EBA83A), // Soft Stitch Amber mesh glow
                            Colors.transparent,
                          ],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, 0.8),
                    radius: 1.3,
                    colors: widget.isDarkMode
                        ? [
                            const Color(0x20FB923C), // Soft Stitch Orange mesh glow
                            Colors.transparent,
                          ]
                        : [
                            const Color(0x1C8B5CF6), // Soft Stitch Lavender mesh glow
                            Colors.transparent,
                          ],
                  ),
                ),
              );
            },
          ),

          // 2. Cinematic Karst Landscape Backdrop
          Positioned.fill(
            child: Opacity(
              opacity: widget.isDarkMode ? 0.15 : 0.08,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBEd9aSL1vohj77JnxkkBZMRADM86F6Q-L7SBFrmlEdnUxW2QNC9K64tQHhqPPTWTPnb7IkydcTre1ZotcJHHZXPYxP2qhQW3nnHSiAg8pMWJlEvIsle5nbblDh7r0r1I06xGIP7dZwxeKjv3J_JpTt_3Ge_UmbziGQVgJJkkgvlyYiW2--hwdrCv5JmXRu3JhruOyAQKHtcOqMh-Q-0r6mUPaLKRx3o1VSzyUKp21MpoCUEL95Xdn_xJKt7mAHTV3cF3tvFQEzltRx',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(); // Fallback if image fails to load
                },
              ),
            ),
          ),

          // Blur overlay for premium glass integration
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: widget.isDarkMode
                    ? Colors.black.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),

          // 3. Floating Particles Layer
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                  color: primaryColor,
                ),
                child: Container(),
              );
            },
          ),

          // 4. Central Logo & Brand Element
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    final floatValue = math.sin(_floatController.value * math.pi * 2) * 12;
                    return Transform.translate(
                      offset: Offset(0, floatValue),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Glassmorphism Logo Card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                                  decoration: BoxDecoration(
                                    color: widget.isDarkMode
                                        ? const Color(0x13FFFFFF)
                                        : const Color(0x16000000),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: widget.isDarkMode
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(alpha: 0.05),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(
                                          alpha: widget.isDarkMode ? 0.15 : 0.08,
                                        ),
                                        blurRadius: 40,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Glowing italic text gradient
                                      ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            colors: widget.isDarkMode
                                                ? [
                                                    primaryColor,
                                                    const Color(0xFFDDA6FF),
                                                    secondaryColor,
                                                  ]
                                                : [
                                                    primaryColor,
                                                    secondaryColor,
                                                    tertiaryColor,
                                                  ],
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          'trip.mate',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: screenWidth > 360 ? 46 : 38,
                                            fontWeight: FontWeight.w800,
                                            fontStyle: FontStyle.italic,
                                            letterSpacing: -2.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Under-logo accent divider line
                                      Container(
                                        width: 48,
                                        height: 3.5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              secondaryColor.withValues(alpha: 0.8),
                                              Colors.transparent,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 5. Cinematic Tagline Footer
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildTaglineText('plan chill.', primaryColor),
                    _buildTaglineText('chia tiền ez.', secondaryColor),
                    _buildTaglineText('lưu moment.', tertiaryColor),
                  ],
                ),
              ),
            ),
          ),

          // 6. Floating Glassmorphic Theme Toggle Button
          Positioned(
            top: 54,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isDarkMode
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: widget.isDarkMode
                            ? const Color(0xFFD0BCFF)
                            : const Color(0xFFE0533C),
                      ),
                      onPressed: () {
                        widget.onThemeToggle();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaglineText(String text, Color highlightColor) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: highlightColor,
      ),
    );
  }
}

class ParticleModel {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double angle;

  ParticleModel({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });

  void update(double progress) {
    // Drifts slowly upwards and oscillates horizontally
    y -= speed * 0.005;
    x += math.sin(progress * math.pi * 4 + angle) * 0.001;
    
    // Wraps around boundaries
    if (y < -0.1) y = 1.1;
    if (x < -0.1) x = 1.1;
    if (x > 1.1) x = -0.1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (var p in particles) {
      p.update(progress);
      paint.color = color.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
