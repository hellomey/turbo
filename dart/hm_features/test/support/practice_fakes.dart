import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'fakes.dart';

/// Fakes for the BOLT-0017 study screens.

const _src = SourceView(
  citation: 'SEED - verify. Class 10 Social Science.',
  pyqExamCode: 'tnpsc-group-4',
  pyqYear: 2024,
  pyqNumber: 57,
);

QuestionView sampleQuestion(String id, {bool tamil = false}) => QuestionView(
  id: id,
  version: 1,
  topicId: 't-1',
  stem: tamil
      ? 'இந்திய அரசியலமைப்பு எப்போது நடைமுறைக்கு வந்தது?'
      : 'When did the Constitution of India come into force?',
  options: const [
    OptionView(id: 'a', text: '26 January 1950'),
    OptionView(id: 'b', text: '15 August 1947'),
    OptionView(id: 'c', text: '26 November 1949'),
    OptionView(id: 'd', text: '2 October 1950'),
  ],
  source: _src,
  tamil: tamil,
);

UsageView sampleUsage({int used = 3, int? limit = 30, bool shown = false}) =>
    UsageView(
      istDay: '2026-10-20',
      used: used,
      limit: limit,
      limitSheetShownToday: shown,
    );

GradedView graded(String qid, {required bool correct}) => GradedView(
  questionId: qid,
  correct: correct,
  correctOptionIds: const ['a'],
  chosenOptionIds: [correct ? 'a' : 'b'],
  explanation: 'It came into force on 26 January 1950.',
  whyChosenIsWrong: correct ? null : '15 August 1947 is Independence Day.',
  topicId: 't-1',
  source: _src,
);

const sampleRelightQueue = RelightQueueView(
  totalMinutes: 7,
  items: [
    RelightItemView(
      topicId: 't-1',
      topicName: 'Constitution',
      dim: HmLampDim.dimming,
      minutes: 3,
    ),
    RelightItemView(
      topicId: 't-3',
      topicName: 'Sangam Age',
      dim: HmLampDim.dim,
      minutes: 4,
    ),
  ],
);

final sampleMistakes = PracticeMistakesFixture.view;

abstract final class PracticeMistakesFixture {
  static final view = MistakesView(
    drills: const DrillsView(items: [], locked: true),
    mistakes: [
      PracticeMistakeView(
        questionId: 'q1',
        topicId: 't-1',
        stem: 'When did the Constitution of India come into force?',
        wrongCount: 2,
        graded: graded('q1', correct: false),
      ),
    ],
  );
}

const pyqFacets = PyqFacetsView(
  years: [
    PyqYearView(year: 2024, count: 200, locked: false),
    PyqYearView(year: 2023, count: 200, locked: false),
    PyqYearView(year: 2022, count: 200, locked: true),
  ],
  subjects: [
    PyqSubjectView(code: 'polity', name: 'Indian Polity', count: 120),
    PyqSubjectView(code: 'history', name: 'History', count: 80),
  ],
);

final pyqPage = PyqPageView(
  items: [
    PyqItemView(question: sampleQuestion('q1'), locked: false),
    PyqItemView(question: sampleQuestion('q9', tamil: true), locked: false),
  ],
);

class FakePracticeRepository implements PracticeRepository {
  final calls = <String>[];
  HmApiException? answerError;
  HmApiException? checkError;
  HmApiException? startError;
  bool answerCorrect = true;
  UsageView sessionUsage = sampleUsage();
  int questionCount = 2;
  CheckKind? lastCheckKind;

  @override
  Future<PracticeSessionView> startSession({
    required StudyMode mode,
    required String examCode,
    String? topicId,
    String? subjectCode,
    String? drillId,
    int size = 10,
    required String idempotencyKey,
  }) async {
    calls.add('start:${mode.name}');
    final e = startError;
    if (e != null) throw e;
    return PracticeSessionView(
      sessionId: 's-1',
      mode: mode,
      questions: [
        for (var i = 1; i <= questionCount; i++) sampleQuestion('q$i'),
      ],
      usage: sessionUsage,
    );
  }

  @override
  Future<PracticeAnswerView> answer(
    String sessionId, {
    required String clientActionId,
    required QuestionView question,
    required List<String> chosen,
    required int timeMs,
  }) async {
    calls.add('answer:${question.id}:$clientActionId');
    final e = answerError;
    if (e != null) throw e;
    return PracticeAnswerView(
      graded: graded(question.id, correct: answerCorrect),
      usage: sampleUsage(used: sessionUsage.used + 1),
      weakTopicIds: answerCorrect ? const [] : const ['t-1'],
    );
  }

  @override
  Future<UsageView> usage() async => sessionUsage;

  @override
  Future<MistakesView> mistakes() async => sampleMistakes;

  @override
  Future<CheckView> startCheck(
    String topicId,
    CheckKind kind, {
    required String idempotencyKey,
  }) async {
    calls.add('startCheck:${kind.name}');
    lastCheckKind = kind;
    final e = checkError;
    if (e != null) throw e;
    return CheckView(
      checkId: 'c-1',
      topicId: topicId,
      kind: kind,
      questions: [for (var i = 1; i <= 3; i++) sampleQuestion('q$i')],
      passMark: 2,
      deadlineAt: kind == CheckKind.gold
          ? fixedNow.add(const Duration(minutes: 10))
          : null,
      serverNow: fixedNow,
    );
  }

  HmApiException? submitError;

  @override
  Future<CheckResultView> submitCheck(
    String checkId,
    List<Map<String, Object>> answers, {
    required String idempotencyKey,
  }) async {
    calls.add('submitCheck:$idempotencyKey');
    final e = submitError;
    if (e != null) throw e;
    return CheckResultView(
      kind: lastCheckKind ?? CheckKind.lit,
      passed: true,
      correct: 3,
      total: 3,
      graded: const [],
      lamp: const HmLampState(lit: true),
      rankUp: rankUp,
    );
  }

  /// Rank reported with the next check result (§5.2).
  RankUpView? rankUp;

  @override
  Future<RelightQueueView> relightQueue() async => sampleRelightQueue;

  Map<String, NextCheck> next = const {'t-1': NextCheck.recall};

  @override
  Future<Map<String, NextCheck>> nextChecks(String examCode) async => next;

  @override
  Future<void> report(QuestionView question, String reason) async =>
      calls.add('report:${question.id}');
}

class FakePyqRepository implements PyqRepository {
  final searches = <PyqFilter>[];

  @override
  Future<PyqFacetsView> facets(String examCode) async => pyqFacets;

  @override
  Future<PyqPageView> search(
    String examCode,
    PyqFilter filter, {
    String? cursor,
  }) async {
    searches.add(filter);
    return pyqPage;
  }
}

/// Wires the study fakes and an in-memory outbox into a [Harness].
class StudyFakes {
  final repo = FakePracticeRepository();
  final pyq = FakePyqRepository();
  final outboxStore = MemoryOutboxStore();
  var nudges = 0;
  var _id = 0;

  late final outbox = OutboxRepository(
    outbox: outboxStore,
    topicStates: MemoryTopicStateStore(),
    clock: () => fixedNow,
  );

  List<Override> get overrides => [
    practiceRepositoryProvider.overrideWithValue(repo),
    pyqRepositoryProvider.overrideWithValue(pyq),
    outboxRepositoryProvider.overrideWithValue(outbox),
    studySyncNudgeProvider.overrideWithValue(() async => nudges++),
    clientActionIdProvider.overrideWithValue(() => 'id-${++_id}'),
  ];

  Harness harness({bool lite = false}) => Harness(lite: lite, extra: overrides);
}
