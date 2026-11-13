import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../plan/application/plan_controller.dart';
import '../../plan/domain/plan_models.dart';
import '../../plan/presentation/plan_card.dart';
import '../../plan/presentation/rank_bar.dart';
import '../../practice/domain/practice_models.dart' show rankUpSubtitle;
import '../../profile/application/profile_controller.dart';

/// Today (§10.5, §10.6 Today, INT-002-S12): rank badge + XP bar, one big Today Card, "Relight N · M min",
/// pocket sessions, then the Study Map, My Plan and the Exam Hall.
///
/// Calm Mode (§10.7, INT-002-S19): only the Today Card, Study and Relight, with slightly bigger text. The
/// rank bar and pocket sessions are hidden; switching Calm off brings them back with no data change.
class TodayTab extends ConsumerWidget {
  const TodayTab({
    super.key,
    required this.onOpenStudyMap,
    this.onOpenExamHall,
    this.onOpenPlan,
    this.onSetUpPlan,
    this.onStartItem,
    this.onOpenRelight,
    this.onStartPocket,
  });

  final VoidCallback onOpenStudyMap;

  /// Opens the Exam Hall (§10.6). Hidden when null.
  final VoidCallback? onOpenExamHall;

  /// Opens My Plan. Hidden when null.
  final VoidCallback? onOpenPlan;

  /// Opens plan setup when the user has no plan yet.
  final VoidCallback? onSetUpPlan;

  /// Starts the Today Card's item (the router decides where it goes).
  final ValueChanged<PlanItemView>? onStartItem;
  final VoidCallback? onOpenRelight;

  /// Starts a pocket session of N minutes (§19.2 Q15).
  final ValueChanged<int>? onStartPocket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calm = ref.watch(meProvider).value?.calmMode ?? false;
    final today = onStartItem == null ? null : ref.watch(todayViewProvider);
    if (onStartItem != null) {
      // Rank up (§5.2): a short celebration when the server reports a higher level. HmCelebration
      // itself stays silent in Calm Mode, Lite Mode and with reduce motion (§10.7, §10.8).
      ref.listen(todayViewProvider, (prev, next) {
        final before = prev?.value?.rank.level;
        final after = next.value?.rank;
        if (before != null && after != null && after.level > before) {
          HmCelebration.show(
            context,
            kind: HmCelebrationKind.rankUp,
            title: 'Level ${after.level}!',
            subtitle: rankUpSubtitle(after.title, after.note),
          );
        }
      });
    }
    final body = TodayBody(
      today: today,
      calm: calm,
      onOpenStudyMap: onOpenStudyMap,
      onOpenExamHall: onOpenExamHall,
      onOpenPlan: onOpenPlan,
      onSetUpPlan: onSetUpPlan,
      onStartItem: onStartItem,
      onOpenRelight: onOpenRelight,
      onStartPocket: onStartPocket,
      onMarkDone: (item) => ref
          .read(planControllerProvider.notifier)
          .mark(item, PlanItemStatusView.done),
      onRetry: () => ref.invalidate(todayProvider),
    );
    if (!calm) return body;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(
          (mq.textScaler.scale(1) * 1.15).clamp(1, 2.3),
        ),
      ),
      child: body,
    );
  }
}

/// Layout only, for tests and goldens. [today] null = no plan section (Phase 1 wiring).
class TodayBody extends StatelessWidget {
  const TodayBody({
    super.key,
    required this.today,
    required this.onOpenStudyMap,
    this.calm = false,
    this.onOpenExamHall,
    this.onOpenPlan,
    this.onSetUpPlan,
    this.onStartItem,
    this.onOpenRelight,
    this.onStartPocket,
    this.onMarkDone,
    this.onRetry,
  });

  final AsyncValue<TodayView>? today;
  final bool calm;
  final VoidCallback onOpenStudyMap;
  final VoidCallback? onOpenExamHall;
  final VoidCallback? onOpenPlan;

  /// Opens plan setup when the user has no plan yet.
  final VoidCallback? onSetUpPlan;
  final ValueChanged<PlanItemView>? onStartItem;
  final VoidCallback? onOpenRelight;
  final ValueChanged<int>? onStartPocket;
  final ValueChanged<PlanItemView>? onMarkDone;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = today?.value;
    // One clear next action (§10.1): when the Today Card has a pending item it is the primary button.
    final cardIsPrimary =
        t != null && (t.hasPlan ? t.todayCard.canMark : onSetUpPlan != null);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.xxl,
      ),
      children: [
        Semantics(
          header: true,
          child: Text('Today', style: text.headlineMedium),
        ),
        const SizedBox(height: HmSpace.xs),
        Text(
          'One small step at a time.',
          style: text.bodyLarge?.copyWith(color: context.hm.textMuted),
        ),
        const SizedBox(height: HmSpace.lg),
        if (today != null) ...[
          ...switch (today!) {
            AsyncData(:final value) => _plan(context, value),
            AsyncError(:final error) => [
              HmCard(
                key: const Key('today-plan-error'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HmIllustration(
                      kind: HmIllustrationKind.error,
                      size: 64,
                    ),
                    const SizedBox(width: HmSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(messageOf(error), style: text.bodyLarge),
                          if (onRetry != null)
                            TextButton(
                              onPressed: onRetry,
                              child: const Text('Try again'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HmSpace.md),
            ],
            _ => [
              Semantics(
                label: 'Loading today',
                liveRegion: true,
                child: ExcludeSemantics(
                  child: HmCard(child: HmSkeleton.card()),
                ),
              ),
              const SizedBox(height: HmSpace.md),
            ],
          },
        ],
        HmCard(
          highlighted: !cardIsPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ExcludeSemantics(
                    child: Lamp(
                      label: 'Lamp',
                      size: 44,
                      state: HmLampState(lit: true),
                    ),
                  ),
                  const SizedBox(width: HmSpace.md),
                  Expanded(child: Text('Study', style: text.titleLarge)),
                ],
              ),
              const SizedBox(height: HmSpace.sm),
              Text(
                'See every subject of your exam. Open a topic and read its lesson.',
                style: text.bodyLarge?.copyWith(color: context.hm.textMuted),
              ),
              const SizedBox(height: HmSpace.lg),
              if (cardIsPrimary)
                HmSecondaryButton(
                  key: const Key('today-open-map'),
                  label: 'Open Study Map',
                  onPressed: onOpenStudyMap,
                )
              else
                HmPrimaryButton(
                  key: const Key('today-open-map'),
                  label: 'Open Study Map',
                  onPressed: onOpenStudyMap,
                ),
            ],
          ),
        ),
        if ((onOpenPlan != null && !calm) || onOpenExamHall != null)
          const HmSectionTitle('More for you'),
        if (onOpenPlan != null && !calm) ...[
          const SizedBox(height: HmSpace.xs),
          HmSecondaryButton(
            key: const Key('today-open-plan'),
            label: 'Open My Plan',
            semanticLabel: 'Open My Plan, the next 14 days',
            icon: Icons.calendar_month_outlined,
            onPressed: onOpenPlan,
          ),
        ],
        if (onOpenExamHall != null) ...[
          const SizedBox(height: 12),
          HmSecondaryButton(
            key: const Key('today-open-exam-hall'),
            label: 'Open Exam Hall',
            semanticLabel: 'Open Exam Hall mocks',
            icon: Icons.assignment_outlined,
            onPressed: onOpenExamHall,
          ),
        ],
      ],
    );
  }

  List<Widget> _plan(BuildContext context, TodayView t) {
    final text = Theme.of(context).textTheme;
    final stretch = PlanCopy.stretch(t.stretch);
    return [
      if (!calm) ...[
        HmCard(child: RankBar(rank: t.rank)),
        const SizedBox(height: HmSpace.lg),
      ],
      if (t.welcomeBack != null) ...[
        Semantics(
          liveRegion: true,
          child: Text(
            t.welcomeBack!,
            key: const Key('today-welcome-back'),
            style: text.bodyLarge,
          ),
        ),
        const SizedBox(height: 12),
      ],
      if (stretch != null && !calm) ...[
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            key: const Key('today-stretch'),
            avatar: const Icon(Icons.flag_outlined),
            label: Text(stretch),
          ),
        ),
        const SizedBox(height: 12),
      ],
      if (t.hasPlan)
        PlanCard(
          item: t.todayCard,
          onStart: () => onStartItem?.call(t.todayCard),
          onMarkDone: () => onMarkDone?.call(t.todayCard),
        )
      else
        HmCard(
          key: const Key('today-no-plan'),
          highlighted: onSetUpPlan != null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(PlanCopy.noPlan, style: text.bodyLarge),
              if (onSetUpPlan != null) ...[
                const SizedBox(height: 12),
                HmPrimaryButton(
                  key: const Key('today-setup-plan'),
                  label: 'Set up your plan',
                  onPressed: onSetUpPlan,
                ),
              ],
            ],
          ),
        ),
      const SizedBox(height: 12),
      if (t.relightCount > 0 && onOpenRelight != null) ...[
        HmCard(
          key: const Key('today-relight'),
          semanticLabel:
              'Relight ${t.relightCount} lamps, about ${t.relightMinutes} minutes',
          onTap: onOpenRelight,
          child: ExcludeSemantics(
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: context.hm.flame,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Relight ${t.relightCount} · ${t.relightMinutes} min',
                    style: text.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
      if (!calm && onStartPocket != null && t.pocketSessions.isNotEmpty) ...[
        const HmSectionTitle('Short on time?', icon: Icons.timer_outlined),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in t.pocketSessions)
              HmSecondaryButton(
                key: Key('today-pocket-$m'),
                label: '$m min',
                semanticLabel: 'Start a $m minute session',
                expand: false,
                onPressed: () => onStartPocket!(m),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    ];
  }
}
