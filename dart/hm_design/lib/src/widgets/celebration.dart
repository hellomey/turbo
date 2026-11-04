import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'buttons.dart';

/// What is being celebrated (§5.1 lamps, §5.2 rank-ups).
enum HmCelebrationKind { lampLit, lampGold, rankUp }

/// A short burst of confetti and a title card: at most 1.2 s ([HmMotion.celebration]), skippable
/// with one tap, then it closes by itself (§10.4).
///
/// Never shown in Calm Mode, Lite Mode, with the platform "reduce motion" setting, or inside
/// [HmPlain] (the Exam Hall, §10.6). Screens must still say the result in plain text.
abstract final class HmCelebration {
  /// Returns true if the overlay was shown.
  static Future<bool> show(
    BuildContext context, {
    required HmCelebrationKind kind,
    required String title,
    String? subtitle,
  }) async {
    if (!enabled(context)) return false;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: const Color(0x99000000),
      transitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => HmCelebrationView(
        kind: kind,
        title: title,
        subtitle: subtitle,
        onDone: () => Navigator.of(context).maybePop(),
      ),
    );
    return true;
  }

  static bool enabled(BuildContext context) =>
      !HmModes.reduceMotion(context) && !HmPlain.of(context);
}

/// The celebration content. [progress] pins the animation (for goldens); null runs it once.
class HmCelebrationView extends StatefulWidget {
  const HmCelebrationView({
    super.key,
    required this.kind,
    required this.title,
    this.subtitle,
    this.onDone,
    this.progress,
  });

  final HmCelebrationKind kind;
  final String title;
  final String? subtitle;
  final VoidCallback? onDone;
  final double? progress;

  @override
  State<HmCelebrationView> createState() => _HmCelebrationViewState();
}

class _HmCelebrationViewState extends State<HmCelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: HmMotion.celebration,
  );
  bool _done = false;

  @override
  void initState() {
    super.initState();
    if (widget.progress == null) {
      unawaited(_c.forward().whenComplete(_finish));
    } else {
      _c.value = widget.progress!;
    }
  }

  void _finish() {
    if (_done || !mounted) return;
    _done = true;
    widget.onDone?.call();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final (icon, accent) = switch (widget.kind) {
      HmCelebrationKind.lampLit => (
        Icons.local_fire_department_rounded,
        p.flame,
      ),
      HmCelebrationKind.lampGold => (Icons.workspace_premium_rounded, p.gold),
      HmCelebrationKind.rankUp => (Icons.military_tech_rounded, p.gold),
    };
    return Semantics(
      liveRegion: true,
      label: [widget.title, ?widget.subtitle].join('. '),
      button: true,
      onTap: _finish,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final pop = Curves.elasticOut.transform(
                (t / 0.5).clamp(0.0, 1.0),
              );
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConfettiPainter(t, [
                        p.gold,
                        p.flame,
                        p.primary,
                        p.success,
                        p.info,
                      ]),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * pop,
                        child: Container(
                          margin: const EdgeInsets.all(HmSpace.xl),
                          padding: const EdgeInsets.all(HmSpace.xl),
                          constraints: const BoxConstraints(maxWidth: 360),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(HmRadius.xl),
                            border: Border.all(color: accent, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: p.goldShade,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.withValues(alpha: 0.18),
                                ),
                                child: Icon(icon, size: 56, color: accent),
                              ),
                              const SizedBox(height: HmSpace.lg),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: text.headlineSmall,
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: HmSpace.sm),
                                Text(
                                  widget.subtitle!,
                                  textAlign: TextAlign.center,
                                  style: text.bodyLarge?.copyWith(
                                    color: p.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.colors);

  final double t;
  final List<Color> colors;

  // Fixed seed: confetti is decoration, not game randomness.
  static final _pieces = List.generate(48, (i) {
    final r = math.Random(i * 7919 + 13);
    return (
      angle: r.nextDouble() * math.pi * 2,
      speed: 0.35 + r.nextDouble() * 0.65,
      spin: r.nextDouble() * 6,
      size: 6 + r.nextDouble() * 6,
      round: r.nextBool(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final c = Offset(size.width / 2, size.height * 0.42);
    final reach = size.shortestSide * 0.62;
    final fade = t < 0.75 ? 1.0 : (1 - (t - 0.75) / 0.25);
    for (var i = 0; i < _pieces.length; i++) {
      final pc = _pieces[i];
      final d = reach * pc.speed * Curves.easeOutCubic.transform(t);
      final pos =
          c +
          Offset(math.cos(pc.angle), math.sin(pc.angle)) * d +
          Offset(0, 120 * t * t);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(
          alpha: fade.clamp(0.0, 1.0),
        );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(pc.spin * t * math.pi);
      if (pc.round) {
        canvas.drawCircle(Offset.zero, pc.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: pc.size,
              height: pc.size * 0.5,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
