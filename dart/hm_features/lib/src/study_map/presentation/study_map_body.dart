import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../practice/application/practice_providers.dart';
import '../../practice/domain/practice_models.dart';
import '../../practice/domain/study_rules.dart';
import '../application/study_providers.dart';
import '../domain/study_map_view.dart';
import 'lamp_path.dart';

/// The Study Map (§10.6): a winding lamp path with a subject filter and a floating lamp count
/// (design/ui/06, BOLT-0117), or a static list in Lite Mode (§10.8).
class StudyMapBody extends StatefulWidget {
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

  @override
  State<StudyMapBody> createState() => _StudyMapBodyState();
}

class _StudyMapBodyState extends State<StudyMapBody> {
  /// null = every subject.
  String? _subject;

  void _tap(BuildContext context, TopicView topic) {
    if (!topic.hasLesson) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Lesson coming soon.')));
      return;
    }
    widget.onOpenTopic?.call(topic);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final subjects = widget.map.subjects;
    final shown = [
      for (final s in subjects)
        if (_subject == null || s.code == _subject) ...s.topics,
    ];
    final title = Semantics(
      header: true,
      child: Text(
        'Study Map',
        style: text.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
    if (widget.lite) {
      return ListView(
        key: const Key('study-map'),
        padding: const EdgeInsets.all(HmSpace.lg),
        children: [
          title,
          const SizedBox(height: HmSpace.lg),
          ?widget.header,
          for (final subject in subjects)
            _LiteSubject(subject: subject, onTap: (t) => _tap(context, t)),
        ],
      );
    }
    Widget chip(String label, String? id) {
      final on = _subject == id;
      return Padding(
        padding: const EdgeInsets.only(right: HmSpace.sm),
        child: Semantics(
          button: true,
          selected: on,
          label: id == null ? 'All subjects' : label,
          excludeSemantics: true,
          child: InkWell(
            key: Key('map-filter-${id ?? 'all'}'),
            borderRadius: BorderRadius.circular(HmRadius.pill),
            onTap: () => setState(() => _subject = id),
            child: AnimatedContainer(
              duration: HmMotion.fast,
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: HmSpace.lg),
              decoration: BoxDecoration(
                color: on ? p.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(HmRadius.pill),
                border: Border.all(
                  color: on ? p.primary : p.outline,
                  width: HmBauhaus.stroke,
                ),
              ),
              child: Text(
                label,
                style: text.titleMedium?.copyWith(
                  color: on ? p.onPrimary : p.textMuted,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView(
          key: const Key('study-map'),
          padding: const EdgeInsets.fromLTRB(
            HmSpace.xl,
            HmSpace.lg,
            HmSpace.xl,
            120,
          ),
          children: [
            title,
            const SizedBox(height: HmSpace.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  chip('All', null),
                  for (final s in subjects) chip(s.name, s.code),
                ],
              ),
            ),
            const SizedBox(height: HmSpace.lg),
            ?widget.header,
            if (shown.isEmpty)
              const HmEmptyView(title: 'No topics here yet.')
            else
              LampPath(
                topics: shown,
                onTap: widget.onOpenTopic == null
                    ? null
                    : (t) => _tap(context, t),
              ),
          ],
        ),
        if (shown.isNotEmpty)
          Positioned(
            left: HmSpace.xl,
            right: HmSpace.xl,
            bottom: HmSpace.md,
            child: LampSummary(topics: shown),
          ),
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
  Widget build(BuildContext context) {
    final p = context.hm;
    Widget action(
      Key key,
      String label,
      IconData icon,
      Color tint,
      VoidCallback onTap,
    ) => Expanded(
      child: HmCard(
        key: key,
        color: tint,
        onTap: onTap,
        semanticLabel: label,
        padding: const EdgeInsets.symmetric(
          vertical: HmSpace.md,
          horizontal: HmSpace.xs,
        ),
        child: ExcludeSemantics(
          child: Column(
            children: [
              Icon(icon, color: p.text, size: 26),
              const SizedBox(height: HmSpace.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          action(
            const Key('study-relight'),
            'Relight',
            Icons.local_fire_department_rounded,
            HmTint.coral,
            actions.onRelight,
          ),
          const SizedBox(width: HmSpace.sm),
          action(
            const Key('study-practice'),
            'Practise',
            Icons.edit_rounded,
            HmTint.amber,
            () => actions.onPractice(examCode),
          ),
          const SizedBox(width: HmSpace.sm),
          action(
            const Key('study-mistakes'),
            'Mistakes',
            Icons.replay_rounded,
            HmTint.mint,
            actions.onMistakes,
          ),
          const SizedBox(width: HmSpace.sm),
          action(
            const Key('study-pyq'),
            'PYQ',
            Icons.inventory_2_rounded,
            HmTint.sky,
            () => actions.onPyqVault(examCode),
          ),
        ],
      ),
    );
  }
}
