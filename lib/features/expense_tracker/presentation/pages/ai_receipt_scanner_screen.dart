import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/app_messenger.dart';
import '../../../../core/format/money.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../premium/presentation/paywall_sheet.dart';
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
  ConsumerState<AiReceiptScannerScreen> createState() =>
      _AiReceiptScannerScreenState();
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
          _merchantName = result['merchant'] ?? 'expense.receipt'.tr();
          _detectedItems.clear();
          final items = result['items'] as List?;
          if (items != null) {
            for (var item in items) {
              _detectedItems.add({
                'name': item['name'] ?? 'expense.dish'.tr(),
                'price': (item['price'] as num?)?.toDouble() ?? 0.0,
                'checked': item['selected'] ?? true,
              });
            }
          } else {
            // Fallback nếu không có list items
            _detectedItems.add({
              'name': 'expense.receipt_total'.tr(),
              'price': (result['total'] as num?)?.toDouble() ?? 0.0,
              'checked': true,
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSelecting = true;
          _isScanning = false;
        });
        if (await PaywallSheet.maybeShow(context, e)) return;
        if (!mounted) return;
        // Hiện đúng lý do BE trả về (AI hết quota, ảnh mờ...) thay vì một câu
        // chung chung khiến người dùng cứ bấm lại mãi.
        showGlobalSnack(
          e is ApiException ? e.message : 'expense.scan_failed'.tr(),
          isError: true,
        );
      }
    } finally {
      _scannerController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onAccentColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = isDark ? GenZTokens.successDark : GenZTokens.success;
    final infoColor = isDark ? GenZTokens.infoDark : GenZTokens.info;
    final lineColor = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fillColor = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final cardBg = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'expense.scan_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: GenZTokens.durationFast),
          child: _isSelecting
              ? _buildReceiptSelector(
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  lineColor: lineColor,
                  infoColor: infoColor,
                  fillColor: fillColor,
                )
              : _isScanning
              ? _buildScanningViewport(
                  primaryColor: primaryColor,
                  cardBg: cardBg,
                  lineColor: lineColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                )
              : _buildItemsBreakdown(
                  primaryColor: primaryColor,
                  onAccentColor: onAccentColor,
                  secondaryColor: secondaryColor,
                  cardBg: cardBg,
                  lineColor: lineColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
        ),
      ),
    );
  }

  // Màn hình chọn hóa đơn mẫu để quét
  Widget _buildReceiptSelector({
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBg,
    required Color lineColor,
    required Color infoColor,
    required Color fillColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      key: const ValueKey('selector_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: lineColor,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                  color: infoColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'expense.scan_sub'.tr(),
                    style: AppFonts.body(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'expense.scan_pick'.tr(),
            style: AppFonts.heading(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Trước đây chỗ này là 2 hoá đơn demo cứng (ảnh món ăn trên Unsplash),
          // nên "quét hoá đơn" không bao giờ đọc được hoá đơn của người dùng.
          _sourceTile(
            icon: PhosphorIcons.camera(),
            title: 'expense.scan_camera'.tr(),
            subtitle: 'expense.scan_camera_sub'.tr(),
            source: ImageSource.camera,
            cardBg: cardBg,
            lineColor: lineColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 12),
          _sourceTile(
            icon: PhosphorIcons.image(),
            title: 'expense.scan_gallery'.tr(),
            subtitle: 'expense.scan_gallery_sub'.tr(),
            source: ImageSource.gallery,
            cardBg: cardBg,
            lineColor: lineColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// Đọc ảnh người dùng chọn rồi gửi base64 lên `/expenses/ocr`.
  ///
  /// BE nhận cả URL lẫn chuỗi base64 (`data:image/...`), nên không cần upload
  /// file trung gian.
  Future<void> _pickAndScan(ImageSource source) async {
    final XFile? file = await ImagePicker().pickImage(
      source: source,
      // Nén bớt: ảnh gốc 12MP làm payload phình to mà OCR không cần.
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    _startScanning(
      'expense.receipt_just_taken'.tr(),
      'data:image/jpeg;base64,${base64Encode(bytes)}',
    );
  }

  Widget _sourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ImageSource source,
    required Color cardBg,
    required Color lineColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return GestureDetector(
      onTap: () => _pickAndScan(source),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: lineColor,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.body(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), color: textSecondary),
          ],
        ),
      ),
    );
  }

  // Hiệu ứng quét hóa đơn
  Widget _buildScanningViewport({
    required Color primaryColor,
    required Color cardBg,
    required Color lineColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
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
                color: cardBg,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(
                  color: primaryColor,
                  width: GenZTokens.borderWidthFocus,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.receipt(),
                          size: 80,
                          color: textPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedReceiptName ?? 'SCANNING...',
                          style: AppFonts.mono(
                            color: textPrimary,
                            fontSize: 12,
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
                          height: 2,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 4,
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
              'expense.scan_working'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'expense.scan_working_sub'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Kết quả bóc tách hóa đơn
  Widget _buildItemsBreakdown({
    required Color primaryColor,
    required Color onAccentColor,
    required Color secondaryColor,
    required Color cardBg,
    required Color lineColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
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
              color: secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: secondaryColor,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: secondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'expense.scan_done'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _merchantName ?? 'expense.receipt_info'.tr(),
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: lineColor,
                width: GenZTokens.borderWidthThin,
              ),
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
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        formatMoney(
                          item['price'] as double,
                          locale: context.locale.languageCode,
                        ),
                        style: AppFonts.body(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
                Divider(height: 24, color: lineColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'expense.your_share'.tr(),
                      style: AppFonts.heading(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      formatMoney(
                        _calculateTotalSelected(),
                        locale: context.locale.languageCode,
                      ),
                      style: AppFonts.body(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
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
                'description': 'expense.scan_description'.tr(
                  namedArgs: {
                    'merchant': _merchantName ?? 'common.unnamed'.tr(),
                  },
                ),
              });
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                color: primaryColor,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'expense.apply_amount'.tr(),
                      style: AppFonts.heading(
                        color: onAccentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.checkCircle(),
                      color: onAccentColor,
                      size: 18,
                    ),
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
