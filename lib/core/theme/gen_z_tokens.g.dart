// Thư mục design/ và build-tokens.mjs không còn trong repo, file này nay bảo trì bằng tay.
import 'package:flutter/material.dart';

/// Design system tokens (A×B: sáng kem, tối graphite).
/// Nguồn sự thật duy nhất: REFACTOR_UI_SPEC.md.
class DsTokens {
  DsTokens._();

  // ── Nền và chữ ────────────────────────────────────
  static const Color cream = Color(0xFFF7F3EC);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1C1A17);
  static const Color inkSoft = Color(0xFF6B655C);

  // ── Dark ──────────────────────────────────────────
  static const Color creamDark = Color(0xFF141617);
  static const Color paperDark = Color(0xFF1D2022);
  static const Color inkDark = Color(0xFFECE7DF);
  static const Color inkSoftDark = Color(0xFF9A948B);

  // ── Đường kẻ và nền chìm ─────────────────────────
  static const Color line = Color(0xFFE3DDD2);
  static const Color lineDark = Color(0xFF2E3235);
  static const Color fill = Color(0xFFF0EBE2);
  static const Color fillDark = Color(0xFF25292B);

  // ── Màu nhấn: sáng đất nung, tối xanh mòng két ────
  static const Color accent = Color(0xFFB4543A);
  static const Color accentDark = Color(0xFF5C9A90); // xanh mòng két (ảnh B), sáng hơn #4E8C82 để chữ trên paperDark đạt 4.5:1
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color onAccentDark = Color(0xFF0F1211);
  static const Color accentSoft = Color(0xFFF2E4DE);
  static const Color accentSoftDark = Color(0xFF1E2B28);
  // Chữ/icon trên nền accentSoft. Accent sáng chỉ đạt 3.96:1 trên accentSoft nên dùng bản đậm hơn.
  static const Color onAccentSoft = Color(0xFF9C4632);
  static const Color onAccentSoftDark = accentDark;

  // ── Màu ngữ nghĩa (trạng thái) ───────────────────
  static const Color success = Color(0xFF2F6D4F);
  static const Color successDark = Color(0xFF6FAF8C);
  static const Color warning = Color(0xFF9A6B12);
  static const Color warningDark = Color(0xFFD8A94A);
  static const Color danger = Color(0xFFA33A2C);
  static const Color dangerDark = Color(0xFFE0705C);
  static const Color info = Color(0xFF3A6073);
  static const Color infoDark = Color(0xFF84A9BC);

  // ── Màu dữ liệu (biểu đồ, phân loại) ──────────────
  static const Color chart1 = Color(0xFF4E7C6B);
  static const Color chart2 = Color(0xFFA8613F);
  static const Color chart3 = Color(0xFF7A6E8F);
  static const Color chart4 = Color(0xFF9A6B12);
  static const Color chart5 = Color(0xFF3A6073);
  static const Color chart6 = Color(0xFF8C5A4A);










  // ── Border ────────────────────────────────────────
  static const double borderWidthThin = 1;
  static const double borderWidth = 1.5;
  static const double borderWidthFocus = 2;

  // ── Shadow ────────────────────────────────────────
  static const double shadowOffsetX = 0;
  static const double shadowOffsetY = 2;
  static const double shadowBlur = 12;

  // ── Radius ────────────────────────────────────────
  static const double radiusInput = 10;
  static const double radiusButton = 10;
  static const double radiusCard = 14;
  static const double radiusPill = 999;

  // ── Spacing ───────────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  // ── Duration (milliseconds) ──────────────────────
  static const int durationFast = 150;
  static const int durationBase = 250;
  static const int durationSlow = 400;

  // ── Font ──────────────────────────────────────────
  static const String fontHeading = 'Instrument Sans';
  static const String fontBody = 'Instrument Sans';
  static const String fontMono = 'Space Mono';
}

/// Dữ liệu preset accent.
class DsAccentPreset {
  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color onPrimaryDark;
  final Color pair;
  final Color bg;
  final Color soft;

  const DsAccentPreset({
    required this.primary,
    Color? primaryDark,
    required this.onPrimary,
    Color? onPrimaryDark,
    required this.pair,
    required this.bg,
    required this.soft,
  })  : primaryDark = primaryDark ?? primary,
        onPrimaryDark = onPrimaryDark ?? onPrimary;
}

/// Bộ màu nhấn duy nhất. Tính năng đổi accent đã bỏ (REFACTOR_UI_SPEC.md mục 2).
const DsAccentPreset _kAccent = DsAccentPreset(
  primary: DsTokens.accent,
  primaryDark: DsTokens.accentDark,
  onPrimary: DsTokens.onAccent,
  onPrimaryDark: DsTokens.onAccentDark,
  pair: DsTokens.accent,
  bg: DsTokens.cream,
  soft: DsTokens.accentSoft,
);

/// Giữ đủ 7 key vì máy người dùng còn lưu tên preset cũ — mọi key trả cùng một bộ.
const Map<String, DsAccentPreset> dsAccents = {
  'mint': _kAccent,
  'sun': _kAccent,
  'pastel': _kAccent,
  'grape': _kAccent,
  'neon': _kAccent,
  'pine': _kAccent,
  'cyber': _kAccent,
};
