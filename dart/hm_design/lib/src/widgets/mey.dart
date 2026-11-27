import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Raster art cut from the approved mock-ups in design/ui/ by tools/design/crop-ui.mjs (BOLT-0117).
/// Rerun that script to regenerate; never edit the PNGs by hand.
enum HmPic {
  meySplash('mey_splash'),
  meyHoldLamp('mey_hold_lamp'),
  meyPeek('mey_peek'),
  meyThink('mey_think'),
  meyReading('mey_reading'),
  meyThumbs('mey_thumbs'),
  meySleepy('mey_sleepy'),
  meyPencil('mey_pencil'),
  meyPuzzled('mey_puzzled'),
  meySmall('mey_small'),
  meyCheer('mey_cheer'),
  meyCalendar('mey_calendar'),
  meyProud('mey_proud'),
  meyCelebrate('mey_celebrate'),
  meyWink('mey_wink'),
  chest('chest'),
  envelope('envelope'),
  lampLit('lamp_lit'),
  lampGold('lamp_gold'),
  lampDim('lamp_dim'),
  lampLocked('lamp_locked'),
  lampFading('lamp_fading'),
  story1('story_1'),
  icGroup4('ic_group4'),
  icGroup2('ic_group2'),
  icGroup1('ic_group1'),
  icPolity('ic_polity'),
  icHistory('ic_history'),
  icGeography('ic_geography'),
  icEconomy('ic_economy'),
  icAptitude('ic_aptitude'),
  icTamil('ic_tamil'),
  icGavel('ic_gavel'),
  icPencilMath('ic_pencil_math'),
  icDuel('ic_duel'),
  icShield('ic_shield'),
  coin('coin'),
  meyDuel('mey_duel'),
  expoStall('expo_stall'),
  meyHandsUp('mey_hands_up'),
  meySticker('mey_sticker'),
  meyBell('mey_bell'),
  meySleep('mey_sleep'),
  icDiya('ic_diya'),
  icTrophy('ic_trophy'),
  icShieldCheck('ic_shield_check'),
  icTrophyGold('ic_trophy_gold'),
  meySquad('mey_squad'),
  deskHero('desk_hero'),
  logo('logo');

  const HmPic(this.file);
  final String file;

  String get asset => 'packages/hm_design/assets/img/$file.png';
}

/// A decorative picture from [HmPic]. Hidden from screen readers unless [semanticLabel] is given.
class HmPicture extends StatelessWidget {
  const HmPicture(
    this.pic, {
    super.key,
    this.width,
    this.height,
    this.semanticLabel,
    this.fit = BoxFit.contain,
  });

  final HmPic pic;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      pic.asset,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => SizedBox(width: width, height: height),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: img)
        : Semantics(image: true, label: semanticLabel, child: img);
  }
}

/// Mey, the lamp mascot, in one of its poses. It hovers gently (a 6 px bob every 2.4 s, four times) unless
/// motion is reduced (platform setting, Calm Mode or Lite Mode), and pops in on first build.
class HmMey extends StatefulWidget {
  const HmMey(this.pose, {super.key, this.size = 120, this.float = true});

  final HmPic pose;

  /// The picture's height in logical pixels.
  final double size;
  final bool float;

  @override
  State<HmMey> createState() => _HmMeyState();
}

class _HmMeyState extends State<HmMey> with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = !widget.float || HmModes.reduceMotion(context);
    if (still) {
      _bob.stop();
    } else if (!_bob.isAnimating && !_started) {
      _started = true;
      // Four bobs (about 10 s), then rest: saves battery and lets tests settle.
      _bob.repeat(count: 4);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = !widget.float || HmModes.reduceMotion(context);
    final pic = HmPicture(widget.pose, height: widget.size);
    final body = still
        ? pic
        : AnimatedBuilder(
            animation: _bob,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, math.sin(_bob.value * 2 * math.pi) * 3),
              child: child,
            ),
            child: pic,
          );
    if (still) return body;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: HmMotion.pop,
      curve: HmMotion.spring,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: body,
    );
  }
}

/// The soft tints used for bento tiles in the mock-ups.
abstract final class HmTint {
  static const amber = Color(0xFFFFEFD5);
  static const mint = Color(0xFFE3F6EC);
  static const coral = Color(0xFFFCD9D2);
  static const sky = Color(0xFFE1EDFB);
  static const cream = Color(0xFFF3EEE5);
}
