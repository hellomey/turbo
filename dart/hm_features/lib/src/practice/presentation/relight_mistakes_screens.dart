import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/practice_providers.dart';
import '../domain/practice_models.dart';
import '../domain/study_rules.dart';
import 'study_widgets.dart';

/// Relight queue (§5.1 Dimming, INT-002-S03): dimming lamps, 2-5 minutes each.
class RelightQueueScreen extends ConsumerWidget {
  const RelightQueueScreen({super.key, required this.onRelight});
  final ValueChanged<String> onRelight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(relightQueueProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Relight')),
      body: queue.when(
        loading: () =>
            const HmSkeletonList(label: 'Loading your relight queue'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(relightQueueProvider),
        ),
        data: (q) => RelightQueueBody(queue: q, onRelight: onRelight),
      ),
    );
  }
}

class RelightQueueBody extends StatelessWidget {
  const RelightQueueBody({
    super.key,
    required this.queue,
    required this.onRelight,
  });
  final RelightQueueView queue;
  final ValueChanged<String> onRelight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (queue.items.isEmpty) {
      return const HmEmptyView(
        kind: HmIllustrationKind.welcome,
        art: HmArtName.lampGold,
        title: 'All bright',
        message: 'All your lamps are bright. Nothing to relight.',
      );
    }
    final p = context.hm;
    final n = queue.items.length;
    final fading = [
      for (final i in queue.items)
        if (i.dim == HmLampDim.dim) i,
    ];
    final dimming = [
      for (final i in queue.items)
        if (i.dim != HmLampDim.dim) i,
    ];
    Widget row(RelightItemView item) => Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.md),
      child: HmCard(
        padding: const EdgeInsets.all(HmSpace.md),
        child: Row(
          children: [
            const HmPicture(HmPic.lampFading, height: 52),
            const SizedBox(width: HmSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.topicName, style: text.titleMedium),
                  const SizedBox(height: HmSpace.xs),
                  // Three segments: how much light is left (dim = 1, dimming = 2).
                  ExcludeSemantics(
                    child: Row(
                      children: [
                        for (var k = 0; k < 3; k++) ...[
                          if (k > 0) const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: k < (item.dim == HmLampDim.dim ? 1 : 2)
                                    ? p.primary
                                    : const Color(0xFFF3E6D3),
                                borderRadius: BorderRadius.circular(
                                  HmRadius.pill,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: HmSpace.xs),
                  Text(
                    '${item.dim == HmLampDim.dim ? 'Dim' : 'Dimming'} · ${item.minutes} min',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: HmSpace.sm),
            Semantics(
              container: true,
              child: HmChunkyButton(
                key: Key('relight-${item.topicId}'),
                label: 'Relight',
                semanticLabel: 'Relight ${item.topicName}',
                expand: false,
                tone: HmButtonTone.secondary,
                onPressed: () => onRelight(item.topicId),
              ),
            ),
          ],
        ),
      ),
    );
    Widget section(String title, List<RelightItemView> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: HmSpace.lg, bottom: HmSpace.sm),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: text.titleLarge?.copyWith(color: p.textMuted),
            ),
          ),
        ),
        for (final i in items) row(i),
      ],
    );
    // Warm light (BOLT-0117, design/ui/09): a coral hero with Mey dimming, then the lamps.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            HmSpace.xl,
            HmSpace.md,
            HmSpace.xl,
            HmSpace.xxl,
          ),
          children: [
            Text(
              'Lamps fade as memory fades. A short relight brings them back.',
              style: text.bodyLarge?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: HmSpace.lg),
            HmEnter(
              child: HmBentoHero(
                key: const Key('relight-hero'),
                color: HmTint.coral,
                title: '$n ${n == 1 ? 'lamp needs' : 'lamps need'} you',
                message: 'About ${queue.totalMinutes} min in all',
                pic: HmPic.meySleepy,
                actionLabel: 'Relight the first',
                onAction: () => onRelight(queue.items.first.topicId),
              ),
            ),
            if (fading.isNotEmpty) section('Fading now', fading),
            if (dimming.isNotEmpty) section('Dimming', dimming),
          ],
        ),
      ),
    );
  }
}

/// Mistake review (§19.4 Q38, INT-002-S08). Concept drills are Pro: locked, marked before tap (§19.9 Q82).
class MistakesScreen extends ConsumerWidget {
  const MistakesScreen({
    super.key,
    required this.onRelight,
    required this.onStartDrill,
  });

  final ValueChanged<String> onRelight;
  final ValueChanged<DrillView> onStartDrill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(mistakesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mistakes')),
      body: data.when(
        loading: () => const HmSkeletonList(label: 'Loading your mistakes'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(mistakesProvider),
        ),
        data: (m) => MistakesBody(
          view: m,
          onRelight: onRelight,
          onStartDrill: onStartDrill,
        ),
      ),
    );
  }
}

class MistakesBody extends StatelessWidget {
  const MistakesBody({
    super.key,
    required this.view,
    required this.onRelight,
    required this.onStartDrill,
  });

  final MistakesView view;
  final ValueChanged<String> onRelight;
  final ValueChanged<DrillView> onStartDrill;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final drills = view.drills;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.xl,
        HmSpace.md,
        HmSpace.xl,
        HmSpace.xxl,
      ),
      children: [
        // Warm light (BOLT-0117, design/ui/11).
        const HmEnter(
          child: HmBentoHero(
            key: Key('mistakes-hero'),
            color: HmTint.cream,
            title: 'Every wrong answer is a free lesson',
            message: 'Look at why, then relight the lamp it came from.',
            pic: HmPic.meyPuzzled,
            picSize: 116,
          ),
        ),
        const SizedBox(height: HmSpace.xl),
        Semantics(
          header: true,
          child: Text('Concept drills', style: text.titleMedium),
        ),
        const SizedBox(height: 8),
        if (drills.locked)
          const HmCard(
            key: Key('drill-locked'),
            semanticLabel: 'Concept drills. Pro. ${StudyCopy.drillLocked}',
            child: Row(
              children: [
                TierChip(pro: true),
                SizedBox(width: 12),
                Expanded(child: Text(StudyCopy.drillLocked)),
              ],
            ),
          )
        else if (drills.items.isEmpty)
          const Text(
            'No drills yet. They appear after repeated mistakes on one lamp.',
          )
        else
          for (final d in drills.items.where((d) => d.open))
            ListTile(
              key: Key('drill-${d.id}'),
              minTileHeight: 48,
              title: Text(d.reason),
              subtitle: Text('${d.questionCount} questions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onStartDrill(d),
            ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text('Your mistakes', style: text.titleMedium),
        ),
        const SizedBox(height: 8),
        if (view.mistakes.isEmpty)
          const Row(
            children: [
              HmArt(HmArtName.emptyNoMistakes, size: 72),
              SizedBox(width: HmSpace.md),
              Expanded(child: Text('No mistakes yet.')),
            ],
          ),
        for (final m in view.mistakes) ...[
          Text(m.stem, style: text.titleSmall),
          Text('Wrong ${m.wrongCount} times', style: text.bodySmall),
          const SizedBox(height: 4),
          FeedbackPanel(
            graded: m.graded,
            onRelight: () => onRelight(m.topicId),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
