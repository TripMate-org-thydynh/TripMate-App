import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Màn hình xem trước giao diện và bảng màu chuẩn của TripMate (A×B: Sáng kem / Tối graphite).
/// Nguồn sự thật duy nhất: REFACTOR_UI_SPEC.md.
class ThemePreviewScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final String? initialTheme;

  const ThemePreviewScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
    this.initialTheme,
  });

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDarkMode;
  }

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
    widget.onThemeToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = _isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = _isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final ink = _isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = _isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = _isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = _isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = _isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final success = _isDark ? GenZTokens.successDark : GenZTokens.success;
    final warning = _isDark ? GenZTokens.warningDark : GenZTokens.warning;
    final info = _isDark ? GenZTokens.infoDark : GenZTokens.info;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.theme_preview'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isDark ? 'Chế độ sáng' : 'Chế độ tối',
            icon: Icon(
              _isDark ? PhosphorIcons.sun() : PhosphorIcons.moon(),
              color: ink,
            ),
            onPressed: _toggleTheme,
          ),
          const SizedBox(width: GenZTokens.space2),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(GenZTokens.space4),
        children: [
          // Tiêu đề bảng màu hiện tại
          Container(
            padding: const EdgeInsets.all(GenZTokens.space4),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: line, width: GenZTokens.borderWidthThin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                      ),
                      child: Icon(
                        _isDark ? PhosphorIcons.moonStars() : PhosphorIcons.sunHorizon(),
                        color: onAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: GenZTokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isDark
                                ? 'B — Tối graphite (Graphite & Xanh mòng két)'
                                : 'A — Sáng kem (Kem dịu & Đất nung)',
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isDark
                                ? 'Nền #141617 · Nhấn #5C9A90'
                                : 'Nền #F7F3EC · Nhấn #B4543A',
                            style: AppFonts.body(
                              fontSize: 12,
                              color: inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GenZTokens.space4),
                Text(
                  'Bảng màu tối giản, chuyên nghiệp theo đặc tả mới. Mỗi màn hình chỉ có duy nhất một điểm nhấn chính và các trạng thái ngữ nghĩa rõ ràng.',
                  style: AppFonts.body(
                    fontSize: 13,
                    color: inkSoft,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: GenZTokens.space4),

          // Thẻ xem trước giao diện mẫu
          Container(
            padding: const EdgeInsets.all(GenZTokens.space4),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: line, width: GenZTokens.borderWidthThin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xem trước thành phần UI',
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: GenZTokens.space3),

                // Mock chat / activity tile
                Container(
                  padding: const EdgeInsets.all(GenZTokens.space3),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                    border: Border.all(color: line, width: GenZTokens.borderWidthThin),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
                        ),
                        child: Icon(
                          PhosphorIcons.airplaneTilt(),
                          size: 20,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: GenZTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đà Lạt Săn Mây',
                              style: AppFonts.heading(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '3 ngày 2 đêm · 4 thành viên',
                              style: AppFonts.body(
                                fontSize: 12,
                                color: inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
                        ),
                        child: Text(
                          '+50 XP',
                          style: AppFonts.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: GenZTokens.space4),

                // Linear progress
                Text(
                  'Tiến độ chuẩn bị: 75%',
                  style: AppFonts.body(
                    fontSize: 13,
                    color: inkSoft,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  child: LinearProgressIndicator(
                    value: 0.75,
                    minHeight: 8,
                    backgroundColor: fill,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),

                const SizedBox(height: GenZTokens.space4),

                // Semantic tags
                Row(
                  children: [
                    _tag(success, 'Đã xác nhận', isDark: _isDark),
                    const SizedBox(width: GenZTokens.space2),
                    _tag(warning, 'Đang chờ duyệt', isDark: _isDark),
                    const SizedBox(width: GenZTokens.space2),
                    _tag(info, 'Thông tin', isDark: _isDark),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: GenZTokens.space5),

          // Nút hành động duy nhất của màn hình
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              child: Text(
                'profile.theme_apply'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: onAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(Color color, String label, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
      ),
      child: Text(
        label,
        style: AppFonts.body(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
