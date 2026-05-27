import 'package:flutter/material.dart';

class PaymentSuccessFriendshipScreen extends StatelessWidget {
  final double amountPaid;
  final String paidTo;

  const PaymentSuccessFriendshipScreen({
    super.key,
    this.amountPaid = 120000.0,
    this.paidTo = 'Alex Nguyễn',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Checked confetti success box
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Main success ring
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Thanh Toán Thành Công! 🎉',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nợ nần đã được giải quyết êm đẹp!',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 36),

              // Friendship Restored Stats Card
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'CHỈ SỐ TÌNH BẠN 💖',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent[100],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Circular friendship indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey[800]?.withValues(alpha: 0.1) ?? Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                            ),
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '100%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                'Khăng khít',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Chúc mừng cưng và $paidTo đã hoàn toàn làm hòa! Tình hữu nghị được bảo toàn tuyệt đối, không một vết rạn nứt! 🥰🍕',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Transaction Summary Details Box
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildSummaryRow('Người nhận:', paidTo, isDark),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Số tiền thanh toán:',
                        '${amountPaid.toStringAsFixed(0)} đ',
                        isDark,
                        isHighlight: true,
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow('Phương thức:', 'Ví MoMo 📱', isDark),
                      const Divider(height: 24),
                      _buildSummaryRow('Mã giao dịch:', 'MOMO_884920482', isDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Button to close and return
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
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
                    'Tuyệt vời! Quay lại chuyến đi',
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
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? Colors.purpleAccent
                : (isDark ? Colors.white : Colors.black87),
            fontSize: isHighlight ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
