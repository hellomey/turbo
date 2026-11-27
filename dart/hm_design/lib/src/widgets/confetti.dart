import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// A one-shot burst of confetti (design/ui/20, 23). It plays once and stops, so tests settle.
/// It draws nothing under reduce-motion (OS, Calm or Lite Mode) and never takes taps.
class HmConfetti extends StatefulWidget {
  const HmConfetti({super.key, this.pieces = 46, this.seed = 7});

  final int pieces;
  final int seed;

  @override
  State<HmConfetti> createState() => _HmConfettiState();
}

class _HmConfettiState extends State<HmConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final List<_Piece> _bits = _Piece.scatter(widget.pieces, widget.seed);
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = HmModes.reduceMotion(context);
    if (!_still && !_c.isAnimating && _c.value == 0) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_still) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_bits, _c.value),
          ),
        ),
      ),
    );
  }
}

class _Piece {
  _Piece(
    this.x,
    this.delay,
    this.speed,
    this.spin,
    this.drift,
    this.color,
    this.size,
  );

  final double x, delay, speed, spin, drift, size;
  final Color color;

  static const _colors = [
    Color(0xFFF5A524),
    Color(0xFF2BB673),
    Color(0xFF3A8DDE),
    Color(0xFFF2645A),
    Color(0xFFB98AE8),
    Color(0xFFFFD36E),
  ];

  static List<_Piece> scatter(int n, int seed) {
    final r = math.Random(seed);
    return [
      for (var i = 0; i < n; i++)
        _Piece(
          r.nextDouble(),
          r.nextDouble() * 0.3,
          0.7 + r.nextDouble() * 0.6,
          (r.nextDouble() - 0.5) * 14,
          (r.nextDouble() - 0.5) * 0.12,
          _colors[i % _colors.length],
          6 + r.nextDouble() * 6,
        ),
    ];
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.bits, this.t);

  final List<_Piece> bits;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    final paint = Paint();
    for (final b in bits) {
      final local = ((t - b.delay) / (1 - b.delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final y = -20 + local * b.speed * (size.height + 40);
      final x = (b.x + b.drift * math.sin(local * 6)) * size.width;
      paint.color = b.color.withValues(alpha: (1 - local) * 0.95);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(b.spin * local);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: b.size,
            height: b.size * 0.45,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
