import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/plan_controller.dart';
import '../domain/plan_models.dart';

/// My Plan: the 14-day view with item status and rebalance (INT-002-S12, §19.2 Q18).
class MyPlanScreen extends ConsumerWidget {
  const MyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(planDaysViewProvider);
    final plan = ref.watch(planControllerProvider);
    final controller = ref.read(planControllerProvider.notifier);
    ref.listen(planControllerProvider.select((s) => s.message), (_, msg) {
      if (msg == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
      controller.clearMessage();
    });
    return Scaffold(
      appBar: AppBar(title: const Text('My Plan')),
      body: days.when(
        loading: () => const HmSkeletonList(label: 'Loading your plan'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(todayProvider),
        ),
        data: (list) => MyPlanBody(
          days: list,
          rebalancing: plan.rebalancing,
          onMark: (item, status) async {
            final ok = await controller.mark(item, status);
            if (ok && context.mounted) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text(PlanCopy.savedOffline)),
                );
            }
          },
          onRebalance: controller.rebalance,
        ),
      ),
    );
  }
}

/// Layout only, for tests and goldens.
class MyPlanBody extends StatelessWidget {
  const MyPlanBody({
    super.key,
    required this.days,
    required this.onMark,
    required this.onRebalance,
    this.rebalancing = false,
  });

  final List<PlanDayView> days;
  final void Function(PlanItemView item, PlanItemStatusView status) onMark;
  final VoidCallback onRebalance;
  final bool rebalancing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.xxl,
      ),
      children: [
        Text(
          'Missed a day? Rebalance spreads the work over the next days.',
          style: text.bodyLarge?.copyWith(color: context.hm.textMuted),
        ),
        const SizedBox(height: HmSpace.md),
        HmSecondaryButton(
          key: const Key('plan-rebalance'),
          label: rebalancing ? 'Rebalancing…' : 'Rebalance my plan',
          semanticLabel: 'Rebalance my plan. Needs a connection.',
          icon: Icons.sync,
          onPressed: rebalancing ? null : onRebalance,
        ),
        const SizedBox(height: 16),
        if (days.isEmpty)
          const HmEmptyView(
            kind: HmIllustrationKind.soon,
            title: 'Nothing planned yet',
            message: 'No study is planned for these days.',
          ),
        for (final (i, d) in days.indexed) ...[
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.only(
                top: HmSpace.lg,
                bottom: HmSpace.sm,
              ),
              child: Text(
                '${i == 0 ? 'Today, ' : ''}${formatDay(d.day)} · ${d.minutes} min',
                style: text.titleMedium,
              ),
            ),
          ),
          if (d.items.isEmpty)
            Row(
              children: [
                Icon(
                  Icons.self_improvement_rounded,
                  size: 20,
                  color: context.hm.textMuted,
                ),
                const SizedBox(width: HmSpace.sm),
                Text(
                  'Rest day',
                  style: text.bodyMedium?.copyWith(color: context.hm.textMuted),
                ),
              ],
            ),
          for (final item in d.items) _ItemTile(item: item, onMark: onMark),
        ],
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.onMark});

  final PlanItemView item;
  final void Function(PlanItemView item, PlanItemStatusView status) onMark;

  /// Status differs by icon shape, not only colour (§10.9).
  IconData get _icon => switch (item.status) {
    PlanItemStatusView.pending => Icons.radio_button_unchecked,
    PlanItemStatusView.done => Icons.check_circle,
    PlanItemStatusView.skipped => Icons.remove_circle_outline,
    PlanItemStatusView.moved => Icons.arrow_circle_right_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = PlanCopy.status(item.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: HmCard(
        key: Key('plan-item-${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Row(
                children: [
                  Icon(
                    _icon,
                    semanticLabel: status,
                    color: item.status == PlanItemStatusView.done
                        ? context.hm.success
                        : context.hm.primaryText,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: text.titleSmall),
                        Text(
                          '${PlanCopy.kind(item.kind)} · ${item.minutes} min · $status',
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (item.canMark) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HmSecondaryButton(
                    key: Key('plan-done-${item.id}'),
                    label: 'Done',
                    semanticLabel: 'Mark ${item.title} as done',
                    expand: false,
                    onPressed: () => onMark(item, PlanItemStatusView.done),
                  ),
                  HmSecondaryButton(
                    key: Key('plan-skip-${item.id}'),
                    label: 'Skip',
                    semanticLabel: 'Skip ${item.title}',
                    expand: false,
                    onPressed: () => onMark(item, PlanItemStatusView.skipped),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
