import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api_service.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/theme/app_fonts.dart';
import '../data/entitlement_provider.dart';

/// Modal hiển thị mã VietQR và thông tin chuyển khoản ngân hàng (SePay).
///
/// Tự động lắng nghe thông báo Webhook từ SePay trong thời gian thực.
/// Khi khách chuyển khoản thành công, hệ thống tự động kích hoạt gói cước
/// và đóng modal mà không cần người dùng phải bấm nút xác nhận thủ công.
class VietQrPaymentSheet extends ConsumerStatefulWidget {
  final String orderCode;
  final int amount;
  final String qrUrl;
  final String? payUrl;
  final Map<String, dynamic>? bankInfo;

  const VietQrPaymentSheet({
    super.key,
    required this.orderCode,
    required this.amount,
    required this.qrUrl,
    this.payUrl,
    this.bankInfo,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String orderCode,
    required int amount,
    required String qrUrl,
    String? payUrl,
    Map<String, dynamic>? bankInfo,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VietQrPaymentSheet(
        orderCode: orderCode,
        amount: amount,
        qrUrl: qrUrl,
        payUrl: payUrl,
        bankInfo: bankInfo,
      ),
    );
  }

  @override
  ConsumerState<VietQrPaymentSheet> createState() => _VietQrPaymentSheetState();
}

class _VietQrPaymentSheetState extends ConsumerState<VietQrPaymentSheet> {
  Timer? _pollTimer;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Lắng nghe trạng thái giao dịch từ Webhook SePay qua backend.
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final res =
            await ApiService.get('/payment/order-status/${widget.orderCode}');
        if (res != null &&
            res is Map &&
            (res['isPaid'] == true || res['status'] == 'SUCCESS')) {
          _pollTimer?.cancel();
          if (mounted) {
            setState(() {
              _isSuccess = true;
            });
            ref.invalidate(entitlementProvider);
            // Tự động đóng modal sau 1.8 giây hiển thị chúc mừng
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            });
          }
        }
      } catch (_) {
        // Bỏ qua lỗi mạng chập chờn khi polling
      }
    });
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr('premium.vietqr_copied', namedArgs: {'label': label, 'value': text}),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) buffer.write('.');
    }
    return '${buffer.toString().split('').reversed.join('')} ₫';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final cardBg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    final bankCode = widget.bankInfo?['bankCode']?.toString() ?? 'MBBank';
    final accountNumber =
        widget.bankInfo?['accountNumber']?.toString() ?? '0949064234';
    final accountName =
        widget.bankInfo?['accountName']?.toString() ?? 'CHAU THANH TRUNG';
    final content =
        widget.bankInfo?['transferContent']?.toString() ?? widget.orderCode;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh gạt modal + Nút đóng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ink.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(PhosphorIcons.x(), size: 20),
                  splashRadius: 18,
                  color: inkSoft,
                  tooltip: tr('common.close'),
                ),
              ],
            ),

            if (_isSuccess) ...[
              // Giao diện khi Webhook báo thanh toán thành công
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: GenZTokens.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: GenZTokens.green, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      color: GenZTokens.green,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr('premium.vietqr_success_title'),
                      style: AppFonts.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('premium.vietqr_success_desc'),
                      style: AppFonts.body(
                        fontSize: 14,
                        color: inkSoft,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              // Tiêu đề
              Text(
                tr('premium.vietqr_title'),
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                tr('premium.vietqr_sub'),
                style: AppFonts.body(
                  fontSize: 13,
                  color: inkSoft,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Mã QR Card
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ink, width: GenZTokens.borderWidth),
                    boxShadow: GenZTokens.hardShadow(ink),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.qrUrl,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 220,
                        height: 220,
                        color: Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.qrCode(),
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(tr('premium.vietqr_error_image'),
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Chi tiết chuyển khoản
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: ink, width: GenZTokens.borderWidthThin),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      label: tr('premium.vietqr_bank'),
                      value: bankCode,
                      ink: ink,
                    ),
                    Divider(height: 16, color: ink.withValues(alpha: 0.15)),
                    _buildDetailRow(
                      context,
                      label: tr('premium.vietqr_account_number'),
                      value: accountNumber,
                      ink: ink,
                      onCopy: () => _copy(accountNumber, tr('premium.vietqr_account_number')),
                    ),
                    Divider(height: 16, color: ink.withValues(alpha: 0.15)),
                    _buildDetailRow(
                      context,
                      label: tr('premium.vietqr_account_name'),
                      value: accountName,
                      ink: ink,
                    ),
                    Divider(height: 16, color: ink.withValues(alpha: 0.15)),
                    _buildDetailRow(
                      context,
                      label: tr('premium.vietqr_amount'),
                      value: _formatCurrency(widget.amount),
                      ink: GenZTokens.purple,
                      isBold: true,
                      onCopy: () => _copy(widget.amount.toString(), tr('premium.vietqr_amount')),
                    ),
                    Divider(height: 16, color: ink.withValues(alpha: 0.15)),
                    _buildDetailRow(
                      context,
                      label: tr('premium.vietqr_content'),
                      value: content,
                      ink: GenZTokens.purple,
                      isBold: true,
                      highlight: true,
                      onCopy: () => _copy(content, tr('premium.vietqr_content')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Thông báo thời gian thực: Webhook đang lắng nghe
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: GenZTokens.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: GenZTokens.purple.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(GenZTokens.purple),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('premium.vietqr_waiting'),
                            style: AppFonts.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: GenZTokens.purple,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr('premium.vietqr_waiting_sub'),
                            style: AppFonts.body(
                              fontSize: 11,
                              color: inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Nút mở cổng SePay nếu cần
              if (widget.payUrl != null)
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final uri = Uri.tryParse(widget.payUrl!);
                      if (uri != null) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: Icon(PhosphorIcons.arrowSquareOut(), size: 18),
                    label: Text(tr('premium.vietqr_open_gateway')),
                    style: TextButton.styleFrom(
                      foregroundColor: GenZTokens.purple,
                      textStyle: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color ink,
    bool isBold = false,
    bool highlight = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.body(
            fontSize: 13,
            color: ink.withValues(alpha: 0.7),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: highlight
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                  : EdgeInsets.zero,
              decoration: highlight
                  ? BoxDecoration(
                      color: GenZTokens.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                value,
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: ink,
                ),
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    PhosphorIcons.copy(),
                    size: 16,
                    color: ink.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
