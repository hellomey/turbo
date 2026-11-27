import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/plan_models.dart';

/// The one big Today Card (§10.6 Today, INT-002-S12): one clear next action (§10.1).
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.item,
    required this.onStart,
    required this.onMarkDone,
    this.bare = false,
  });

  /// True when a bento tile already draws the box (BOLT-0110): no card of its own, and ink text
  /// on the tile's yellow fill while a step is pending.
  final bool bare;

  final PlanItemView item;
  final VoidCallback onStart;
  final VoidCallback onMarkDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pending = item.canMark;
    final p = context.hm;
    final ink = bare && pending ? p.onGold : null;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HmIconBadge(
              icon: Icons.wb_sunny_rounded,
              color: context.hm.gold,
              size: 36,
            ),
            const SizedBox(width: HmSpace.sm),
            Expanded(
              child: Text(
                'Today: ${PlanCopy.kind(item.kind)} · ${item.minutes} min',
                style: text.labelLarge?.copyWith(
                  color: ink ?? context.hm.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: HmSpace.md),
        Text(item.title, style: text.headlineMedium?.copyWith(color: ink)),
        const SizedBox(height: HmSpace.lg),
        if (pending) ...[
          HmPrimaryButton(
            key: const Key('today-card-start'),
            label: 'Start',
            semanticLabel: 'Start ${item.title}',
            onPressed: onStart,
          ),
          const SizedBox(height: 8),
          HmSecondaryButton(
            key: const Key('today-card-done'),
            label: 'Mark as done',
            semanticLabel: 'Mark ${item.title} as done',
            onPressed: onMarkDone,
          ),
        ] else
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: context.hm.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.status == PlanItemStatusView.done
                        ? 'Done. Well done.'
                        : PlanCopy.status(item.status),
                    style: text.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    if (bare) {
      return Padding(
        key: const Key('today-card'),
        padding: const EdgeInsets.all(HmSpace.xl),
        child: body,
      );
    }
    return HmCard(
      key: const Key('today-card'),
      highlighted: pending,
      child: body,
    );
  }
}
