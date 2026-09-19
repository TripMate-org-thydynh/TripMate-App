// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'gen_z_tokens.g.dart';

/// Design tokens theo bảng màu mới (A×B: sáng kem, tối graphite).
/// Nguồn sự thật duy nhất: REFACTOR_UI_SPEC.md.
///
/// Giá trị lấy từ [DsTokens].
/// Giữ nguyên API công khai để ~1900 call-site trong features/ không bị vỡ.
class GenZTokens {
  GenZTokens._();

  // ── Nền và chữ ────────────────────────────────────────────────────────────
  static const Color cream = DsTokens.cream;
  static const Color ink = DsTokens.ink;
  static const Color inkSoft = DsTokens.inkSoft;
  static const Color paper = DsTokens.paper;

  // ── Dark ──────────────────────────────────────────────────────────────────
  static const Color creamDark = DsTokens.creamDark;
  static const Color paperDark = DsTokens.paperDark;
  static const Color inkDark = DsTokens.inkDark;
  static const Color inkSoftDark = DsTokens.inkSoftDark;

  // ── Đường kẻ và nền chìm ─────────────────────────────────────────────────
  static const Color line = DsTokens.line;
  static const Color lineDark = DsTokens.lineDark;
  static const Color fill = DsTokens.fill;
  static const Color fillDark = DsTokens.fillDark;

  // ── Màu nhấn (duy nhất) ──────────────────────────────────────────────────
  static const Color accent = DsTokens.accent;
  static const Color accentDark = DsTokens.accentDark;
  static const Color onAccent = DsTokens.onAccent;
  static const Color onAccentDark = DsTokens.onAccentDark;
  static const Color accentSoft = DsTokens.accentSoft;
  static const Color accentSoftDark = DsTokens.accentSoftDark;
  static const Color onAccentSoft = DsTokens.onAccentSoft;
  static const Color onAccentSoftDark = DsTokens.onAccentSoftDark;

  // ── Màu ngữ nghĩa ─────────────────────────────────────────────────────────
  static const Color success = DsTokens.success;
  static const Color successDark = DsTokens.successDark;
  static const Color warning = DsTokens.warning;
  static const Color warningDark = DsTokens.warningDark;
  static const Color danger = DsTokens.danger;
  static const Color dangerDark = DsTokens.dangerDark;
  static const Color info = DsTokens.info;
  static const Color infoDark = DsTokens.infoDark;

  // ── Màu dữ liệu (biểu đồ, phân loại) ───────────────────────────────────────
  static const Color chart1 = DsTokens.chart1;
  static const Color chart2 = DsTokens.chart2;
  static const Color chart3 = DsTokens.chart3;
  static const Color chart4 = DsTokens.chart4;
  static const Color chart5 = DsTokens.chart5;
  static const Color chart6 = DsTokens.chart6;

  // ── 9 màu cũ (trỏ sang màu mới theo spec mục 1, giữ API để feature refactor dần) ──
  static const Color yellow = DsTokens.yellow;
  static const Color orange = DsTokens.orange;
  static const Color green = DsTokens.green;
  static const Color magenta = DsTokens.magenta;
  static const Color purple = DsTokens.purple;
  static const Color red = DsTokens.red;
  static const Color lilac = DsTokens.lilac;
  static const Color blue = DsTokens.blue;
  static const Color pink = DsTokens.pink;

  // ── Border & shadow ───────────────────────────────────────────────────────
  static const double borderWidth = DsTokens.borderWidth;
  static const double borderWidthThin = DsTokens.borderWidthThin;
  static const double borderWidthFocus = DsTokens.borderWidthFocus;

  static const Offset shadowOffset = Offset(
    DsTokens.shadowOffsetX,
    DsTokens.shadowOffsetY,
  );

  /// Bóng chuẩn theo spec mục 4:
  /// - Sáng: bóng mờ nhẹ (alpha 0.06, blur 12, offset(0, 2)).
  /// - Tối: không bóng (phân tách bằng viền lineDark).
  static List<BoxShadow> hardShadow([Color color = ink, bool isDark = false]) {
    if (isDark || color == inkDark) return const [];
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.06),
        offset: shadowOffset,
        blurRadius: DsTokens.shadowBlur,
      ),
    ];
  }

  /// Viền đen ngoài chữ để tăng độ tương phản (backward-compatibility).
  static List<Shadow> textOutline([Color color = ink]) => [
    Shadow(offset: const Offset(-1.2, -1.2), color: color),
    Shadow(offset: const Offset(1.2, -1.2), color: color),
    Shadow(offset: const Offset(1.2, 1.2), color: color),
    Shadow(offset: const Offset(-1.2, 1.2), color: color),
  ];

  // ── Radius ────────────────────────────────────────────────────────────────
  static const double radiusButton = DsTokens.radiusButton;
  static const double radiusInput = DsTokens.radiusInput;
  static const double radiusCard = DsTokens.radiusCard;
  static const double radiusPill = DsTokens.radiusPill;

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double space1 = DsTokens.space1;
  static const double space2 = DsTokens.space2;
  static const double space3 = DsTokens.space3;
  static const double space4 = DsTokens.space4;
  static const double space5 = DsTokens.space5;
  static const double space6 = DsTokens.space6;

  // ── Duration ──────────────────────────────────────────────────────────────
  static const int durationFast = DsTokens.durationFast;
  static const int durationBase = DsTokens.durationBase;
  static const int durationSlow = DsTokens.durationSlow;

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 14,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
}
