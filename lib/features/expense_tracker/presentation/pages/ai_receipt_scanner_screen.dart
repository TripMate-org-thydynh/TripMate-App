import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_messenger.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../data/expenses_repository.dart';

class AiReceiptScannerScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const AiReceiptScannerScreen({
    super.key,
    required this.tripId,
    required this.isDarkMode,
  });

  @override
  ConsumerState<AiReceiptScannerScreen> createState() => _AiReceiptScannerScreenState();
}

class _AiReceiptScannerScreenState extends ConsumerState<AiReceiptScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;

  bool _isSelecting = true;
  bool _isScanning = false;
  String? _selectedReceiptName;
  String? _merchantName;

  final List<Map<String, dynamic>> _detectedItems = [];

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startScanning(String receiptName, String mockUrl) async {
    setState(() {
      _isSelecting = false;
      _isScanning = true;
      _selectedReceiptName = receiptName;
    });

    _scannerController.repeat(reverse: true);

    try {
      // Gọi BE NestJS thật endpoint: /trips/:tripId/expenses/ocr
      final result = await ref
          .read(expensesRepositoryProvider)
          .scanReceipt(widget.tripId, mockUrl);

      // Cho chạy hiệu ứng quét tối thiểu 1.5 giây cho "vibe" công nghệ.
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _isScanning = false;
          _merchantName = result['merchant'] ?? 'Hóa đơn chi tiêu';
          _detectedItems.clear();
          final items = result['items'] as List?;
          if (items != null) {
            for (var item in items) {
              _detectedItems.add({
                'name': item['name'] ?? 'Món ăn',
                'price': (item['price'] as num?)?.toDouble() ?? 0.0,
                'checked': item['selected'] ?? true,
              });
            }
          } else {
            // Fallback nếu không có list items
            _detectedItems.add({
              'name': 'Tổng hóa đơn',
              'price': (result['total'] as num?)?.toDouble() ?? 0.0,
              'checked': true,
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showGlobalSnack('Không thể quét hóa đơn. Vui lòng thử lại!', isError: true);
        setState(() {
          _isSelecting = true;
          _isScanning = false;
        });
      }
    } finally {
      _scannerController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFF5822B);
    final secondaryColor = const Color(0xFF1FA85C);
    final bgColor = widget.isDarkMode ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
    final textPrimary = widget.isDarkMode ? Colors.white : const Color(0xFF262019);
    final textSecondary = widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
    final cardBg = widget.isDarkMode ? const Color(0xFF262019) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quét Hóa Đơn AI 📸',
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSelecting
              ? _buildReceiptSelector(textPrimary, textSecondary, cardBg)
              : _isScanning
                  ? _buildScanningViewport(primaryColor, secondaryColor, textPrimary, textSecondary)
                  : _buildItemsBreakdown(primaryColor, secondaryColor, cardBg, textPrimary, textSecondary),
        ),
      ),
    );
  }

  // Màn hình chọn hóa đơn mẫu để quét
  Widget _buildReceiptSelector(Color textPrimary, Color textSecondary, Color cardBg) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      key: const ValueKey('selector_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GenZTokens.ink, width: 2),
              boxShadow: GenZTokens.hardShadow(GenZTokens.ink),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chọn hóa đơn từ máy ảnh hoặc bộ sưu tập để AI tự động phân tích chi phí nhóm!',
                    style: AppFonts.body(
                      color: GenZTokens.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'HÓA ĐƠN GẦN ĐÂY',
            style: AppFonts.heading(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _receiptTile(
                  title: 'Lẩu gà lá é Tao Ngộ 🍜',
                  subtitle: 'Đà Lạt • 12/07/2026',
                  mockUrl: 'https://images.unsplash.com/photo-1552566626-52f8b828add9',
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: 16),
                _receiptTile(
                  title: 'Cafe Xe Cổ Đà Lạt ☕',
                  subtitle: 'Đèo Mimosa • 12/07/2026',
                  mockUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptTile({
    required String title,
    required String subtitle,
    required String mockUrl,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return GestureDetector(
      onTap: () => _startScanning(title, mockUrl),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textPrimary, width: 2),
          boxShadow: GenZTokens.hardShadow(textPrimary),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD84D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: textPrimary, width: 1.5),
              ),
              child: const Icon(Icons.receipt_long, color: GenZTokens.ink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.heading(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.body(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textPrimary),
          ],
        ),
      ),
    );
  }

  // Hiệu ứng quét hóa đơn
  Widget _buildScanningViewport(Color primaryColor, Color secondaryColor, Color textPrimary, Color textSecondary) {
    return Center(
      key: const ValueKey('scanning_view'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor, width: 3),
                boxShadow: GenZTokens.hardShadow(textPrimary),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, size: 80, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          _selectedReceiptName ?? 'SCANNING...',
                          style: AppFonts.mono(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scannerAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scannerAnimation.value * 230 + 20,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.8),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'AI ĐANG PHÂN TÍCH HÓA ĐƠN...',
              style: AppFonts.heading(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hệ thống trích xuất tên món và giá tiền từ ảnh chụp.',
              textAlign: TextAlign.center,
              style: AppFonts.body(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kết quả bóc tách hóa đơn
  Widget _buildItemsBreakdown(
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('breakdown_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đã quét thành công! Chọn các món bạn tiêu dùng để tính toán số tiền.',
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _merchantName ?? 'Thông tin hóa đơn',
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: textPrimary, width: 2),
              boxShadow: GenZTokens.hardShadow(textPrimary),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _detectedItems.length,
                  itemBuilder: (context, index) {
                    final item = _detectedItems[index];
                    final isChecked = item['checked'] as bool;
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        item['name'] as String,
                        style: AppFonts.heading(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${(item['price'] as double).toStringAsFixed(0)} đ',
                        style: AppFonts.body(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      value: isChecked,
                      onChanged: (bool? val) {
                        setState(() {
                          _detectedItems[index]['checked'] = val ?? false;
                        });
                      },
                    );
                  },
                ),
                const Divider(height: 24, color: Colors.black12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng phần của bạn:',
                      style: AppFonts.heading(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '${_calculateTotalSelected().toStringAsFixed(0)} đ',
                      style: AppFonts.body(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              final total = _calculateTotalSelected();
              Navigator.pop(context, {
                'amount': total,
                'description': 'Quét hóa đơn: ${_merchantName ?? "Không tên"}',
              });
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: primaryColor,
                border: Border.all(color: textPrimary, width: 2),
                boxShadow: GenZTokens.hardShadow(textPrimary),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Áp dụng số tiền chi tiêu',
                      style: AppFonts.heading(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalSelected() {
    double sum = 0.0;
    for (var item in _detectedItems) {
      if (item['checked'] as bool) {
        sum += item['price'] as double;
      }
    }
    return sum;
  }
}
