import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';

import '../domain/exam_hall_models.dart';

/// What the server said after a batch of answers was saved.
class SaveAck {
  const SaveAck({required this.serverNow, required this.ignoredAfterDeadline});
  final DateTime serverNow;
  final int ignoredAfterDeadline;
}

/// Exam Hall data (§10.6, INT-002-S10/S11) over the exam-hall routes (BOLT-0011).
abstract interface class ExamHallRepository {
  Future<MockListView> mocks(String examCode);

  /// Null when no State Mock Sunday is scheduled for this exam.
  Future<StateMockCardView?> stateMock(String examCode);

  /// The paper's answer mode (`GET /v1/exams/{code}/structure`); null for a paper type not built yet.
  Future<AnswerMode?> answerMode(String examCode, String paperCode);

  Future<MockSession> start(
    String mockId,
    AnswerMode mode, {
    required String idempotencyKey,
  });

  Future<MockSession> attempt(String attemptId);

  Future<SaveAck> saveAnswers(
    String attemptId,
    List<LocalMockAnswer> answers, {
    required String idempotencyKey,
  });

  Future<ReportView> submit(String attemptId, {required String idempotencyKey});

  Future<ReportView> report(String attemptId);
}

class ApiExamHallRepository implements ExamHallRepository {
  ApiExamHallRepository(this._api);

  final HmApi _api;

  static const _unknown = HmApiException(
    HmApiException.unknownError,
    HmApiException.unknownMessage,
  );

  /// Generated `fromJson` returns null for a non-object and throws on a wrong-typed field.
  static T _parse<T>(T? Function() read) {
    try {
      return read() ?? (throw _unknown);
    } on FormatException {
      throw _unknown;
    } on TypeError {
      throw _unknown;
    }
  }

  @override
  Future<MockListView> mocks(String examCode) async {
    final json = await _api.listMocks(examCode);
    return mockListFromApi(_parse(() => api.MockList.fromJson(json)));
  }

  @override
  Future<StateMockCardView?> stateMock(String examCode) async {
    final Map<String, dynamic> json;
    try {
      json = await _api.getStateMockSunday(examCode);
    } on HmApiException catch (e) {
      if (e.code == 'MOCK_NOT_FOUND' || e.statusCode == 404) return null;
      rethrow;
    }
    return stateMockFromApi(_parse(() => api.StateMockInfo.fromJson(json)));
  }

  @override
  Future<AnswerMode?> answerMode(String examCode, String paperCode) async {
    final json = await _api.getExamStructure(examCode);
    final structure = _parse(() => api.ExamStructure.fromJson(json));
    for (final stage in structure.stages) {
      for (final paper in stage.papers) {
        if (paper.code == paperCode) {
          return paper.type == api.PaperType.descriptive
              ? null
              : answerModeFromPaper(paper.mode.value);
        }
      }
    }
    return null;
  }

  @override
  Future<MockSession> start(
    String mockId,
    AnswerMode mode, {
    required String idempotencyKey,
  }) async {
    final json = await _api.startMockAttempt(
      mockId,
      mode: mode.name,
      idempotencyKey: idempotencyKey,
    );
    return sessionFromApi(_parse(() => api.MockAttemptState.fromJson(json)));
  }

  @override
  Future<MockSession> attempt(String attemptId) async {
    final json = await _api.getMockAttempt(attemptId);
    return sessionFromApi(_parse(() => api.MockAttemptState.fromJson(json)));
  }

  @override
  Future<SaveAck> saveAnswers(
    String attemptId,
    List<LocalMockAnswer> answers, {
    required String idempotencyKey,
  }) async {
    final json = await _api.saveMockAnswers(attemptId, {
      'answers': [
        for (final a in answers)
          <String, Object>{
            'questionId': a.questionId,
            'chosenOptionIds': a.chosenOptionIds,
            'markedForReview': a.markedForReview,
            'clientAt': a.clientAt.toUtc().toIso8601String(),
          },
      ],
    }, idempotencyKey: idempotencyKey);
    final saved = _parse(() => api.MockAnswersSaved.fromJson(json));
    return SaveAck(
      serverNow: saved.serverNow,
      ignoredAfterDeadline: saved.ignoredAfterDeadline,
    );
  }

  @override
  Future<ReportView> submit(
    String attemptId, {
    required String idempotencyKey,
  }) async {
    final json = await _api.submitMockAttempt(
      attemptId,
      idempotencyKey: idempotencyKey,
    );
    return reportFromApi(_parse(() => api.MockReport.fromJson(json)));
  }

  @override
  Future<ReportView> report(String attemptId) async {
    final json = await _api.getMockReport(attemptId);
    return reportFromApi(_parse(() => api.MockReport.fromJson(json)));
  }
}

MockKindView _kind(api.MockKind kind) => switch (kind.value) {
  'sectional' => MockKindView.sectional,
  'state_mock_sunday' => MockKindView.stateMockSunday,
  _ => MockKindView.full,
};

MockItem mockItemFromApi(api.MockSummary m) => MockItem(
  id: m.id,
  title: m.title,
  examCode: m.examCode,
  paperCode: m.paperCode,
  kind: _kind(m.kind),
  questionCount: m.questionCount,
  durationMinutes: m.durationMinutes,
  negativeMarking: m.negativeMarking,
  free: m.free,
  locked: m.locked,
  opensAt: m.opensAt,
  closesAt: m.closesAt,
  lastAttemptId: m.myLastAttemptId,
);

MockListView mockListFromApi(api.MockList list) => MockListView(
  items: [for (final m in list.items) mockItemFromApi(m)],
  freeFullMocksUsed: list.allowance.freeFullMocksUsed,
  freeFullMocksLimit: list.allowance.freeFullMocksLimit,
);

StateMockCardView stateMockFromApi(api.StateMockInfo info) {
  final m = info.mock;
  return StateMockCardView(
    mockId: m.id,
    title: m.title,
    examCode: m.examCode,
    paperCode: m.paperCode,
    questionCount: m.questionCount,
    durationMinutes: m.durationMinutes,
    negativeMarking: m.negativeMarking,
    opensAt: m.opensAt,
    lateJoinUntil: m.lateJoinUntil,
    closesAt: m.closesAt,
    rankPublishAt: info.rankPublishAt,
    lastAttemptId: m.myLastAttemptId,
  );
}

MockSession sessionFromApi(api.MockAttemptState s) => MockSession(
  attemptId: s.attemptId,
  mockId: s.mock.id,
  title: s.mock.title,
  mode: s.mode == api.MockMode.omr ? AnswerMode.omr : AnswerMode.cbt,
  status: switch (s.status.value) {
    'submitted' => AttemptStatus.submitted,
    'expired' => AttemptStatus.expired,
    _ => AttemptStatus.inProgress,
  },
  deadlineAt: s.deadlineAt,
  serverNow: s.serverNow,
  sections: [
    for (final sec in s.sections)
      MockSection(code: sec.code, name: sec.name, questionIds: sec.questionIds),
  ],
  questions: [
    for (final q in s.questions)
      ExamQuestion(
        id: q.id,
        stem: q.stem,
        options: [
          for (final o in q.options) ExamOption(id: o.id, text: o.text),
        ],
      ),
  ],
  answers: {
    for (final a in s.answers)
      a.questionId: SessionAnswer(
        chosen: a.chosenOptionIds,
        marked: a.markedForReview,
      ),
  },
  ranked: s.ranked,
);

String _marks(api.Marks m) => formatMarks(m.numerator, m.denominator);

ReportView reportFromApi(api.MockReport r) => ReportView(
  attemptId: r.attemptId,
  scoreDisplay: r.scoreDisplay,
  maxScoreDisplay: _marks(r.maxScore),
  correct: r.correct,
  wrong: r.wrong,
  unanswered: r.unanswered,
  sections: [
    for (final s in r.sections)
      SectionScore(
        name: s.name,
        correct: s.correct,
        wrong: s.wrong,
        unanswered: s.unanswered,
        score: _marks(s.score),
        maxScore: _marks(s.maxScore),
      ),
  ],
  mistakes: [
    for (final m in r.mistakes)
      MistakeView(
        questionId: m.questionId,
        explanation: m.explanationMarkdown,
        topicId: m.topicId,
        whyChosenIsWrong: m.whyChosenIsWrong,
      ),
  ],
  weakTopicIds: r.weakTopicIds,
  ranked: r.ranked,
  fullReportLocked: r.fullReportLocked,
);
