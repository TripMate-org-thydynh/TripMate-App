import 'package:flutter/material.dart';

class PaymentMethodManagerScreen extends StatefulWidget {
  const PaymentMethodManagerScreen({super.key});

  @override
  State<PaymentMethodManagerScreen> createState() => _PaymentMethodManagerScreenState();
}

class _PaymentMethodManagerScreenState extends State<PaymentMethodManagerScreen> {
  final List<Map<String, dynamic>> _savedCards = [
    {
      'id': 'card-1',
      'type': 'VISA',
      'lastFour': '4242',
      'expiry': '12/28',
      'cardHolder': 'NGUYEN VAN A',
      'color': const Color(0xFF1E293B),
    },
    {
      'id': 'card-2',
      'type': 'MASTERCARD',
      'lastFour': '8890',
      'expiry': '05/29',
      'cardHolder': 'NGUYEN VAN A',
      'color': const Color(0xFF8B5CF6),
    },
  ];

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  bool _isAddingCard = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty ||
        _cardHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ các thông số bảo mật của thẻ')),
      );
      return;
    }
    setState(() {
      _savedCards.add({
        'id': 'card-${DateTime.now().millisecondsSinceEpoch}',
        'type': _cardNumberController.text.startsWith('4') ? 'VISA' : 'MASTERCARD',
        'lastFour': _cardNumberController.text.substring(_cardNumberController.text.length - 4),
        'expiry': _expiryController.text,
        'cardHolder': _cardHolderController.text.toUpperCase(),
        'color': const Color(0xFFEC4899),
      });
      _isAddingCard = false;
      _cardNumberController.clear();
      _expiryController.clear();
      _cvvController.clear();
      _cardHolderController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Đã liên kết thẻ tín dụng mới thành công!'),
        backgroundColor: Colors.purple,
      ),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Quản Lý Thẻ Thanh Toán 💳',
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
            if (!_isAddingCard) ...[
              // LIST OF SAVED CREDIT CARDS
              Text(
                'Thẻ Đã Liên Kết',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedCards.length,
                itemBuilder: (context, index) {
                  final card = _savedCards[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: card['color'] as Color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                card['type'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Icon(Icons.nfc, color: Colors.white70),
                            ],
                          ),
                          Text(
                            '**** **** **** ${card['lastFour']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                card['cardHolder'] as String,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                card['expiry'] as String,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingCard = true;
                    });
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
                      Icon(Icons.add_card),
                      SizedBox(width: 8),
                      Text('Thêm Thẻ Tín Dụng Mới', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ADD CREDIT CARD ENTRY FORM
              Text(
                'Nhập Thông Tin Thẻ 💳',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _cardNumberController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(
                          labelText: 'Số thẻ (16 chữ số)',
                          hintText: '4242 4242 4242 4242',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _expiryController,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                              decoration: const InputDecoration(
                                labelText: 'Hạn dùng (MM/YY)',
                                hintText: '12/28',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                              decoration: const InputDecoration(
                                labelText: 'CVV / CVC',
                                hintText: '123',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _cardHolderController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(
                          labelText: 'Tên chủ thẻ',
                          hintText: 'NGUYEN VAN A',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Lưu thẻ bảo mật', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isAddingCard = false;
                    });
                  },
                  child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
