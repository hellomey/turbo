import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../application/practice_controller.dart';
import '../domain/practice_models.dart';
import '../domain/study_rules.dart';
import 'study_widgets.dart';

/// Practice session (§10.6 Practice/recall, INT-002-S06/S07): one question per screen, instant feedback.
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key, required this.request, this.onRelight});

  final PracticeRequest request;
  final ValueChanged<String>? onRelight;

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(practiceControllerProvider(widget.request).notifier).start(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = practiceControllerProvider(widget.request);
    ref.listen(provider.select((s) => s.showLimitSheet), (_, show) async {
      if (!show) return;
      final ctl = ref.read(provider.notifier);
      final limit = ref.read(provider).usage?.limit;
      ctl.limitSheetShown();
      await LimitSheet.show(context, limit: limit);
    });
    final state = ref.watch(provider);
    final ctl = ref.read(provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.request.mode) {
          StudyMode.pyq => 'PYQ practice',
          StudyMode.mistakes => 'Mistake review',
          StudyMode.drill => 'Concept drill',
          StudyMode.practice => 'Practice',
        }),
      ),
      body: state.loading
          ? const HmSkeletonList(count: 2, label: 'Loading questions')
          : state.error != null
          ? HmErrorView(message: state.error!, onRetry: ctl.start)
          : PracticeBody(
              state: state,
              onChoose: ctl.choose,
              onCheck: ctl.check,
              onNext: ctl.next,
              onDone: () => Navigator.of(context).maybePop(),
              onRelight: widget.onRelight,
            ),
    );
  }
}

/// Layout only; every decision is in [PracticeController].
class PracticeBody extends StatelessWidget {
  const PracticeBody({
    super.key,
    required this.state,
    required this.onChoose,
    required this.onCheck,
    required this.onNext,
    required this.onDone,
    this.onRelight,
  });

  final PracticeState state;
  final ValueChanged<String> onChoose;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final VoidCallback onDone;
  final ValueChanged<String>? onRelight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final q = state.question;
    final usageLine = state.usage?.line;
    if (state.limitReached && (q == null || state.outcome == null)) {
      return _Center(
        kind: HmIllustrationKind.soon,
        title: StudyCopy.limitTitle(state.usage?.limit),
        body: StudyCopy.limitBody,
        action: HmPrimaryButton(label: 'Done', onPressed: onDone),
      );
    }
    if (q == null) {
      final offline = state.savedOfflineCount;
      return _Center(
        kind: HmIllustrationKind.trophy,
        title: 'Session done',
        body:
            '${state.correctCount} correct.'
            '${offline > 0 ? ' $offline saved on this phone.' : ''}'
            '${state.weakTopicIds.isNotEmpty ? ' Weak spots are marked on your map.' : ''}',
        action: HmPrimaryButton(
          key: const Key('practice-done'),
          label: 'Done',
          onPressed: onDone,
        ),
      );
    }
    final outcome = state.outcome;
    final total = state.session?.questions.length ?? 0;
    return ListView(
      padding: const EdgeInsets.only(bottom: HmSpace.xl),
      children: [
        if (total > 0) HmStepHeader(step: state.index + 1, total: total),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: HmSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (usageLine != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: HmSpace.sm),
                  child: Text(
                    usageLine,
                    style: text.bodySmall?.copyWith(
                      color: context.hm.textMuted,
                    ),
                  ),
                ),
              QuestionCard(
                question: q,
                number: 'Question ${state.index + 1} of $total',
                chosen: state.chosen[q.id] ?? const [],
                graded: outcome is Graded<PracticeAnswerView>
                    ? outcome.value.graded
                    : null,
                onChoose: outcome == null ? onChoose : null,
              ),
              const SizedBox(height: 8),
              switch (outcome) {
                null => HmPrimaryButton(
                  key: const Key('practice-check'),
                  label: 'Check',
                  busy: state.busy,
                  onPressed: (state.chosen[q.id]?.isNotEmpty ?? false)
                      ? onCheck
                      : null,
                ),
                Graded(:final value) => FeedbackPanel(
                  graded: value.graded,
                  onRelight: onRelight == null
                      ? null
                      : () => onRelight!(value.graded.topicId),
                ),
                SavedOffline() => const WillSyncNote(
                  detail: StudyCopy.savedOffline,
                ),
                NotSaved(:final message) => CouldNotSaveNote(message: message),
                LimitReached() => const SizedBox.shrink(),
              },
              if (outcome != null) ...[
                const SizedBox(height: 12),
                HmPrimaryButton(
                  key: const Key('practice-next'),
                  label: state.index + 1 >= total ? 'Finish' : 'Next',
                  onPressed: onNext,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({
    required this.title,
    required this.body,
    required this.action,
    required this.kind,
  });
  final HmIllustrationKind kind;
  final String title;
  final String body;
  final Widget action;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(HmSpace.xl),
    children: [
      Center(child: HmIllustration(kind: kind, size: 112)),
      const SizedBox(height: HmSpace.lg),
      Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: HmSpace.sm),
      Text(
        body,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: context.hm.textMuted),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: HmSpace.xl),
      action,
    ],
  );
}
