import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../practice/application/practice_providers.dart';
import '../../practice/domain/practice_models.dart';
import '../../practice/domain/study_rules.dart';
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
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.xxl,
      ),
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
                  Row(
                    children: [
                      HmIconBadge(
                        icon: Icons.landscape_rounded,
                        color: context.hm.primary,
                      ),
                      const SizedBox(width: HmSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                subject.name,
                                style: text.titleMedium,
                              ),
                            ),
                            Text(
                              '${subject.topics.length} lamps',
                              style: text.bodySmall?.copyWith(
                                color: context.hm.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HmSpace.md),
                  HmProgressBar(
                    value: subject.topics.isEmpty
                        ? 0
                        : subject.topics.where((t) => t.lamp.lit).length /
                              subject.topics.length,
                    height: 10,
                    color: context.hm.gold,
                    semanticLabel: '${subject.name} lamps lit',
                  ),
                  const SizedBox(height: HmSpace.lg),
                  Wrap(
                    spacing: HmSpace.sm,
                    runSpacing: HmSpace.md,
                    children: [
                      for (final topic in subject.topics)
                        SizedBox(
                          width: 96,
                          child: Lamp(
                            key: Key('lamp-${topic.id}'),
                            label: topic.name,
                            state: topic.lamp,
                            size: 44,
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
          const SizedBox(height: HmSpace.lg),
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
            subtitle: Text(
              topic.hasLesson ? lampWords(topic.lamp) : 'Lesson coming soon',
            ),
            onTap: () => onTap(topic),
          ),
      ],
    );
  }
}

/// The Study Map tab: loads the main exam, then its map.
class StudyMapTab extends ConsumerWidget {
  const StudyMapTab({
    super.key,
    required this.onOpenTopic,
    this.actions,
    this.onStartCheck,
  });

  final ValueChanged<TopicView> onOpenTopic;

  /// When set, tapping a lamp with a check to offer opens the lamp sheet (recall, Gold, relight; BOLT-0017).
  final void Function(TopicView topic, CheckKind kind)? onStartCheck;

  /// Study entry points above the map (BOLT-0017): relight, practice, mistakes, PYQ Vault.
  final StudyActions? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final main = ref.watch(mainExamCodeProvider);
    return main.when(
      loading: () => const HmSkeletonList(label: 'Loading your Study Map'),
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
        if (onStartCheck != null) ref.watch(nextChecksProvider(code));
        return map.when(
          loading: () => const HmSkeletonList(label: 'Loading your Study Map'),
          error: (e, _) => HmErrorView(
            message: messageOf(e),
            onRetry: () => ref.invalidate(studyMapProvider(code)),
          ),
          data: (m) => StudyMapBody(
            map: m,
            lite: ref.watch(liteModeProvider),
            onOpenTopic: onStartCheck == null
                ? onOpenTopic
                : (t) => _openTopic(context, ref, code, t),
            header: actions == null
                ? null
                : StudyActionsRow(actions: actions!, examCode: code),
          ),
        );
      },
    );
  }
}

extension on StudyMapTab {
  void _openTopic(
    BuildContext context,
    WidgetRef ref,
    String code,
    TopicView t,
  ) {
    final next =
        ref.read(nextChecksProvider(code)).value?[t.id] ?? NextCheck.none;
    final actions = topicActions(
      next: next,
      lamp: t.lamp,
      hasLesson: t.hasLesson,
    );
    if (actions.every((a) => a.kind == null)) {
      onOpenTopic(t);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => LampSheet(
        topic: t,
        actions: actions,
        onAction: (a) {
          Navigator.of(c).pop();
          final kind = a.kind;
          kind == null ? onOpenTopic(t) : onStartCheck!(t, kind);
        },
      ),
    );
  }
}

/// The lamp sheet (§5.1): the lamp's state in words and its checks, the server's next check first.
/// Gold is timed by the server, so it is disabled offline with the reason shown.
class LampSheet extends ConsumerWidget {
  const LampSheet({
    super.key,
    required this.topic,
    required this.actions,
    required this.onAction,
  });

  final TopicView topic;
  final List<TopicAction> actions;
  final ValueChanged<TopicAction> onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(networkStateProvider).value?.online ?? true;
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('lamp-sheet'),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(topic.name, style: text.titleLarge),
            ),
            Text(lampWords(topic.lamp), style: text.bodyMedium),
            const SizedBox(height: 16),
            for (final (i, a) in actions.indexed) ...[
              if (i == 0)
                HmPrimaryButton(
                  key: Key('lamp-action-${a.kind?.name ?? 'lesson'}'),
                  label: a.label,
                  onPressed: a.needsConnection && !online
                      ? null
                      : () => onAction(a),
                )
              else
                HmSecondaryButton(
                  key: Key('lamp-action-${a.kind?.name ?? 'lesson'}'),
                  label: a.label,
                  onPressed: a.needsConnection && !online
                      ? null
                      : () => onAction(a),
                ),
              if (a.needsConnection && !online)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(StudyCopy.goldNeedsConnection),
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// Callbacks for the study entry points; the app's router decides where they go.
typedef StudyActions = ({
  VoidCallback onRelight,
  ValueChanged<String> onPractice,
  VoidCallback onMistakes,
  ValueChanged<String> onPyqVault,
});

/// Relight first: the one clear next action (§10.1), then practice, mistakes and the PYQ Vault.
class StudyActionsRow extends StatelessWidget {
  const StudyActionsRow({
    super.key,
    required this.actions,
    required this.examCode,
  });

  final StudyActions actions;
  final String examCode;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HmPrimaryButton(
          key: const Key('study-relight'),
          label: 'Relight lamps',
          icon: Icons.lightbulb_outline,
          onPressed: actions.onRelight,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HmSecondaryButton(
              key: const Key('study-practice'),
              label: 'Practise',
              expand: false,
              onPressed: () => actions.onPractice(examCode),
            ),
            HmSecondaryButton(
              key: const Key('study-mistakes'),
              label: 'Mistakes',
              expand: false,
              onPressed: actions.onMistakes,
            ),
            HmSecondaryButton(
              key: const Key('study-pyq'),
              label: 'PYQ Vault',
              expand: false,
              onPressed: () => actions.onPyqVault(examCode),
            ),
          ],
        ),
      ],
    ),
  );
}
