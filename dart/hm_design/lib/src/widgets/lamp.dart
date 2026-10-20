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
    final faint = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.3);
    final icon = CustomPaint(
      size: Size.square(size),
      painter: LampPainter(state: state, faint: faint),
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
  LampPainter({required this.state, required this.faint});

  final HmLampState state;
  final Color faint;

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
        ..color = state.gold ? on(HmColors.templeGold) : faint,
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
          ..color = filled ? on(HmColors.peacockTeal) : faint,
      );
    }

    // Lit: solid inner circle.
    canvas.drawCircle(
      c,
      r * 0.34,
      Paint()
        ..style = state.lit ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = state.lit ? on(HmColors.flameOrange) : faint,
    );
  }

  @override
  bool shouldRepaint(LampPainter old) =>
      old.state != state || old.faint != faint;
}
