import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api_service.dart';

class BillingHistoryScreen extends StatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  State<BillingHistoryScreen> createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends State<BillingHistoryScreen> {
  List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-9982',
      'date': '2026-05-20',
      'title': 'Elite Squad Subscription (1 Tháng) 👑',
      'amount': '99.000đ',
      'method': 'Visa *4242',
      'status': 'Thành công',
    },
    {
      'id': 'INV-8812',
      'date': '2026-04-20',
      'title': 'Xuất Video Recap Kyoto 4K 🎞️',
      'amount': '25.000đ',
      'method': 'Momo Wallet',
      'status': 'Thành công',
    },
    {
      'id': 'INV-7734',
      'date': '2026-03-15',
      'title': 'Chủ Đề Dalat Vintage Premium 🌲',
      'amount': '49.000đ',
      'method': 'Vietcombank *9999',
      'status': 'Thành công',
    }
  ];
  
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
        _invoices = list.map((item) => {
          'id': item['id'] ?? 'GD-${item.hashCode.abs()}',
          'date': item['date'] ?? 'Vừa qua',
          'title': item['description'] ?? 'Giao dịch nâng cấp',
          'amount': '${(item['amount'] as int?) ?? 0}đ',
          'method': item['method'] ?? 'Nguồn đã lưu',
          'status': item['status'] ?? 'Thành công',
        }).toList();
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
    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final backgroundColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch Sử Hóa Đơn 🧾',
          style: GoogleFonts.plusJakartaSans(
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
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            inv['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
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
                          style: GoogleFonts.plusJakartaSans(
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
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nguồn thanh toán: ${inv['method']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.download_for_offline_outlined, color: primaryColor),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📥 Đang tải hóa đơn ${inv['id']} dạng PDF...'),
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
