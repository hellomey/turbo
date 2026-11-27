import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'buttons.dart';

/// Motion helpers for the Bauhaus theme (BOLT-0110), built on implicit tweens. Each is a
/// plain pass-through when motion is off: Calm Mode, Lite Mode, the OS reduce-motion setting or
/// the Exam Hall ([HmPlain]). Durations stay between 150 and 400 ms with a spring-like curve.
/// Implicit tweens leave no timers behind (flutter_animate schedules one on every build, which
/// breaks widget tests that never pump).
///
/// True when decorative motion must be off.
bool hmMotionOff(BuildContext context) =>
    HmModes.reduceMotion(context) || HmPlain.of(context);

/// A tile entrance: a short fade and rise with a spring. [index] staggers tiles by 40 ms each
/// (capped). Built on a tween rather than flutter_animate so a screen that is built and thrown
/// away at once leaves no timer behind.
class HmEnter extends StatelessWidget {
  const HmEnter({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (hmMotionOff(context)) return child;
    final lead = 40 * index.clamp(0, 6);
    final total = HmMotion.enter.inMilliseconds + lead;
    final start = lead / total;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(start, 1),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: FractionalTranslation(
          translation: Offset(0, 0.06 * (1 - HmMotion.spring.transform(t))),
          child: child,
        ),
      ),
    );
  }
}

/// A pop: scale up from 85% with a spring overshoot. Used for correct answers and newly lit
/// lamps. A new [trigger] value replays it. With [playOnFirstBuild] false it only plays when
/// [trigger] changes (a lamp that lights up while you watch, not every lamp on load).
class HmPop extends StatefulWidget {
  const HmPop({
    super.key,
    required this.child,
    this.trigger,
    this.haptic = false,
    this.playOnFirstBuild = true,
  });

  final Widget child;

  /// Any value; a new value replays the pop.
  final Object? trigger;

  /// A light haptic tick when the pop plays (wins only).
  final bool haptic;
  final bool playOnFirstBuild;

  @override
  State<HmPop> createState() => _HmPopState();
}

class _HmPopState extends State<HmPop> {
  late bool _armed = widget.playOnFirstBuild;
  bool _buzzed = false;

  @override
  void didUpdateWidget(HmPop old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) {
      _armed = true;
      _buzzed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_armed || hmMotionOff(context)) return widget.child;
    if (widget.haptic && !_buzzed) {
      _buzzed = true;
      HapticFeedback.lightImpact();
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.trigger),
      tween: Tween(begin: 0.85, end: 1),
      duration: HmMotion.pop,
      curve: HmMotion.spring,
      child: widget.child,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
    );
  }
}

/// A gentle sideways shake for a wrong answer: three small swings that settle (no flash, no
/// sound). A new [trigger] value replays it.
class HmShake extends StatelessWidget {
  const HmShake({super.key, required this.child, this.trigger});

  final Widget child;
  final Object? trigger;

  @override
  Widget build(BuildContext context) {
    if (hmMotionOff(context)) return child;
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 0, end: 1),
      duration: HmMotion.shake,
      child: child,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(math.sin(t * math.pi * 6) * 5 * (1 - t), 0),
        child: child,
      ),
    );
  }
}
