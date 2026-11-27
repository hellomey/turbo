import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/ports.dart';
import '../../study_map/application/study_providers.dart';
import '../application/play_controller.dart';

/// The scoring table and limits, shown before every duel (the rules card) and on Rules & odds.
class DuelRulesCard extends StatelessWidget {
  const DuelRulesCard({super.key, required this.rules});

  final DuelRulesView rules;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      key: const Key('duel-rules'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How Points are scored', style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              'For each answer, say how sure you are. Sure and right earns '
              'the most. Sure and wrong earns nothing. You never lose Points.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 8),
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
                      Text(r.label),
                      Text('${r.correctPoints}'),
                      Text('${r.wrongPoints}'),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${rules.questionsPerDuel} questions, ${rules.timeLimitSeconds} '
              'seconds. Up to ${rules.dailyPointsCap} duel Points a day; after '
              'that, duels are for practice. Answers sent within '
              '${rules.minSecondsForPoints} seconds earn no Points. A dropped '
              'connection gets ${rules.graceSeconds} extra seconds.',
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Confidence Duel (BOLT-0115): five practice questions against the clock, solo. The server grades and scores;
/// the countdown here is only a guide (the server uses its own time).
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
    return Scaffold(
      appBar: AppBar(title: const Text('Confidence Duel')),
      body: r != null && d != null
          ? _results(context, d, r)
          : d != null
          ? _playing(context, d)
          : _intro(context),
    );
  }

  Widget _intro(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final exam = ref.watch(mainExamCodeProvider).value;
    final rules = ref.watch(gameRulesProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Five practice questions against the clock. Just you, no opponent. '
          'Free to play.',
          style: text.bodyLarge,
        ),
        const SizedBox(height: 12),
        rules.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(messageOf(e)),
          data: (g) => DuelRulesCard(rules: g.duel),
        ),
        const SizedBox(height: 12),
        if (_error != null) _errorText(context),
        FilledButton(
          key: const Key('duel-start'),
          onPressed: exam == null || _busy ? null : () => _start(exam),
          child: Text(exam == null ? 'Choose your exam first' : 'Start duel'),
        ),
      ],
    );
  }

  Widget _errorText(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      liveRegion: true,
      child: Text(
        _error!,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  );

  Widget _playing(BuildContext context, DuelView d) {
    final text = Theme.of(context).textTheme;
    final left = _secondsLeft(d);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          label: '$left seconds left',
          child: ExcludeSemantics(
            child: Text(
              left > 0 ? '$left s left' : 'Time is up. Send your answers.',
              key: const Key('duel-clock'),
              style: text.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < d.questions.length; i++)
          _QuestionCard(
            index: i,
            question: d.questions[i],
            scoring: d.rules.scoring,
            choice: _choice[d.questions[i].id],
            confidence: _confidence[d.questions[i].id] ?? 2,
            onChoose: (o) => setState(() => _choice[d.questions[i].id] = o),
            onConfidence: (c) =>
                setState(() => _confidence[d.questions[i].id] = c),
          ),
        if (_error != null) _errorText(context),
        FilledButton(
          key: const Key('duel-submit'),
          onPressed: _busy ? null : () => _submit(d),
          child: const Text('Send answers'),
        ),
      ],
    );
  }

  Widget _results(BuildContext context, DuelView d, DuelResultView r) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final byId = {for (final q in d.questions) q.id: q};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            'You scored ${r.score}. +${r.pointsAwarded} Points.',
            key: const Key('duel-score'),
            style: text.titleLarge,
          ),
        ),
        if (r.withheldNote case final note?)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(note, key: const Key('duel-withheld')),
          ),
        Text(
          'Duel Points today: ${r.pointsToday} of ${r.dailyPointsCap}.',
          style: text.bodySmall,
        ),
        const SizedBox(height: 12),
        for (final a in r.results)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(byId[a.questionId]?.stem ?? '', style: text.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${a.correct ? 'Right' : (a.chosenOptionId == null ? 'Not answered' : 'Wrong')}'
                    ' · ${a.points} Points',
                    style: text.titleSmall?.copyWith(
                      color: a.correct
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                  if (!a.correct)
                    Text(
                      'Answer: ${a.correctOptionIds.map((id) => byId[a.questionId]?.options.where((o) => o.id == id).firstOrNull?.text ?? id).join(', ')}',
                    ),
                  const SizedBox(height: 4),
                  Text(a.explanation, style: text.bodySmall),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('duel-again'),
          onPressed: () => setState(() {
            _duel = null;
            _result = null;
          }),
          child: const Text('Play again'),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
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
  final int confidence;
  final ValueChanged<String> onChoose;
  final ValueChanged<int> onConfidence;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      key: Key('duel-q-$index'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}. ${question.stem}', style: text.bodyLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in question.options)
                  ChoiceChip(
                    key: Key('duel-q-$index-${o.id}'),
                    label: Text(o.text),
                    selected: choice == o.id,
                    onSelected: (_) => onChoose(o.id),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('How sure are you?', style: text.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in scoring)
                  ChoiceChip(
                    key: Key('duel-q-$index-c${s.confidence}'),
                    label: Text(s.label),
                    selected: confidence == s.confidence,
                    onSelected: (_) => onConfidence(s.confidence),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
