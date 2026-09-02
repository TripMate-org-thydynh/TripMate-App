import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mở các ứng dụng thanh toán Việt Nam (Momo / ZaloPay) bằng deep-link thật.
///
/// Lưu ý: việc tự động điền sẵn SỐ TIỀN vào màn chuyển khoản của Momo/ZaloPay
/// cần tích hợp API đối tác chính thức. Ở tầng client này ta mở thẳng app người
/// nhận và đồng thời copy sẵn thông tin (SĐT + số tiền + ghi chú) vào clipboard
/// để người dùng dán nhanh — đây là pattern an toàn, không "ảo giác" API.
class PaymentLauncher {
  PaymentLauncher._();

  /// Mở bottom sheet chọn phương thức thanh toán cho 1 khoản nợ.
  static Future<void> showPaymentSheet(
    BuildContext context, {
    required String recipientName,
    required String recipientPhone,
    required double amount,
    String note = 'TripMate chia tiền',
    bool? isDarkMode,
  }) {
    final isDark =
        isDarkMode ?? Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PaymentSheet(
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        amount: amount,
        note: note,
        isDark: isDark,
      ),
    );
  }

  /// Copy thông tin chuyển khoản để dán vào app thanh toán.
  static Future<void> copyTransferInfo({
    required String recipientPhone,
    required double amount,
    required String note,
  }) {
    final text = '$recipientPhone | ${amount.toStringAsFixed(0)}đ | $note';
    return Clipboard.setData(ClipboardData(text: text));
  }

  /// Thử mở Momo. Trả về true nếu mở được app/web.
  static Future<bool> launchMomo(String phone) async {
    // 1) App scheme
    if (await _tryLaunch(Uri.parse('momo://'))) return true;
    // 2) Universal link hồ sơ người nhận
    if (await _tryLaunch(Uri.parse('https://me.momo.vn/$phone'))) return true;
    return false;
  }

  /// Thử mở ZaloPay. Trả về true nếu mở được app/web.
  static Future<bool> launchZaloPay(String phone) async {
    if (await _tryLaunch(Uri.parse('zalopay://'))) return true;
    if (await _tryLaunch(Uri.parse('https://zalopay.vn/'))) return true;
    return false;
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // nuốt lỗi, để caller xử lý fallback
    }
    return false;
  }
}

class _PaymentSheet extends StatelessWidget {
  final String recipientName;
  final String recipientPhone;
  final double amount;
  final String note;
  final bool isDark;

  const _PaymentSheet({
    required this.recipientName,
    required this.recipientPhone,
    required this.amount,
    required this.note,
    required this.isDark,
  });

  Color get _primary =>
      isDark ? const Color(0xFFFF6A4A) : const Color(0xFFE0533C);
  Color get _surface => isDark ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _bg => isDark ? const Color(0xFF141218) : const Color(0xFFFCFAF6);
  Color get _textPri => isDark ? Colors.white : const Color(0xFF1E2022);
  Color get _textSec =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);

  Future<void> _handle(BuildContext context, String method) async {
    // Luôn copy sẵn thông tin để người dùng dán nhanh.
    await PaymentLauncher.copyTransferInfo(
      recipientPhone: recipientPhone,
      amount: amount,
      note: note,
    );

    bool ok = false;
    if (method == 'momo') {
      ok = await PaymentLauncher.launchMomo(recipientPhone);
    } else if (method == 'zalopay') {
      ok = await PaymentLauncher.launchZaloPay(recipientPhone);
    }

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? _primary : Colors.blueGrey,
        content: Text(
          ok
              ? 'Đã mở app — thông tin chuyển khoản đã được copy sẵn'
              : 'Chưa tìm thấy app — đã copy thông tin để bạn chuyển tay',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grip
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _textSec.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Amount + recipient
              Text(
                'payment.transfer_to'.tr(),
                style: AppFonts.body(fontSize: 13, color: _textSec),
              ),
              const SizedBox(height: 4),
              Text(
                recipientName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textPri,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                recipientPhone,
                style: AppFonts.body(fontSize: 13, color: _textSec),
              ),
              const SizedBox(height: 14),
              Text(
                '${amount.toStringAsFixed(0)} đ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),

              // Methods
              _PayOption(
                icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
                label: 'Momo',
                sublabel: 'payment.open_momo'.tr(),
                bg: const Color(0xFFA50064),
                surface: _surface,
                textPri: _textPri,
                textSec: _textSec,
                isDark: isDark,
                onTap: () => _handle(context, 'momo'),
              ),
              const SizedBox(height: 10),
              _PayOption(
                icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
                label: 'ZaloPay',
                sublabel: 'payment.open_zalopay'.tr(),
                bg: const Color(0xFF0068FF),
                surface: _surface,
                textPri: _textPri,
                textSec: _textSec,
                isDark: isDark,
                onTap: () => _handle(context, 'zalopay'),
              ),
              const SizedBox(height: 10),
              _PayOption(
                icon: PhosphorIcons.copy(),
                label: 'Sao chép thông tin',
                sublabel: 'SĐT • số tiền • ghi chú',
                bg: _textSec,
                surface: _surface,
                textPri: _textPri,
                textSec: _textSec,
                isDark: isDark,
                onTap: () async {
                  await PaymentLauncher.copyTransferInfo(
                    recipientPhone: recipientPhone,
                    amount: amount,
                    note: note,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: _primary,
                      content: Text('payment.copied'.tr()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color bg;
  final Color surface;
  final Color textPri;
  final Color textSec;
  final bool isDark;
  final VoidCallback onTap;

  const _PayOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.bg,
    required this.surface,
    required this.textPri,
    required this.textSec,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: bg, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: AppFonts.body(fontSize: 12, color: textSec),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: textSec),
          ],
        ),
      ),
    );
  }
}
