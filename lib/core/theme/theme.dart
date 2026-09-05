import 'package:flutter/material.dart';
import 'app_fonts.dart';
import 'gen_z_tokens.dart';
import 'theme_provider.dart';

/// Theme Gen Z Neo-Brutalist: khối màu đặc, viền ink dày, hard shadow,
/// heading Space Grotesk 800, số liệu Space Mono.
class TripMateTheme {
  // ── Active theme states ─────────────────────────────────────────────────────
  static AppAccent _activeAccent = AppAccent.mint;
  static ThemeMode activeThemeMode = ThemeMode.light;

  static set activeAccent(AppAccent accent) => _activeAccent = accent;

  // ── Dynamic getters driven by current accent ────────────────────────────────
  static Color get lightPrimary => _activeAccent.accent;
  static Color get lightSecondary => _activeAccent.pair;
  static Color get lightTertiary => GenZTokens.lilac;
  static Color get lightBackground => _activeAccent.lightBackground;
  static Color get lightSurface => GenZTokens.paper;
  static Color get lightTextPrimary => GenZTokens.ink;
  static Color get lightTextSecondary => GenZTokens.inkSoft;

  static Color get darkPrimary => _activeAccent.accent;
  static Color get darkSecondary => _activeAccent.pair;
  static Color get darkTertiary => GenZTokens.lilac;
  static Color get darkBackground => GenZTokens.creamDark;
  static Color get darkSurface => GenZTokens.paperDark;
  static Color get darkSurfaceLow => const Color(0xFF15120D);
  static Color get darkSurfaceHigh => const Color(0xFF2E2820);
  static Color get darkSurfaceHighest => const Color(0xFF383126);
  static Color get darkTextPrimary => GenZTokens.inkDark;
  static Color get darkTextSecondary => GenZTokens.inkSoftDark;

  // ── Shared ──────────────────────────────────────────────────────────────────
  static const double radiusCard = GenZTokens.radiusCard;
  static const double radiusButton = GenZTokens.radiusButton;
  static const double radiusChip = GenZTokens.radiusPill;

  static ThemeData get lightTheme => buildLight(_activeAccent);
  static ThemeData get darkTheme => buildDark(_activeAccent);

  // ── Light theme ─────────────────────────────────────────────────────────────
  static ThemeData buildLight(AppAccent accent) {
    _activeAccent = accent;

    return _build(
      brightness: Brightness.light,
      accent: accent.accent,
      onAccent: accent.onAccent,
      accentSoft: accent.lightSoft,
      background: accent.lightBackground,
      surface: GenZTokens.paper,
      ink: GenZTokens.ink,
      inkSoft: GenZTokens.inkSoft,
    );
  }

  // ── Dark theme ──────────────────────────────────────────────────────────────
  static ThemeData buildDark(AppAccent accent) {
    _activeAccent = accent;

    return _build(
      brightness: Brightness.dark,
      accent: accent.accent,
      onAccent: accent.onAccent,
      accentSoft: accent.lightSoft,
      background: GenZTokens.creamDark,
      surface: GenZTokens.paperDark,
      ink: GenZTokens.inkDark,
      inkSoft: GenZTokens.inkSoftDark,
    );
  }

  // ── Core builder ────────────────────────────────────────────────────────────
  static ThemeData _build({
    required Brightness brightness,
    required Color accent,
    required Color onAccent,
    required Color accentSoft,
    required Color background,
    required Color surface,
    required Color ink,
    required Color inkSoft,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: onAccent,
        secondary: accentSoft,
        onSecondary: onAccent,
        tertiary: GenZTokens.lilac,
        onTertiary: onAccent,
        error: GenZTokens.red,
        onError: GenZTokens.paper,
        surface: surface,
        onSurface: ink,
        onSurfaceVariant: inkSoft,
        outline: ink,
      ),
      textTheme: _buildTextTheme(ink, inkSoft),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ink, size: 26),
        titleTextStyle: AppFonts.heading(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(GenZTokens.radiusCard),
          ),
          side: BorderSide(color: ink, width: GenZTokens.borderWidth),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(accent),
          foregroundColor: WidgetStatePropertyAll(onAccent),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(GenZTokens.buttonPadding),
          side: WidgetStatePropertyAll(
            BorderSide(color: ink, width: GenZTokens.borderWidth),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(GenZTokens.radiusButton),
              ),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            AppFonts.heading(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: ink, width: GenZTokens.borderWidth),
          padding: GenZTokens.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(GenZTokens.radiusButton),
            ),
          ),
          textStyle: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: AppFonts.heading(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: GenZTokens.inputPadding,
        labelStyle: AppFonts.body(color: inkSoft, fontWeight: FontWeight.w600),
        hintStyle: AppFonts.body(color: inkSoft, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          borderSide: BorderSide(color: ink, width: GenZTokens.borderWidthThin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          borderSide: BorderSide(color: ink, width: GenZTokens.borderWidthThin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          borderSide: BorderSide(
            color: accent,
            width: GenZTokens.borderWidthFocus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          borderSide: const BorderSide(
            color: GenZTokens.red,
            width: GenZTokens.borderWidthThin,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentSoft,
        side: BorderSide(color: ink, width: GenZTokens.borderWidthThin),
        shape: const StadiumBorder(),
        labelStyle: AppFonts.mono(
          color: ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(color: ink, thickness: 2, space: 0),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: ink,
        unselectedItemColor: inkSoft,
        selectedLabelStyle: AppFonts.heading(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppFonts.body(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: AppFonts.body(
          color: ink,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          side: BorderSide(color: ink, width: GenZTokens.borderWidthThin),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: ink, width: GenZTokens.borderWidth),
        ),
      ),
    );
  }

  // ── Text theme: Baloo 2 display + Nunito body + Space Mono số liệu ────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return AppFonts.bodyTextTheme().copyWith(
      displayLarge: AppFonts.heading(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.5,
        height: 1.05,
      ),
      displayMedium: AppFonts.heading(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.5,
        height: 1.05,
      ),
      titleLarge: AppFonts.heading(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.5,
      ),
      titleMedium: AppFonts.heading(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleSmall: AppFonts.heading(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      bodyLarge: AppFonts.body(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyMedium: AppFonts.body(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelLarge: AppFonts.heading(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      labelSmall: AppFonts.mono(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: secondary,
      ),
    );
  }

  /// Style mono cho số tiền / ngày / giờ ("$1,140", "9:41").
  static TextStyle mono({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) => AppFonts.mono(fontSize: fontSize, fontWeight: fontWeight, color: color);
}
