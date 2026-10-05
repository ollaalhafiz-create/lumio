import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumio_palette.dart';

/// Application theme for Lumio.
///
/// The palette is the bright, gamified "Lumio" identity defined in
/// [LumioPalette]: fresh green as the brand, turquoise and cyan for
/// interactive elements, soft gold for rewards, coral for challenges and soft
/// purple for special sections — all sitting on white or a barely-tinted
/// background.
///
/// Uses the bundled Cairo variable font. Cairo covers Arabic, Latin and
/// digits, so a single family serves both languages.
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Cairo';

  /// Seed colour for the Material 3 scheme. Kept as the brand green so any
  /// surface Material generates on its own still harmonises with the app.
  static const Color seed = LumioPalette.green;

  /// Corner radius used by cards and sheets.
  static const double radius = 20;

  /// Builds a [ThemeData] for the given brightness.
  ///
  /// [textDirection] is applied to the theme so that direction-dependent
  /// widgets (lists, steppers, progress indicators) mirror correctly even
  /// before the ambient [Directionality] is resolved.
  static ThemeData light({TextDirection textDirection = TextDirection.rtl}) =>
      _build(Brightness.light, textDirection);

  static ThemeData dark({TextDirection textDirection = TextDirection.rtl}) =>
      _build(Brightness.dark, textDirection);

  /// The accent tokens for a brightness, exposed through
  /// [ThemeData.extensions].
  static LumioAccents accentsFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? LumioAccents.dark()
          : LumioAccents.light();

  static ThemeData _build(Brightness brightness, TextDirection textDirection) {
    final bool isDark = brightness == Brightness.dark;
    final LumioAccents accents = accentsFor(brightness);

    final Color ink = accents.ink;
    final Color muted = accents.inkMuted;
    final Color background =
        isDark ? LumioPalette.backgroundDark : LumioPalette.background;
    final Color surface = isDark ? LumioPalette.surfaceDark : LumioPalette.surface;
    final Color border =
        isDark ? LumioPalette.outlineDark : LumioPalette.outline;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(
      primary: accents.brand,
      onPrimary: Colors.white,
      primaryContainer: accents.brandTint,
      onPrimaryContainer: ink,
      secondary: accents.aqua,
      onSecondary: Colors.white,
      secondaryContainer: accents.aquaTint,
      onSecondaryContainer: ink,
      tertiary: accents.goldDeep,
      onTertiary: Colors.white,
      tertiaryContainer: accents.goldTint,
      onTertiaryContainer: ink,
      error: isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
      surfaceContainerLowest: surface,
      surfaceContainerLow: isDark
          ? LumioPalette.backgroundDark
          : LumioPalette.background,
      surfaceContainer: isDark
          ? LumioPalette.surfaceDark
          : LumioPalette.surfaceMuted,
      surfaceContainerHigh: isDark
          ? const Color(0xFF1B2C24)
          : const Color(0xFFEDF5F0),
    );

    final TextTheme textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: accents.brandTint,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? accents.brand
                : muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            final bool selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontVariations: const <FontVariation>[FontVariation('wght', 700)],
              color: selected ? accents.brand : muted,
            );
          },
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: border,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: accents.brand,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(color: muted),
      ),
      // Buttons -----------------------------------------------------------------
      // The plain Material buttons carry the brand colour and a soft coloured
      // shadow so they read as raised, tappable and energetic. The gradient
      // variant lives in `lumio_components.dart` as `LumioGradientButton`.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          textStyle: textTheme.labelLarge,
          backgroundColor: accents.brand,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: accents.brand.withValues(alpha: 0.35),
          overlayColor: Colors.white.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 54),
          textStyle: textTheme.labelLarge,
          elevation: 0,
          backgroundColor: surface,
          foregroundColor: accents.brand,
          shadowColor: accents.brand.withValues(alpha: 0.28),
          overlayColor: accents.brandTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),
          textStyle: textTheme.labelLarge,
          foregroundColor: accents.brand,
          side: BorderSide(color: accents.brand.withValues(alpha: 0.45)),
          overlayColor: accents.brandTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(color: accents.brand),
          foregroundColor: accents.brand,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: accents.brand),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accents.brand,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      // Inputs and selection -----------------------------------------------------
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accents.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accents.brandTint,
        selectedColor: accents.brandTint,
        labelStyle: textTheme.labelMedium?.copyWith(color: ink),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: ink),
        side: BorderSide(color: accents.brand.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: accents.coral,
        textColor: Colors.white,
        textStyle: textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? accents.brand
              : border,
        ),
        trackOutlineColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? accents.brand
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
        side: BorderSide(color: accents.brand.withValues(alpha: 0.5), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? accents.brand
              : null,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accents.brand,
        linearTrackColor: accents.brandTint,
        circularTrackColor: accents.brandTint,
        linearMinHeight: 10,
        borderRadius: BorderRadius.circular(999),
        strokeWidth: 6,
        strokeCap: StrokeCap.round,
      ),
      // Surfaces -----------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: muted),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: accents.brand.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: accents.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: accents.goldBright,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accents.brand,
        unselectedLabelColor: muted,
        indicatorColor: accents.brand,
        dividerColor: border,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: accents.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
      extensions: <ThemeExtension<dynamic>>[accents],
    );
  }

  /// Cairo is a variable font; the `wght` axis is selected explicitly through
  /// [FontVariation] so Arabic glyphs keep their proper weight instead of being
  /// synthetically emboldened (which breaks Arabic ligatures).
  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle style(double weight, double size, FontWeight fw, {double? height}) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: fw,
          fontVariations: <FontVariation>[FontVariation('wght', weight)],
          color: scheme.onSurface,
          height: height ?? 1.5,
        );

    return TextTheme(
      displayLarge: style(800, 40, FontWeight.w800),
      displayMedium: style(800, 34, FontWeight.w800),
      displaySmall: style(800, 30, FontWeight.w800),
      headlineLarge: style(800, 28, FontWeight.w800),
      headlineMedium: style(700, 24, FontWeight.w700),
      headlineSmall: style(700, 20, FontWeight.w700),
      titleLarge: style(700, 20, FontWeight.w700),
      titleMedium: style(700, 16, FontWeight.w700),
      titleSmall: style(700, 14, FontWeight.w700),
      bodyLarge: style(400, 16, FontWeight.w400, height: 1.6),
      bodyMedium: style(400, 14, FontWeight.w400, height: 1.6),
      bodySmall: style(400, 12, FontWeight.w400, height: 1.6),
      labelLarge: style(700, 15, FontWeight.w700),
      labelMedium: style(700, 13, FontWeight.w700),
      labelSmall: style(600, 11, FontWeight.w600),
    );
  }
}