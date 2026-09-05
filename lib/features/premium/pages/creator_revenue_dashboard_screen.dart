import '../../../core/format/money.dart';
import '../../../core/theme/theme.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api_service.dart';

class CreatorRevenueDashboardScreen extends StatefulWidget {
  const CreatorRevenueDashboardScreen({super.key});

  @override
  State<CreatorRevenueDashboardScreen> createState() =>
      _CreatorRevenueDashboardScreenState();
}

class _CreatorRevenueDashboardScreenState
    extends State<CreatorRevenueDashboardScreen> {
  bool _isPayoutRequesting = false;
  bool _isLoading = false;

  // Khởi tạo 0, không phải số bịa. Trước đây các biến này mặc định
  // 42 theme / 128 sticker / 1.45tr doanh thu, và vì API dùng `?? _biến` nên
  // creator chưa bán gì vẫn thấy một bảng doanh thu như thật.
  int _themesSold = 0;
  int _stickersSold = 0;
  int _totalSales = 0;
  int _creatorShare = 0;
  int _payoutPending = 0;

  // Rỗng cho tới khi API trả giao dịch thật. Trước đây đây là 3 đơn bịa
  // (người mua "Hoàng Yến", "Phú Khang", "Minh Nhật") hiện cho mọi tài khoản.
  List<Map<String, dynamic>> _recentSales = [];

  @override
  void initState() {
    super.initState();
    _fetchRevenueData();
  }

  Future<void> _fetchRevenueData() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.get('/premium/creator-revenue');
    if (response != null) {
      setState(() {
        _themesSold = (response['themesSoldCount'] as int?) ?? _themesSold;
        _stickersSold =
            (response['stickersSoldCount'] as int?) ?? _stickersSold;
        _totalSales = (response['totalSalesRevenue'] as int?) ?? _totalSales;
        _creatorShare = (response['creatorShare'] as int?) ?? _creatorShare;
        _payoutPending = (response['payoutPending'] as int?) ?? _payoutPending;

        if (response['recentSales'] != null) {
          final List<dynamic> salesList =
              response['recentSales'] as List<dynamic>;
          _recentSales = salesList
              .map(
                (item) => {
                  'item': item['item'] ?? 'premium.creative_product'.tr(),
                  'buyer': item['buyer'] ?? 'common.friends'.tr(),
                  'price': (item['price'] as int?) ?? 0,
                  'date': item['date'] ?? 'premium.recent'.tr(),
                },
              )
              .toList();
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestPayout() async {
    setState(() {
      _isPayoutRequesting = true;
    });

    // Simulate direct post to confirm payouts
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() {
      _isPayoutRequesting = false;
      _payoutPending = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('premium.payout_ok'.tr()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Brand design tokens
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
          'premium.creator_revenue'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRevenueData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Panel using vibrant Obsidian and brand coloring gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'premium.available_balance'.tr(),
                          style: AppFonts.heading(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatMoney(_payoutPending, locale: context.locale.languageCode),
                              style: AppFonts.heading(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  _payoutPending == 0 || _isPayoutRequesting
                                  ? null
                                  : _requestPayout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isPayoutRequesting
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    )
                                  : Text(
                                      'premium.request_payout'.tr(),
                                      style: AppFonts.heading(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white30, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniStat(
                              'Doanh Thu Shop',
                              formatMoney(_totalSales, locale: context.locale.languageCode),
                            ),
                            _buildMiniStat(
                              'premium.creator_share'.tr(),
                              formatMoney(_creatorShare, locale: context.locale.languageCode),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Visual Chart
                  Text(
                    'premium.sales_trend'.tr(),
                    style: AppFonts.heading(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _RevenueChartPainter(
                        isDark: isDark,
                        strokeColor: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Recent sales lists
                  Text(
                    'premium.recent_txn'.tr(),
                    style: AppFonts.heading(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    borderOnForeground: false,
                    child: Column(
                      children: _recentSales.map((sale) {
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              title: Text(
                                sale['item'] as String,
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                'premium.bought_by_on'.tr(
                                  namedArgs: {
                                    'buyer': '${sale['buyer']}',
                                    'date': '${sale['date']}',
                                  },
                                ),
                                style: AppFonts.heading(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Text(
                                '+${formatMoney((sale['price'] as num?) ?? 0, locale: context.locale.languageCode)}',
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (_recentSales.indexOf(sale) <
                                _recentSales.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.heading(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppFonts.heading(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

// Custom Painter representing revenue line chart
class _RevenueChartPainter extends CustomPainter {
  final bool isDark;
  final Color strokeColor;
  _RevenueChartPainter({required this.isDark, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          strokeColor.withValues(alpha: 0.3),
          strokeColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.7,
        size.width * 0.4,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.3,
      )
      ..lineTo(size.width, size.height * 0.2);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw grid horizontal line
    final gridPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[200]!
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(0, size.height * 0.25 * i),
        Offset(size.width, size.height * 0.25 * i),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
