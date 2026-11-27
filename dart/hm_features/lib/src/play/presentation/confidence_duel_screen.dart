import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/ports.dart';
import '../../progress/application/progress_controller.dart';
import '../../study_map/application/study_providers.dart';
import '../application/play_controller.dart';

/// The scoring table and limits, shown before every duel (the rules card) and on Rules & odds.
class DuelRulesCard extends StatelessWidget {
  const DuelRulesCard({super.key, required this.rules});

  final DuelRulesView rules;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    return HmCard(
      key: const Key('duel-rules'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Points are scored',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: HmSpace.sm),
          Text(
            'For each answer, say how sure you are. Sure and right earns '
            'the most. Sure and wrong earns nothing. You never lose Points.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: HmSpace.md),
          Table(
            columnWidths: const {0: FlexColumnWidth(2)},
            children: [
              TableRow(
                children: [
                  Text('How sure', style: text.labelLarge),
                  Text('Right', style: text.labelLarge),
                  Text('Wrong', style: text.labelLarge),
                ],
              ),
              for (final r in rules.scoring)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(r.label),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${r.correctPoints}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${r.wrongPoints}'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: HmSpace.sm),
          Text(
            '${rules.questionsPerDuel} questions, ${rules.timeLimitSeconds} '
            'seconds. Up to ${rules.dailyPointsCap} duel Points a day; after '
            'that, duels are for practice. Answers sent within '
            '${rules.minSecondsForPoints} seconds earn no Points. A dropped '
            'connection gets ${rules.graceSeconds} extra seconds.',
            style: text.bodySmall?.copyWith(color: p.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Confidence Duel (BOLT-0115, design/ui/21): five practice questions against the clock, solo, one at a time.
/// Pick an answer, then say how sure you are; that moves you on. The server grades and scores; the countdown here
/// is only a guide (the server uses its own time).
class ConfidenceDuelScreen extends ConsumerStatefulWidget {
  const ConfidenceDuelScreen({super.key});

  @override
  ConsumerState<ConfidenceDuelScreen> createState() =>
      _ConfidenceDuelScreenState();
}

class _ConfidenceDuelScreenState extends ConsumerState<ConfidenceDuelScreen> {
  DuelView? _duel;
  DuelResultView? _result;
  final Map<String, String> _choice = {};
  final Map<String, int> _confidence = {};
  int _page = 0;
  DateTime? _openedAt;
  Timer? _tick;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _start(String examCode) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final d = await ref.read(playRepositoryProvider).startDuel(examCode);
      if (!mounted) return;
      _choice.clear();
      _confidence.clear();
      _page = 0;
      _openedAt = ref.read(clockProvider)();
      _tick?.cancel();
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      setState(() {
        _duel = d;
        _result = null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = messageOf(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _submit(DuelView d) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final answers = <DuelAnswer>[
        for (final q in d.questions)
          if (_choice[q.id] case final option?)
            (
              questionId: q.id,
              optionId: option,
              confidence: _confidence[q.id] ?? 2,
            ),
      ];
      final r = await ref
          .read(playRepositoryProvider)
          .submitDuel(d.duelId, answers);
      _tick?.cancel();
      ref.invalidate(myProgressProvider);
      if (mounted) setState(() => _result = r);
    } on Object catch (e) {
      if (mounted) setState(() => _error = messageOf(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  int _secondsLeft(DuelView d) {
    final opened = _openedAt;
    if (opened == null) return d.rules.timeLimitSeconds;
    final used = ref.read(clockProvider)().difference(opened).inSeconds;
    return (d.rules.timeLimitSeconds - used).clamp(0, d.rules.timeLimitSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final d = _duel;
    final r = _result;
    final p = context.hm;
    final playing = d != null && r == null;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        centerTitle: true,
        leading: playing
            ? IconButton(
                key: const Key('duel-close'),
                tooltip: 'Leave duel',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          playing
              ? 'Q ${_page + 1} of ${d.questions.length}'
              : 'Confidence Duel',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (playing)
            Padding(
              padding: const EdgeInsets.only(right: HmSpace.md),
              child: Center(child: _clock(context, d)),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: r != null && d != null
              ? _results(context, d, r)
              : d != null
              ? _playing(context, d)
              : _intro(context),
        ),
      ),
    );
  }

  Widget _clock(BuildContext context, DuelView d) {
    final left = _secondsLeft(d);
    final p = context.hm;
    return Semantics(
      label: '$left seconds left',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: HmSpace.md,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: HmTint.amber,
            borderRadius: BorderRadius.circular(HmRadius.pill),
            border: Border.all(color: p.primary, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: p.primaryText),
              const SizedBox(width: 4),
              Text(
                left > 0 ? '$left s' : 'Time up',
                key: const Key('duel-clock'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: p.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final exam = ref.watch(mainExamCodeProvider).value;
    final rules = ref.watch(gameRulesProvider);
    return ListView(
      padding: const EdgeInsets.all(HmSpace.lg),
      children: [
        const HmMey(HmPic.meyDuel, size: 150),
        const SizedBox(height: HmSpace.md),
        Text(
          'Be sure. Be right.',
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: HmSpace.xs),
        Text(
          'Five practice questions against the clock. Just you, no opponent. '
          'Free to play.',
          textAlign: TextAlign.center,
          style: text.bodyLarge,
        ),
        const SizedBox(height: HmSpace.lg),
        rules.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(messageOf(e)),
          data: (g) => DuelRulesCard(rules: g.duel),
        ),
        const SizedBox(height: HmSpace.lg),
        if (_error != null) _errorText(context),
        HmChunkyButton(
          key: const Key('duel-start'),
          expand: true,
          busy: _busy,
          onPressed: exam == null || _busy ? null : () => _start(exam),
          label: exam == null ? 'Choose your exam first' : 'Start duel',
        ),
      ],
    );
  }

  Widget _errorText(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HmSpace.sm),
    child: Semantics(
      liveRegion: true,
      child: Text(_error!, style: TextStyle(color: context.hm.error)),
    ),
  );

  Widget _playing(BuildContext context, DuelView d) {
    final p = context.hm;
    final total = d.questions.length;
    final q = d.questions[_page];
    final last = _page == total - 1;
    final left = _secondsLeft(d);
    final answered = d.questions.where((q) => _choice.containsKey(q.id)).length;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(HmSpace.lg, 0, HmSpace.lg, 140),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(HmRadius.pill),
              child: LinearProgressIndicator(
                value: d.rules.timeLimitSeconds == 0
                    ? 0
                    : left / d.rules.timeLimitSeconds,
                minHeight: 6,
                color: p.primary,
                backgroundColor: const Color(0xFFF1E6D3),
              ),
            ),
            const SizedBox(height: HmSpace.lg),
            AnimatedSwitcher(
              duration: HmModes.reduceMotion(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(a),
                  child: child,
                ),
              ),
              child: _QuestionPage(
                key: ValueKey(q.id),
                index: _page,
                question: q,
                scoring: d.rules.scoring,
                choice: _choice[q.id],
                confidence: _confidence[q.id],
                onChoose: (o) => setState(() => _choice[q.id] = o),
                onConfidence: (c) => setState(() {
                  _confidence[q.id] = c;
                  if (_choice.containsKey(q.id) && !last) _page++;
                }),
              ),
            ),
            const SizedBox(height: HmSpace.md),
            if (_error != null) _errorText(context),
            Row(
              children: [
                if (_page > 0)
                  HmGhostButton(
                    key: const Key('duel-back'),
                    label: 'Back',
                    onPressed: () => setState(() => _page--),
                  ),
                const Spacer(),
                if (!last)
                  HmGhostButton(
                    key: const Key('duel-next'),
                    label: 'Skip',
                    onPressed: () => setState(() => _page++),
                  ),
              ],
            ),
            if (last || left == 0) ...[
              const SizedBox(height: HmSpace.sm),
              HmChunkyButton(
                key: const Key('duel-submit'),
                expand: true,
                busy: _busy,
                onPressed: _busy ? null : () => _submit(d),
                label: left == 0
                    ? 'Time is up. Send answers'
                    : 'Send answers ($answered of $total)',
              ),
            ],
          ],
        ),
        const Positioned(
          right: 0,
          bottom: 0,
          child: IgnorePointer(child: HmMey(HmPic.meyDuel, size: 110)),
        ),
      ],
    );
  }

  Widget _results(BuildContext context, DuelView d, DuelResultView r) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final byId = {for (final q in d.questions) q.id: q};
    final right = r.results.where((a) => a.correct).length;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(HmSpace.lg),
          children: [
            HmMey(
              right * 2 >= r.results.length
                  ? HmPic.meyCelebrate
                  : HmPic.meyThumbs,
              size: 130,
            ),
            const SizedBox(height: HmSpace.sm),
            Semantics(
              liveRegion: true,
              child: Text(
                'You scored ${r.score}. +${r.pointsAwarded} Points.',
                key: const Key('duel-score'),
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '$right of ${r.results.length} right',
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(color: p.textMuted),
            ),
            if (r.withheldNote case final note?)
              Padding(
                padding: const EdgeInsets.only(top: HmSpace.sm),
                child: HmCard(
                  color: HmTint.cream,
                  padding: const EdgeInsets.all(HmSpace.md),
                  child: Text(note, key: const Key('duel-withheld')),
                ),
              ),
            const SizedBox(height: HmSpace.xs),
            Text(
              'Duel Points today: ${r.pointsToday} of ${r.dailyPointsCap}.',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
            const SizedBox(height: HmSpace.md),
            for (final a in r.results)
              Padding(
                padding: const EdgeInsets.only(bottom: HmSpace.sm),
                child: HmCard(
                  color: a.correct ? HmTint.mint : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            a.correct
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: a.correct ? p.success : p.error,
                          ),
                          const SizedBox(width: HmSpace.sm),
                          Expanded(
                            child: Text(
                              byId[a.questionId]?.stem ?? '',
                              style: text.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: HmSpace.xs),
                      Text(
                        '${a.correct ? 'Right' : (a.chosenOptionId == null ? 'Not answered' : 'Wrong')}'
                        ' · ${a.points} Points',
                        style: text.titleSmall?.copyWith(
                          color: a.correct ? p.success : p.error,
                        ),
                      ),
                      if (!a.correct)
                        Text(
                          'Answer: ${a.correctOptionIds.map((id) => byId[a.questionId]?.options.where((o) => o.id == id).firstOrNull?.text ?? id).join(', ')}',
                        ),
                      const SizedBox(height: HmSpace.xs),
                      Text(a.explanation, style: text.bodySmall),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: HmSpace.md),
            HmChunkyButton(
              key: const Key('duel-again'),
              expand: true,
              onPressed: () => setState(() {
                _duel = null;
                _result = null;
              }),
              label: 'Play again',
            ),
          ],
        ),
        if (r.pointsAwarded > 0) const Positioned.fill(child: HmConfetti()),
      ],
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    super.key,
    required this.index,
    required this.question,
    required this.scoring,
    required this.choice,
    required this.confidence,
    required this.onChoose,
    required this.onConfidence,
  });

  final int index;
  final DuelQuestionView question;
  final List<DuelScoringRowView> scoring;
  final String? choice;
  final int? confidence;
  final ValueChanged<String> onChoose;
  final ValueChanged<int> onConfidence;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    return Column(
      key: Key('duel-q-$index'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HmCard(
          child: Text(
            question.stem,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: HmSpace.md),
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: HmSpace.sm),
            child: _OptionRow(
              key: Key('duel-q-$index-${question.options[i].id}'),
              letter: String.fromCharCode(65 + i),
              label: question.options[i].text,
              selected: choice == question.options[i].id,
              onTap: () => onChoose(question.options[i].id),
            ),
          ),
        const SizedBox(height: HmSpace.sm),
        Text(
          'How sure are you?',
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: HmSpace.sm),
        for (final s in scoring)
          Padding(
            padding: const EdgeInsets.only(bottom: HmSpace.sm, right: 96),
            child: Semantics(
              button: true,
              selected: confidence == s.confidence,
              label:
                  '${s.label}. Right ${s.correctPoints}, wrong ${s.wrongPoints} Points',
              child: ExcludeSemantics(
                child: InkWell(
                  key: Key('duel-q-$index-c${s.confidence}'),
                  borderRadius: BorderRadius.circular(HmRadius.pill),
                  onTap: () => onConfidence(s.confidence),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: HmSpace.sm),
                    decoration: BoxDecoration(
                      color: confidence == s.confidence
                          ? HmTint.amber
                          : p.surface,
                      borderRadius: BorderRadius.circular(HmRadius.pill),
                      border: Border.all(
                        color: confidence == s.confidence
                            ? p.primary
                            : p.outline,
                        width: confidence == s.confidence ? 2 : 1.5,
                      ),
                    ),
                    child: Opacity(
                      opacity: choice == null ? 0.55 : 1,
                      child: Column(
                        children: [
                          Text(
                            s.label,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '(+${s.correctPoints} / ${s.wrongPoints} pts)',
                            style: text.bodySmall?.copyWith(color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One answer row: "A.  Chennai", amber with a radio dot when chosen (design/ui/21).
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    super.key,
    required this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$letter. $label',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HmRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: HmSpace.lg,
              vertical: HmSpace.md,
            ),
            decoration: BoxDecoration(
              color: selected ? HmTint.amber : p.surface,
              borderRadius: BorderRadius.circular(HmRadius.lg),
              border: Border.all(
                color: selected ? p.primary : p.outline,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '$letter.',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: HmSpace.md),
                Expanded(child: Text(label, style: text.titleMedium)),
                if (selected)
                  Icon(Icons.radio_button_checked_rounded, color: p.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
