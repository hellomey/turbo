import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'art.dart';
import 'buttons.dart';
import 'motion.dart';
import 'views.dart';

/// Bento layout (BOLT-0110): one hero tile on top, then tiles in a two-column grid. Tiles with
/// `span: 2` take a full row. On narrow screens or large text (200%) the grid becomes one column,
/// so nothing is cut off.
class HmBentoGrid extends StatelessWidget {
  const HmBentoGrid({super.key, required this.children, this.gap = HmSpace.lg});

  final List<HmBentoTile> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return LayoutBuilder(
      builder: (context, box) {
        final oneColumn = box.maxWidth < 340 || textScale > 1.4;
        final rows = <Widget>[];
        var i = 0;
        var n = 0;
        while (i < children.length) {
          final a = children[i];
          final canPair =
              !oneColumn &&
              a.span == 1 &&
              i + 1 < children.length &&
              children[i + 1].span == 1;
          if (canPair) {
            final b = children[i + 1];
            // No IntrinsicHeight: tiles may hold LayoutBuilders (progress bars).
            rows.add(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: HmEnter(index: n++, child: a),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: HmEnter(index: n++, child: b),
                  ),
                ],
              ),
            );
            i += 2;
          } else {
            rows.add(HmEnter(index: n++, child: a));
            i += 1;
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: gap),
              rows[r],
            ],
          ],
        );
      },
    );
  }
}

/// The Bauhaus corner mark on a tile: a circle, a square or a triangle.
enum HmShape { circle, square, triangle, none }

/// One bento tile: an outlined [HmCard] with an optional eyebrow, a corner shape and one child.
class HmBentoTile extends StatelessWidget {
  const HmBentoTile({
    super.key,
    required this.child,
    this.span = 1,
    this.eyebrow,
    this.color,
    this.shape = HmShape.none,
    this.shapeColor,
    this.onTap,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(HmSpace.lg),
  });

  final Widget child;

  /// 1 = half a row, 2 = a full row.
  final int span;

  /// A short label above the content, e.g. "Plan".
  final String? eyebrow;
  final Color? color;
  final HmShape shape;
  final Color? shapeColor;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final plain = HmPlain.of(context);
    final text = Theme.of(context).textTheme;
    final fill = color ?? p.surface;
    final onFill = _onColor(p, fill);
    return HmCard(
      color: fill,
      onTap: onTap,
      semanticLabel: semanticLabel,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          if (!plain && shape != HmShape.none)
            Positioned(
              right: -10,
              top: -10,
              child: ExcludeSemantics(
                child: HmShapeMark(
                  shape: shape,
                  color: shapeColor ?? p.gold,
                  size: 44,
                ),
              ),
            ),
          Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: onFill),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (eyebrow != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: Text(
                        eyebrow!.toUpperCase(),
                        style: text.labelMedium?.copyWith(
                          color: onFill,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: HmSpace.sm),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text colour for a tile fill: ink on light fills, light text on blue/red/dark fills.
Color _onColor(HmPalette p, Color fill) {
  if (fill == p.primary) return p.onPrimary;
  if (fill == p.blue) return p.onBlue;
  if (fill == p.gold) return p.onGold;
  return p.text;
}

/// The hero tile of a bento screen: a big heading, a line of text, Bauhaus art on the right and
/// one main action. [color] defaults to the palette blue; text colours follow the fill.
class HmBentoHero extends StatelessWidget {
  const HmBentoHero({
    super.key,
    required this.title,
    this.eyebrow,
    this.message,
    this.art,
    this.footer,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.color,
  });

  final String title;
  final String? eyebrow;
  final String? message;
  final HmArtName? art;
  final Widget? footer;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final plain = HmPlain.of(context);
    final text = Theme.of(context).textTheme;
    final fill = plain ? p.surface : (color ?? p.blue);
    final on = _onColor(p, fill);
    final narrow = MediaQuery.textScalerOf(context).scale(16) / 16 > 1.4;
    final artWidget = art == null || plain
        ? null
        : HmArt(art!, size: narrow ? 72 : 96);
    return HmCard(
      color: fill,
      padding: const EdgeInsets.all(HmSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!.toUpperCase(),
                        style: text.labelMedium?.copyWith(
                          color: on,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: HmSpace.sm),
                    ],
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: text.headlineMedium?.copyWith(color: on),
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: HmSpace.sm),
                      Text(
                        message!,
                        style: text.bodyLarge?.copyWith(color: on),
                      ),
                    ],
                  ],
                ),
              ),
              if (artWidget != null && !narrow) ...[
                const SizedBox(width: HmSpace.md),
                artWidget,
              ],
            ],
          ),
          if (artWidget != null && narrow) ...[
            const SizedBox(height: HmSpace.md),
            artWidget,
          ],
          if (footer != null) ...[const SizedBox(height: HmSpace.lg), footer!],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: HmSpace.lg),
            HmPrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
              icon: actionIcon,
              tone: fill == p.primary
                  ? HmButtonTone.gold
                  : HmButtonTone.primary,
            ),
          ],
        ],
      ),
    );
  }
}

/// A big number with a small label under it, for stat tiles ("12 lamps lit").
class HmStat extends StatelessWidget {
  const HmStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = DefaultTextStyle.of(context).style.color;
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: text.displaySmall?.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(label, style: text.labelLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// A Bauhaus shape: a circle, a square or a triangle with an ink outline. Decorative.
class HmShapeMark extends StatelessWidget {
  const HmShapeMark({
    super.key,
    required this.shape,
    required this.color,
    this.size = 32,
  });

  final HmShape shape;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _ShapePainter(shape, color, context.hm.outline),
  );
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.shape, this.color, this.ink);

  final HmShape shape;
  final Color color;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    const w = HmBauhaus.strokeSmall;
    final path = switch (shape) {
      HmShape.circle =>
        Path()..addOval(Rect.fromLTWH(w, w, s - 2 * w, s - 2 * w)),
      HmShape.square =>
        Path()..addRect(Rect.fromLTWH(w, w, s - 2 * w, s - 2 * w)),
      HmShape.triangle =>
        Path()
          ..moveTo(s / 2, w)
          ..lineTo(s - w, s - w)
          ..lineTo(w, s - w)
          ..close(),
      HmShape.none => Path(),
    };
    canvas
      ..drawPath(path, Paint()..color = color)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeJoin = StrokeJoin.round
          ..color = ink,
      );
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.shape != shape || old.color != color || old.ink != ink;
}

/// A small persistent "Beta" chip. Screen readers and long-press hear the full line, and a tap
/// shows it: "HeyMey is in beta and still being built."
class HmBetaChip extends StatelessWidget {
  const HmBetaChip({super.key});

  static const message = 'HeyMey is in beta and still being built.';

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    return Tooltip(
      message: message,
      child: Semantics(
        button: true,
        label: 'Beta. $message',
        excludeSemantics: true,
        child: InkWell(
          onTap: () => ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(const SnackBar(content: Text(message))),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: HmSizes.minTapTarget,
              minWidth: HmSizes.minTapTarget,
            ),
            child: Center(
              widthFactor: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: HmSpace.sm,
                  vertical: HmSpace.xxs,
                ),
                decoration: BoxDecoration(
                  color: p.gold,
                  border: Border.all(
                    color: p.outline,
                    width: HmBauhaus.strokeSmall,
                  ),
                ),
                child: Text(
                  'BETA',
                  style: text.labelMedium?.copyWith(
                    color: p.onGold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
