import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

/// The lamp picture (Bauhaus SVGs from hm_design, BOLT-0110): the dark lamp fading into the lit
/// lamp as [glow] runs from 0 (dark) to 1 (lit). Decorative: screen readers skip it.
class LampArt extends StatelessWidget {
  const LampArt({super.key, required this.glow, this.size = 96});

  final double glow;
  final double size;

  @override
  Widget build(BuildContext context) {
    final g = glow.clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (g < 1)
              Opacity(
                opacity: 1 - g,
                child: HmArt(HmArtName.lampDark, size: size),
              ),
            if (g > 0)
              Opacity(
                opacity: g,
                child: HmArt(HmArtName.lampLit, size: size),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lights [LampArt] from dark to lit once (300 ms). Shows it lit at once under reduce motion, Calm
/// Mode or Lite Mode.
class LightingLamp extends StatelessWidget {
  const LightingLamp({super.key, this.size = 120, this.lit = true});

  final double size;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final target = lit ? 1.0 : 0.0;
    if (HmModes.reduceMotion(context)) {
      return LampArt(glow: target, size: size);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (_, g, _) => LampArt(glow: g, size: size),
    );
  }
}
