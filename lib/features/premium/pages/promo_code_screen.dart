import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api_service.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final _promoController = TextEditingController();
  bool _isValidating = false;
  String? _successMessage;
  String? _errorMessage;

  Future<void> _validateCode() async {
    final text = _promoController.text.trim().toUpperCase();
    if (text.isEmpty) return;

    setState(() {
      _isValidating = true;
      _successMessage = null;
      _errorMessage = null;
    });

    // Call live NestJS backend promo validator!
    final response = await ApiService.post('/premium/promo-codes/validate', {
      'code': text,
    });

    setState(() {
      _isValidating = false;
      if (response != null && response['valid'] == true) {
        final double discount = (response['discount'] as num).toDouble() * 100;
        final String desc = response['description'] ?? 'Mã giảm giá';
        _successMessage = 'Mã áp dụng thành công! Giảm ${discount.toInt()}% ($desc) cho Elite Squad Tier! 🎉💸';
      } else {
        _errorMessage = 'Mã giảm giá không hợp lệ hoặc đã hết hạn! 😭';
      }
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Brand design system tokens
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
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
          'Nhập Mã Khuyến Mãi 🎫',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sử dụng vé giảm giá hoặc mã khuyến mãi du lịch để giảm chi phí gói dịch vụ của cưng.',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Input form
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập mã (Ví dụ: MATEYCHAT)',
                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13.5),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _isValidating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purpleAccent),
                        )
                      : TextButton(
                          onPressed: _validateCode,
                          child: Text(
                            'Áp dụng',
                            style: GoogleFonts.plusJakartaSans(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Result Messages
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.green[300],
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.redAccent[100],
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 36),

            // Helpful tips
            Text(
              'Gợi ý mã khuyến mãi đang hoạt động:',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildActivePromoItem('MATEYCHAT', 'Giảm 15% gói Elite Squad mừng Companion Launch! 🔮', isDark, primaryColor, surfaceColor),
            _buildActivePromoItem('DALATCHILL', 'Giảm 20% gói Adventure cho nhóm đi phượt Đà Lạt! 🌲', isDark, primaryColor, surfaceColor),
            _buildActivePromoItem('ELITESQUAD', 'Giảm 50% thử nghiệm nửa giá cực bốc! 💎', isDark, primaryColor, surfaceColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePromoItem(String code, String desc, bool isDark, Color primaryColor, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                code,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[650],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
