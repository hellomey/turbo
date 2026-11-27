import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'buttons.dart';

/// A chunky Bauhaus progress bar (BOLT-0110): a square track with an ink outline and a flat fill. When [value] grows the fill animates and a shine sweeps across
/// once (no looping, so it never keeps the CPU busy). No motion in Calm/Lite Mode or [HmPlain].
class HmProgressBar extends StatefulWidget {
  const HmProgressBar({
    super.key,
    required this.value,
    required this.semanticLabel,
    this.height = 16,
    this.color,
    this.animate = true,
  });

  /// False draws the fill at once with no shine (step headers, BOLT-0022).
  final bool animate;

  /// 0..1.
  final double value;

  /// What the bar measures, e.g. "XP to next rank". The percent is added for screen readers.
  final String semanticLabel;
  final double height;
  final Color? color;

  @override
  State<HmProgressBar> createState() => _HmProgressBarState();
}

class _HmProgressBarState extends State<HmProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: HmMotion.shine,
  );

  @override
  void didUpdateWidget(HmProgressBar old) {
    super.didUpdateWidget(old);
    if (widget.value > old.value && !_still(context)) {
      _shine.forward(from: 0);
    }
  }

  bool _still(BuildContext context) =>
      !widget.animate || HmModes.reduceMotion(context) || HmPlain.of(context);

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final v = widget.value.clamp(0.0, 1.0);
    final still = _still(context);
    final fill = widget.color ?? p.primary;
    final r = BorderRadius.circular(HmRadius.pill);
    return Semantics(
      label: widget.semanticLabel,
      value: '${(v * 100).round()} percent',
      excludeSemantics: true,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: p.brightness == Brightness.light
              ? const Color(0xFFF6E8D2)
              : p.surface2,
          borderRadius: r,
        ),
        child: LayoutBuilder(
          builder: (context, box) => Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: v),
              duration: still ? Duration.zero : HmMotion.progress,
              curve: HmMotion.standard,
              builder: (context, t, _) {
                final w = box.maxWidth * t;
                if (w <= 0) return const SizedBox.shrink();
                return ClipRRect(
                  borderRadius: r,
                  child: SizedBox(
                    width: w < widget.height ? widget.height : w,
                    height: widget.height,
                    child: Stack(
                      children: [
                        Positioned.fill(child: ColoredBox(color: fill)),
                        if (!still)
                          AnimatedBuilder(
                            animation: _shine,
                            builder: (context, _) {
                              if (!_shine.isAnimating) {
                                return const SizedBox.shrink();
                              }
                              return Positioned(
                                left: (w + 40) * _shine.value - 40,
                                top: 0,
                                bottom: 0,
                                width: 28,
                                child: Transform(
                                  transform: Matrix4.skewX(-0.4),
                                  child: ColoredBox(
                                    color: const Color(
                                      0xFFFFFFFF,
                                    ).withValues(alpha: 0.45),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A round progress ring (warm light, BOLT-0117): a pale track and an amber arc that grows from the
/// top when [value] changes. [center] sits in the middle, usually a big number.
class HmRing extends StatelessWidget {
  const HmRing({
    super.key,
    required this.value,
    required this.semanticLabel,
    this.size = 120,
    this.stroke = 12,
    this.color,
    this.center,
  });

  /// 0..1.
  final double value;
  final String semanticLabel;
  final double size;
  final double stroke;
  final Color? color;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final still = HmModes.reduceMotion(context);
    return Semantics(
      label: semanticLabel,
      value: '${(value.clamp(0, 1) * 100).round()} percent',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: still ? Duration.zero : HmMotion.progress * 1.5,
          curve: HmMotion.standard,
          builder: (context, t, child) => CustomPaint(
            painter: _RingPainter(
              t,
              color ?? p.primary,
              p.brightness == Brightness.light
                  ? const Color(0xFFEDE7DD)
                  : p.surface3,
              stroke,
            ),
            child: child,
          ),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t, this.color, this.track, this.stroke);

  final double t;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 6.283185, false, paint..color = track);
    if (t > 0) {
      canvas.drawArc(rect, -1.5708, 6.283185 * t, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.t != t || old.color != color || old.track != track;
}
