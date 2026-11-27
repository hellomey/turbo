import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../expo/presentation/expo_hero_tile.dart';
import '../../plan/application/plan_controller.dart';
import '../../plan/domain/plan_models.dart';
import '../../plan/presentation/rank_bar.dart';
import '../../practice/domain/practice_models.dart' show rankUpSubtitle;
import '../../profile/application/profile_controller.dart';
import 'today_tiles.dart';

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
    this.onOpenExpo,
    this.onOpenLeaderboard,
    this.onOpenReadiness,
    this.onOpenAlerts,
    this.onOpenProfile,
  });

  final VoidCallback onOpenStudyMap;

  /// BOLT-0117: the readiness tile, the exam-alert tile and the avatar open these.
  final VoidCallback? onOpenReadiness;
  final VoidCallback? onOpenAlerts;
  final VoidCallback? onOpenProfile;

  /// Opens the Expo Challenge (BOLT-0111). The hero tile is hidden when null.
  final VoidCallback? onOpenExpo;

  /// BOLT-0113: shows the XP / level + check-in card when set; opens the weekly leaderboard.
  final VoidCallback? onOpenLeaderboard;

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
      onOpenExpo: onOpenExpo,
      live: onOpenLeaderboard != null,
      onOpenLeaderboard: onOpenLeaderboard,
      onOpenReadiness: onOpenReadiness,
      onOpenAlerts: onOpenAlerts,
      onOpenProfile: onOpenProfile,
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
///
/// Warm light layout (design/ui/05, BOLT-0117): greeting header, one amber hero ("Your next lamp"),
/// then mint check-in + coral recall beside the lamps-lit ring, the sky exam-alert tile, and quieter
/// tiles below. [live] turns on the tiles that read their own providers (check-in, ring, alert).
class TodayBody extends StatelessWidget {
  const TodayBody({
    super.key,
    required this.today,
    required this.onOpenStudyMap,
    this.calm = false,
    this.live = false,
    this.onOpenExamHall,
    this.onOpenPlan,
    this.onSetUpPlan,
    this.onStartItem,
    this.onOpenRelight,
    this.onStartPocket,
    this.onMarkDone,
    this.onRetry,
    this.onOpenExpo,
    this.onOpenLeaderboard,
    this.onOpenReadiness,
    this.onOpenAlerts,
    this.onOpenProfile,
  });

  /// Opens the Expo Challenge. The hero tile is hidden when null.
  final VoidCallback? onOpenExpo;

  final AsyncValue<TodayView>? today;
  final bool calm;
  final bool live;
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
  final VoidCallback? onOpenLeaderboard;
  final VoidCallback? onOpenReadiness;
  final VoidCallback? onOpenAlerts;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final t = today?.value;
    final wide = MediaQuery.textScalerOf(context).scale(16) / 16 <= 1.4;
    var n = 0;
    Widget enter(Widget w) => HmEnter(index: n++, child: w);
    const gap = SizedBox(height: HmSpace.lg);
    final stretch = t == null ? null : PlanCopy.stretch(t.stretch);
    final children = <Widget>[
      if (live)
        TodayHeader(onOpenProfile: onOpenProfile)
      else
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Today',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            const HmBetaChip(),
          ],
        ),
      const SizedBox(height: HmSpace.xl),
      enter(_hero(context)),
      if (onOpenExpo != null) ...[
        gap,
        enter(ExpoHeroTile(onOpen: onOpenExpo!)),
      ],
      if (today case AsyncError(:final error)) ...[
        gap,
        enter(
          HmCard(
            key: const Key('today-plan-error'),
            child: Row(
              children: [
                const HmMey(HmPic.meySleepy, size: 72, float: false),
                const SizedBox(width: HmSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(messageOf(error)),
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
        ),
      ],
      if (live && !calm) ...[
        gap,
        enter(
          wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const CheckInTile(),
                          const SizedBox(height: HmSpace.lg),
                          RecallTile(
                            count: t?.relightCount ?? 0,
                            minutes: t?.relightMinutes,
                            onOpen: onOpenRelight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: HmSpace.lg),
                    Expanded(child: ReadinessTile(onOpen: onOpenReadiness)),
                  ],
                )
              : Column(
                  children: [
                    const CheckInTile(),
                    gap,
                    RecallTile(
                      count: t?.relightCount ?? 0,
                      minutes: t?.relightMinutes,
                      onOpen: onOpenRelight,
                    ),
                    gap,
                    ReadinessTile(onOpen: onOpenReadiness),
                  ],
                ),
        ),
        gap,
        enter(AlertTile(onOpen: onOpenAlerts)),
      ] else if (t != null && t.relightCount > 0 && onOpenRelight != null) ...[
        gap,
        enter(
          RecallTile(
            count: t.relightCount,
            minutes: t.relightMinutes,
            onOpen: onOpenRelight,
          ),
        ),
      ],
      if (t != null &&
          (t.welcomeBack != null || (stretch != null && !calm))) ...[
        gap,
        enter(_notes(context, t, stretch)),
      ],
      gap,
      enter(HmBentoGrid(children: _links(context))),
      if (!calm &&
          t != null &&
          onStartPocket != null &&
          t.pocketSessions.isNotEmpty) ...[
        gap,
        enter(_pocket(context, t)),
      ],
      if (!calm && t != null) ...[
        gap,
        enter(
          HmBentoTile(
            span: 2,
            eyebrow: 'Your rank',
            child: RankBar(rank: t.rank),
          ),
        ),
      ],
    ];
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            HmSpace.xl,
            HmSpace.lg,
            HmSpace.xl,
            HmSpace.xxl,
          ),
          children: children,
        ),
      ),
    );
  }

  /// The amber hero: the plan's next step (or its done state), "set up your plan", or the Study Map.
  Widget _hero(BuildContext context) {
    final t = today?.value;
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    if (today != null && t == null && today is! AsyncError) {
      return Semantics(
        label: 'Loading today',
        liveRegion: true,
        child: ExcludeSemantics(child: HmSkeleton.card()),
      );
    }
    if (t != null && t.hasPlan) {
      final item = t.todayCard;
      final lesson = item.kind == PlanItemKindView.lesson;
      if (item.canMark) {
        return HmBentoHero(
          key: const Key('today-card'),
          eyebrow: lesson ? 'Your next lamp' : 'Your next step',
          title: item.title,
          message:
              '${item.minutes} min ${PlanCopy.kind(item.kind).toLowerCase()}',
          pic: HmPic.meyHoldLamp,
          actionKey: const Key('today-card-start'),
          actionLabel: 'Start',
          onAction: onStartItem == null ? null : () => onStartItem!(item),
          footer: onMarkDone == null
              ? null
              : HmGhostButton(
                  key: const Key('today-card-done'),
                  label: 'Mark as done',
                  semanticLabel: 'Mark ${item.title} as done',
                  onPressed: () => onMarkDone!(item),
                ),
        );
      }
      return HmBentoHero(
        key: const Key('today-card'),
        eyebrow: "Today's step",
        title: item.title,
        pic: HmPic.meyCheer,
        footer: Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: p.success),
              const SizedBox(width: HmSpace.sm),
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
        actionKey: const Key('today-open-map'),
        actionLabel: 'Open Study Map',
        onAction: onOpenStudyMap,
      );
    }
    if (t != null && onSetUpPlan != null) {
      return HmBentoHero(
        key: const Key('today-no-plan'),
        eyebrow: 'Start here',
        title: 'Build your study plan',
        message: PlanCopy.noPlan,
        pic: HmPic.meyThink,
        actionKey: const Key('today-setup-plan'),
        actionLabel: 'Set up your plan',
        onAction: onSetUpPlan,
      );
    }
    return HmBentoHero(
      key: Key(t == null ? 'today-study' : 'today-no-plan'),
      eyebrow: 'Study',
      title: 'Light your next lamp',
      message: t == null
          ? 'Open a topic on the Study Map and read its lesson.'
          : PlanCopy.noPlan,
      pic: HmPic.meyHoldLamp,
      actionKey: const Key('today-open-map'),
      actionLabel: 'Open Study Map',
      onAction: onOpenStudyMap,
    );
  }

  Widget _notes(BuildContext context, TodayView t, String? stretch) => HmCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (t.welcomeBack != null)
          Semantics(
            liveRegion: true,
            child: Text(
              t.welcomeBack!,
              key: const Key('today-welcome-back'),
              style: Theme.of(context).textTheme.bodyLarge,
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
  );

  List<HmBentoTile> _links(BuildContext context) {
    final t = today?.value;
    final mapIsHero =
        t == null || (t.hasPlan ? !t.todayCard.canMark : onSetUpPlan == null);
    return [
      if (!mapIsHero)
        HmBentoTile(
          key: const Key('today-open-map'),
          semanticLabel: 'Open the Study Map',
          onTap: onOpenStudyMap,
          child: const _TileLink(
            pic: HmPic.lampLit,
            title: 'Study Map',
            line: 'Every topic is a lamp',
          ),
        ),
      if (onOpenPlan != null && !calm)
        HmBentoTile(
          key: const Key('today-open-plan'),
          semanticLabel: 'Open My Plan, the next 14 days',
          onTap: onOpenPlan,
          child: const _TileLink(
            pic: HmPic.meyCalendar,
            title: 'My Plan',
            line: 'The next 14 days',
          ),
        ),
      if (onOpenExamHall != null)
        HmBentoTile(
          key: const Key('today-open-exam-hall'),
          semanticLabel: 'Open Exam Hall mocks',
          onTap: onOpenExamHall,
          child: const _TileLink(
            pic: HmPic.chest,
            title: 'Exam Hall',
            line: 'Timed mock tests',
          ),
        ),
      if (onOpenLeaderboard != null && !calm)
        HmBentoTile(
          key: const Key('today-open-leaderboard'),
          semanticLabel: 'Open the weekly leaderboard',
          onTap: onOpenLeaderboard,
          child: const _TileLink(
            pic: HmPic.meyCelebrate,
            title: 'Leaderboard',
            line: 'Opt-in, XP from learning',
          ),
        ),
    ];
  }

  Widget _pocket(BuildContext context, TodayView t) => HmCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Short on time?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: HmSpace.sm),
        Wrap(
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
      ],
    ),
  );
}

/// A tile body that opens something: a picture, a bold title and one short line.
class _TileLink extends StatelessWidget {
  const _TileLink({required this.pic, required this.title, required this.line});

  final HmPic pic;
  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HmPicture(pic, height: 52),
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
