import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/study_map_view.dart';

/// The Study Map as a game path (design/ui/06, BOLT-0117): topics sit on a soft winding road, each
/// drawn as a lamp in its real state (gold, lit, dimming, dark, or locked when there is no lesson
/// yet). Mey waits on the next lamp to light. Lamps are buttons named after their topic, so the map
/// reads as a list for screen readers. The road is decoration and hidden from them.
class LampPath extends StatelessWidget {
  const LampPath({super.key, required this.topics, this.onTap});

  final List<TopicView> topics;
  final ValueChanged<TopicView>? onTap;

  static const _rowHeight = 132.0;
  static const _node = 84.0;

  /// The first topic with a lesson that is not lit yet: where Mey stands.
  static int nextIndex(List<TopicView> topics) =>
      topics.indexWhere((t) => t.hasLesson && !t.lamp.lit);

  @override
  Widget build(BuildContext context) {
    final next = nextIndex(topics);
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        // Node centres swing left and right along a sine, like a winding road.
        Offset centre(int i) => Offset(
          w / 2 + math.sin(i * 1.1) * (w / 2 - _node * 0.8),
          _rowHeight * i + _rowHeight / 2,
        );
        final height = _rowHeight * topics.length + HmSpace.lg;
        return SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _RoadPainter([
                      for (var i = 0; i < topics.length; i++) centre(i),
                    ]),
                  ),
                ),
              ),
              for (final (i, t) in topics.indexed)
                Positioned(
                  left: (centre(i).dx - 60).clamp(0, w - 120),
                  top: centre(i).dy - _node / 2 - 8,
                  width: 120,
                  child: HmEnter(
                    index: i,
                    child: _Node(
                      topic: t,
                      isNext: i == next,
                      onTap: onTap == null ? null : () => onTap!(t),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.topic, required this.isNext, this.onTap});

  final TopicView topic;
  final bool isNext;
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
        ? HmMey(pic, size: LampPath._node + 14)
        : HmPicture(pic, height: LampPath._node);
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
            // Shared element with the topic's lesson (Study Map -> topic).
            Hero(tag: 'lamp-${topic.id}', child: lamp),
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

/// A wide, soft beige road through the node centres, with a faint dotted kolam texture beside it.
class _RoadPainter extends CustomPainter {
  _RoadPainter(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final dots = Paint()..color = const Color(0xFFEDE5D6);
    for (var y = 24.0; y < size.height; y += 36) {
      for (var x = 18.0; x < size.width; x += 36) {
        canvas.drawCircle(Offset(x, y), 2, dots);
      }
    }
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy - 30);
    var prev = Offset(points.first.dx, points.first.dy - 30);
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
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE9E2D5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 64
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_RoadPainter old) => old.points.length != points.length;
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
