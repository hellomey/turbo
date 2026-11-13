import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// The three shipped themes (§10.3), built from one token source ([HmPalette]). Dark is the default.
/// Calm Mode and Lite Mode change behaviour and motion ([HmModes]), not tokens.
abstract final class HmTheme {
  static ThemeData dark() => fromPalette(HmPalette.dark);

  static ThemeData light() => fromPalette(HmPalette.light);

  static ThemeData highContrast() => fromPalette(HmPalette.highContrast);

  static ThemeData fromPalette(HmPalette p) {
    // Material widgets use `primary` as text too, so it is the AA-safe [primaryText];
    // hm_design's chunky buttons paint the vivid [HmPalette.primary] themselves.
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primaryText,
      onPrimary: p.brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : p.onPrimary,
      primaryContainer: p.primary,
      onPrimaryContainer: p.onPrimary,
      secondary: p.gold,
      onSecondary: p.onGold,
      secondaryContainer: p.surface3,
      onSecondaryContainer: p.text,
      tertiary: p.flame,
      onTertiary: p.onGold,
      error: p.onErrorTint,
      onError: p.brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000),
      errorContainer: p.errorTint,
      onErrorContainer: p.onErrorTint,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.textMuted,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface2,
      surfaceContainerHigh: p.surface2,
      surfaceContainerHighest: p.surface3,
      outline: p.outline,
      outlineVariant: p.outline,
      shadow: const Color(0xFF000000),
      inverseSurface: p.text,
      onInverseSurface: p.background,
      inversePrimary: p.primary,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      fontFamily: HmFonts.ui,
    );
    final text = _textTheme(base.textTheme, p);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HmRadius.md),
    );
    const minSize = Size(64, HmSizes.minTapTarget);
    const pad = EdgeInsets.symmetric(
      horizontal: HmSpace.xl,
      vertical: HmSpace.md,
    );
    final label = text.labelLarge;
    return base.copyWith(
      extensions: [p],
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: text,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      dividerTheme: DividerThemeData(color: p.outline, thickness: 1),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HmRadius.lg),
          side: BorderSide(color: p.outline, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      // Every button is at least 48 dp tall (§10.9).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minSize,
          padding: pad,
          shape: shape,
          textStyle: label,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: minSize,
          padding: pad,
          shape: shape,
          textStyle: label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          padding: pad,
          shape: shape,
          foregroundColor: p.primaryText,
          side: BorderSide(color: p.outline, width: 2),
          textStyle: label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minSize,
          foregroundColor: p.primaryText,
          shape: shape,
          textStyle: label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HmRadius.md),
          borderSide: BorderSide(color: p.outline, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HmRadius.md),
          borderSide: BorderSide(color: p.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HmRadius.md),
          borderSide: BorderSide(color: p.primaryText, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface2,
        labelStyle: text.labelLarge?.copyWith(color: p.text),
        side: BorderSide(color: p.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HmRadius.pill),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.surface3,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surface3,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(HmRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HmRadius.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.text,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HmRadius.md),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textMuted,
        textColor: p.text,
        minVerticalPadding: HmSpace.md,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onPrimary : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : p.surface3,
        ),
      ),
    );
  }

  /// Rounded, friendly type scale. Headings are heavy (800-900), body is regular, labels bold.
  static TextTheme _textTheme(TextTheme base, HmPalette p) {
    TextStyle? s(TextStyle? t, double size, FontWeight w, {double h = 1.3}) =>
        t?.copyWith(
          fontFamily: HmFonts.ui,
          fontSize: size,
          fontWeight: w,
          height: h,
          color: p.text,
          letterSpacing: 0,
        );
    return base.copyWith(
      displayLarge: s(base.displayLarge, 48, FontWeight.w900, h: 1.1),
      displayMedium: s(base.displayMedium, 40, FontWeight.w900, h: 1.1),
      displaySmall: s(base.displaySmall, 34, FontWeight.w900, h: 1.15),
      headlineLarge: s(base.headlineLarge, 30, FontWeight.w900, h: 1.2),
      headlineMedium: s(base.headlineMedium, 26, FontWeight.w800, h: 1.2),
      headlineSmall: s(base.headlineSmall, 22, FontWeight.w800, h: 1.25),
      titleLarge: s(base.titleLarge, 20, FontWeight.w800),
      titleMedium: s(base.titleMedium, 17, FontWeight.w800),
      titleSmall: s(base.titleSmall, 15, FontWeight.w700),
      bodyLarge: s(base.bodyLarge, 17, FontWeight.w600, h: 1.45),
      bodyMedium: s(base.bodyMedium, 15, FontWeight.w600, h: 1.45),
      bodySmall: s(
        base.bodySmall,
        13,
        FontWeight.w600,
        h: 1.4,
      )?.copyWith(color: p.textMuted),
      labelLarge: s(base.labelLarge, 16, FontWeight.w800, h: 1.2),
      labelMedium: s(base.labelMedium, 13, FontWeight.w800, h: 1.2),
      labelSmall: s(base.labelSmall, 11, FontWeight.w800, h: 1.2),
    );
  }
}
