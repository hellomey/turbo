import 'package:flutter/painting.dart';

/// Colour tokens from blueprint §10.3. Widgets use these (or the theme), never raw hex values.
abstract final class HmColors {
  /// Night Indigo: dark background (default theme).
  static const nightIndigo = Color(0xFF0F1230);

  /// Deep Ink: cards in dark mode.
  static const deepInk = Color(0xFF1A1E45);

  /// Ivory: light background.
  static const ivory = Color(0xFFFFF8EC);

  /// Temple Gold (primary): main buttons, Gold rings, ranks.
  static const templeGold = Color(0xFFF2B33D);

  /// Peacock Teal (secondary): links, progress, Steady rings.
  static const peacockTeal = Color(0xFF0FA3A3);

  /// Flame Orange: Lit rings, check-in flame.
  static const flameOrange = Color(0xFFFF8A3D);

  /// Ember Red: errors, dimming warnings.
  static const emberRed = Color(0xFFE2453C);

  /// Leaf Green: correct answers, success.
  static const leafGreen = Color(0xFF2FA866);

  /// Brass gradient: premium items, Pro badge.
  static const brassGradient = LinearGradient(
    colors: [Color(0xFFC8963E), Color(0xFFF6D27A)],
  );
}

/// Lamp rings differ by SHAPE and colour so they are colour-blind safe (§10.9).
enum LampRing { lit, steady, gold }

abstract final class HmMotion {
  /// Screen transitions take 200-300 ms.
  static const screenTransition = Duration(milliseconds: 250);

  /// Celebrations last at most 1.5 s and are always skippable.
  static const maxCelebration = Duration(milliseconds: 1500);
}

abstract final class HmSizes {
  /// Minimum tap target in dp (§10.9).
  static const minTapTarget = 48.0;
}

abstract final class HmFonts {
  static const ui = 'PlusJakartaSans';
  static const numbers = 'Sora';

  /// Only inside Tamil Language paper CONTENT. Never interface text (§1 decision 3).
  static const tamilContentOnly = 'NotoSansTamil';
}
