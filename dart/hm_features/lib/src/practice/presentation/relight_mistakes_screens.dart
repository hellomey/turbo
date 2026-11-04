import 'package:flutter/material.dart';
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
        title: 'All bright',
        message: 'All your lamps are bright. Nothing to relight.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(
            '${queue.items.length} lamps to relight · about ${queue.totalMinutes} min',
            style: text.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        for (final item in queue.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: CustomPaint(
                        size: const Size.square(32),
                        painter: LampPainter(
                          state: HmLampState(lit: true, dim: item.dim),
                          faint: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.topicName, style: text.titleSmall),
                          Text(
                            '${item.dim == HmLampDim.dim ? 'Dim' : 'Dimming'} · ${item.minutes} min',
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      container: true,
                      child: HmSecondaryButton(
                        key: Key('relight-${item.topicId}'),
                        label: 'Relight',
                        semanticLabel: 'Relight ${item.topicName}',
                        expand: false,
                        onPressed: () => onRelight(item.topicId),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
      padding: const EdgeInsets.all(16),
      children: [
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
        if (view.mistakes.isEmpty) const Text('No mistakes yet.'),
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
