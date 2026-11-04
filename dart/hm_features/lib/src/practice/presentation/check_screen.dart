import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../../profile/application/profile_controller.dart';
import '../application/check_controller.dart';
import '../domain/practice_models.dart';
import '../domain/study_rules.dart';
import 'study_widgets.dart';

/// Lit, recall, relight and Gold checks (§5.1, INT-002-S01..S04). The server picks questions and grades.
class CheckScreen extends ConsumerStatefulWidget {
  const CheckScreen({
    super.key,
    required this.request,
    this.lessonAlreadyFinished = false,
  });

  final CheckRequest request;

  /// The user tapped "I've finished" on the lesson itself: record it and go straight to the Lit check.
  final bool lessonAlreadyFinished;

  @override
  ConsumerState<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends ConsumerState<CheckScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    if (widget.lessonAlreadyFinished && widget.request.lessonStep) {
      Future.microtask(
        () => ref
            .read(checkControllerProvider(widget.request).notifier)
            .finishLesson(),
      );
    } else if (!widget.request.lessonStep) {
      Future.microtask(
        () => ref.read(checkControllerProvider(widget.request).notifier).load(),
      );
    }
    if (widget.request.kind == CheckKind.gold) {
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  /// Lamp lit, Gold earned and rank up get a short celebration (§5.1, §5.2, §10.4). The overlay
  /// is skipped in Calm Mode, Lite Mode and with reduce motion; the result text always shows.
  Future<void> _celebrate(SaveOutcome<CheckResultView>? outcome) async {
    if (outcome is! Graded<CheckResultView>) return;
    final v = outcome.value;
    if (v.passed && widget.request.kind == CheckKind.gold && v.lamp.gold) {
      await HmCelebration.show(
        context,
        kind: HmCelebrationKind.lampGold,
        title: 'Gold earned!',
        subtitle: 'This lamp now shines Gold.',
      );
    } else if (v.passed && widget.request.kind == CheckKind.lit && v.lamp.lit) {
      await HmCelebration.show(
        context,
        kind: HmCelebrationKind.lampLit,
        title: 'Lamp lit!',
        subtitle: 'Nice work. Keep it bright with short recalls.',
      );
    }
    final rank = v.rankUp;
    if (rank != null && mounted) {
      await HmCelebration.show(
        context,
        kind: HmCelebrationKind.rankUp,
        title: 'New rank!',
        subtitle: rankUpSubtitle(rank.title, rank.note),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = checkControllerProvider(widget.request);
    final state = ref.watch(provider);
    final ctl = ref.read(provider.notifier);
    final check = state.check;
    final issued = state.issuedLocal;
    final left = check == null || issued == null
        ? null
        : goldTimeLeft(check, issued, ref.read(clockProvider)());
    ref.listen(provider, (prev, next) {
      if (prev?.stage != CheckStage.done && next.stage == CheckStage.done) {
        unawaited(_celebrate(next.outcome));
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text(StudyCopy.checkTitle(widget.request.kind))),
      body: CheckBody(
        state: state,
        kind: widget.request.kind,
        timeLeft: left,
        onFinishLesson: ctl.finishLesson,
        onRetry: ctl.load,
        onChoose: ctl.choose,
        onNext: ctl.next,
        onBack: ctl.back,
        onSubmit: ctl.submit,
        onDone: () => Navigator.of(context).maybePop(),
        calm: ref.watch(meProvider).value?.calmMode ?? false,
      ),
    );
  }
}

/// Layout only; decisions live in [CheckController].
class CheckBody extends StatelessWidget {
  const CheckBody({
    super.key,
    required this.state,
    required this.kind,
    required this.onFinishLesson,
    required this.onRetry,
    required this.onChoose,
    required this.onNext,
    required this.onBack,
    required this.onSubmit,
    required this.onDone,
    this.timeLeft,
    this.calm = false,
  });

  /// Calm Mode hides rank lines (§10.7).
  final bool calm;

  final CheckState state;
  final CheckKind kind;
  final Duration? timeLeft;
  final VoidCallback onFinishLesson;
  final VoidCallback onRetry;
  final ValueChanged<String> onChoose;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    switch (state.stage) {
      case CheckStage.lesson:
        return ListView(
          padding: const EdgeInsets.all(HmSpace.xl),
          children: [
            const Center(
              child: HmIllustration(kind: HmIllustrationKind.book, size: 112),
            ),
            const SizedBox(height: HmSpace.lg),
            Semantics(
              header: true,
              child: Text(
                'Finished the lesson?',
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: HmSpace.sm),
            Text(
              'Next is a 3-question check. Pass it to light this lamp.',
              style: text.bodyLarge?.copyWith(color: context.hm.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HmSpace.xl),
            HmPrimaryButton(
              key: const Key('lesson-finished'),
              label: "I've finished",
              onPressed: onFinishLesson,
            ),
          ],
        );
      case CheckStage.loading:
        return const HmSkeletonList(count: 2, label: 'Loading the check');
      case CheckStage.failed:
        return HmErrorView(
          message: state.message ?? StudyCopy.checkNeedsConnection,
          onRetry: onRetry,
        );
      case CheckStage.answering:
      case CheckStage.sending:
        final check = state.check!;
        final q = state.question!;
        final chosen = state.chosen[q.id] ?? const <String>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, HmSpace.xl),
          children: [
            HmStepHeader(step: state.index + 1, total: check.questions.length),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: HmSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.index == 0)
                    Text(
                      StudyCopy.checkIntro(
                        kind,
                        check.questions.length,
                        check.passMark,
                      ),
                      style: text.bodyMedium?.copyWith(
                        color: context.hm.textMuted,
                      ),
                    ),
                  if (timeLeft != null)
                    Semantics(
                      label:
                          'Time left ${timeLeft!.inMinutes} minutes '
                          '${timeLeft!.inSeconds % 60} seconds',
                      excludeSemantics: true,
                      child: Text(
                        'Time left ${timeLeft!.inMinutes}:${(timeLeft!.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: text.titleSmall,
                      ),
                    ),
                  const SizedBox(height: 8),
                  QuestionCard(
                    question: q,
                    number:
                        'Question ${state.index + 1} of ${check.questions.length}',
                    chosen: chosen,
                    onChoose: state.stage == CheckStage.answering
                        ? onChoose
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (state.index > 0)
                        Expanded(
                          child: HmSecondaryButton(
                            label: 'Back',
                            onPressed: onBack,
                          ),
                        ),
                      if (state.index > 0) const SizedBox(width: 12),
                      Expanded(
                        child: state.isLast
                            ? HmPrimaryButton(
                                key: const Key('check-submit'),
                                label: 'Submit',
                                busy: state.stage == CheckStage.sending,
                                onPressed: onSubmit,
                              )
                            : HmPrimaryButton(
                                key: const Key('check-next'),
                                label: 'Next',
                                onPressed: onNext,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      case CheckStage.done:
        return CheckResultBody(
          outcome: state.outcome!,
          kind: kind,
          onDone: onDone,
          calm: calm,
        );
    }
  }
}

class CheckResultBody extends StatelessWidget {
  const CheckResultBody({
    super.key,
    required this.outcome,
    required this.kind,
    required this.onDone,
    this.calm = false,
  });

  final SaveOutcome<CheckResultView> outcome;
  final CheckKind kind;
  final VoidCallback onDone;

  /// Calm Mode hides rank lines (§10.7).
  final bool calm;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final done = HmPrimaryButton(
      key: const Key('check-done'),
      label: 'Done',
      onPressed: onDone,
    );
    return ListView(
      padding: const EdgeInsets.all(HmSpace.xl),
      children: switch (outcome) {
        Graded(:final value) => [
          Center(
            child: Lamp(label: 'This lamp', state: value.lamp, size: 96),
          ),
          const SizedBox(height: HmSpace.lg),
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              value.passed
                  ? StudyCopy.checkPassed(kind)
                  : StudyCopy.checkFailed,
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: HmSpace.sm),
          Text(
            '${value.correct} of ${value.total} right · ${lampWords(value.lamp)}',
            textAlign: TextAlign.center,
            style: text.bodyLarge?.copyWith(color: context.hm.textMuted),
          ),
          if (value.lateAnswersIgnored > 0)
            Text(
              '${value.lateAnswersIgnored} answers came after the time limit and were not counted.',
              textAlign: TextAlign.center,
            ),
          // Rank lines are hidden in Calm Mode (§10.7, compliance C-P2-3).
          if (value.rankUp != null && !calm) ...[
            const SizedBox(height: 12),
            HmCard(
              highlighted: true,
              child: Row(
                children: [
                  HmIconBadge(
                    icon: Icons.emoji_events_rounded,
                    color: context.hm.gold,
                  ),
                  const SizedBox(width: HmSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New rank: ${value.rankUp!.title}',
                          style: text.titleMedium,
                        ),
                        Text(value.rankUp!.note, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final g in value.graded.where((g) => !g.correct)) ...[
            FeedbackPanel(graded: g),
            const SizedBox(height: 8),
          ],
          done,
        ],
        SavedOffline() => [
          const WillSyncNote(detail: StudyCopy.savedOffline),
          const SizedBox(height: 12),
          done,
        ],
        NotSaved(:final message) => [
          CouldNotSaveNote(message: message),
          const SizedBox(height: 12),
          done,
        ],
        LimitReached() => [done],
      },
    );
  }
}
