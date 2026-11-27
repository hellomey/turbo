import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

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
  Timer? _deadline;
  bool _timedOut = false;

  int get _seconds => widget.state.challenge!.secondsPerQuestion;

  @override
  void initState() {
    super.initState();
    _time = AnimationController(
      vsync: this,
      duration: Duration(seconds: _seconds),
    );
    _time.forward();
    // The deadline is a plain timer so it fires on time even when frames are skipped.
    _deadline = Timer(Duration(seconds: _seconds), _onTimeUp);
  }

  @override
  void dispose() {
    _pause?.cancel();
    _deadline?.cancel();
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
    _deadline?.cancel();
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
    final p = context.hm;
    final picked = s.pickedOnCurrent;
    final answered = s.answeredCurrent;
    final still = HmModes.reduceMotion(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HmSpace.lg,
              HmSpace.sm,
              HmSpace.lg,
              HmSpace.lg,
            ),
            children: [
              // Progress dots: amber for done, a ring for this one, grey for the rest. Grading happens at the end,
              // so the dots never claim right or wrong.
              ExcludeSemantics(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < total; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == s.index ? 16 : 12,
                        height: i == s.index ? 16 : 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < s.index
                              ? p.primary
                              : i == s.index
                              ? HmTint.amber
                              : const Color(0xFFE6DED0),
                          border: i == s.index
                              ? Border.all(color: p.primary, width: 2.5)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: HmSpace.md),
              HmCard(
                padding: const EdgeInsets.all(HmSpace.md),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(HmRadius.md),
                      child: const HmPicture(
                        HmPic.expoStall,
                        width: 96,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: HmSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expo Challenge',
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Question ${s.index + 1} of $total',
                            style: text.bodyMedium?.copyWith(
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HmSpace.md),
              AnimatedBuilder(
                animation: _time,
                builder: (context, _) {
                  final elapsed = _time.value * _seconds;
                  // Under reduce motion the bar steps once a second instead of gliding.
                  final left = still
                      ? (_seconds - elapsed.floor()).clamp(0, _seconds)
                      : (_seconds - elapsed);
                  final secondsLeft = (_seconds - elapsed).ceil().clamp(
                    0,
                    _seconds,
                  );
                  final low = secondsLeft <= 5;
                  return Semantics(
                    label: '$secondsLeft seconds left',
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                HmRadius.pill,
                              ),
                              child: SizedBox(
                                height: 8,
                                child: Stack(
                                  children: [
                                    Container(color: const Color(0xFFF1E6D3)),
                                    FractionallySizedBox(
                                      key: const Key('expo-timer-bar'),
                                      widthFactor: (left / _seconds)
                                          .clamp(0.0, 1.0)
                                          .toDouble(),
                                      child: Container(
                                        color: low ? p.error : p.primary,
                                      ),
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
                              style: text.labelLarge?.copyWith(
                                color: low ? p.error : null,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: HmSpace.lg),
              Semantics(
                header: true,
                child: Text(
                  q.stem,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: HmSpace.lg),
              for (var i = 0; i < q.options.length; i++) ...[
                _OptionButton(
                  key: Key('expo-option-${q.options[i].id}'),
                  letter: String.fromCharCode(65 + i),
                  label: q.options[i].text,
                  picked: picked == q.options[i].id,
                  locked: answered,
                  onTap: () => _record(q.options[i].id),
                ),
                const SizedBox(height: HmSpace.sm),
              ],
            ],
          ),
        ),
        // The sheet at the bottom: Mey and a plain line once the answer is in.
        AnimatedSize(
          duration: still ? Duration.zero : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: answered
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    HmSpace.lg,
                    HmSpace.md,
                    HmSpace.md,
                    HmSpace.md,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(HmRadius.xl),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.shadow,
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _timedOut && picked == null
                                ? "Time's up. On to the next one."
                                : 'Answer locked in.',
                            key: const Key('expo-feedback'),
                            style: text.titleMedium,
                          ),
                        ),
                      ),
                      HmMey(
                        _timedOut && picked == null
                            ? HmPic.meyPuzzled
                            : HmPic.meyHandsUp,
                        size: 72,
                        float: false,
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    super.key,
    required this.letter,
    required this.label,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool picked;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: picked,
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(HmRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: HmSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: HmSpace.lg,
            vertical: HmSpace.md,
          ),
          decoration: BoxDecoration(
            color: picked ? HmTint.amber : p.surface,
            borderRadius: BorderRadius.circular(HmRadius.lg),
            border: Border.all(
              color: picked ? p.primary : p.outline,
              width: picked ? 2 : 1.5,
            ),
            boxShadow: picked
                ? null
                : [
                    BoxShadow(
                      color: p.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  '$letter.',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: HmSpace.md),
              Expanded(child: Text(label, style: text.titleMedium)),
              if (picked)
                HmPop(
                  child: Icon(Icons.check_circle_rounded, color: p.primary),
                ),
            ],
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

    return Stack(
      children: [
        _list(context, text, cs, optionText),
        const Positioned.fill(child: HmConfetti()),
      ],
    );
  }

  Widget _list(
    BuildContext context,
    TextTheme text,
    ColorScheme cs,
    String Function(ExpoQuestion, String?) optionText,
  ) {
    return ListView(
      padding: const EdgeInsets.all(HmSpace.lg),
      children: [
        const HmMey(HmPic.meyCelebrate, size: 150),
        const SizedBox(height: HmSpace.md),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            'You got ${result.score} of ${result.total}',
            key: const Key('expo-score'),
            textAlign: TextAlign.center,
            style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
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
