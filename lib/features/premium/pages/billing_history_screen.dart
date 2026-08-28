import '../../../core/theme/theme.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/api_service.dart';

class BillingHistoryScreen extends StatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  State<BillingHistoryScreen> createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends State<BillingHistoryScreen> {
  // Rỗng cho tới khi /premium/billing-history trả giao dịch thật (endpoint
  // nay đọc bảng payment_transactions). Trước đây 3 hoá đơn cứng
  // "Visa *4242 · 99.000đ · Thành công" hiện cho cả tài khoản chưa mua gì.
  List<Map<String, dynamic>> _invoices = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBillingHistory();
  }

  Future<void> _fetchBillingHistory() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.get('/premium/billing-history');
    if (response != null && response['history'] != null) {
      final List<dynamic> list = response['history'] as List<dynamic>;
      setState(() {
        _invoices = list
            .map(
              (item) => {
                'id': item['id'] ?? 'GD-${item.hashCode.abs()}',
                'date': item['date'] ?? 'Vừa qua',
                'title': item['description'] ?? 'Giao dịch nâng cấp',
                'amount': '${(item['amount'] as int?) ?? 0}đ',
                'method': item['method'] ?? 'Nguồn đã lưu',
                'status': item['status'] ?? 'Thành công',
              },
            )
            .toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Brand Tokens
    final primaryColor = isDark
        ? TripMateTheme.darkPrimary
        : TripMateTheme.lightPrimary;
    final backgroundColor = isDark
        ? TripMateTheme.darkBackground
        : TripMateTheme.lightBackground;
    final surfaceColor = isDark
        ? TripMateTheme.darkSurface
        : TripMateTheme.lightSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch Sử Hóa Đơn 🧾',
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBillingHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : _invoices.isEmpty
          // Chưa mua gì thì nói thẳng, thay vì hiện hoá đơn bịa như trước.
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'premium.no_invoices'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final inv = _invoices[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            inv['title'] as String,
                            style: AppFonts.heading(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          inv['amount'] as String,
                          style: AppFonts.heading(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Mã GD: ${inv['id']}  •  Ngày: ${inv['date']}',
                          style: AppFonts.heading(
                            fontSize: 11.5,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nguồn thanh toán: ${inv['method']}',
                          style: AppFonts.heading(
                            fontSize: 11.5,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.download_for_offline_outlined,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '📥 Đang tải hóa đơn ${inv['id']} dạng PDF...',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
