import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/study_map_view.dart';

/// The Study Map as a level road (design/ui/06, BOLT-0118). On arrival the road draws itself down the
/// screen, each lamp pops in as the road reaches it, an amber trail runs over the finished stretch, and Mey hops
/// onto the next lamp to light, which then pulses. Each lamp carries its level number. Lamps are buttons named
/// after their topic, so the map reads as a list for screen readers; the road is decoration and hidden from them.
/// Under reduce motion (OS, Calm or Lite) everything is shown at rest.
class LampPath extends StatefulWidget {
  const LampPath({super.key, required this.topics, this.onTap});

  final List<TopicView> topics;
  final ValueChanged<TopicView>? onTap;

  static const rowHeight = 132.0;
  static const node = 84.0;

  /// The first topic with a lesson that is not lit yet: where Mey stands.
  static int nextIndex(List<TopicView> topics) =>
      topics.indexWhere((t) => t.hasLesson && !t.lamp.lit);

  @override
  State<LampPath> createState() => _LampPathState();
}

class _LampPathState extends State<LampPath> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (500 + widget.topics.length * 90).clamp(700, 2200),
    ),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = HmModes.reduceMotion(context);
    if (_still) {
      _intro.value = 1;
      _pulse.value = 0;
    } else if (_intro.value == 0 && !_intro.isAnimating) {
      _intro.forward().whenComplete(() {
        // A few gentle pulses on the next lamp, then rest (saves battery, lets tests settle).
        if (mounted) _pulse.repeat(count: 8);
      });
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = widget.topics;
    final next = LampPath.nextIndex(topics);
    final done = next < 0 ? topics.length : next;
    const rowH = LampPath.rowHeight;
    const nodeS = LampPath.node;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        Offset centre(int i) => Offset(
          w / 2 + math.sin(i * 1.1) * (w / 2 - nodeS * 0.8),
          rowH * i + rowH / 2,
        );
        final points = [for (var i = 0; i < topics.length; i++) centre(i)];
        final height = rowH * topics.length + HmSpace.lg;
        return AnimatedBuilder(
          animation: Listenable.merge([_intro, _pulse]),
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_intro.value);
            // Mey hops in during the last 30% of the intro.
            final hop = ((_intro.value - 0.7) / 0.3).clamp(0.0, 1.0);
            return SizedBox(
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: CustomPaint(
                        painter: _RoadPainter(
                          points,
                          progress: t,
                          trailTo: done,
                          pulse: next < 0 ? null : (centre(next), _pulse.value),
                        ),
                      ),
                    ),
                  ),
                  for (final (i, topic) in topics.indexed)
                    () {
                      // A lamp appears when the road reaches it.
                      final reach = topics.length <= 1
                          ? 0.0
                          : i / topics.length;
                      final s = ((t - reach) / 0.18).clamp(0.0, 1.0);
                      final scale =
                          Curves.elasticOut.transform(s) * 0.4 + s * 0.6;
                      final isNext = i == next;
                      return Positioned(
                        left: (centre(i).dx - 60).clamp(0, w - 120),
                        top: centre(i).dy - nodeS / 2 - 8,
                        width: 120,
                        child: Opacity(
                          opacity: s,
                          child: Transform.scale(
                            scale: s == 0 ? 0.01 : scale.clamp(0.01, 1.2),
                            child: _Node(
                              topic: topic,
                              level: i + 1,
                              isNext: isNext,
                              meyIn: isNext ? hop : 1,
                              onTap: widget.onTap == null
                                  ? null
                                  : () => widget.onTap!(topic),
                            ),
                          ),
                        ),
                      );
                    }(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.topic,
    required this.level,
    required this.isNext,
    required this.meyIn,
    this.onTap,
  });

  final TopicView topic;
  final int level;
  final bool isNext;

  /// 0..1: Mey's hop onto the next lamp (arc up, land with a squash).
  final double meyIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final l = topic.lamp;
    final (pic, words) = !topic.hasLesson
        ? (HmPic.lampLocked, 'lesson coming soon')
        : isNext
        ? (HmPic.meyWink, 'next to light')
        : l.gold
        ? (HmPic.lampGold, 'gold')
        : l.lit && l.dim != HmLampDim.bright
        ? (HmPic.lampFading, 'dimming')
        : l.lit
        ? (HmPic.lampLit, 'lit')
        : (HmPic.lampDim, 'not lit yet');
    final glow = l.lit && !l.gold && l.dim == HmLampDim.bright && !isNext;
    Widget lamp = isNext
        ? Transform.translate(
            offset: Offset(
              0,
              -math.sin(meyIn * math.pi) * 46 - (1 - meyIn) * 30,
            ),
            child: Opacity(
              opacity: meyIn == 0 ? 0 : 1,
              child: Transform.scale(
                scaleY: meyIn > 0.85 ? 1 - (1 - meyIn) * 0.8 : 1,
                alignment: Alignment.bottomCenter,
                child: HmPicture(pic, height: LampPath.node + 14),
              ),
            ),
          )
        : HmPicture(pic, height: LampPath.node);
    if (glow) {
      lamp = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: p.primary.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: lamp,
      );
    }
    if (!topic.hasLesson) lamp = Opacity(opacity: 0.75, child: lamp);
    final badgeColor = !topic.hasLesson
        ? const Color(0xFFCFC6B8)
        : l.gold
        ? const Color(0xFFE0A400)
        : l.lit
        ? p.primary
        : isNext
        ? p.primaryShade
        : const Color(0xFFB9AE9C);
    return Semantics(
      button: onTap != null,
      label: lampSemanticsLabel(topic.name, l),
      hint: words,
      excludeSemantics: true,
      child: GestureDetector(
        key: Key('lamp-${topic.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Shared element with the topic's lesson (Study Map -> topic).
                Hero(tag: 'lamp-${topic.id}', child: lamp),
                Positioned(
                  right: 6,
                  bottom: 2,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Text(
                      '$level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              topic.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: text.labelMedium?.copyWith(
                color: topic.hasLesson ? p.text : p.textMuted,
                fontWeight: isNext ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The road: a soft beige band drawn down to [progress], an amber dotted trail over the finished stretch (up to
/// node [trailTo]), and pulsing rings under the next lamp.
class _RoadPainter extends CustomPainter {
  _RoadPainter(
    this.points, {
    required this.progress,
    required this.trailTo,
    this.pulse,
  });

  final List<Offset> points;
  final double progress;
  final int trailTo;
  final (Offset, double)? pulse;

  Path _road() {
    final start = Offset(points.first.dx, points.first.dy - 30);
    final path = Path()..moveTo(start.dx, start.dy);
    var prev = start;
    for (final pt in points) {
      final mid = (prev.dy + pt.dy) / 2;
      path.cubicTo(prev.dx, mid, pt.dx, mid, pt.dx, pt.dy);
      prev = pt;
    }
    path.cubicTo(
      prev.dx,
      prev.dy + 60,
      prev.dx,
      prev.dy + 60,
      prev.dx,
      prev.dy + 90,
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dots = Paint()..color = const Color(0xFFEDE5D6);
    for (var y = 24.0; y < size.height; y += 36) {
      for (var x = 18.0; x < size.width; x += 36) {
        canvas.drawCircle(Offset(x, y), 2, dots);
      }
    }
    if (points.isEmpty || progress <= 0) return;
    final metric = _road().computeMetrics().first;
    final shown = metric.extractPath(0, metric.length * progress);
    canvas
      ..drawPath(
        shown,
        Paint()
          ..color = const Color(0xFFE9E2D5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 64
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawPath(
        shown,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    if (trailTo > 0) _trail(canvas, metric);
    final pulse = this.pulse;
    if (pulse != null && progress >= 1) {
      final (c, v) = pulse;
      for (final phase in [0.0, 0.5]) {
        final k = (v + phase) % 1;
        canvas.drawCircle(
          c + const Offset(0, 4),
          46 + k * 26,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = const Color(0xFFF5A524).withValues(alpha: (1 - k) * 0.5),
        );
      }
      canvas.drawCircle(
        c + const Offset(0, 4),
        44,
        Paint()..color = const Color(0xFFFFEFD5).withValues(alpha: 0.9),
      );
    }
  }

  /// Amber dots along the road from the start to the last finished lamp.
  void _trail(Canvas canvas, PathMetric metric) {
    final end = points[math.min(trailTo, points.length) - 1];
    // Find how far along the road the last finished lamp sits.
    var stop = metric.length;
    for (var d = 0.0; d < metric.length; d += 4) {
      final pos = metric.getTangentForOffset(d)!.position;
      if ((pos - end).distance < 6) {
        stop = d;
        break;
      }
    }
    stop = math.min(stop, metric.length * progress);
    final paint = Paint()..color = const Color(0xFFF5A524);
    for (var d = 0.0; d <= stop; d += 18) {
      canvas.drawCircle(metric.getTangentForOffset(d)!.position, 4.5, paint);
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) =>
      old.progress != progress ||
      old.trailTo != trailTo ||
      old.pulse != pulse ||
      old.points.length != points.length;
}

/// "● 12 lit · ○ 3 dimming · ★ 2 gold": the floating summary under the map.
class LampSummary extends StatelessWidget {
  const LampSummary({super.key, required this.topics});

  final List<TopicView> topics;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme.titleMedium;
    final lit = topics.where((t) => t.lamp.lit).length;
    final dimming = topics
        .where((t) => t.lamp.lit && t.lamp.dim != HmLampDim.bright)
        .length;
    final gold = topics.where((t) => t.lamp.gold).length;
    Widget dot(Color c) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    return Semantics(
      label: '$lit lit, $dimming dimming, $gold gold',
      excludeSemantics: true,
      child: HmCard(
        key: const Key('lamp-summary'),
        padding: const EdgeInsets.symmetric(
          horizontal: HmSpace.lg,
          vertical: HmSpace.md,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: HmSpace.sm,
          runSpacing: HmSpace.xs,
          children: [
            dot(p.primary),
            Text('$lit lit', style: text),
            Text('·', style: text?.copyWith(color: p.textMuted)),
            dot(const Color(0xFFE2DBCF)),
            Text('$dimming dimming', style: text),
            Text('·', style: text?.copyWith(color: p.textMuted)),
            Icon(Icons.star_rounded, color: p.primary, size: 20),
            Text('$gold gold', style: text),
          ],
        ),
      ),
    );
  }
}
