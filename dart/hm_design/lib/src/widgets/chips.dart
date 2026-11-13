import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// A small pill: icon + value. Used for XP and the Career Ladder rank (§5.2).
class _HmPill extends StatelessWidget {
  const _HmPill({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.semanticLabel,
    this.onTap,
  });

  final Widget icon;
  final Color iconColor;
  final String text;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final pill = Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(
        horizontal: HmSpace.md,
        vertical: HmSpace.xs,
      ),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(HmRadius.pill),
        border: Border.all(color: p.outline, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: HmSpace.xs + 2),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontFamily: HmFonts.numbers,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: onTap == null
          ? pill
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(HmRadius.pill),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: HmSizes.minTapTarget,
                ),
                child: Center(widthFactor: 1, child: pill),
              ),
            ),
    );
  }
}

/// XP chip: a gold bolt + the number.
class HmXpChip extends StatelessWidget {
  const HmXpChip({super.key, required this.xp, this.onTap});

  final int xp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _HmPill(
    icon: Icon(Icons.bolt_rounded, color: context.hm.goldText, size: 20),
    iconColor: context.hm.goldText,
    text: '$xp XP',
    semanticLabel: '$xp XP',
    onTap: onTap,
  );
}

/// Rank chip: level number in a gold shield + the rank title (a game title, §5.2).
class HmRankChip extends StatelessWidget {
  const HmRankChip({
    super.key,
    required this.level,
    required this.title,
    this.onTap,
  });

  final int level;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return _HmPill(
      icon: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.gold,
          shape: BoxShape.circle,
          border: Border.all(color: p.goldShade, width: 2),
        ),
        child: FittedBox(
          child: Text(
            '$level',
            style: TextStyle(
              fontFamily: HmFonts.numbers,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: p.onGold,
            ),
          ),
        ),
      ),
      iconColor: p.gold,
      text: title,
      semanticLabel: 'Rank $level, $title',
      onTap: onTap,
    );
  }
}
