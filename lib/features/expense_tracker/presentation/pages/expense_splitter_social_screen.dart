import 'dart:math';
import 'package:flutter/material.dart';

class ExpenseSplitterSocialScreen extends StatefulWidget {
  const ExpenseSplitterSocialScreen({super.key});

  @override
  State<ExpenseSplitterSocialScreen> createState() => _ExpenseSplitterSocialScreenState();
}

class _ExpenseSplitterSocialScreenState extends State<ExpenseSplitterSocialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final List<Map<String, String>> _members = [
    {'name': 'Alex Nguyễn', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex'},
    {'name': 'Trần Bình', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Binh'},
    {'name': 'Lê Minh', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Minh'},
    {'name': 'Hoàng Yến', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Yen'},
    {'name': 'Bảo Trân', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Tran'},
  ];

  int _selectedWinnerIndex = -1;
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

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.decelerate,
    );

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          // Calculate which sector the spinner pointer points to (top is 270 degrees / 1.5 * pi)
          final finalAngle = (_endRotation) % (2 * pi);
          final sectorAngle = (2 * pi) / _members.length;
          // Offset to align pointer pointing at top (12 o'clock)
          final alignedAngle = (5 * pi / 2 - finalAngle) % (2 * pi);
          _selectedWinnerIndex = ((alignedAngle / sectorAngle).floor()) % _members.length;
        });

        _showWinnerDialog();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedWinnerIndex = -1;
      _startRotation = _endRotation % (2 * pi);
      // Spin between 4 to 8 full rotations + extra random angle
      final random = Random();
      final extraSpins = 4 + random.nextInt(4);
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

  void _showWinnerDialog() {
    final winner = _members[_selectedWinnerIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 THẦN TÀI GÕ ĐẦU 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                  child: Image.network(
                    winner['avatar']!,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 50, color: Colors.purple),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  winner['name']!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chúc mừng cưng đã trúng giải độc đắc thanh toán toàn bộ hóa đơn này! Đừng khóc nhé, tình bạn sẽ khăng khít hơn bao giờ hết! 😉💸',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(winner);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Đồng ý chi tiền',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
    final primaryColor = Colors.purple;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Roulette Chọn Người Trả',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'AI Squad Splitter — Game Edition 🎯',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.pinkAccent, Colors.orangeAccent],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Không ai muốn trả tiền? Hãy để vòng quay nhân phẩm định đoạt số phận của hóa đơn này!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Spinning Wheel Visualizer
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glowing ring
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.pinkAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Animated wheel rotation
                  AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinAnimation.value,
                        child: CustomPaint(
                          size: const Size(300, 300),
                          painter: WheelPainter(
                            members: _members,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                  ),

                  // Center Spin Button Hub
                  GestureDetector(
                    onTap: _spinWheel,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.purpleAccent,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _isSpinning ? 'SPIN...' : 'SPIN!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pointer Arrow pointing down from Top
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Participant list preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.purpleAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Danh sách nạn nhân',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final item = _members[index];
                          final isSelected = _selectedWinnerIndex == index;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.purple.withValues(alpha: 0.1),
                              child: Image.network(item['avatar']!),
                            ),
                            title: Text(
                              item['name']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.purpleAccent : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.stars, color: Colors.amber)
                                : null,
                          );
                        },
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
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, String>> members;
  final bool isDark;

  WheelPainter({required this.members, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double sectorAngle = (2 * pi) / members.length;

    final List<Color> colors = [
      Colors.purple[400]!,
      Colors.pink[400]!,
      Colors.teal[400]!,
      Colors.amber[600]!,
      Colors.cyan[400]!,
      Colors.indigo[400]!,
    ];

    for (int i = 0; i < members.length; i++) {
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

      // Draw member names inside the sector
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      final String name = members[i]['name']!.split(' ').last;
      textPainter.text = TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();

      // Calculate placement angle in the center of the sector
      final double textAngle = i * sectorAngle + (sectorAngle / 2);
      canvas.save();
      canvas.translate(
        center.dx + cos(textAngle) * (radius * 0.6),
        center.dy + sin(textAngle) * (radius * 0.6),
      );
      // Rotate text outward
      canvas.rotate(textAngle);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
