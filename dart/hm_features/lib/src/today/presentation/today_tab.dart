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
    final p = context.hm;
    final t = today?.value;
    // One clear next action (§10.1): when the Today Card has a pending item it is the primary button.
    final cardIsPrimary =
        t != null && (t.hasPlan ? t.todayCard.canMark : onSetUpPlan != null);
    // Bento (BOLT-0110): one hero tile (the Today Card, or Study when there is no plan step), then
    // smaller tiles. Calm Mode keeps only the Today Card, Study and Relight.
    final tiles = <HmBentoTile>[
      if (today != null)
        ...switch (today!) {
          AsyncData(:final value) => _plan(context, value),
          AsyncError(:final error) => [
            HmBentoTile(
              key: const Key('today-plan-error'),
              span: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HmArt(HmArtName.emptyOffline, size: 64),
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
          ],
          _ => [
            HmBentoTile(
              span: 2,
              child: Semantics(
                label: 'Loading today',
                liveRegion: true,
                child: ExcludeSemantics(child: HmSkeleton.card()),
              ),
            ),
          ],
        },
      _studyTile(context, hero: !cardIsPrimary),
      if (onOpenPlan != null && !calm)
        HmBentoTile(
          key: const Key('today-open-plan'),
          semanticLabel: 'Open My Plan, the next 14 days',
          onTap: onOpenPlan,
          shape: HmShape.square,
          shapeColor: p.gold,
          child: const _TileLink(
            art: HmArtName.badgeWeekPlan,
            title: 'My Plan',
            line: 'The next 14 days',
          ),
        ),
      if (onOpenExamHall != null)
        HmBentoTile(
          key: const Key('today-open-exam-hall'),
          semanticLabel: 'Open Exam Hall mocks',
          onTap: onOpenExamHall,
          shape: HmShape.triangle,
          shapeColor: p.primary,
          child: const _TileLink(
            art: HmArtName.badgeMockDone,
            title: 'Exam Hall',
            line: 'Timed mock tests',
          ),
        ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.xxl,
      ),
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
                    child: Text('Today', style: text.displaySmall),
                  ),
                  const SizedBox(height: HmSpace.xs),
                  Text(
                    'One small step at a time.',
                    style: text.bodyLarge?.copyWith(color: p.textMuted),
                  ),
                ],
              ),
            ),
            const HmBetaChip(),
          ],
        ),
        const SizedBox(height: HmSpace.xl),
        HmBentoGrid(children: tiles),
      ],
    );
  }

  /// Study: the blue hero tile when there is no pending plan step, otherwise a quiet tile.
  HmBentoTile _studyTile(BuildContext context, {required bool hero}) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final on = hero ? p.onBlue : p.text;
    return HmBentoTile(
      span: 2,
      color: hero ? p.blue : null,
      shape: hero ? HmShape.circle : HmShape.none,
      shapeColor: p.gold,
      padding: EdgeInsets.all(hero ? HmSpace.xl : HmSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ExcludeSemantics(
                child: Lamp(
                  label: 'Lamp',
                  size: 52,
                  state: HmLampState(lit: true),
                ),
              ),
              const SizedBox(width: HmSpace.md),
              Expanded(
                child: Text(
                  'Study',
                  style: (hero ? text.headlineMedium : text.titleLarge)
                      ?.copyWith(color: on),
                ),
              ),
            ],
          ),
          const SizedBox(height: HmSpace.sm),
          Text(
            'See every subject of your exam. Open a topic and read its lesson.',
            style: text.bodyLarge?.copyWith(color: on),
          ),
          const SizedBox(height: HmSpace.lg),
          if (hero)
            HmPrimaryButton(
              key: const Key('today-open-map'),
              label: 'Open Study Map',
              tone: HmButtonTone.gold,
              onPressed: onOpenStudyMap,
            )
          else
            HmSecondaryButton(
              key: const Key('today-open-map'),
              label: 'Open Study Map',
              onPressed: onOpenStudyMap,
            ),
        ],
      ),
    );
  }

  List<HmBentoTile> _plan(BuildContext context, TodayView t) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final stretch = PlanCopy.stretch(t.stretch);
    return [
      if (t.hasPlan)
        HmBentoTile(
          span: 2,
          padding: EdgeInsets.zero,
          color: t.todayCard.canMark ? p.gold : null,
          child: PlanCard(
            item: t.todayCard,
            onStart: () => onStartItem?.call(t.todayCard),
            onMarkDone: () => onMarkDone?.call(t.todayCard),
            bare: true,
          ),
        )
      else
        HmBentoTile(
          key: const Key('today-no-plan'),
          span: 2,
          color: onSetUpPlan != null ? p.gold : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      PlanCopy.noPlan,
                      style: text.bodyLarge?.copyWith(
                        color: onSetUpPlan != null ? p.onGold : p.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: HmSpace.sm),
                  const HmArt(HmArtName.scenePlanBoard, width: 96, height: 60),
                ],
              ),
              if (onSetUpPlan != null) ...[
                const SizedBox(height: HmSpace.md),
                HmPrimaryButton(
                  key: const Key('today-setup-plan'),
                  label: 'Set up your plan',
                  onPressed: onSetUpPlan,
                ),
              ],
            ],
          ),
        ),
      if (t.welcomeBack != null || (stretch != null && !calm))
        HmBentoTile(
          span: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (t.welcomeBack != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    t.welcomeBack!,
                    key: const Key('today-welcome-back'),
                    style: text.bodyLarge,
                  ),
                ),
              if (stretch != null && !calm) ...[
                if (t.welcomeBack != null) const SizedBox(height: HmSpace.sm),
                Chip(
                  key: const Key('today-stretch'),
                  avatar: const Icon(Icons.flag_outlined),
                  label: Text(stretch),
                ),
              ],
            ],
          ),
        ),
      if (!calm)
        HmBentoTile(
          span: 2,
          eyebrow: 'Your rank',
          child: RankBar(rank: t.rank),
        ),
      if (t.relightCount > 0 && onOpenRelight != null)
        HmBentoTile(
          key: const Key('today-relight'),
          span: 2,
          semanticLabel:
              'Relight ${t.relightCount} lamps, about ${t.relightMinutes} minutes',
          onTap: onOpenRelight,
          shape: HmShape.circle,
          shapeColor: p.primary,
          child: ExcludeSemantics(
            child: _TileLink(
              art: HmArtName.lampFading,
              title: 'Relight ${t.relightCount} · ${t.relightMinutes} min',
              line: 'Bring dimming lamps back to full light',
            ),
          ),
        ),
      if (!calm && onStartPocket != null && t.pocketSessions.isNotEmpty)
        HmBentoTile(
          span: 2,
          eyebrow: 'Short on time?',
          child: Wrap(
            spacing: HmSpace.sm,
            runSpacing: HmSpace.sm,
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
        ),
    ];
  }
}

/// A tile body that opens something: art, a bold title and one short line.
class _TileLink extends StatelessWidget {
  const _TileLink({required this.art, required this.title, required this.line});

  final HmArtName art;
  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HmArt(art, size: 44),
        const SizedBox(height: HmSpace.sm),
        Text(title, style: text.titleMedium),
        const SizedBox(height: HmSpace.xxs),
        Text(
          line,
          style: text.bodyMedium?.copyWith(color: context.hm.textMuted),
        ),
      ],
    );
  }
}
