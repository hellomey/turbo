import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/study_providers.dart';
import '../domain/study_map_view.dart';

/// Subjects as islands with their lamps (§10.6), or a static list in Lite Mode (§10.8).
class StudyMapBody extends StatelessWidget {
  const StudyMapBody({
    super.key,
    required this.map,
    this.onOpenTopic,
    this.lite = false,
    this.header,
  });

  final StudyMapView map;
  final ValueChanged<TopicView>? onOpenTopic;
  final bool lite;
  final Widget? header;

  void _tap(BuildContext context, TopicView topic) {
    if (!topic.hasLesson) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Lesson coming soon.')));
      return;
    }
    onOpenTopic?.call(topic);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      key: const Key('study-map'),
      padding: const EdgeInsets.all(16),
      children: [
        ?header,
        for (final subject in map.subjects) ...[
          if (lite)
            _LiteSubject(subject: subject, onTap: (t) => _tap(context, t))
          else
            HmCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(subject.name, style: text.titleMedium),
                  ),
                  Text('${subject.topics.length} lamps', style: text.bodySmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final topic in subject.topics)
                        SizedBox(
                          width: 96,
                          child: Lamp(
                            key: Key('lamp-${topic.id}'),
                            label: topic.name,
                            state: topic.lamp,
                            size: 36,
                            showLabel: true,
                            onTap: onOpenTopic == null
                                ? null
                                : () => _tap(context, topic),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _LiteSubject extends StatelessWidget {
  const _LiteSubject({required this.subject, required this.onTap});

  final SubjectView subject;
  final ValueChanged<TopicView> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            subject.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final topic in subject.topics)
          ListTile(
            key: Key('lite-topic-${topic.id}'),
            minTileHeight: 48,
            leading: ExcludeSemantics(
              child: CustomPaint(
                size: const Size.square(24),
                painter: LampPainter(
                  state: topic.lamp,
                  faint: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            title: Text(topic.name),
            subtitle: topic.hasLesson ? null : const Text('Lesson coming soon'),
            onTap: () => onTap(topic),
          ),
      ],
    );
  }
}

/// The Study Map tab: loads the main exam, then its map.
class StudyMapTab extends ConsumerWidget {
  const StudyMapTab({super.key, required this.onOpenTopic});

  final ValueChanged<TopicView> onOpenTopic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final main = ref.watch(mainExamCodeProvider);
    return main.when(
      loading: () => const HmLoadingView(label: 'Loading your Study Map'),
      error: (e, _) => HmErrorView(
        message: messageOf(e),
        onRetry: () => ref.invalidate(mainExamCodeProvider),
      ),
      data: (code) {
        if (code == null) {
          return const HmErrorView(
            message: 'Pick your main exam to see your Study Map.',
          );
        }
        final map = ref.watch(studyMapProvider(code));
        return map.when(
          loading: () => const HmLoadingView(label: 'Loading your Study Map'),
          error: (e, _) => HmErrorView(
            message: messageOf(e),
            onRetry: () => ref.invalidate(studyMapProvider(code)),
          ),
          data: (m) => StudyMapBody(
            map: m,
            lite: ref.watch(liteModeProvider),
            onOpenTopic: onOpenTopic,
          ),
        );
      },
    );
  }
}
