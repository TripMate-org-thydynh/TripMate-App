import 'package:flutter/material.dart';
import 'expense_splitter_social_screen.dart';

class LogDamageScreen extends StatefulWidget {
  const LogDamageScreen({super.key});

  @override
  State<LogDamageScreen> createState() => _LogDamageScreenState();
}

class _LogDamageScreenState extends State<LogDamageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '350000');
  final _descriptionController = TextEditingController(text: 'Lẩu gà lá é ăn tối');

  String _selectedCategory = 'FOOD';
  String _selectedSplitType = 'EQUAL'; // EQUAL, EXACT, PERCENTAGE

  final List<Map<String, dynamic>> _categories = [
    {'name': 'FOOD', 'label': 'Ăn uống 🍜', 'icon': Icons.restaurant_menu_outlined, 'color': Color(0xFFEBA83A)},
    {'name': 'ACCOMMODATION', 'label': 'Nơi ở 🏠', 'icon': Icons.home_work_outlined, 'color': Color(0xFF8B5CF6)},
    {'name': 'TRANSPORT', 'label': 'Di chuyển 🚗', 'icon': Icons.train_outlined, 'color': Color(0xFF06B6D4)},
    {'name': 'ACTIVITIES', 'label': 'Hoạt động 🎢', 'icon': Icons.local_activity_outlined, 'color': Color(0xFFE0533C)},
    {'name': 'OTHER', 'label': 'Khác 🛍️', 'icon': Icons.category_outlined, 'color': Color(0xFF94A3B8)},
  ];

  final List<Map<String, dynamic>> _members = [
    {'id': '1', 'name': 'Alex Nguyễn', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex', 'share': 1, 'amount': 0.0},
    {'id': '2', 'name': 'Trần Bình', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Binh', 'share': 1, 'amount': 0.0},
    {'id': '3', 'name': 'Lê Minh', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Minh', 'share': 1, 'amount': 0.0},
    {'id': '4', 'name': 'Hoàng Yến', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Yen', 'share': 1, 'amount': 0.0},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _calculateSplits() {
    final double total = double.tryParse(_amountController.text) ?? 0.0;
    if (_selectedSplitType == 'EQUAL') {
      final perPerson = total / _members.length;
      for (var member in _members) {
        member['amount'] = perPerson;
        member['share'] = 1;
      }
    } else if (_selectedSplitType == 'EXACT') {
      // Manual/exact split logic setup, we distribute unequally
      _members[0]['amount'] = total * 0.4;
      _members[1]['amount'] = total * 0.2;
      _members[2]['amount'] = total * 0.2;
      _members[3]['amount'] = total * 0.2;
    } else if (_selectedSplitType == 'PERCENTAGE') {
      _members[0]['amount'] = total * 0.5; // 50%
      _members[1]['amount'] = total * 0.2; // 20%
      _members[2]['amount'] = total * 0.2; // 20%
      _members[3]['amount'] = total * 0.1; // 10%
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateSplits();
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
          'Ghi Nhận Thiệt Hại 💸',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input Card
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Tổng số tiền hại ví',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                              ),
                              onChanged: (val) {
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'đ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Mô tả thiệt hại (ví dụ: Lẩu gà ngon lành...)',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                          prefixIcon: const Icon(Icons.description, color: Colors.purpleAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Categories Selector
              Text(
                'Danh Mục 🏷️',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat['name'];
                          });
                        },
                        child: Container(
                          width: 90,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (cat['color'] as Color).withValues(alpha: 0.2)
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? (cat['color'] as Color) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                color: isSelected ? (cat['color'] as Color) : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                child: Text(
                                  cat['label'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Split Type Selector
              Text(
                'Phương thức chia tiền 🍕',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSplitTypePill('Chia đều', 'EQUAL', isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSplitTypePill('Số lẻ', 'EXACT', isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSplitTypePill('Phần trăm', 'PERCENTAGE', isDark),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Split Breakdown
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi tiết phần chia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                                  child: Image.network(member['avatar']!),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    member['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(member['amount'] as double).toStringAsFixed(0)} đ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.purpleAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Log success and pop
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Ghi nhận hóa đơn thành công! Tình anh em bền vững!'),
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
                    'Đăng Hóa Đơn & Chia Nợ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to social picker
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ExpenseSplitterSocialScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.purpleAccent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gamepad_outlined, color: Colors.purpleAccent),
                      const SizedBox(width: 8),
                      const Text(
                        'Dùng Game Vòng Quay Chọn Người Trả',
                        style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSplitTypePill(String label, String value, bool isDark) {
    final isSelected = _selectedSplitType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSplitType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.purple : (isDark ? Colors.grey[800]! : Colors.grey[350]!),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
        ),
      ),
    );
  }
}
