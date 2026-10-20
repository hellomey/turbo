import 'package:flutter/material.dart';

import 'tokens.dart';

/// The three shipped themes (§10.3). Calm Mode and Lite Mode change behaviour/motion, not tokens.
abstract final class HmTheme {
  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    background: HmColors.nightIndigo,
    surface: HmColors.deepInk,
  );

  static ThemeData light() => _build(
    brightness: Brightness.light,
    background: HmColors.ivory,
    surface: Colors.white,
  );

  static ThemeData highContrast() => _build(
    brightness: Brightness.dark,
    background: Colors.black,
    surface: const Color(0xFF111111),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: HmColors.templeGold,
      brightness: brightness,
      primary: HmColors.templeGold,
      secondary: HmColors.peacockTeal,
      error: HmColors.emberRed,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: HmFonts.ui,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      cardTheme: CardThemeData(color: surface, elevation: 0),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      // Every button is at least 48 dp tall (§10.9).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, HmSizes.minTapTarget),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, HmSizes.minTapTarget),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, HmSizes.minTapTarget),
        ),
      ),
    );
  }
}
