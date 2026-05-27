import 'package:flutter/material.dart';

class BudgetGoalScreen extends StatefulWidget {
  const BudgetGoalScreen({super.key});

  @override
  State<BudgetGoalScreen> createState() => _BudgetGoalScreenState();
}

class _BudgetGoalScreenState extends State<BudgetGoalScreen> {
  double _budgetLimit = 15000000.0;
  double _warningThreshold = 80.0;

  final List<Map<String, dynamic>> _categoryLimits = [
    {'category': 'Stays', 'label': 'Lưu trú 🏠', 'amount': 5000000.0},
    {'category': 'Food & Drinks', 'label': 'Ăn uống 🍜', 'amount': 4000000.0},
    {'category': 'Transport', 'label': 'Di chuyển 🚗', 'amount': 3000000.0},
    {'category': 'Entertainment', 'label': 'Giải trí 🎢', 'amount': 2000000.0},
  ];

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
          'Hạn Mức Ngân Sách 🎯',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current budget limits card
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TỔNG HẠN MỨC SQUAD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_budgetLimit.toStringAsFixed(0)} đ',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Slider to change budget
                    Text(
                      'Điều chỉnh hạn mức:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[300] : Colors.grey[750],
                      ),
                    ),
                    Slider(
                      value: _budgetLimit,
                      min: 5000000.0,
                      max: 50000000.0,
                      divisions: 9,
                      activeColor: Colors.purpleAccent,
                      label: '${(_budgetLimit / 1000000).toStringAsFixed(0)} triệu',
                      onChanged: (val) {
                        setState(() {
                          _budgetLimit = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Warning Threshold settings
            Text(
              'Cảnh Báo Vượt Hạn Mức ⚠️',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cảnh báo khi đạt:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${_warningThreshold.toInt()}% ngân sách',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _warningThreshold,
                      min: 50.0,
                      max: 95.0,
                      divisions: 9,
                      activeColor: Colors.purpleAccent,
                      label: '${_warningThreshold.toInt()}%',
                      onChanged: (val) {
                        setState(() {
                          _warningThreshold = val;
                        });
                      },
                    ),
                    Text(
                      'AI sẽ gửi thông báo khẩn cấp cho cả Squad khi tổng chi tiêu vượt quá cột mốc này để tránh cháy túi cả lũ! 🔥',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Category Limiters
            Text(
              'Hạn Mức Từng Danh Mục 🏷',
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
              itemCount: _categoryLimits.length,
              itemBuilder: (context, index) {
                final cat = _categoryLimits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cat['label'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '${(cat['amount'] as double).toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, size: 16, color: Colors.purpleAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Save changes button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Đã cập nhật hạn mức và cảnh báo ngân sách thành công!'),
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
                ),
                child: const Text('Lưu Thiết Lập Ngân Sách', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
