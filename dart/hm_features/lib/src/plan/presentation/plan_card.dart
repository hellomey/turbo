import 'package:flutter/material.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/plan_models.dart';

/// The one big Today Card (§10.6 Today, INT-002-S12): one clear next action (§10.1).
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.item,
    required this.onStart,
    required this.onMarkDone,
  });

  final PlanItemView item;
  final VoidCallback onStart;
  final VoidCallback onMarkDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pending = item.canMark;
    return HmCard(
      key: const Key('today-card'),
      highlighted: pending,
      child: Column(
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
                  style: text.labelLarge?.copyWith(color: context.hm.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: HmSpace.md),
          Text(item.title, style: text.headlineSmall),
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
      ),
    );
  }
}
