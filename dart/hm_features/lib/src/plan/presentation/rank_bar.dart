import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/plan_models.dart';

/// Rank badge + XP bar at the top of Today (Career Ladder, §10.6 Today, INT-002-S12). The bar's shine
/// only plays when XP grows and is off in Calm and Lite Mode (§10.7, §10.8).
class RankBar extends StatelessWidget {
  const RankBar({super.key, required this.rank});

  final RankView rank;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final toNext = rank.xpToNext;
    final line = toNext == null
        ? 'Top level reached'
        : '$toNext XP to level ${rank.level + 1}';
    return Semantics(
      key: const Key('rank-bar'),
      container: true,
      label: 'Rank: level ${rank.level}, ${rank.title}. ${rank.xp} XP. $line.',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: HmSizes.minTapTarget,
              height: HmSizes.minTapTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.gold,
                border: Border.all(color: p.goldShade, width: 3),
              ),
              child: FittedBox(
                child: Text(
                  '${rank.level}',
                  style: text.titleMedium?.copyWith(
                    fontFamily: HmFonts.numbers,
                    fontWeight: FontWeight.w900,
                    color: p.onGold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rank.title, style: text.titleMedium),
                  const SizedBox(height: 4),
                  HmProgressBar(
                    value: rank.progress,
                    height: 12,
                    color: p.gold,
                    semanticLabel: 'XP to next level',
                  ),
                  const SizedBox(height: 4),
                  Text(line, style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
