import 'package:flutter/material.dart';
import 'gen_z_tokens.g.dart';

/// Design tokens cho phong cách Gen Z Neo-Brutalist / Playful Sticker.
/// Nguyên tắc: khối màu đặc, viền ink dày, hard shadow lệch (0,4) blur 0,
/// chữ display 800–900, mono cho số liệu.
///
/// Giá trị lấy từ [DsTokens] (sinh tự động từ design/tokens.json).
/// Giữ nguyên API công khai để ~1900 call-site trong features/ không bị vỡ.
class GenZTokens {
  GenZTokens._();

  // ── Base ──────────────────────────────────────────────────────────────────
  static const Color cream = DsTokens.cream;
  static const Color ink = DsTokens.ink;
  static const Color inkSoft = DsTokens.inkSoft;
  static const Color paper = DsTokens.paper;

  // Dark-mode counterparts (giữ DNA: nền tối ấm, surface giấy tối, viền sáng kem)
  static const Color creamDark = DsTokens.creamDark;
  static const Color paperDark = DsTokens.paperDark;
  static const Color inkDark = DsTokens.inkDark; // "ink" trong dark = kem
  static const Color inkSoftDark = DsTokens.inkSoftDark;

  // ── Accent blocks ─────────────────────────────────────────────────────────
  static const Color yellow = DsTokens.yellow;
  static const Color orange = DsTokens.orange;
  static const Color green = DsTokens.green;
  static const Color magenta = DsTokens.magenta;
  static const Color purple = DsTokens.purple;
  static const Color red = DsTokens.red;
  static const Color lilac = DsTokens.lilac;
  static const Color blue = DsTokens.blue;
  static const Color pink = DsTokens.pink;

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = DsTokens.success;
  static const Color warning = DsTokens.warning;
  static const Color danger = DsTokens.danger;
  static const Color info = DsTokens.info;

  // ── Border & shadow ───────────────────────────────────────────────────────
  static const double borderWidth = DsTokens.borderWidth;
  static const double borderWidthThin = DsTokens.borderWidthThin;
  static const double borderWidthFocus = DsTokens.borderWidthFocus;

  static const Offset shadowOffset = Offset(
    DsTokens.shadowOffsetX,
    DsTokens.shadowOffsetY,
  );

  /// Hard shadow chuẩn: lệch xuống 4px, blur 0.
  static List<BoxShadow> hardShadow([Color color = ink]) => [
    BoxShadow(
      color: color,
      offset: shadowOffset,
      blurRadius: DsTokens.shadowBlur,
    ),
  ];

  /// Viền đen ngoài chữ để tăng độ tương phản (đặc biệt cho chữ màu vàng/vàng cam trên nền sáng)
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

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );
}
