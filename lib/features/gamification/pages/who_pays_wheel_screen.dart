import 'dart:math';
import 'package:flutter/material.dart';

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
    {'name': 'Alex Nguyễn', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex'},
    {'name': 'Minh Nhật', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nhat'},
    {'name': 'Trần Bình', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Binh'},
    {'name': 'Lê Minh', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Minh'},
    {'name': 'Hoàng Yến', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Yen'},
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
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🔥 CHAOS PAYER DETECTED 🔥',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  child: Image.network(winner['avatar']!),
                ),
                const SizedBox(height: 16),
                Text(
                  winner['name']!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thần tài hỗn loạn đã gõ đầu cưng! Ngoài việc phải bao trọn hóa đơn này, cưng còn phải thực hiện một thử thách Dare ngẫu nhiên tiếp theo! 💀💸',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Chấp nhận số phận 💸', style: TextStyle(fontWeight: FontWeight.bold)),
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Who Pays — Chaos Mode 🎡', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VÒNG QUAY HỖN LOẠN ⚡',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Colors.redAccent, Colors.purpleAccent],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Chế độ tăng cực mạnh chỉ số hỗn loạn của cả Squad!'),
              const SizedBox(height: 40),

              // Animated Wheel
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.redAccent, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinAnimation.value,
                        child: CustomPaint(
                          size: const Size(300, 300),
                          painter: ChaosWheelPainter(participants: _participants),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: _spin,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'SPIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class ChaosWheelPainter extends CustomPainter {
  final List<Map<String, String>> participants;

  ChaosWheelPainter({required this.participants});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    final sectorAngle = (2 * pi) / participants.length;

    final colors = [
      Colors.redAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.deepOrangeAccent,
    ];

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

      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: participants[i]['name']!.split(' ').last,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      );
      tp.layout();

      final angle = i * sectorAngle + (sectorAngle / 2);
      canvas.save();
      canvas.translate(
        center.dx + cos(angle) * (radius * 0.65),
        center.dy + sin(angle) * (radius * 0.65),
      );
      canvas.rotate(angle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
