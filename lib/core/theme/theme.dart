import 'package:flutter/material.dart';
import 'app_fonts.dart';
import 'gen_z_tokens.dart';
import 'theme_provider.dart';

/// Theme TripMate mới (A×B: sáng kem, tối graphite).
/// Nguồn sự thật duy nhất: REFACTOR_UI_SPEC.md.
class TripMateTheme {
  // ── Active theme states ─────────────────────────────────────────────────────
  static AppAccent _activeAccent = AppAccent.mint;
  static ThemeMode activeThemeMode = ThemeMode.light;

  static set activeAccent(AppAccent accent) => _activeAccent = accent;

  // ── Dynamic getters driven by current accent ────────────────────────────────
  static Color get lightPrimary => _activeAccent.accent;
  static Color get lightSecondary => _activeAccent.pair;
  static Color get lightTertiary => GenZTokens.chart3;
  static Color get lightBackground => GenZTokens.cream;
  static Color get lightSurface => GenZTokens.paper;
  static Color get lightTextPrimary => GenZTokens.ink;
  static Color get lightTextSecondary => GenZTokens.inkSoft;

  static Color get darkPrimary => _activeAccent.darkAccent;
  static Color get darkSecondary => _activeAccent.pair;
  static Color get darkTertiary => GenZTokens.chart3;
  static Color get darkBackground => GenZTokens.creamDark;
  static Color get darkSurface => GenZTokens.paperDark;
  static Color get darkSurfaceLow => const Color(0xFF141617);
  static Color get darkSurfaceHigh => const Color(0xFF25292B);
  static Color get darkSurfaceHighest => const Color(0xFF2E3235);
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
      background: GenZTokens.cream,
      surface: GenZTokens.paper,
      line: GenZTokens.line,
      fill: GenZTokens.fill,
      ink: GenZTokens.ink,
      inkSoft: GenZTokens.inkSoft,
    );
  }

  // ── Dark theme ──────────────────────────────────────────────────────────────
  static ThemeData buildDark(AppAccent accent) {
    _activeAccent = accent;

    return _build(
      brightness: Brightness.dark,
      accent: accent.darkAccent,
      onAccent: accent.darkOnAccent,
      accentSoft: GenZTokens.accentSoftDark,
      background: GenZTokens.creamDark,
      surface: GenZTokens.paperDark,
      line: GenZTokens.lineDark,
      fill: GenZTokens.fillDark,
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
    required Color line,
    required Color fill,
    required Color ink,
    required Color inkSoft,
  }) {
    final isDark = brightness == Brightness.dark;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

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
        primaryContainer: accentSoft,
        onPrimaryContainer: isDark ? GenZTokens.onAccentSoftDark : GenZTokens.onAccentSoft,
        secondary: accentSoft,
        onSecondary: ink,
        tertiary: GenZTokens.chart3,
        onTertiary: onAccent,
        error: danger,
        onError: onAccent,
        surface: surface,
        onSurface: ink,
        onSurfaceVariant: inkSoft,
        outline: line,
      ),
      textTheme: _buildTextTheme(ink, inkSoft),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ink, size: 24),
        titleTextStyle: AppFonts.heading(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
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
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(accent),
          foregroundColor: WidgetStatePropertyAll(onAccent),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          padding: const WidgetStatePropertyAll(GenZTokens.buttonPadding),
          side: const WidgetStatePropertyAll(BorderSide.none),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(GenZTokens.radiusButton),
              ),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            AppFonts.heading(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
          padding: GenZTokens.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(GenZTokens.radiusButton),
            ),
          ),
          textStyle: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: AppFonts.heading(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fill,
        contentPadding: GenZTokens.inputPadding,
        labelStyle: AppFonts.body(color: inkSoft, fontWeight: FontWeight.w500),
        hintStyle: AppFonts.body(color: inkSoft, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          borderSide: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          borderSide: BorderSide(color: line, width: GenZTokens.borderWidthThin),
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
          borderSide: BorderSide(
            color: danger,
            width: GenZTokens.borderWidthThin,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: fill,
        side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        shape: const StadiumBorder(),
        labelStyle: AppFonts.body(
          color: inkSoft,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 0),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: inkSoft,
        selectedLabelStyle: AppFonts.heading(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppFonts.body(
          fontSize: 12,
          fontWeight: FontWeight.w400,
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
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
      ),
    );
  }

  // ── Text theme: Instrument Sans display/body + Space Mono số liệu ──────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return AppFonts.bodyTextTheme().copyWith(
      displayLarge: AppFonts.heading(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.2,
      ),
      displayMedium: AppFonts.heading(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.2,
      ),
      displaySmall: AppFonts.heading(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.2,
      ),
      titleLarge: AppFonts.heading(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.2,
      ),
      titleMedium: AppFonts.heading(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: AppFonts.heading(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: AppFonts.body(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyMedium: AppFonts.body(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      bodySmall: AppFonts.body(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: AppFonts.heading(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: AppFonts.body(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: AppFonts.mono(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w700,
        color: secondary,
      ),
    );
  }

  /// Style mono cho số tiền / ngày / giờ ("$1,140", "9:41").
  static TextStyle mono({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) => AppFonts.mono(fontSize: fontSize, fontWeight: fontWeight, color: color);
}
