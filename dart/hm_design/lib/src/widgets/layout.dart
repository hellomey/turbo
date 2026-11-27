import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'buttons.dart';
import 'illustrations.dart';
import 'progress.dart';
import 'views.dart';

/// Screen building blocks (BOLT-0022): one hierarchy for every screen (§10.1): a hero or header,
/// sections with titles, and one clear next action.

/// A progress header for step-by-step flows (onboarding, checks): "Step 2 of 4" plus a chunky bar.
/// Screen readers hear the step text; the bar is decorative.
class HmStepHeader extends StatelessWidget {
  const HmStepHeader({
    super.key,
    required this.step,
    required this.total,
    this.label,
  });

  /// 1-based step number.
  final int step;
  final int total;

  /// Optional short name of the step, e.g. "Your exams".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final safeTotal = total < 1 ? 1 : total;
    final s = step.clamp(0, safeTotal);
    final stepText = 'Step $s of $safeTotal';
    return Semantics(
      container: true,
      label: label == null ? stepText : '$stepText: $label',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          HmSpace.lg,
          HmSpace.sm,
          HmSpace.lg,
          HmSpace.md,
        ),
        // Warm light (BOLT-0117): amber segments, one per step, with "2 of 8" under them.
        child: Column(
          children: [
            if (safeTotal <= 12)
              Row(
                children: [
                  for (var i = 0; i < safeTotal; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: AnimatedContainer(
                        duration: HmMotion.fast,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i < s ? p.primary : const Color(0xFFE9E4DB),
                          borderRadius: BorderRadius.circular(HmRadius.pill),
                        ),
                      ),
                    ),
                  ],
                ],
              )
            else
              HmProgressBar(
                value: s / safeTotal,
                semanticLabel: stepText,
                height: 8,
                animate: false,
              ),
            const SizedBox(height: HmSpace.sm),
            Text(
              label == null ? '$s of $safeTotal' : '$label · $s of $safeTotal',
              style: text.labelLarge?.copyWith(color: p.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// A section title with an optional trailing widget (e.g. a chip or a ghost button).
class HmSectionTitle extends StatelessWidget {
  const HmSectionTitle(this.title, {super.key, this.trailing, this.icon});

  final String title;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return Padding(
      padding: const EdgeInsets.only(top: HmSpace.lg, bottom: HmSpace.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: p.primaryText),
            const SizedBox(width: HmSpace.sm),
          ],
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A Bauhaus circle with an ink outline and a tinted icon: leading art for list cards.
class HmIconBadge extends StatelessWidget {
  const HmIconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final c = color ?? p.primary;
    final plain = HmPlain.of(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: plain
              ? p.surface2
              : Color.alphaBlend(c.withValues(alpha: 0.18), p.surface),
          shape: BoxShape.circle,
          border: Border.all(color: p.outline, width: HmBauhaus.strokeSmall),
        ),
        child: Icon(icon, size: size * 0.55, color: plain ? p.text : c),
      ),
    );
  }
}

/// The top-of-screen hero card: illustration, title, a short line and (optionally) one action.
/// In [HmPlain] it renders flat with no illustration.
class HmHeroCard extends StatelessWidget {
  const HmHeroCard({
    super.key,
    required this.title,
    this.message,
    this.illustration,
    this.footer,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  final String title;
  final String? message;
  final HmIllustrationKind? illustration;

  /// Extra content under the message (chips, a progress bar).
  final Widget? footer;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final plain = HmPlain.of(context);
    return HmCard(
      padding: const EdgeInsets.all(HmSpace.xl),
      color: plain ? null : p.surface2,
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
                    Semantics(
                      header: true,
                      child: Text(title, style: text.headlineSmall),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: HmSpace.sm),
                      Text(
                        message!,
                        style: text.bodyLarge?.copyWith(color: p.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (illustration != null && !plain) ...[
                const SizedBox(width: HmSpace.md),
                HmIllustration(kind: illustration!, size: 76),
              ],
            ],
          ),
          if (footer != null) ...[const SizedBox(height: HmSpace.lg), footer!],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: HmSpace.lg),
            HmPrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
              icon: actionIcon,
            ),
          ],
        ],
      ),
    );
  }
}

/// A list of card skeletons for loading screens. Screen readers hear [label] once.
class HmSkeletonList extends StatelessWidget {
  const HmSkeletonList({super.key, this.count = 3, this.label = 'Loading'});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return Semantics(
      label: label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(HmSpace.lg),
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(height: HmSpace.md),
          itemBuilder: (context, i) => Container(
            padding: const EdgeInsets.all(HmSpace.lg),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(HmRadius.lg),
              border: Border.all(color: p.outline, width: HmBauhaus.stroke),
            ),
            child: HmSkeleton.card(),
          ),
        ),
      ),
    );
  }
}
