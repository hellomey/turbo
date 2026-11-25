import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'buttons.dart';

/// A chunky, rounded progress bar. When [value] grows the fill animates and a shine sweeps across
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
        decoration: BoxDecoration(color: p.surface3, borderRadius: r),
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
                        // A soft highlight stripe along the top: the "glossy" look.
                        Positioned(
                          left: widget.height / 3,
                          right: widget.height / 3,
                          top: widget.height * 0.2,
                          height: widget.height * 0.22,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFFFFF,
                              ).withValues(alpha: 0.35),
                              borderRadius: r,
                            ),
                          ),
                        ),
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
