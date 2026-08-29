import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/auth_provider.dart';

/// Quyền riêng tư & Tài khoản (PDPD - NĐ 13/2023).
/// Gồm: tóm tắt chính sách, link điều khoản, và xoá tài khoản gọi BE thật.
class AccountPrivacyScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const AccountPrivacyScreen({super.key, this.isDarkMode = false});

  @override
  ConsumerState<AccountPrivacyScreen> createState() =>
      _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends ConsumerState<AccountPrivacyScreen> {
  bool _deleting = false;

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _primary =>
      widget.isDarkMode ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
  Color get _textPri => _ink;
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  Future<void> _confirmDelete() async {
    HapticFeedback.heavyImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xoá tài khoản?',
          style: AppFonts.heading(fontWeight: FontWeight.w800, color: _textPri),
        ),
        content: Text(
          'Toàn bộ dữ liệu của bạn sẽ bị xoá và không thể khôi phục. '
          'Bạn sẽ bị đăng xuất ngay sau đó.',
          style: AppFonts.body(color: _textSec, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: _textSec),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá vĩnh viễn'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _deleting = true);
    try {
      await ref.read(apiClientProvider).deleteData('/users/me');
      await ref.read(authProvider.notifier).logout();
      // Router redirect tự đưa về /auth khi token bị xoá.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quyền riêng tư & Tài khoản',
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
            title: 'Dữ liệu của bạn được bảo vệ',
            body:
                'TripMate chỉ thu thập dữ liệu cần thiết để chạy ứng dụng (hồ sơ, '
                'chuyến đi, chi tiêu, ảnh kỷ niệm). Dữ liệu vị trí & camera chỉ dùng '
                'khi bạn cho phép. Chúng tôi không bán dữ liệu cho bên thứ ba.',
          ),
          _linkTile(Icons.description_outlined, 'Chính sách quyền riêng tư'),
          _linkTile(Icons.gavel_outlined, 'Điều khoản sử dụng'),
          _linkTile(Icons.download_outlined, 'Yêu cầu bản sao dữ liệu của tôi'),
          const SizedBox(height: 28),

          // Danger zone
          Text(
            'Vùng nguy hiểm',
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFD8422B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _ink, width: 2.5),
              boxShadow: [BoxShadow(color: _ink, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xoá tài khoản',
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFFFDF5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xoá vĩnh viễn tài khoản và toàn bộ dữ liệu liên quan.',
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFDF5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFDF5),
                      foregroundColor: const Color(0xFFD8422B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF141210),
                          width: 2,
                        ),
                      ),
                    ),
                    onPressed: _deleting ? null : _confirmDelete,
                    icon: _deleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFD8422B),
                            ),
                          )
                        : const Icon(Icons.delete_forever),
                    label: Text(
                      _deleting ? 'Đang xoá...' : 'Xoá tài khoản của tôi',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ink, width: 2),
        boxShadow: [BoxShadow(color: _ink, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textPri,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: _textSec,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label — sẽ mở trang web chính thức')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _ink, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: _textSec, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPri,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, size: 14, color: _textSec),
          ],
        ),
      ),
    );
  }
}
