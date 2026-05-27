import 'package:flutter/material.dart';
import 'linked_bank_accounts_screen.dart';
import 'payment_method_manager_screen.dart';
import 'transaction_receipt_detail_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
          'Ví Của Tôi 💳',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glassmorphic Visa/MasterCard Template
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    blurRadius: 20,
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
                        'TripMate Premium Card',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.nfc_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '**** **** **** 4242',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hạn mức thanh toán: Vô hạn 🚀',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NGUYEN VAN A',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '12/28',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Balances Row (Momo, ZaloPay, Cash)
            Row(
              children: [
                Expanded(
                  child: _buildBalanceCard('Momo Wallet 📱', '2.500.000 đ', isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBalanceCard('ZaloPay 💸', '1.200.000 đ', isDark),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Wallet Actions Hub
            Text(
              'Quản Lý Ví ⚙️',
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
                  child: _buildActionBtn(
                    context,
                    Icons.account_balance_outlined,
                    'Liên kết ngân hàng',
                    isDark,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LinkedBankAccountsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    Icons.credit_card_outlined,
                    'Quản lý thẻ',
                    isDark,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodManagerScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Recent digital receipts
            Text(
              'Lịch Sử Giao Dịch Gần Đây 🕒',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildTransactionItem(
              context,
              'Lẩu gà lá é Tao Ngộ',
              'Ăn uống • May 26, 2026',
              '- 484.000 đ',
              Colors.amber,
              isDark,
            ),
            _buildTransactionItem(
              context,
              'Vé tàu cao tốc Shinkansen',
              'Di chuyển • May 25, 2026',
              '- 1.200.000 đ',
              Colors.cyan,
              isDark,
            ),
            _buildTransactionItem(
              context,
              'Nạp tiền ví Momo',
              'Nạp tiền • May 24, 2026',
              '+ 2.000.000 đ',
              Colors.green,
              isDark,
              isIncome: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String balance, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purpleAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String sub,
    String amount,
    Color catColor,
    bool isDark, {
    bool isIncome = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: () {
            // Push to transaction digital receipt breakdown
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionReceiptDetailScreen(
                  title: title,
                  amount: amount,
                  isIncome: isIncome,
                ),
              ),
            );
          },
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.add_circle_outline : Icons.receipt_long_outlined,
              color: catColor,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(sub),
          trailing: Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.purpleAccent,
            ),
          ),
        ),
      ),
    );
  }
}
