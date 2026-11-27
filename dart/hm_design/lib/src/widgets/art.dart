import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'mey.dart';

/// Every hand-drawn Bauhaus SVG in `hm_design/assets/svg` (BOLT-0110). Features ask for art by name
/// ([HmArt]) and never by path, so files can be redrawn without touching a screen.
enum HmArtName {
  // Lamps (§5.1).
  lampDark('lamp_dark'),
  lampLit('lamp_lit'),
  lampFading('lamp_fading'),
  lampGold('lamp_gold'),

  // The Lamplighter mascot, built from a circle, a square and a triangle.
  mascotWave('mascot_wave'),
  mascotThink('mascot_think'),
  mascotCheer('mascot_cheer'),
  mascotPoint('mascot_point'),
  mascotSleep('mascot_sleep'),

  // Story scenes.
  sceneDarkHall('scene_dark_hall'),
  sceneTamilNadu('scene_tamil_nadu'),
  scenePlanBoard('scene_plan_board'),
  sceneFirstLesson('scene_first_lesson'),
  sceneFirstLamp('scene_first_lamp'),

  // Badge and level emblems.
  badgeFirstLamp('badge_first_lamp'),
  badgeTenLamps('badge_ten_lamps'),
  badgeGoldLamp('badge_gold_lamp'),
  badgeLevelUp('badge_level_up'),
  badgeMockDone('badge_mock_done'),
  badgeWeekPlan('badge_week_plan'),

  // Empty states.
  emptyNoAlerts('empty_no_alerts'),
  emptyNoMistakes('empty_no_mistakes'),
  emptyOffline('empty_offline'),

  // Confetti pieces.
  confettiCircle('confetti_circle'),
  confettiSquare('confetti_square'),
  confettiTriangle('confetti_triangle'),

  // Bottom bar icons: single-colour line art, tinted with [HmArt.color].
  navToday('nav_today'),
  navMap('nav_map'),
  navPlay('nav_play'),
  navSquad('nav_squad'),
  navProfile('nav_profile'),
  navExam('nav_exam');

  const HmArtName(this.file);

  final String file;

  /// The asset key inside the hm_design package.
  String get asset => 'packages/hm_design/assets/svg/$file.svg';

  /// Line icons are drawn in one ink colour and may be tinted.
  bool get isIcon => name.startsWith('nav');

  /// The warm light picture that replaces this Bauhaus drawing (BOLT-0117), or null to keep the SVG.
  HmPic? get warm => switch (this) {
    lampDark => HmPic.lampDim,
    lampLit => HmPic.lampLit,
    lampFading => HmPic.lampFading,
    lampGold => HmPic.lampGold,
    mascotWave => HmPic.meySmall,
    mascotThink => HmPic.meyThink,
    mascotCheer => HmPic.meyCheer,
    mascotPoint => HmPic.meyThumbs,
    mascotSleep => HmPic.meySleepy,
    sceneDarkHall => HmPic.story1,
    sceneTamilNadu => HmPic.meyWink,
    scenePlanBoard => HmPic.meyCalendar,
    sceneFirstLesson => HmPic.meyReading,
    sceneFirstLamp => HmPic.meyHoldLamp,
    badgeFirstLamp => HmPic.lampLit,
    badgeTenLamps => HmPic.meyProud,
    badgeGoldLamp => HmPic.lampGold,
    badgeLevelUp => HmPic.meyCelebrate,
    badgeMockDone => HmPic.chest,
    badgeWeekPlan => HmPic.meyCalendar,
    emptyNoAlerts => HmPic.envelope,
    emptyNoMistakes => HmPic.meyProud,
    emptyOffline => HmPic.meySleepy,
    _ => null,
  };
}

/// Draws one named Bauhaus SVG. Decorative by default (hidden from screen readers); pass
/// [semanticLabel] when the picture carries meaning. [color] tints single-colour icons.
class HmArt extends StatelessWidget {
  const HmArt(
    this.art, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.semanticLabel,
    this.fit = BoxFit.contain,
  });

  final HmArtName art;

  /// Square size; [width] and [height] win when given.
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final String? semanticLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    final warm = art.warm;
    if (warm != null && context.hm.brightness == Brightness.light) {
      return HmPicture(
        warm,
        width: w,
        height: h,
        fit: fit,
        semanticLabel: semanticLabel,
      );
    }
    final tint = color ?? (art.isIcon ? context.hm.text : null);
    final picture = SvgPicture.asset(
      art.asset,
      width: w,
      height: h,
      fit: fit,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
      // Keeps layout stable while the file loads (no layout shift).
      placeholderBuilder: (_) => SizedBox(width: w, height: h),
      excludeFromSemantics: true,
    );
    if (semanticLabel == null) return ExcludeSemantics(child: picture);
    return Semantics(image: true, label: semanticLabel, child: picture);
  }
}

/// Picks the lamp picture for a lamp's state: gold, lit, fading (dimming or dim) or dark.
HmArtName lampArtFor({
  required bool lit,
  required bool gold,
  required bool fading,
}) {
  if (!lit) return HmArtName.lampDark;
  if (fading) return HmArtName.lampFading;
  if (gold) return HmArtName.lampGold;
  return HmArtName.lampLit;
}
