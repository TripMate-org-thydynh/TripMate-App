import 'package:flutter/material.dart';

class LinkedBankAccountsScreen extends StatefulWidget {
  const LinkedBankAccountsScreen({super.key});

  @override
  State<LinkedBankAccountsScreen> createState() => _LinkedBankAccountsScreenState();
}

class _LinkedBankAccountsScreenState extends State<LinkedBankAccountsScreen> {
  final List<Map<String, String>> _availableBanks = [
    {'name': 'Vietcombank', 'code': 'VCB', 'desc': 'Ngân hàng Ngoại thương Việt Nam'},
    {'name': 'Techcombank', 'code': 'TCB', 'desc': 'Ngân hàng Kỹ thương Việt Nam'},
    {'name': 'MB Bank', 'code': 'MBB', 'desc': 'Ngân hàng Quân đội'},
    {'name': 'BIDV', 'code': 'BIDV', 'desc': 'Ngân hàng Đầu tư và Phát triển'},
    {'name': 'ACB', 'code': 'ACB', 'desc': 'Ngân hàng Á Châu'},
    {'name': 'Momo Wallet', 'code': 'MOMO', 'desc': 'Ví điện tử MoMo'},
  ];

  String _searchQuery = '';
  String? _selectedBank;
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtpVerification = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _triggerLinkBank() {
    if (_accountNumberController.text.isEmpty || _accountHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin tài khoản')),
      );
      return;
    }
    setState(() {
      _showOtpVerification = true;
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP không hợp lệ')),
      );
      return;
    }
    // Success linkage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Đã liên kết thành công tài khoản $_selectedBank!'),
        backgroundColor: Colors.purple,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredBanks = _availableBanks.where((bank) {
      return bank['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bank['code']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
          'Liên Kết Ngân Hàng 🏦',
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
            if (!_showOtpVerification && _selectedBank == null) ...[
              Text(
                'Chọn Ngân Hàng Hoặc Ví Điện Tử',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // Search input
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Tìm tên ngân hàng, ví dụ: VCB, MB...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Bank list selection cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBanks.length,
                itemBuilder: (context, index) {
                  final bank = filteredBanks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedBank = bank['name'];
                          });
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.withValues(alpha: 0.1),
                          child: Text(
                            bank['code']!,
                            style: const TextStyle(
                              color: Colors.purpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          bank['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(bank['desc']!),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ),
                  );
                },
              ),
            ] else if (!_showOtpVerification && _selectedBank != null) ...[
              // BANK INFORMATION DETAILS SHEET
              Row(
                children: [
                  const Icon(Icons.account_balance, color: Colors.purpleAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Liên kết tài khoản $_selectedBank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
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
                        controller: _accountNumberController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(
                          labelText: 'Số tài khoản / Số thẻ',
                          hintText: 'Nhập số tài khoản ngân hàng',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _accountHolderController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(
                          labelText: 'Tên chủ tài khoản',
                          hintText: 'VIET IN INHOA CHU',
                          prefixIcon: Icon(Icons.person),
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
                  onPressed: _triggerLinkBank,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Liên kết ngân hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBank = null;
                    });
                  },
                  child: const Text('Chọn ngân hàng khác', style: TextStyle(color: Colors.purpleAccent)),
                ),
              ),
            ] else ...[
              // OTP MFA SMS SHEET OVERLAY
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.sms_failed_outlined, color: Colors.purpleAccent, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Xác thực mã OTP 🔐',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Một mã OTP bảo mật gồm 6 chữ số đã được gửi qua số điện thoại đăng ký của cưng. Nhập mã để hoàn tất.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _otpController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '******',
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Xác nhận & Liên kết', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
