import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhoPaysWheelScreen extends StatefulWidget {
  const WhoPaysWheelScreen({super.key});

  @override
  State<WhoPaysWheelScreen> createState() => _WhoPaysWheelScreenState();
}

class _WhoPaysWheelScreenState extends State<WhoPaysWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final List<Map<String, String>> _participants = [
    {'name': 'Minh Nhật', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nhat'},
    {'name': 'Thảo Ly', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ly'},
    {'name': 'Nam Trung', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Trung'},
    {'name': 'Duy Khang', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Khang'},
  ];

  int _winnerIndex = -1;
  bool _isSpinning = false;
  double _startRotation = 0.0;
  double _endRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _spinAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_spinController);

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          final finalAngle = _endRotation % (2 * pi);
          final sectorAngle = (2 * pi) / _participants.length;
          final alignedAngle = (5 * pi / 2 - finalAngle) % (2 * pi);
          _winnerIndex = ((alignedAngle / sectorAngle).floor()) % _participants.length;
        });
        _showChaosPayerDialog();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _winnerIndex = -1;
      _startRotation = _endRotation % (2 * pi);
      final random = Random();
      final extraSpins = 5 + random.nextInt(4);
      final targetAngle = random.nextDouble() * 2 * pi;
      _endRotation = _startRotation + (extraSpins * 2 * pi) + targetAngle;

      _spinAnimation = Tween<double>(
        begin: _startRotation,
        end: _endRotation,
      ).animate(CurvedAnimation(
        parent: _spinController,
        curve: Curves.decelerate,
      ));
    });

    _spinController.reset();
    _spinController.forward();
  }

  void _showChaosPayerDialog() {
    final winner = _participants[_winnerIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF171F33) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFEF4444),
                width: 2.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔥 CHAOS PAYER 🔥',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFEF4444),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEF4444), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        blurRadius: 15,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    backgroundImage: NetworkImage(winner['avatar']!),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  winner['name']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thần tài hỗn loạn đã gõ đầu cưng! Ngoài việc phải bao trọn hóa đơn này, cưng còn phải thực hiện một thử thách Dare ngẫu nhiên tiếp theo! 💀💸',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Chấp nhận số phận 💸',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Standard Palette colors
    final Color bgColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final Color primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final Color surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;
    final Color textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
    final Color textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B1326),
                    Color(0xFF131B2E),
                    Color(0xFF060E20),
                  ],
                ),
              )
            : null,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  // Top Navigation Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: textPrimary),
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor.withValues(alpha: isDark ? 0.3 : 0.8),
                          shape: const CircleBorder(),
                        ),
                      ),
                      Text(
                        'trip.mate',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add_reaction_outlined, color: primaryColor),
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor.withValues(alpha: isDark ? 0.3 : 0.8),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Flashing Alert Pill
                  const FlashingPill(),
                  const SizedBox(height: 16),

                  // Title Text
                  Text(
                    'Who Pays?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chế độ tăng cực mạnh chỉ số hỗn loạn của cả Squad!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Spinning Wheel Widget Stack with comical floaty bubbles
                  SizedBox(
                    width: 360,
                    height: 360,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Left bubble: please not me
                        FloatingBubble(
                          text: "please not me 😭",
                          top: -12,
                          left: -16,
                          textColor: const Color(0xFFFB923C),
                          isDark: isDark,
                        ),
                        // Right bubble: my wallet is empty
                        FloatingBubble(
                          text: "my wallet is empty 💸",
                          top: 160,
                          right: -32,
                          textColor: const Color(0xFF34D399),
                          isDark: isDark,
                        ),
                        // Wheel glowing outer border container
                        Container(
                          width: 312,
                          height: 312,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                                  : const Color(0xFFE0533C).withValues(alpha: 0.3),
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C))
                                    .withValues(alpha: 0.15),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                        // The Spinning Wheel
                        GestureDetector(
                          onTap: _spin,
                          child: AnimatedBuilder(
                            animation: _spinAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _spinAnimation.value,
                                child: CustomPaint(
                                  size: const Size(300, 300),
                                  painter: ChaosWheelPainter(
                                    participants: _participants,
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Wheel Center Hub with Dice icon
                        GestureDetector(
                          onTap: _spin,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                    : [Colors.white, const Color(0xFFE2E8F0)],
                              ),
                              border: Border.all(
                                color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? const Color(0xFF8B5CF6)
                                          : const Color(0xFFE0533C))
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.casino,
                                color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        // Top pointer indicator
                        Positioned(
                          top: -12,
                          child: Icon(
                            Icons.arrow_drop_down_sharp,
                            color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Bottom Gradient "casino SPIN TO DECIDE" button
                  GestureDetector(
                    onTap: _spin,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            isDark ? const Color(0xFFEC4899) : const Color(0xFFFBA83A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.casino,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SPIN TO DECIDE',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
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
  }
}

class ChaosWheelPainter extends CustomPainter {
  final List<Map<String, String>> participants;
  final bool isDark;

  ChaosWheelPainter({required this.participants, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    final sectorAngle = (2 * pi) / participants.length;

    final darkColors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF34D399), // Mint Green
      const Color(0xFFFB923C), // Orange
      const Color(0xFFEF4444), // Red
    ];

    final lightColors = [
      const Color(0xFFE0533C), // Coral
      const Color(0xFFEBA83A), // Amber
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
    ];

    final colors = isDark ? darkColors : lightColors;

    for (int i = 0; i < participants.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sectorAngle,
        sectorAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sectorAngle,
        sectorAngle,
        true,
        borderPaint,
      );

      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: participants[i]['name']!,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 1),
              blurRadius: 3,
            )
          ],
        ),
      );
      tp.layout();

      final angle = i * sectorAngle + (sectorAngle / 2);
      canvas.save();
      canvas.translate(
        center.dx + cos(angle) * (radius * 0.58),
        center.dy + sin(angle) * (radius * 0.58),
      );
      canvas.rotate(angle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlashingPill extends StatefulWidget {
  const FlashingPill({super.key});

  @override
  State<FlashingPill> createState() => _FlashingPillState();
}

class _FlashingPillState extends State<FlashingPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: _opacityAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: _opacityAnimation.value * 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Chaos Mode Active ⚠️',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFEF4444),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FloatingBubble extends StatefulWidget {
  final String text;
  final double top;
  final double? left;
  final double? right;
  final double? bottom;
  final Color textColor;
  final bool isDark;

  const FloatingBubble({
    super.key,
    required this.text,
    required this.top,
    this.left,
    this.right,
    this.bottom,
    required this.textColor,
    required this.isDark,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF171F33).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            widget.text,
            style: GoogleFonts.inter(
              color: widget.textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
