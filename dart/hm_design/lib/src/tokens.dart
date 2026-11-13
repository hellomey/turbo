import 'package:material_ui/material_ui.dart';

/// Brand colours from blueprint §10.3. Kept as named brand constants; screens should prefer the
/// theme-aware [HmPalette] (`context.hm`) so light, dark and high contrast all work (BOLT-0021).
abstract final class HmColors {
  /// Night Indigo: brand dark background.
  static const nightIndigo = Color(0xFF0F1230);

  /// Deep Ink: brand dark surface.
  static const deepInk = Color(0xFF1A1E45);

  /// Ivory: light background.
  static const ivory = Color(0xFFFFF8EC);

  /// Temple Gold: the reward colour (Gold rings, ranks, lamps).
  static const templeGold = Color(0xFFF2B33D);

  /// Peacock Teal: the primary action colour (BOLT-0021) and Steady rings.
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

/// The full colour set of one theme (BOLT-0021). Every `on*` / `text*` colour meets WCAG AA (4.5:1)
/// on the background it is paired with; `test/contrast_test.dart` checks every pair.
@immutable
class HmPalette extends ThemeExtension<HmPalette> {
  const HmPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.outline,
    required this.text,
    required this.textMuted,
    required this.primary,
    required this.primaryShade,
    required this.onPrimary,
    required this.primaryText,
    required this.gold,
    required this.goldShade,
    required this.onGold,
    required this.goldText,
    required this.flame,
    required this.steady,
    required this.success,
    required this.successTint,
    required this.onSuccessTint,
    required this.error,
    required this.errorTint,
    required this.onErrorTint,
    required this.info,
    required this.infoTint,
    required this.onInfoTint,
    required this.disabled,
    required this.onDisabled,
  });

  final Brightness brightness;

  /// Surface levels: background < surface < surface2 < surface3.
  final Color background, surface, surface2, surface3, outline;
  final Color text, textMuted;

  /// The vivid main action colour, its 3D shade, its label colour and its colour as text/links.
  final Color primary, primaryShade, onPrimary, primaryText;

  /// Reward gold: lamps, Gold rings, ranks, XP.
  final Color gold, goldShade, onGold, goldText;

  /// Lit ring (flame) and Steady ring colours.
  final Color flame, steady;
  final Color success, successTint, onSuccessTint;
  final Color error, errorTint, onErrorTint;
  final Color info, infoTint, onInfoTint;
  final Color disabled, onDisabled;

  /// Warm and bright: ivory background, white cards, vivid teal action, gold rewards.
  static const light = HmPalette(
    brightness: Brightness.light,
    background: Color(0xFFFFF8EC),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFFFF0D6),
    surface3: Color(0xFFFFE6BD),
    outline: Color(0xFFEBD3AE),
    text: Color(0xFF2A1F14),
    textMuted: Color(0xFF6B5A48),
    primary: Color(0xFF19B5AE),
    primaryShade: Color(0xFF0E8A84),
    onPrimary: Color(0xFF052826),
    primaryText: Color(0xFF0B7C78),
    gold: Color(0xFFF2B33D),
    goldShade: Color(0xFFC8862A),
    onGold: Color(0xFF2B1B00),
    goldText: Color(0xFF8A5A00),
    flame: Color(0xFFFF8A3D),
    steady: Color(0xFF0FA3A3),
    success: Color(0xFF2FA866),
    successTint: Color(0xFFE3F7EA),
    onSuccessTint: Color(0xFF145C34),
    error: Color(0xFFE2453C),
    errorTint: Color(0xFFFDE8E6),
    onErrorTint: Color(0xFFB3261E),
    info: Color(0xFF2F6FEB),
    infoTint: Color(0xFFE6EEFF),
    onInfoTint: Color(0xFF1F55C9),
    disabled: Color(0xFFEFE4D2),
    onDisabled: Color(0xFF6B5A48),
  );

  /// Rich, not flat: deep indigo-violet layers with a glowing teal action and warm gold.
  static const dark = HmPalette(
    brightness: Brightness.dark,
    background: Color(0xFF100D2B),
    surface: Color(0xFF1C1846),
    surface2: Color(0xFF262158),
    surface3: Color(0xFF312A6B),
    outline: Color(0xFF3E3780),
    text: Color(0xFFF5F3FF),
    textMuted: Color(0xFFB9B4E0),
    primary: Color(0xFF2DD4C8),
    primaryShade: Color(0xFF179A90),
    onPrimary: Color(0xFF04201F),
    primaryText: Color(0xFF2DD4C8),
    gold: Color(0xFFFFC94D),
    goldShade: Color(0xFFC8862A),
    onGold: Color(0xFF2B1B00),
    goldText: Color(0xFFFFD45C),
    flame: Color(0xFFFF9A52),
    steady: Color(0xFF2DD4C8),
    success: Color(0xFF3DDC84),
    successTint: Color(0xFF12382A),
    onSuccessTint: Color(0xFF8EF0B8),
    error: Color(0xFFFF6B5E),
    errorTint: Color(0xFF3D1A1F),
    onErrorTint: Color(0xFFFFB4AB),
    info: Color(0xFF7AA7FF),
    infoTint: Color(0xFF1A2650),
    onInfoTint: Color(0xFFA9C4FF),
    disabled: Color(0xFF2B2752),
    onDisabled: Color(0xFFB9B4E0),
  );

  /// High contrast (§10.9): black and white with bright accents.
  static const highContrast = HmPalette(
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF111111),
    surface2: Color(0xFF1A1A1A),
    surface3: Color(0xFF242424),
    outline: Color(0xFFFFFFFF),
    text: Color(0xFFFFFFFF),
    textMuted: Color(0xFFE6E6E6),
    primary: Color(0xFF7CF0E6),
    primaryShade: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF000000),
    primaryText: Color(0xFF7CF0E6),
    gold: Color(0xFFFFE14D),
    goldShade: Color(0xFFFFFFFF),
    onGold: Color(0xFF000000),
    goldText: Color(0xFFFFE14D),
    flame: Color(0xFFFFB27A),
    steady: Color(0xFF7CF0E6),
    success: Color(0xFF6BFFA8),
    successTint: Color(0xFF000000),
    onSuccessTint: Color(0xFF6BFFA8),
    error: Color(0xFFFF8A80),
    errorTint: Color(0xFF000000),
    onErrorTint: Color(0xFFFF8A80),
    info: Color(0xFF9CC2FF),
    infoTint: Color(0xFF000000),
    onInfoTint: Color(0xFF9CC2FF),
    disabled: Color(0xFF242424),
    onDisabled: Color(0xFFE6E6E6),
  );

  /// Text/background pairs that must meet WCAG AA. Used by the contrast test.
  Map<String, (Color, Color)> get contrastPairs => {
    'text/background': (text, background),
    'text/surface': (text, surface),
    'text/surface2': (text, surface2),
    'text/surface3': (text, surface3),
    'textMuted/background': (textMuted, background),
    'textMuted/surface': (textMuted, surface),
    'textMuted/surface2': (textMuted, surface2),
    'onPrimary/primary': (onPrimary, primary),
    'primaryText/background': (primaryText, background),
    'primaryText/surface': (primaryText, surface),
    'onGold/gold': (onGold, gold),
    'goldText/surface': (goldText, surface),
    'goldText/background': (goldText, background),
    'onSuccessTint/successTint': (onSuccessTint, successTint),
    'onErrorTint/errorTint': (onErrorTint, errorTint),
    'onErrorTint/surface': (onErrorTint, surface),
    'onInfoTint/infoTint': (onInfoTint, infoTint),
    'onDisabled/disabled': (onDisabled, disabled),
  };

  /// WCAG 2.x contrast ratio between two opaque colours.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  @override
  HmPalette copyWith({Color? primary}) => this;

  @override
  HmPalette lerp(HmPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

/// `context.hm` gives the current palette (falls back to dark, the default theme).
extension HmPaletteContext on BuildContext {
  HmPalette get hm =>
      Theme.of(this).extension<HmPalette>() ??
      (Theme.of(this).brightness == Brightness.light
          ? HmPalette.light
          : HmPalette.dark);
}

/// Lamp rings differ by SHAPE and colour so they are colour-blind safe (§10.9).
enum LampRing { lit, steady, gold }

/// Spacing scale (4 dp grid).
abstract final class HmSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

/// Corner radius scale: friendly, rounded.
abstract final class HmRadius {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;
}

/// Elevation: the "3D" depth of chunky buttons and cards (a solid bottom edge, not a blur).
abstract final class HmElevation {
  static const buttonDepth = 4.0;
  static const cardDepth = 3.0;
  static const tileDepth = 3.0;
  static const navDepth = 0.0;
}

abstract final class HmMotion {
  /// Button press / tile tap.
  static const press = Duration(milliseconds: 90);

  /// Small state changes.
  static const fast = Duration(milliseconds: 150);

  /// Screen transitions take 200-300 ms (§10.4).
  static const screenTransition = Duration(milliseconds: 250);

  /// Progress bar fill and shine.
  static const progress = Duration(milliseconds: 600);
  static const shine = Duration(milliseconds: 1600);

  /// Celebrations in this design system last 1.2 s (§10.4 caps them at 1.5 s) and are skippable.
  static const celebration = Duration(milliseconds: 1200);
  static const maxCelebration = Duration(milliseconds: 1500);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
}

abstract final class HmSizes {
  /// Minimum tap target in dp (§10.9).
  static const minTapTarget = 48.0;
  static const buttonHeight = 52.0;
}

abstract final class HmFonts {
  /// Nunito (SIL OFL 1.1), bundled in hm_design/assets/fonts so it works offline (BOLT-0021).
  static const ui = 'packages/hm_design/Nunito';

  /// Big numbers use the same rounded face, heavy weight, tabular figures.
  static const numbers = ui;

  /// Only inside Tamil Language paper CONTENT. Never interface text (§1 decision 3).
  static const tamilContentOnly = 'NotoSansTamil';
}

/// Calm Mode (§10.7) and Lite Mode (§10.8) for hm_design widgets. Apps put this above the
/// navigator; widgets read it with [HmModes.of]. Both turn celebrations and decorative motion off,
/// as does the platform "reduce motion" setting.
class HmModes extends InheritedWidget {
  const HmModes({
    super.key,
    this.calm = false,
    this.lite = false,
    required super.child,
  });

  final bool calm;
  final bool lite;

  static HmModes? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HmModes>();

  /// True when celebrations and decorative motion (shine, confetti, bounce) must be off.
  static bool reduceMotion(BuildContext context) {
    final m = maybeOf(context);
    final platform = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return platform || (m?.calm ?? false) || (m?.lite ?? false);
  }

  @override
  bool updateShouldNotify(HmModes old) => old.calm != calm || old.lite != lite;
}
