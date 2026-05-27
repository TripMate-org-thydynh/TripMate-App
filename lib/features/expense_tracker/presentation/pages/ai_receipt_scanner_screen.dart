import 'package:flutter/material.dart';

class AiReceiptScannerScreen extends StatefulWidget {
  const AiReceiptScannerScreen({super.key});

  @override
  State<AiReceiptScannerScreen> createState() => _AiReceiptScannerScreenState();
}

class _AiReceiptScannerScreenState extends State<AiReceiptScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;

  bool _isScanning = true;
  bool _showItems = false;

  final List<Map<String, dynamic>> _detectedItems = [
    {'name': 'Lẩu gà lá é lớn', 'price': 350000.0, 'checked': true},
    {'name': 'Nước ngọt lon', 'price': 60000.0, 'checked': true},
    {'name': 'Mì gói thêm', 'price': 20000.0, 'checked': false},
    {'name': 'Khăn lạnh', 'price': 10000.0, 'checked': false},
  ];

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    // Mock completing scan in 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _showItems = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
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
          'Quét Hóa Đơn AI 📸',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // SCANNING VIEWPORT
          if (_isScanning)
            Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.purpleAccent, width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Mock receipt background
                        Opacity(
                          opacity: 0.4,
                          child: Center(
                            child: Icon(
                              Icons.receipt_long,
                              size: 150,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),

                        // Animated scanning line
                        AnimatedBuilder(
                          animation: _scannerAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _scannerAnimation.value * 280 + 40,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.purpleAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purpleAccent.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Status loading text
                        Positioned(
                          bottom: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'AI đang quét các món...',
                                  style: TextStyle(
                                    color: Colors.purpleAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Đặt hóa đơn ngay ngắn trong khung hình để AI đọc chính xác giá trị và tên món ăn nhé cưng!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),

          // DETECTED ITEMS SHEET
          if (_showItems)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI đã quét xong! Tỉ lệ chính xác 96%. Vui lòng tích chọn những món cưng đã xơi để tính tiền.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Receipt details
                  Text(
                    'Lẩu gà lá é Tao Ngộ 🍜',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Ngày quét: Hôm nay • Kyoto-Dalat Trip',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Item breakdown checkboxes
                  Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _detectedItems.length,
                            itemBuilder: (context, index) {
                              final item = _detectedItems[index];
                              return CheckboxListTile(
                                activeColor: primaryColor,
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text(
                                  item['name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  '${(item['price'] as double).toStringAsFixed(0)} đ',
                                  style: const TextStyle(
                                    color: Colors.purpleAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                value: item['checked'] as bool,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _detectedItems[index]['checked'] = value ?? false;
                                  });
                                },
                              );
                            },
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Phần cưng cần trả:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${_calculateTotalSelected().toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Split button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã lưu hóa đơn quét bằng AI! Phần của cưng là ${_calculateTotalSelected().toStringAsFixed(0)} đ',
                            ),
                            backgroundColor: Colors.purple,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Xác nhận phần chia của tôi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  double _calculateTotalSelected() {
    double sum = 0.0;
    for (var item in _detectedItems) {
      if (item['checked'] as bool) {
        sum += item['price'] as double;
      }
    }
    return sum;
  }
}
