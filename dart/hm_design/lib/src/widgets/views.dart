import 'package:flutter/material.dart';

import '../tokens.dart';
import 'buttons.dart';
import 'illustrations.dart';

/// A rounded surface card with a solid bottom edge for depth. Tappable cards sink when pressed and
/// are buttons for screen readers.
class HmCard extends StatefulWidget {
  const HmCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(HmSpace.lg),
    this.highlighted = false,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;

  /// A gold edge, e.g. the top 5 exams on the eligibility result (§10.6).
  final bool highlighted;

  /// Optional fill (defaults to the theme surface).
  final Color? color;

  @override
  State<HmCard> createState() => _HmCardState();
}

class _HmCardState extends State<HmCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final plain = HmPlain.of(context);
    final edge = widget.highlighted ? p.gold : p.outline;
    final depth = plain ? 0.0 : HmElevation.cardDepth;
    final sink = _pressed ? depth : 0.0;
    final radius = BorderRadius.circular(HmRadius.lg);
    Widget card = AnimatedContainer(
      duration: HmMotion.press,
      margin: EdgeInsets.only(top: sink, bottom: depth - sink),
      decoration: BoxDecoration(
        color: widget.color ?? p.surface,
        borderRadius: radius,
        border: Border.all(color: edge, width: widget.highlighted ? 2.5 : 1.5),
        boxShadow: depth - sink > 0
            ? [BoxShadow(color: edge, offset: Offset(0, depth - sink))]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          type: MaterialType.transparency,
          child: widget.onTap == null
              ? Padding(padding: widget.padding, child: widget.child)
              : InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: HmSizes.minTapTarget,
                    ),
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ),
        ),
      ),
    );
    if (widget.onTap == null && widget.semanticLabel == null) return card;
    card = Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: card,
    );
    return card;
  }
}

/// A friendly message block with a drawn illustration and at most one action (§10.1).
class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.kind,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.liveRegion = false,
  });

  final HmIllustrationKind kind;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(HmSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HmIllustration(kind: kind, size: 112),
              const SizedBox(height: HmSpace.lg),
              if (title != null)
                Text(
                  title!,
                  style: text.titleLarge,
                  textAlign: TextAlign.center,
                ),
              if (message != null) ...[
                const SizedBox(height: HmSpace.sm),
                Semantics(
                  liveRegion: liveRegion,
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: text.bodyLarge?.copyWith(color: p.textMuted),
                  ),
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: HmSpace.xl),
                HmSecondaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A calm error state with one action. [message] is simple English (usually the API's message).
class HmErrorView extends StatelessWidget {
  const HmErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.title,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final String? title;

  @override
  Widget build(BuildContext context) => _MessageView(
    kind: HmIllustrationKind.error,
    title: title,
    message: message,
    actionLabel: retryLabel,
    onAction: onRetry,
    liveRegion: true,
  );
}

/// A friendly "nothing here yet" state with an optional single action.
class HmEmptyView extends StatelessWidget {
  const HmEmptyView({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.kind = HmIllustrationKind.empty,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// The drawn illustration (BOLT-0022 adds book, bell, chart, shield, trophy, welcome).
  final HmIllustrationKind kind;

  @override
  Widget build(BuildContext context) => _MessageView(
    kind: kind,
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

/// A loading state. Screen readers hear [label].
class HmLoadingView extends StatelessWidget {
  const HmLoadingView({super.key, this.label = 'Loading'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label,
        liveRegion: true,
        child: CircularProgressIndicator(
          color: context.hm.primary,
          strokeWidth: 4,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}

/// A calm placeholder for parts that arrive later (Play, Squad in Phase 1).
class HmComingSoon extends StatelessWidget {
  const HmComingSoon({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) =>
      _MessageView(kind: HmIllustrationKind.soon, title: title, message: body);
}

/// A skeleton placeholder block that gently pulses (static in Calm/Lite Mode and [HmPlain]).
class HmSkeleton extends StatefulWidget {
  const HmSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = HmRadius.sm,
  });

  final double? width;
  final double height;
  final double radius;

  /// A ready-made card skeleton: a title line and three text lines.
  static Widget card({Key? key, String label = 'Loading'}) => Semantics(
    key: key,
    label: label,
    child: const ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HmSkeleton(width: 160, height: 22),
          SizedBox(height: HmSpace.md),
          HmSkeleton(),
          SizedBox(height: HmSpace.sm),
          HmSkeleton(),
          SizedBox(height: HmSpace.sm),
          HmSkeleton(width: 120),
        ],
      ),
    ),
  );

  @override
  State<HmSkeleton> createState() => _HmSkeletonState();
}

class _HmSkeletonState extends State<HmSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = HmModes.reduceMotion(context) || HmPlain.of(context);
    if (still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(p.surface2, p.surface3, _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
