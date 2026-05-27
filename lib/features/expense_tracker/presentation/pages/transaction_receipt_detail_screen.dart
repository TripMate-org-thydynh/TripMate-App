import 'package:flutter/material.dart';

class TransactionReceiptDetailScreen extends StatelessWidget {
  final String title;
  final String amount;
  final bool isIncome;

  const TransactionReceiptDetailScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.isIncome,
  });

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chi Tiết Hóa Đơn 🧾',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Floating digital ticket shape card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'May 26, 2026 • 19:42',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Giao dịch hoàn tất ✅',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),

                  // Ticket detailed item lines
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHI TIẾT MÓN ĂN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildReceiptItemRow('Lẩu gà lá é lớn', '1x', '350.000 đ', isDark),
                        const SizedBox(height: 12),
                        _buildReceiptItemRow('Nước ngọt lon', '4x', '60.000 đ', isDark),
                        const SizedBox(height: 12),
                        _buildReceiptItemRow('Mì gói thêm', '2x', '20.000 đ', isDark),
                        const SizedBox(height: 12),
                        _buildReceiptItemRow('Khăn lạnh', '4x', '10.000 đ', isDark),
                        const Divider(height: 32),
                        _buildReceiptSummaryRow('Tạm tính:', '440.000 đ', isDark),
                        const SizedBox(height: 8),
                        _buildReceiptSummaryRow('Thuế VAT (10%):', '44.000 đ', isDark),
                        const SizedBox(height: 8),
                        _buildReceiptSummaryRow('Phí dịch vụ:', '0 đ', isDark),
                        const SizedBox(height: 16),
                        _buildReceiptSummaryRow('Tổng số tiền:', '484.000 đ', isDark, isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Share PDF Receipt & Report problem buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Đã xuất hóa đơn PDF thành công về máy cưng!'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_outlined),
                    SizedBox(width: 8),
                    Text('Tải Hóa Đơn PDF Chi Tiết', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptItemRow(String name, String qty, String price, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          qty,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        const SizedBox(width: 24),
        Text(
          price,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildReceiptSummaryRow(String title, String val, bool isDark, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? Colors.purpleAccent : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
