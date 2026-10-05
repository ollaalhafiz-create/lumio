
import 'package:flutter/material.dart';

/// Application theme for Lumio.
///
/// Uses the bundled Cairo variable font. Cairo covers Arabic, Latin and
/// digits, so a single family serves both languages.
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Cairo';

  /// Seed colour for the Material 3 scheme.
  static const Color seed = Color(0xFF00695C);

  /// Builds a [ThemeData] for the given brightness.
  ///
  /// [textDirection] is applied to the theme so that direction-dependent
  /// widgets (lists, steppers, progress indicators) mirror correctly even
  /// before the ambient [Directionality] is resolved.
  static ThemeData light({TextDirection textDirection = TextDirection.rtl}) =>
      _build(Brightness.light, textDirection);

  static ThemeData dark({TextDirection textDirection = TextDirection.rtl}) =>
      _build(Brightness.dark, textDirection);

  static ThemeData _build(Brightness brightness, TextDirection textDirection) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final TextTheme textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.labelMedium,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant,
      ),
    );
  }

  /// Cairo is a variable font; the `wght` axis is selected explicitly through
  /// [FontVariation] so Arabic glyphs keep their proper weight instead of being
  /// synthetically emboldened (which breaks Arabic ligatures).
  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle style(double weight, double size, FontWeight fw) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: fw,
          fontVariations: [FontVariation('wght', weight)],
          color: scheme.onSurface,
          height: 1.6,
        );

    return TextTheme(
      displayLarge: style(700, 40, FontWeight.w700),
      displayMedium: style(700, 34, FontWeight.w700),
      displaySmall: style(700, 30, FontWeight.w700),
      headlineLarge: style(700, 28, FontWeight.w700),
      headlineMedium: style(700, 24, FontWeight.w700),
      headlineSmall: style(600, 20, FontWeight.w600),
      titleLarge: style(700, 20, FontWeight.w700),
      titleMedium: style(600, 16, FontWeight.w600),
      titleSmall: style(600, 14, FontWeight.w600),
      bodyLarge: style(400, 16, FontWeight.w400),
      bodyMedium: style(400, 14, FontWeight.w400),
      bodySmall: style(400, 12, FontWeight.w400),
      labelLarge: style(600, 15, FontWeight.w600),
      labelMedium: style(500, 13, FontWeight.w500),
      labelSmall: style(500, 11, FontWeight.w500),
    );
  }
}