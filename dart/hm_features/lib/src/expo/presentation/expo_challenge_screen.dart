import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/lamp_art.dart';
import '../application/expo_controller.dart';
import '../domain/expo_models.dart';
import 'sticker_screen.dart';

/// How long the "answer locked in" moment shows before the next question.
const expoFeedbackPause = Duration(milliseconds: 700);

/// Expo Challenge (BOLT-0111, route `/expo`): timed questions, a score, a lamp, then the sticker.
class ExpoChallengeScreen extends ConsumerStatefulWidget {
  const ExpoChallengeScreen({super.key});

  @override
  ConsumerState<ExpoChallengeScreen> createState() =>
      _ExpoChallengeScreenState();
}

class _ExpoChallengeScreenState extends ConsumerState<ExpoChallengeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expoControllerProvider.notifier).start());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expoControllerProvider);
    final c = ref.read(expoControllerProvider.notifier);
    ref.listen(expoControllerProvider.select((s) => s.phase), (_, phase) {
      if (phase == ExpoPhase.result) HapticFeedback.mediumImpact();
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Expo Challenge')),
      body: SafeArea(
        child: switch (state.phase) {
          ExpoPhase.loading => const HmLoadingView(label: 'Getting questions'),
          ExpoPhase.error => HmErrorView(
            message: state.error ?? 'Something went wrong.',
            onRetry: c.start,
          ),
          ExpoPhase.question => _QuestionView(
            key: ValueKey(state.current?.id),
            state: state,
          ),
          ExpoPhase.submitting =>
            state.error == null
                ? const HmLoadingView(label: 'Checking your answers')
                : HmErrorView(
                    message: state.error!,
                    retryLabel: 'Send again',
                    onRetry: c.submit,
                  ),
          ExpoPhase.result => _ResultView(
            challenge: state.challenge!,
            answers: state.answers,
            result: state.result!,
          ),
        },
      ),
    );
  }
}

class _QuestionView extends ConsumerStatefulWidget {
  const _QuestionView({super.key, required this.state});

  final ExpoState state;

  @override
  ConsumerState<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends ConsumerState<_QuestionView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time;
  final _watch = Stopwatch()..start();
  Timer? _pause;
  bool _timedOut = false;

  int get _seconds => widget.state.challenge!.secondsPerQuestion;

  @override
  void initState() {
    super.initState();
    _time =
        AnimationController(
          vsync: this,
          duration: Duration(seconds: _seconds),
        )..addStatusListener((s) {
          if (s == AnimationStatus.completed) _onTimeUp();
        });
    _time.forward();
  }

  @override
  void dispose() {
    _pause?.cancel();
    _time.dispose();
    super.dispose();
  }

  void _onTimeUp() {
    if (!mounted) return;
    setState(() => _timedOut = true);
    _record(null);
  }

  void _record(String? optionId) {
    final c = ref.read(expoControllerProvider.notifier);
    if (ref.read(expoControllerProvider).answeredCurrent) return;
    _time.stop();
    c.answer(optionId, _watch.elapsedMilliseconds);
    if (optionId != null) HapticFeedback.selectionClick();
    _pause = Timer(expoFeedbackPause, c.next);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(expoControllerProvider);
    final q = s.current!;
    final total = s.challenge!.questions.length;
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final picked = s.pickedOnCurrent;
    final answered = s.answeredCurrent;
    final still = HmModes.reduceMotion(context);
    return ListView(
      padding: const EdgeInsets.all(HmSpace.lg),
      children: [
        Text(
          'Question ${s.index + 1} of $total',
          style: text.titleSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: HmSpace.sm),
        AnimatedBuilder(
          animation: _time,
          builder: (context, _) {
            final elapsed = _time.value * _seconds;
            // Under reduce motion the bar steps once a second instead of gliding.
            final left = still
                ? (_seconds - elapsed.floor()).clamp(0, _seconds)
                : (_seconds - elapsed);
            final secondsLeft = (_seconds - elapsed).ceil().clamp(0, _seconds);
            return Semantics(
              label: '$secondsLeft seconds left',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: SizedBox(
                          height: 10,
                          child: Stack(
                            children: [
                              Container(color: cs.surfaceContainerHighest),
                              FractionallySizedBox(
                                key: const Key('expo-timer-bar'),
                                widthFactor: (left / _seconds)
                                    .clamp(0.0, 1.0)
                                    .toDouble(),
                                child: Container(color: cs.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: HmSpace.sm),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$secondsLeft s',
                        textAlign: TextAlign.end,
                        style: text.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: HmSpace.lg),
        Semantics(header: true, child: Text(q.stem, style: text.titleLarge)),
        const SizedBox(height: HmSpace.lg),
        for (final o in q.options) ...[
          _OptionButton(
            key: Key('expo-option-${o.id}'),
            label: o.text,
            picked: picked == o.id,
            locked: answered,
            onTap: () => _record(o.id),
          ),
          const SizedBox(height: HmSpace.sm),
        ],
        if (answered)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.only(top: HmSpace.sm),
              child: Text(
                _timedOut && picked == null
                    ? "Time's up. On to the next one."
                    : 'Answer locked in.',
                key: const Key('expo-feedback'),
                style: text.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    super.key,
    required this.label,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final bool picked;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: picked,
      child: Material(
        color: picked ? cs.primary : cs.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: picked ? cs.primary : cs.outline,
            width: picked ? 2.5 : 1.5,
          ),
        ),
        child: InkWell(
          onTap: locked ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: HmSizes.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HmSpace.lg,
                vertical: HmSpace.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: picked ? cs.onPrimary : cs.onSurface,
                      ),
                    ),
                  ),
                  if (picked) Icon(Icons.check_rounded, color: cs.onPrimary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.challenge,
    required this.answers,
    required this.result,
  });

  final ExpoChallenge challenge;
  final List<ExpoAnswer> answers;
  final ExpoResult result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    String optionText(ExpoQuestion q, String? id) {
      for (final o in q.options) {
        if (o.id == id) return o.text;
      }
      return 'No answer';
    }

    return ListView(
      padding: const EdgeInsets.all(HmSpace.lg),
      children: [
        const Center(child: LightingLamp(size: 132)),
        const SizedBox(height: HmSpace.md),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            'You got ${result.score} of ${result.total}',
            key: const Key('expo-score'),
            textAlign: TextAlign.center,
            style: text.headlineMedium,
          ),
        ),
        const SizedBox(height: HmSpace.xs),
        Text(
          result.stickerCode == null
              ? 'You finished the challenge. Your lamp is lit.'
              : 'You finished the challenge. Your sticker code is ready.',
          textAlign: TextAlign.center,
          style: text.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: HmSpace.lg),
        HmPrimaryButton(
          key: const Key('expo-collect-sticker'),
          label: 'Collect your sticker',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StickerScreen(initialCode: result.stickerCode),
            ),
          ),
        ),
        const HmSectionTitle('Your answers'),
        for (final q in challenge.questions)
          if (_resultFor(q.id) case final r?)
            Padding(
              padding: const EdgeInsets.only(bottom: HmSpace.sm),
              child: HmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          r.correct
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: r.correct ? cs.primary : cs.error,
                          semanticLabel: r.correct ? 'Right' : 'Not right',
                        ),
                        const SizedBox(width: HmSpace.sm),
                        Expanded(child: Text(q.stem, style: text.titleSmall)),
                      ],
                    ),
                    const SizedBox(height: HmSpace.sm),
                    if (!r.correct)
                      Text(
                        'You chose: ${optionText(q, _answerFor(q.id))}',
                        style: text.bodyMedium,
                      ),
                    Text(
                      'Answer: ${optionText(q, r.correctOptionId)}',
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (r.explanation.isNotEmpty) ...[
                      const SizedBox(height: HmSpace.xs),
                      Text(
                        r.explanation,
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
      ],
    );
  }

  ExpoQuestionResult? _resultFor(String id) {
    for (final r in result.results) {
      if (r.questionId == id) return r;
    }
    return null;
  }

  String? _answerFor(String id) {
    for (final a in answers) {
      if (a.questionId == id) return a.optionId;
    }
    return null;
  }
}
