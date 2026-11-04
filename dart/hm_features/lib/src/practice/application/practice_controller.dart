import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../domain/practice_models.dart';
import '../domain/study_rules.dart';
import 'practice_providers.dart';

/// What to practise (§10.6 Practice): free practice, PYQs, mistakes or a concept drill.
typedef PracticeRequest = ({
  StudyMode mode,
  String examCode,
  String? topicId,
  String? subjectCode,
  String? drillId,
});

@immutable
class PracticeState {
  const PracticeState({
    this.session,
    this.index = 0,
    this.chosen = const {},
    this.outcomes = const {},
    this.usage,
    this.loading = true,
    this.busy = false,
    this.error,
    this.limitReached = false,
    this.showLimitSheet = false,
  });

  final PracticeSessionView? session;
  final int index;
  final Map<String, List<String>> chosen;
  final Map<String, SaveOutcome<PracticeAnswerView>> outcomes;
  final UsageView? usage;
  final bool loading;
  final bool busy;
  final String? error;

  /// Today's free questions are used up (§11). Practice stops; lessons, relights and mocks stay open (§13).
  final bool limitReached;

  /// One-shot: the screen shows the limit sheet, then calls [PracticeController.limitSheetShown].
  final bool showLimitSheet;

  QuestionView? get question {
    final qs = session?.questions ?? const [];
    return index < qs.length ? qs[index] : null;
  }

  bool get finished => session != null && index >= session!.questions.length;

  SaveOutcome<PracticeAnswerView>? get outcome {
    final q = question;
    return q == null ? null : outcomes[q.id];
  }

  /// Lamps with wrong answers in this session, to mark on the map (§19.5 Q41).
  List<String> get weakTopicIds => {
    for (final o in outcomes.values)
      if (o is Graded<PracticeAnswerView>) ...o.value.weakTopicIds,
    for (final o in outcomes.values)
      if (o is Graded<PracticeAnswerView> && !o.value.graded.correct)
        o.value.graded.topicId,
  }.toList();

  int get correctCount => outcomes.values
      .whereType<Graded<PracticeAnswerView>>()
      .where((o) => o.value.graded.correct)
      .length;

  int get savedOfflineCount =>
      outcomes.values.whereType<SavedOffline<PracticeAnswerView>>().length;

  PracticeState copyWith({
    PracticeSessionView? session,
    int? index,
    Map<String, List<String>>? chosen,
    Map<String, SaveOutcome<PracticeAnswerView>>? outcomes,
    UsageView? usage,
    bool? loading,
    bool? busy,
    String? Function()? error,
    bool? limitReached,
    bool? showLimitSheet,
  }) => PracticeState(
    session: session ?? this.session,
    index: index ?? this.index,
    chosen: chosen ?? this.chosen,
    outcomes: outcomes ?? this.outcomes,
    usage: usage ?? this.usage,
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    error: error == null ? this.error : error(),
    limitReached: limitReached ?? this.limitReached,
    showLimitSheet: showLimitSheet ?? this.showLimitSheet,
  );
}

/// One question per screen, instant feedback (§10.6, INT-002-S06/S07).
class PracticeController extends Notifier<PracticeState> {
  PracticeController(this.request);

  final PracticeRequest request;
  DateTime? _shownAt;

  DateTime _now() => ref.read(clockProvider)();

  @override
  PracticeState build() => const PracticeState();

  Future<void> start() async {
    state = const PracticeState();
    try {
      final session = await ref
          .read(practiceRepositoryProvider)
          .startSession(
            mode: request.mode,
            examCode: request.examCode,
            topicId: request.topicId,
            subjectCode: request.subjectCode,
            drillId: request.drillId,
            idempotencyKey: ref.read(clientActionIdProvider)(),
          );
      _shownAt = _now();
      state = PracticeState(
        session: session,
        usage: session.usage,
        loading: false,
        limitReached: session.questions.isEmpty && session.usage.limitReached,
      );
    } on HmApiException catch (e) {
      if (e.code == 'PRACTICE_DAILY_LIMIT') {
        _limit(null);
        return;
      }
      state = PracticeState(loading: false, error: e.message);
    }
  }

  void choose(String optionId) {
    final q = state.question;
    if (q == null || state.outcomes.containsKey(q.id) || state.busy) return;
    state = state.copyWith(
      chosen: {
        ...state.chosen,
        q.id: [optionId],
      },
    );
  }

  Future<void> check() async {
    final q = state.question;
    final session = state.session;
    if (q == null || session == null || state.busy) return;
    if (state.outcomes.containsKey(q.id)) return;
    state = state.copyWith(busy: true);
    final started = _shownAt ?? _now();
    final ms = _now().difference(started).inMilliseconds.clamp(0, 3600000);
    final outcome = await ref
        .read(studyRecorderProvider)
        .practiceAnswer(
          sessionId: session.sessionId,
          mode: session.mode,
          question: q,
          chosen: state.chosen[q.id] ?? const [],
          timeMs: ms,
          lastUsage: state.usage,
          sheetShownOnIstDay: ref.read(limitSheetShownDayProvider),
        );
    if (!ref.mounted) return;
    switch (outcome) {
      case Graded(:final value):
        state = state.copyWith(
          busy: false,
          usage: value.usage,
          outcomes: {...state.outcomes, q.id: outcome},
        );
      case LimitReached(:final showSheet):
        state = state.copyWith(
          busy: false,
          limitReached: true,
          showLimitSheet: showSheet,
        );
      case SavedOffline() || NotSaved():
        state = state.copyWith(
          busy: false,
          outcomes: {...state.outcomes, q.id: outcome},
        );
    }
  }

  void next() {
    if (state.outcome == null) return;
    _shownAt = _now();
    state = state.copyWith(index: state.index + 1);
  }

  void _limit(UsageView? usage) {
    state = PracticeState(
      loading: false,
      usage: usage,
      limitReached: true,
      showLimitSheet: shouldShowLimitSheet(
        lastUsage: usage,
        shownOnIstDay: ref.read(limitSheetShownDayProvider),
      ),
    );
  }

  /// The screen showed the sheet: never again today on this phone (§13).
  void limitSheetShown() {
    ref
        .read(limitSheetShownDayProvider.notifier)
        .mark(state.usage?.istDay ?? 'today');
    state = state.copyWith(showLimitSheet: false);
  }
}

final practiceControllerProvider = NotifierProvider.autoDispose
    .family<PracticeController, PracticeState, PracticeRequest>(
      PracticeController.new,
    );
