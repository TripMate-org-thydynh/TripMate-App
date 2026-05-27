import 'package:flutter/material.dart';
import 'pages/ai_receipt_scanner_screen.dart';
import 'pages/budget_analytics_screen.dart';
import 'pages/budget_goal_screen.dart';
import 'pages/debt_simplification_screen.dart';
import 'pages/expense_splitter_social_screen.dart';
import 'pages/log_damage_screen.dart';
import 'pages/wallet_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final double _totalBudget = 15000000.0;
  final double _totalSpent = 9485000.0;

  final List<Map<String, dynamic>> _expenses = [
    {
      'title': 'Ryokan Booking',
      'category': 'Stays',
      'amount': '5.000.000 đ',
      'date': 'May 24, 2026',
      'icon': Icons.home_work_outlined,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Express Train Ticket',
      'category': 'Transport',
      'amount': '1.200.000 đ',
      'date': 'May 25, 2026',
      'icon': Icons.train_outlined,
      'color': const Color(0xFF06B6D4),
    },
    {
      'title': 'Nishiki Lunch Crawl',
      'category': 'Food & Drinks',
      'amount': '2.450.000 đ',
      'date': 'May 26, 2026',
      'icon': Icons.restaurant_menu_outlined,
      'color': const Color(0xFFEBA83A),
    },
    {
      'title': 'Kinkaku-ji Tickets',
      'category': 'Entertainment',
      'amount': '835.000 đ',
      'date': 'May 26, 2026',
      'icon': Icons.confirmation_number_outlined,
      'color': const Color(0xFFE0533C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentageUsed = _totalSpent / _totalBudget;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TripMate Finance Hub 💸',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.wallet, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WalletScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return BudgetAnalyticsScreen(
                      isDarkMode: isDark,
                      onThemeToggle: () {},
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Card showing Budget Progress
            Card(
              elevation: 4,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      isDark ? const Color(0xFF8B5CF6).withValues(alpha: 0.15) : const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                      isDark ? const Color(0xFFEC4899).withValues(alpha: 0.1) : const Color(0xFFEC4899).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngân sách cả nhóm',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_totalBudget.toStringAsFixed(0)} đ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.currency_exchange, size: 16, color: Colors.purpleAccent),
                              SizedBox(width: 6),
                              Text(
                                'VND',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Custom Circular Progress Layout
                    Row(
                      children: [
                        SizedBox(
                          height: 70,
                          width: 70,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: percentageUsed,
                                strokeWidth: 8,
                                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                              ),
                              Center(
                                child: Text(
                                  '${(percentageUsed * 100).toInt()}%',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đã tiêu: ${_totalSpent.toStringAsFixed(0)} đ',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Còn lại: ${(_totalBudget - _totalSpent).toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  color: Colors.purpleAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // QUICK ACTIONS ROW HUB
            Text(
              'Tính Năng Nổi Bật 🚀',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickAction(
                  context,
                  Icons.post_add,
                  'Log Damage 💸',
                  const LogDamageScreen(),
                  isDark,
                ),
                _buildQuickAction(
                  context,
                  Icons.camera_alt,
                  'AI Scanner 📸',
                  const AiReceiptScannerScreen(),
                  isDark,
                ),
                _buildQuickAction(
                  context,
                  Icons.people_outline,
                  'Wheel Splitter 🎡',
                  const ExpenseSplitterSocialScreen(),
                  isDark,
                ),
                _buildQuickAction(
                  context,
                  Icons.device_hub_outlined,
                  'Debt Simplify 🕸️',
                  const DebtSimplificationScreen(),
                  isDark,
                ),
                _buildQuickAction(
                  context,
                  Icons.donut_large,
                  'Analytics 📊',
                  BudgetAnalyticsScreen(
                    isDarkMode: isDark,
                    onThemeToggle: () {},
                  ),
                  isDark,
                ),
                _buildQuickAction(
                  context,
                  Icons.track_changes,
                  'Budget Goal 🎯',
                  const BudgetGoalScreen(),
                  isDark,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Recent Expenses Log List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi Tiêu Gần Đây',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LogDamageScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Thêm Mới',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expense Log List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final item = _expenses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${item['category']} • ${item['date']}',
                      ),
                      trailing: Text(
                        item['amount'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.purpleAccent,
                        ),
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

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Widget target,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => target),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
