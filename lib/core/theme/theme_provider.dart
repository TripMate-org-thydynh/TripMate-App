import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app_fonts.dart';
import 'gen_z_tokens.dart';
import 'gen_z_tokens.g.dart';
import 'theme.dart';

// ── Accent presets (A×B: sáng kem, tối graphite) ────────────────────────────
// Tên enum giữ nguyên (key đã lưu trong SharedPreferences).
// Bảng màu mới: 7 sắc độ trầm cùng tông (REFACTOR_UI_SPEC.md mục 2).
enum AppAccent { mint, sun, pastel, grape, neon, pine, cyber }

/// Ba accent cuối phải đổi bằng XP mới dùng được. Bốn cái đầu luôn miễn phí.
const Set<AppAccent> kPremiumAccents = {
  AppAccent.neon,
  AppAccent.pine,
  AppAccent.cyber,
};

/// Khoá theme ở backend tương ứng với accent — để đối chiếu với `themes/mine`.
const Map<AppAccent, String> kAccentThemeId = {
  AppAccent.neon: 'theme-neon',
  AppAccent.pine: 'theme-pine',
  AppAccent.cyber: 'theme-cyber',
};

extension AppAccentX on AppAccent {
  String get key => name;

  // Lấy preset từ dsAccents
  DsAccentPreset get _preset => dsAccents[name]!;

  // Primary accent (CTA, chip, khối màu)
  Color get accent => _preset.primary;
  Color get primary => accent;
  Color get darkAccent => _preset.primaryDark;

  // Màu cặp phụ trợ: spec 2 yêu cầu cho bằng chính primary (tránh chọi màu)
  Color get pair => _preset.primary;

  // Chữ trên accent — theo contrast WCAG AA
  Color get onAccent => _preset.onPrimary;
  Color get darkOnAccent => _preset.onPrimaryDark;

  // Nền dùng chung nền kem, không nhuộm theo accent (spec mục 2)
  Color get lightBackground => GenZTokens.cream;

  // Surface soft cho chip/tag
  Color get lightSoft => _preset.soft;

  String get label {
    final key = const {
      AppAccent.mint: 'theme.accent_mint',
      AppAccent.sun: 'theme.accent_sun',
      AppAccent.pastel: 'theme.accent_pastel',
      AppAccent.grape: 'theme.accent_grape',
      AppAccent.neon: 'theme.accent_neon',
      AppAccent.pine: 'theme.accent_pine',
      AppAccent.cyber: 'theme.accent_cyber',
    }[this]!;
    final trValue = key.tr();
    if (trValue != key) return trValue;
    return const {
      AppAccent.mint: 'Đất nung',
      AppAccent.sun: 'Hổ phách',
      AppAccent.pastel: 'Xanh biển sâu',
      AppAccent.grape: 'Mận chín',
      AppAccent.neon: 'Rêu',
      AppAccent.pine: 'Thông',
      AppAccent.cyber: 'Thạch mực',
    }[this]!;
  }
}

// ── ThemeMode provider ────────────────────────────────────────────────────────
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  // Default LIGHT: sáng kem (cream) là mode chính; dark (graphite) là tuỳ chọn.
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  @override
  set state(ThemeMode value) {
    super.state = value;
    TripMateTheme.activeThemeMode = value;
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeKey);
      if (savedMode == 'light') {
        state = ThemeMode.light;
      } else if (savedMode == 'dark') {
        state = ThemeMode.dark;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setString(_themeKey, 'light');
    } else {
      state = ThemeMode.dark;
      await prefs.setString(_themeKey, 'dark');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setString(_themeKey, mode.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// ── Accent provider ───────────────────────────────────────────────────────────
class AccentNotifier extends StateNotifier<AppAccent> {
  AccentNotifier() : super(AppAccent.mint);

  @override
  set state(AppAccent value) {
    super.state = value;
    TripMateTheme.activeAccent = value;
  }

  // Đổi accent đã bỏ: không đọc giá trị đã lưu. Khoá `app_accent` vẫn để
  // nguyên trong SharedPreferences — xoá không cần thiết và không có lợi gì.
  @Deprecated('Đã bỏ tính năng đổi accent — xem REFACTOR_UI_SPEC.md mục 2')
  Future<void> setAccent(AppAccent accent) async {}
}

final accentProvider = StateNotifierProvider<AccentNotifier, AppAccent>((ref) {
  return AccentNotifier();
});

// ── Font Family provider ──────────────────────────────────────────────────────
extension AppFontOptionX on AppFontOption {
  String get key => name;

  String get label {
    final key = const {
      AppFontOption.playful: 'theme.font_playful',
      AppFontOption.curly: 'theme.font_curly',
      AppFontOption.handwriting: 'theme.font_handwriting',
      AppFontOption.modern: 'theme.font_modern',
      AppFontOption.brutalist: 'theme.font_brutalist',
      AppFontOption.clean: 'theme.font_clean',
    }[this]!;
    return key.tr();
  }

  String get description {
    final key = const {
      AppFontOption.playful: 'theme.desc_playful',
      AppFontOption.curly: 'theme.desc_curly',
      AppFontOption.handwriting: 'theme.desc_handwriting',
      AppFontOption.modern: 'theme.desc_modern',
      AppFontOption.brutalist: 'theme.desc_brutalist',
      AppFontOption.clean: 'theme.desc_clean',
    }[this]!;
    return key.tr();
  }
}

class FontNotifier extends StateNotifier<AppFontOption> {
  static const _fontKey = 'app_font_option';

  FontNotifier() : super(AppFontOption.modern) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_fontKey);
      if (saved != null) {
        final match = AppFontOption.values
            .where((f) => f.key == saved)
            .firstOrNull;
        if (match != null) {
          state = match;
          AppFonts.currentOption = match;
        }
      }
    } catch (_) {}
  }

  Future<void> setFontOption(AppFontOption option) async {
    final prefs = await SharedPreferences.getInstance();
    state = option;
    AppFonts.currentOption = option;
    await prefs.setString(_fontKey, option.key);
  }
}

final fontProvider = StateNotifierProvider<FontNotifier, AppFontOption>((ref) {
  return FontNotifier();
});
