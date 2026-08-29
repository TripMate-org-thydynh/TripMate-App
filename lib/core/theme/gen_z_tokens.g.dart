// GENERATED FROM design/tokens.json — DO NOT EDIT
import 'package:flutter/material.dart';

/// Token gốc sinh từ design/tokens.json.
/// Không sửa file này — sửa tokens.json rồi chạy: node design/build-tokens.mjs
class DsTokens {
  DsTokens._();

  // ── Base ──────────────────────────────────────────
  static const Color ink = Color(0xFF141210);
  static const Color inkSoft = Color(0xFF4A453E);
  static const Color cream = Color(0xFFFDF6D3);
  static const Color paper = Color(0xFFFFFDF5);

  // ── Dark ──────────────────────────────────────────
  static const Color inkDark = Color(0xFFFDF6D3);
  static const Color inkSoftDark = Color(0xFFB8AE9C);
  static const Color creamDark = Color(0xFF1A1712);
  static const Color paperDark = Color(0xFF262019);

  // ── Palette ───────────────────────────────────────
  static const Color yellow = Color(0xFFFFD84D);
  static const Color orange = Color(0xFFF5822B);
  static const Color green = Color(0xFF1FA85C);
  static const Color magenta = Color(0xFFD6248C);
  static const Color purple = Color(0xFF8B4DE8);
  static const Color red = Color(0xFFD8422B);
  static const Color lilac = Color(0xFFC9B8FF);
  static const Color blue = Color(0xFF3D8BFF);
  static const Color pink = Color(0xFFFFA8D2);

  // ── Semantic ──────────────────────────────────────
  static const Color success = Color(0xFF1FA85C);
  static const Color warning = Color(0xFFFFD84D);
  static const Color danger = Color(0xFFD8422B);
  static const Color info = Color(0xFF8B4DE8);

  // ── Border ────────────────────────────────────────
  static const double borderWidthThin = 2;
  static const double borderWidth = 2.5;
  static const double borderWidthFocus = 3;

  // ── Shadow ────────────────────────────────────────
  static const double shadowOffsetX = 0;
  static const double shadowOffsetY = 4;
  static const double shadowBlur = 0;

  // ── Radius ────────────────────────────────────────
  static const double radiusInput = 12;
  static const double radiusButton = 14;
  static const double radiusCard = 20;
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
  static const String fontHeading = 'Baloo 2';
  static const String fontBody = 'Nunito';
  static const String fontMono = 'Space Mono';
}

/// Dữ liệu preset accent.
class DsAccentPreset {
  final Color primary;
  final Color onPrimary;
  final Color pair;
  final Color bg;
  final Color soft;

  const DsAccentPreset({
    required this.primary,
    required this.onPrimary,
    required this.pair,
    required this.bg,
    required this.soft,
  });
}

/// Map 4 preset accent — key khớp AppAccent.name.
const Map<String, DsAccentPreset> dsAccents = {
  'mint': DsAccentPreset(
    primary: Color(0xFFFFD84D),
    onPrimary: Color(0xFF141210),
    pair: Color(0xFF8B4DE8),
    bg: Color(0xFFFDF6D3),
    soft: Color(0xFFFFEFAE),
  ),
  'sun': DsAccentPreset(
    primary: Color(0xFF1FA85C),
    onPrimary: Color(0xFF141210),
    pair: Color(0xFFFFD84D),
    bg: Color(0xFFEBF7DE),
    soft: Color(0xFFC9EDBA),
  ),
  'pastel': DsAccentPreset(
    primary: Color(0xFF3D8BFF),
    onPrimary: Color(0xFF141210),
    pair: Color(0xFFFFA8D2),
    bg: Color(0xFFE7F1FD),
    soft: Color(0xFFC5DEFF),
  ),
  'grape': DsAccentPreset(
    primary: Color(0xFFF5822B),
    onPrimary: Color(0xFF141210),
    pair: Color(0xFF141210),
    bg: Color(0xFFFDEEDC),
    soft: Color(0xFFFFD9B3),
  ),
  'neon': DsAccentPreset(
    primary: Color(0xFFFF2E93),
    onPrimary: Color(0xFF141210),
    pair: Color(0xFF3D8BFF),
    bg: Color(0xFFFDE7F1),
    soft: Color(0xFFFFC2DE),
  ),
  'pine': DsAccentPreset(
    primary: Color(0xFF0F766E),
    onPrimary: Color(0xFFFFFFFF),
    pair: Color(0xFFFFD84D),
    bg: Color(0xFFE4F2F0),
    soft: Color(0xFFB9DDD9),
  ),
  'cyber': DsAccentPreset(
    primary: Color(0xFF3D8BFF),
    onPrimary: Color(0xFF141210),
    pair: Color(0xFFFF2E93),
    bg: Color(0xFFE4EEFD),
    soft: Color(0xFFBBD5FF),
  ),
};
