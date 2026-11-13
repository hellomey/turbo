import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Friendly illustrations drawn in code (no third-party art, BOLT-0021). Decorative only:
/// screen readers skip them; the text next to them carries the meaning.
enum HmIllustrationKind {
  /// A small unlit lamp with sparkles: "nothing here yet".
  empty,

  /// A lamp with a loose plug: "something went wrong".
  error,

  /// An hourglass with a star: "coming soon".
  soon,

  /// A bright lamp with rays: welcomes and fresh starts (BOLT-0022).
  welcome,

  /// A shield with a tick: privacy and consent.
  shield,

  /// A bell with a dot: exam alerts.
  bell,

  /// An open book: lessons and the PYQ Vault.
  book,

  /// Rising bars: readiness and reports.
  chart,

  /// A trophy cup: ranks and wins.
  trophy,
}

class HmIllustration extends StatelessWidget {
  const HmIllustration({super.key, required this.kind, this.size = 120});

  final HmIllustrationKind kind;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _IllustrationPainter(kind, context.hm),
    ),
  );
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter(this.kind, this.p);

  final HmIllustrationKind kind;
  final HmPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w / 2, w / 2);
    // Soft blob behind everything.
    canvas.drawCircle(c, w * 0.46, Paint()..color = p.surface3);
    canvas.drawCircle(
      c.translate(w * 0.18, -w * 0.2),
      w * 0.12,
      Paint()..color = p.surface2,
    );

    switch (kind) {
      case HmIllustrationKind.empty:
      case HmIllustrationKind.error:
        _lamp(canvas, w, c, lit: kind == HmIllustrationKind.empty);
        if (kind == HmIllustrationKind.empty) {
          _sparkle(canvas, c.translate(-w * 0.28, -w * 0.22), w * 0.07, p.gold);
          _sparkle(canvas, c.translate(w * 0.3, -w * 0.05), w * 0.05, p.gold);
        } else {
          _plug(canvas, w, c);
        }
      case HmIllustrationKind.soon:
        _hourglass(canvas, w, c);
        _sparkle(canvas, c.translate(w * 0.27, -w * 0.25), w * 0.07, p.gold);
      case HmIllustrationKind.welcome:
        _rays(canvas, w, c.translate(0, -w * 0.08));
        _lamp(canvas, w, c, lit: true);
        _sparkle(canvas, c.translate(-w * 0.3, -w * 0.18), w * 0.07, p.gold);
        _sparkle(canvas, c.translate(w * 0.3, -w * 0.24), w * 0.06, p.primary);
      case HmIllustrationKind.shield:
        _shield(canvas, w, c);
        _sparkle(canvas, c.translate(w * 0.3, -w * 0.24), w * 0.06, p.gold);
      case HmIllustrationKind.bell:
        _bell(canvas, w, c);
        _sparkle(canvas, c.translate(-w * 0.3, -w * 0.2), w * 0.06, p.gold);
      case HmIllustrationKind.book:
        _book(canvas, w, c);
        _sparkle(canvas, c.translate(w * 0.28, -w * 0.28), w * 0.07, p.gold);
      case HmIllustrationKind.chart:
        _chart(canvas, w, c);
        _sparkle(canvas, c.translate(w * 0.26, -w * 0.3), w * 0.06, p.gold);
      case HmIllustrationKind.trophy:
        _trophy(canvas, w, c);
        _sparkle(canvas, c.translate(-w * 0.32, -w * 0.22), w * 0.07, p.gold);
        _sparkle(canvas, c.translate(w * 0.32, -w * 0.1), w * 0.05, p.primary);
    }
  }

  void _rays(Canvas canvas, double w, Offset c) {
    final ray = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.03
      ..color = p.gold.withValues(alpha: 0.55);
    for (var i = 0; i < 7; i++) {
      final a = -math.pi + (i + 0.5) * math.pi / 7;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * w * 0.3, c + d * w * 0.4, ray);
    }
  }

  void _shield(Canvas canvas, double w, Offset c) {
    final s = Path()
      ..moveTo(c.dx, c.dy - w * 0.3)
      ..lineTo(c.dx + w * 0.24, c.dy - w * 0.2)
      ..quadraticBezierTo(
        c.dx + w * 0.24,
        c.dy + w * 0.18,
        c.dx,
        c.dy + w * 0.32,
      )
      ..quadraticBezierTo(
        c.dx - w * 0.24,
        c.dy + w * 0.18,
        c.dx - w * 0.24,
        c.dy - w * 0.2,
      )
      ..close();
    canvas.drawPath(
      s.shift(Offset(0, w * 0.03)),
      Paint()..color = p.primaryShade,
    );
    canvas.drawPath(s, Paint()..color = p.primary);
    final tick = Path()
      ..moveTo(c.dx - w * 0.1, c.dy)
      ..lineTo(c.dx - w * 0.02, c.dy + w * 0.08)
      ..lineTo(c.dx + w * 0.12, c.dy - w * 0.08);
    canvas.drawPath(
      tick,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * 0.045
        ..color = p.onPrimary,
    );
  }

  void _bell(Canvas canvas, double w, Offset c) {
    final body = Path()
      ..moveTo(c.dx - w * 0.24, c.dy + w * 0.16)
      ..quadraticBezierTo(
        c.dx - w * 0.16,
        c.dy + w * 0.08,
        c.dx - w * 0.17,
        c.dy - w * 0.06,
      )
      ..quadraticBezierTo(
        c.dx - w * 0.16,
        c.dy - w * 0.26,
        c.dx,
        c.dy - w * 0.26,
      )
      ..quadraticBezierTo(
        c.dx + w * 0.16,
        c.dy - w * 0.26,
        c.dx + w * 0.17,
        c.dy - w * 0.06,
      )
      ..quadraticBezierTo(
        c.dx + w * 0.16,
        c.dy + w * 0.08,
        c.dx + w * 0.24,
        c.dy + w * 0.16,
      )
      ..close();
    canvas.drawPath(
      body.shift(Offset(0, w * 0.03)),
      Paint()..color = p.goldShade,
    );
    canvas.drawPath(body, Paint()..color = p.gold);
    canvas.drawCircle(
      c.translate(0, w * 0.22),
      w * 0.06,
      Paint()..color = p.goldShade,
    );
    canvas.drawCircle(
      c.translate(w * 0.17, -w * 0.2),
      w * 0.065,
      Paint()..color = p.error,
    );
  }

  void _book(Canvas canvas, double w, Offset c) {
    final r = Radius.circular(w * 0.04);
    final left = RRect.fromLTRBR(
      c.dx - w * 0.3,
      c.dy - w * 0.2,
      c.dx - w * 0.01,
      c.dy + w * 0.22,
      r,
    );
    final right = RRect.fromLTRBR(
      c.dx + w * 0.01,
      c.dy - w * 0.2,
      c.dx + w * 0.3,
      c.dy + w * 0.22,
      r,
    );
    final edge = Paint()..color = p.primaryShade;
    canvas.drawRRect(left.shift(Offset(0, w * 0.03)), edge);
    canvas.drawRRect(right.shift(Offset(0, w * 0.03)), edge);
    canvas.drawRRect(left, Paint()..color = p.surface);
    canvas.drawRRect(right, Paint()..color = p.surface);
    final line = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.022
      ..color = p.textMuted.withValues(alpha: 0.6);
    for (var i = 0; i < 4; i++) {
      final y = c.dy - w * 0.1 + i * w * 0.08;
      canvas.drawLine(
        Offset(c.dx - w * 0.24, y),
        Offset(c.dx - w * 0.07, y),
        line,
      );
      canvas.drawLine(
        Offset(c.dx + w * 0.07, y),
        Offset(c.dx + w * 0.24, y),
        line,
      );
    }
    canvas.drawRect(
      Rect.fromLTRB(
        c.dx + w * 0.16,
        c.dy - w * 0.22,
        c.dx + w * 0.21,
        c.dy - w * 0.06,
      ),
      Paint()..color = p.error,
    );
  }

  void _chart(Canvas canvas, double w, Offset c) {
    final base = c.dy + w * 0.24;
    const heights = [0.16, 0.28, 0.4];
    final colors = [p.steady, p.primary, p.gold];
    for (var i = 0; i < 3; i++) {
      final x = c.dx - w * 0.24 + i * w * 0.17;
      final r = RRect.fromLTRBR(
        x,
        base - w * heights[i],
        x + w * 0.13,
        base,
        Radius.circular(w * 0.03),
      );
      canvas.drawRRect(
        r.shift(Offset(0, w * 0.025)),
        Paint()..color = p.outline,
      );
      canvas.drawRRect(r, Paint()..color = colors[i]);
    }
  }

  void _trophy(Canvas canvas, double w, Offset c) {
    final gold = Paint()..color = p.gold;
    final shade = Paint()..color = p.goldShade;
    final handle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..color = p.goldShade;
    canvas.drawArc(
      Rect.fromCircle(
        center: c.translate(-w * 0.18, -w * 0.1),
        radius: w * 0.08,
      ),
      math.pi / 2,
      math.pi,
      false,
      handle,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: c.translate(w * 0.18, -w * 0.1),
        radius: w * 0.08,
      ),
      -math.pi / 2,
      math.pi,
      false,
      handle,
    );
    final cup = Path()
      ..moveTo(c.dx - w * 0.2, c.dy - w * 0.24)
      ..lineTo(c.dx + w * 0.2, c.dy - w * 0.24)
      ..quadraticBezierTo(
        c.dx + w * 0.2,
        c.dy + w * 0.06,
        c.dx,
        c.dy + w * 0.08,
      )
      ..quadraticBezierTo(
        c.dx - w * 0.2,
        c.dy + w * 0.06,
        c.dx - w * 0.2,
        c.dy - w * 0.24,
      )
      ..close();
    canvas.drawPath(cup.shift(Offset(0, w * 0.03)), shade);
    canvas.drawPath(cup, gold);
    canvas.drawRect(
      Rect.fromLTRB(
        c.dx - w * 0.04,
        c.dy + w * 0.08,
        c.dx + w * 0.04,
        c.dy + w * 0.18,
      ),
      shade,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        c.dx - w * 0.15,
        c.dy + w * 0.18,
        c.dx + w * 0.15,
        c.dy + w * 0.27,
        Radius.circular(w * 0.03),
      ),
      gold,
    );
    _sparkle(canvas, c.translate(0, -w * 0.1), w * 0.07, p.onGold);
  }

  void _lamp(Canvas canvas, double w, Offset c, {required bool lit}) {
    // A diya: a bowl with a flame.
    final bowl = Path()
      ..moveTo(c.dx - w * 0.28, c.dy + w * 0.06)
      ..quadraticBezierTo(
        c.dx,
        c.dy + w * 0.38,
        c.dx + w * 0.28,
        c.dy + w * 0.06,
      )
      ..close();
    canvas.drawPath(
      bowl.shift(Offset(0, w * 0.03)),
      Paint()..color = p.goldShade,
    );
    canvas.drawPath(bowl, Paint()..color = p.gold);
    final flame = Path()
      ..moveTo(c.dx, c.dy - w * 0.26)
      ..quadraticBezierTo(
        c.dx + w * 0.11,
        c.dy - w * 0.05,
        c.dx,
        c.dy + w * 0.05,
      )
      ..quadraticBezierTo(
        c.dx - w * 0.11,
        c.dy - w * 0.05,
        c.dx,
        c.dy - w * 0.26,
      )
      ..close();
    canvas.drawPath(
      flame,
      lit
          ? (Paint()..color = p.flame)
          : (Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.025
              ..color = p.textMuted),
    );
    if (lit) {
      canvas.drawCircle(
        c.translate(0, -w * 0.06),
        w * 0.035,
        Paint()..color = p.gold,
      );
    }
    // Two friendly eyes on the bowl.
    final eye = Paint()..color = p.onGold;
    canvas.drawCircle(c.translate(-w * 0.07, w * 0.13), w * 0.022, eye);
    canvas.drawCircle(c.translate(w * 0.07, w * 0.13), w * 0.022, eye);
  }

  void _plug(Canvas canvas, double w, Offset c) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.03
      ..color = p.textMuted;
    final cord = Path()
      ..moveTo(c.dx + w * 0.26, c.dy + w * 0.12)
      ..cubicTo(
        c.dx + w * 0.42,
        c.dy + w * 0.2,
        c.dx + w * 0.3,
        c.dy + w * 0.36,
        c.dx + w * 0.16,
        c.dy + w * 0.36,
      );
    canvas.drawPath(cord, line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c.translate(w * 0.1, w * 0.36),
          width: w * 0.1,
          height: w * 0.08,
        ),
        Radius.circular(w * 0.02),
      ),
      Paint()..color = p.error,
    );
  }

  void _hourglass(Canvas canvas, double w, Offset c) {
    final frame = Paint()..color = p.goldShade;
    final glass = Paint()..color = p.surface;
    final sand = Paint()..color = p.gold;
    final top = c.dy - w * 0.26, bottom = c.dy + w * 0.26, half = w * 0.18;
    canvas.drawRRect(
      RRect.fromLTRBR(
        c.dx - half - 6,
        top - 8,
        c.dx + half + 6,
        top,
        const Radius.circular(4),
      ),
      frame,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        c.dx - half - 6,
        bottom,
        c.dx + half + 6,
        bottom + 8,
        const Radius.circular(4),
      ),
      frame,
    );
    final body = Path()
      ..moveTo(c.dx - half, top)
      ..lineTo(c.dx + half, top)
      ..lineTo(c.dx + 4, c.dy)
      ..lineTo(c.dx + half, bottom)
      ..lineTo(c.dx - half, bottom)
      ..lineTo(c.dx - 4, c.dy)
      ..close();
    canvas.drawPath(body, glass);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - half * 0.7, bottom)
        ..lineTo(c.dx, bottom - w * 0.12)
        ..lineTo(c.dx + half * 0.7, bottom)
        ..close(),
      sand,
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - half * 0.55, top + w * 0.06)
        ..lineTo(c.dx + half * 0.55, top + w * 0.06)
        ..lineTo(c.dx, c.dy - 2)
        ..close(),
      sand,
    );
  }

  void _sparkle(Canvas canvas, Offset at, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final rr = i.isEven ? r : r * 0.35;
      final pt = at + Offset(math.cos(a), math.sin(a)) * rr;
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) =>
      old.kind != kind || old.p != p;
}
