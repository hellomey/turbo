import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

/// A geometric lamp (a circle flame on a half-disc bowl and a bar base) drawn from theme colours, so
/// any theme applies to it. [glow] runs from 0 (dark) to 1 (lit). Decorative: screen readers skip it.
class LampArt extends StatelessWidget {
  const LampArt({super.key, required this.glow, this.size = 96});

  final double glow;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _LampPainter(
            glow: glow.clamp(0.0, 1.0),
            flame: cs.secondary,
            body: cs.primary,
            dark: cs.outline,
          ),
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

class _LampPainter extends CustomPainter {
  _LampPainter({
    required this.glow,
    required this.flame,
    required this.body,
    required this.dark,
  });

  final double glow;
  final Color flame;
  final Color body;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final flameCenter = Offset(w / 2, h * 0.36);
    if (glow > 0) {
      canvas.drawCircle(
        flameCenter,
        w * 0.34 * glow,
        Paint()..color = flame.withValues(alpha: 0.22 * glow),
      );
    }
    // Flame: a circle, dark when unlit.
    canvas.drawCircle(
      flameCenter,
      w * 0.12,
      Paint()..color = Color.lerp(dark, flame, glow)!,
    );
    // Bowl: a half disc.
    final bowl = Rect.fromCenter(
      center: Offset(w / 2, h * 0.56),
      width: w * 0.62,
      height: h * 0.36,
    );
    canvas.drawArc(bowl, 0, math.pi, true, Paint()..color = body);
    // Base: a bar.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.3, h * 0.78, w * 0.4, h * 0.08),
      Paint()..color = body,
    );
  }

  @override
  bool shouldRepaint(_LampPainter old) =>
      old.glow != glow ||
      old.flame != flame ||
      old.body != body ||
      old.dark != dark;
}
