import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// How bright a lamp is (§5.1: lamps dim when not revised).
enum HmLampDim { bright, dimming, dim }

/// The three rings of a lamp (§5.1). Phase 1 shows every lamp unlit (D-2026-10-20-14).
@immutable
class HmLampState {
  const HmLampState({
    this.lit = false,
    this.steadyLevel = 0,
    this.gold = false,
    this.dim = HmLampDim.bright,
  }) : assert(steadyLevel >= 0 && steadyLevel <= maxSteady);

  static const maxSteady = 4;
  static const unlit = HmLampState();

  final bool lit;
  final int steadyLevel;
  final bool gold;
  final HmLampDim dim;

  @override
  bool operator ==(Object other) =>
      other is HmLampState &&
      other.lit == lit &&
      other.steadyLevel == steadyLevel &&
      other.gold == gold &&
      other.dim == dim;

  @override
  int get hashCode => Object.hash(lit, steadyLevel, gold, dim);

  bool isOn(LampRing ring) => switch (ring) {
    LampRing.lit => lit,
    LampRing.steady => steadyLevel > 0,
    LampRing.gold => gold,
  };
}

/// What a screen reader says for a lamp: every ring is named, so nothing depends on colour (§10.9).
String lampSemanticsLabel(String topic, HmLampState s) {
  final parts = <String>[
    topic,
    'Lit ring: ${s.lit ? 'on' : 'off'}',
    'Steady ring: ${s.steadyLevel} of ${HmLampState.maxSteady}',
    'Gold ring: ${s.gold ? 'on' : 'off'}',
    if (s.dim == HmLampDim.dimming) 'Dimming, relight soon',
    if (s.dim == HmLampDim.dim) 'Dim, relight now',
  ];
  return '${parts.join('. ')}.';
}

/// A lamp with three rings that differ by SHAPE and colour (colour-blind safe, §10.9):
/// - Lit: a solid inner circle (Flame Orange);
/// - Steady: four separate arc segments, one per level (Peacock Teal);
/// - Gold: an outer octagon (Temple Gold).
/// Rings that are off are drawn as thin faint outlines of the same shape.
class Lamp extends StatelessWidget {
  const Lamp({
    super.key,
    required this.label,
    this.state = HmLampState.unlit,
    this.size = 48,
    this.onTap,
    this.showLabel = false,
  });

  /// Topic name (used for semantics and the optional caption).
  final String label;
  final HmLampState state;
  final double size;
  final VoidCallback? onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final pal = context.hm;
    final faint = pal.text.withValues(alpha: 0.3);
    final icon = CustomPaint(
      size: Size.square(size),
      painter: LampPainter(state: state, faint: faint, palette: pal),
    );
    final body = showLabel
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          )
        : icon;
    return Semantics(
      label: lampSemanticsLabel(label, state),
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: HmSizes.minTapTarget,
            minHeight: HmSizes.minTapTarget,
          ),
          child: Padding(padding: const EdgeInsets.all(4), child: body),
        ),
      ),
    );
  }
}

class LampPainter extends CustomPainter {
  LampPainter({
    required this.state,
    required this.faint,
    this.palette = HmPalette.dark,
  });

  final HmLampState state;
  final Color faint;
  final HmPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final dimFactor = switch (state.dim) {
      HmLampDim.bright => 1.0,
      HmLampDim.dimming => 0.7,
      HmLampDim.dim => 0.45,
    };
    Color on(Color color) => color.withValues(alpha: dimFactor);

    // Gold: outer octagon.
    final octagon = Path();
    for (var i = 0; i < 8; i++) {
      final a = math.pi / 8 + i * math.pi / 4;
      final p = c + Offset(math.cos(a), math.sin(a)) * (r * 0.94);
      i == 0 ? octagon.moveTo(p.dx, p.dy) : octagon.lineTo(p.dx, p.dy);
    }
    octagon.close();
    canvas.drawPath(
      octagon,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = state.gold ? r * 0.12 : 1
        ..color = state.gold ? on(palette.gold) : faint,
    );

    // Steady: four arc segments with gaps.
    final arcRect = Rect.fromCircle(center: c, radius: r * 0.66);
    const gap = 0.35;
    const sweep = math.pi / 2 - gap;
    for (var i = 0; i < HmLampState.maxSteady; i++) {
      final filled = i < state.steadyLevel;
      canvas.drawArc(
        arcRect,
        -math.pi / 2 + gap / 2 + i * math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = filled ? r * 0.14 : 1
          ..color = filled ? on(palette.steady) : faint,
      );
    }

    // Lit: solid inner circle with a soft glow when bright.
    if (state.lit && state.dim == HmLampDim.bright) {
      canvas.drawCircle(
        c,
        r * 0.5,
        Paint()
          ..color = palette.flame.withValues(alpha: 0.28)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
      );
    }
    canvas.drawCircle(
      c,
      r * 0.34,
      Paint()
        ..style = state.lit ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = state.lit ? on(palette.flame) : faint,
    );
  }

  @override
  bool shouldRepaint(LampPainter old) =>
      old.state != state || old.faint != faint || old.palette != palette;
}

/// The named lamp states shown on a badge (§5.1): Unlit, Lit, Steady 1-4, Dimming, Dim, Gold.
enum HmLampStatus {
  unlit('Unlit', HmLampState.unlit),
  lit('Lit', HmLampState(lit: true)),
  steady1('Steady 1', HmLampState(lit: true, steadyLevel: 1)),
  steady2('Steady 2', HmLampState(lit: true, steadyLevel: 2)),
  steady3('Steady 3', HmLampState(lit: true, steadyLevel: 3)),
  steady4('Steady 4', HmLampState(lit: true, steadyLevel: 4)),
  dimming(
    'Dimming',
    HmLampState(lit: true, steadyLevel: 2, dim: HmLampDim.dimming),
  ),
  dim('Dim', HmLampState(lit: true, steadyLevel: 1, dim: HmLampDim.dim)),
  gold('Gold', HmLampState(lit: true, steadyLevel: 4, gold: true));

  const HmLampStatus(this.label, this.state);

  final String label;
  final HmLampState state;

  /// The status that best names a lamp state (dim states win, then Gold, Steady, Lit).
  static HmLampStatus of(HmLampState s) {
    if (s.dim == HmLampDim.dim) return HmLampStatus.dim;
    if (s.dim == HmLampDim.dimming) return HmLampStatus.dimming;
    if (s.gold) return HmLampStatus.gold;
    if (s.steadyLevel > 0) return HmLampStatus.values[1 + s.steadyLevel];
    return s.lit ? HmLampStatus.lit : HmLampStatus.unlit;
  }
}

/// A lamp with its status word under it in a pill (shape + colour + words, never colour alone, §10.9).
class HmLampBadge extends StatelessWidget {
  const HmLampBadge({
    super.key,
    required this.topic,
    required this.state,
    this.size = 56,
    this.onTap,
  });

  final String topic;
  final HmLampState state;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final status = HmLampStatus.of(state);
    final (bg, fg) = switch (status) {
      HmLampStatus.gold => (p.gold, p.onGold),
      HmLampStatus.dimming || HmLampStatus.dim => (p.errorTint, p.onErrorTint),
      HmLampStatus.unlit => (p.surface2, p.textMuted),
      _ => (p.surface2, p.text),
    };
    return Semantics(
      label: lampSemanticsLabel(topic, state),
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HmRadius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: HmSizes.minTapTarget,
            minHeight: HmSizes.minTapTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.all(HmSpace.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: Size.square(size),
                  painter: LampPainter(
                    state: state,
                    faint: p.text.withValues(alpha: 0.3),
                    palette: p,
                  ),
                ),
                const SizedBox(height: HmSpace.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HmSpace.sm,
                    vertical: HmSpace.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(HmRadius.pill),
                  ),
                  child: Text(
                    status.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
