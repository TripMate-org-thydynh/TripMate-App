import '../../../core/theme/theme.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../core/api_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionCheckoutScreen extends StatefulWidget {
  const SubscriptionCheckoutScreen({super.key});

  @override
  State<SubscriptionCheckoutScreen> createState() =>
      _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState
    extends State<SubscriptionCheckoutScreen> {
  String _selectedMethod = 'VISA'; // VISA, MOMO, TECHCOM
  bool _isProcessing = false;
  List<String> _benefits = [
    'Không giới hạn AI Recap Exports 🎬',
    'Bộ nhãn dán Social Chaos độc quyền 🕹️',
    'Tải lên tệp phương tiện độ phân giải gốc 📂',
    'Quyền truy cập sớm các mini-game nâng cao 🎭',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionInfo();
  }

  Future<void> _fetchSubscriptionInfo() async {
    final response = await ApiService.get('/premium/subscriptions');
    if (response != null && response['benefits'] != null) {
      setState(() {
        _benefits = List<String>.from(response['benefits']);
      });
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    Map<String, dynamic>? response;
    String? failureMessage;

    try {
      final InAppPurchase iap = InAppPurchase.instance;
      final bool isAvailable = await iap.isAvailable();
      if (!isAvailable) {
        failureMessage =
            'Google Play Billing chưa sẵn sàng trên máy này. '
            'Thử cập nhật ứng dụng CH Play rồi quay lại nhé.';
      } else {
        const Set<String> kIds = <String>{'elite_squad_monthly'};
        final ProductDetailsResponse res = await iap.queryProductDetails(kIds);
        if (res.productDetails.isEmpty) {
          // Sản phẩm chưa được tạo trên Play Console → CHƯA mở bán.
          // Tuyệt đối không fallback sang endpoint cấp Premium miễn phí:
          // vừa thất thoát doanh thu, vừa vi phạm chính sách thanh toán của
          // Google Play (hàng hoá số bắt buộc đi qua Play Billing).
          failureMessage =
              'Gói Premium chưa mở bán. Bọn mình đang hoàn tất thủ tục '
              'thanh toán, quay lại sau ít hôm nha! 🙏';
        } else {
          final ProductDetails productDetails = res.productDetails.first;
          final bool started = await iap.buyNonConsumable(
            purchaseParam: PurchaseParam(productDetails: productDetails),
          );
          if (!started) {
            failureMessage = 'Không mở được cửa sổ thanh toán. Thử lại nhé.';
          } else {
            // Biên lai thật do Play trả về qua purchaseStream; backend sẽ xác
            // thực với Google trước khi kích hoạt Premium.
            response = await ApiService.post('/premium/verify-google-play', {
              'productId': 'elite_squad_monthly',
            });
          }
        }
      }
    } catch (e) {
      debugPrint('IAP Error: $e');
      failureMessage = 'Thanh toán không thành công. Thử lại sau nhé.';
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    if (failureMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failureMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String message = response != null && response['message'] != null
        ? response['message'] as String
        : 'Kích hoạt Premium thành công! Chúc cưng chuyến đi ngập tràn vibe luxury! 💸✨';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF262019)
            : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Gia Nhập Elite Squad Thành Công! 💸👑',
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF5822B)
                      : const Color(0xFFF5822B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // close modal
                  Navigator.pop(context); // back to previous screen
                },
                child: Text(
                  'Bắt Đầu Trải Nghiệm Luxury ✨',
                  style: AppFonts.heading(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design System colors
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
          'Nâng Cấp Elite Squad 👑',
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Luxury Header Card using Brand Purple & Teal gradients
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ELITE SQUAD TIER 💎',
                          style: AppFonts.heading(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Text('👑', style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '99.000đ / tháng',
                    style: AppFonts.heading(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tận hưởng phong cách du lịch đẳng cấp cùng hội bạn với sức mạnh AI bứt tốc.',
                    style: AppFonts.heading(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Comparison Table
            Text(
              'Đặc Quyền Của Cưng 📊',
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: _benefits.map((benefit) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                benefit,
                                style: AppFonts.heading(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_benefits.indexOf(benefit) < _benefits.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // Select Payment Method
            Text(
              'Phương Thức Thanh Toán 💳',
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMethodCard(
                    'VISA',
                    'Visa Card 💳',
                    isDark,
                    primaryColor,
                    surfaceColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMethodCard(
                    'MOMO',
                    'Momo Wallet 💸',
                    isDark,
                    primaryColor,
                    surfaceColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Kích Hoạt Ngay 👑',
                        style: AppFonts.heading(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    String method,
    String label,
    bool isDark,
    Color primaryColor,
    Color surfaceColor,
  ) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppFonts.heading(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
