import 'package:flutter/material.dart';

class DebtSimplificationScreen extends StatefulWidget {
  const DebtSimplificationScreen({super.key});

  @override
  State<DebtSimplificationScreen> createState() => _DebtSimplificationScreenState();
}

class _DebtSimplificationScreenState extends State<DebtSimplificationScreen> {
  bool _useSimplification = true;

  final List<Map<String, dynamic>> _rawDebts = [
    {'from': 'Trần Bình', 'to': 'Alex Nguyễn', 'amount': 150000.0},
    {'from': 'Lê Minh', 'to': 'Trần Bình', 'amount': 200000.0},
    {'from': 'Hoàng Yến', 'to': 'Alex Nguyễn', 'amount': 120000.0},
    {'from': 'Bảo Trân', 'to': 'Lê Minh', 'amount': 300000.0},
    {'from': 'Bảo Trân', 'to': 'Alex Nguyễn', 'amount': 50000.0},
  ];

  final List<Map<String, dynamic>> _simplifiedDebts = [
    {'from': 'Trần Bình', 'to': 'Alex Nguyễn', 'amount': 150000.0},
    {'from': 'Lê Minh', 'to': 'Alex Nguyễn', 'amount': 250000.0},
    {'from': 'Bảo Trân', 'to': 'Alex Nguyễn', 'amount': 350000.0},
    {'from': 'Hoàng Yến', 'to': 'Alex Nguyễn', 'amount': 120000.0},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final debtsToShow = _useSimplification ? _simplifiedDebts : _rawDebts;

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
          'Tối Ưu Hóa Nợ Nhóm 🕸️',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.pinkAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI DEBT SIMPLIFIER ⚡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Thuật toán đồ thị thông minh tự động rút gọn số giao dịch thừa để thanh toán nhanh gọn nhất.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Toggle switch between simplified and raw
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bật bộ lọc tối ưu hóa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Switch(
                  value: _useSimplification,
                  activeTrackColor: Colors.purpleAccent,
                  onChanged: (val) {
                    setState(() {
                      _useSimplification = val;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Graph representation visualizer panel
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.2)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Nodes paths background lines
                  CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: GraphLinesPainter(isDark: isDark),
                  ),

                  // Simplified visual nodes representing trip squad members
                  Positioned(
                    top: 20,
                    left: 40,
                    child: _buildNode('Trần Bình', 'assets/images/binh.png', isDark),
                  ),
                  Positioned(
                    top: 20,
                    right: 40,
                    child: _buildNode('Lê Minh', 'assets/images/minh.png', isDark),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 30,
                    child: _buildNode('Hoàng Yến', 'assets/images/yen.png', isDark),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 30,
                    child: _buildNode('Bảo Trân', 'assets/images/tran.png', isDark),
                  ),
                  Positioned(
                    top: 80,
                    child: _buildCenterNode('Alex Nguyễn', 'assets/images/alex.png'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Debt list breakdown
            Text(
              'Các giao dịch cần thực hiện (${debtsToShow.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: debtsToShow.length,
              itemBuilder: (context, index) {
                final debt = debtsToShow[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      debt['from'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Người trả',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(Icons.arrow_forward, color: Colors.purpleAccent, size: 20),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      debt['to'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Người nhận',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(debt['amount'] as double).toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Chuyển khoản qua MoMo liên kết siêu nhanh!'),
                                      backgroundColor: Colors.purple,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Trả Ngay 💸',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purpleAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(String name, String image, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.purpleAccent, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.person, color: Colors.purpleAccent, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name.split(' ').last,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterNode(String name, String image) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.pinkAccent, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withValues(alpha: 0.3),
                blurRadius: 10,
              )
            ],
          ),
          child: const Center(
            child: Icon(Icons.star, color: Colors.pinkAccent, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name.split(' ').last,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ],
    );
  }
}

class GraphLinesPainter extends CustomPainter {
  final bool isDark;

  GraphLinesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.purple[800]!.withValues(alpha: 0.4) : Colors.purple[200]!.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    // Draw lines connecting outer nodes to central hub node
    canvas.drawLine(const Offset(60, 40), center, paint);
    canvas.drawLine(Offset(size.width - 60, 40), center, paint);
    canvas.drawLine(Offset(50, size.height - 40), center, paint);
    canvas.drawLine(Offset(size.width - 50, size.height - 40), center, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
