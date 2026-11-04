import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/practice_models.dart';
import '../domain/study_rules.dart';

/// Mastery + practice routes (BOLT-0009, BOLT-0010). JSON is mapped by hand into view models because the
/// generated models treat some nullable fields as required (BOLT-0016 follow-up); the contract is the same.
abstract interface class PracticeRepository {
  Future<PracticeSessionView> startSession({
    required StudyMode mode,
    required String examCode,
    String? topicId,
    String? subjectCode,
    String? drillId,
    int size,
    required String idempotencyKey,
  });

  Future<PracticeAnswerView> answer(
    String sessionId, {
    required String clientActionId,
    required QuestionView question,
    required List<String> chosen,
    required int timeMs,
  });

  Future<UsageView> usage();
  Future<MistakesView> mistakes();

  Future<CheckView> startCheck(
    String topicId,
    CheckKind kind, {
    required String idempotencyKey,
  });

  Future<CheckResultView> submitCheck(
    String checkId,
    List<Map<String, Object>> answers, {
    required String idempotencyKey,
  });

  Future<RelightQueueView> relightQueue();

  /// `nextCheck` per topic id from `GET /v1/me/topic-states`.
  Future<Map<String, NextCheck>> nextChecks(String examCode);

  Future<void> report(QuestionView question, String reason);
}

class ApiPracticeRepository implements PracticeRepository {
  ApiPracticeRepository(this._api);
  final HmApi _api;

  @override
  Future<PracticeSessionView> startSession({
    required StudyMode mode,
    required String examCode,
    String? topicId,
    String? subjectCode,
    String? drillId,
    int size = 10,
    required String idempotencyKey,
  }) async => practiceSessionFromJson(
    await _api.startPracticeSession({
      'mode': mode.name,
      'examCode': examCode,
      'topicId': ?topicId,
      'subjectCode': ?subjectCode,
      'drillId': ?drillId,
      'size': size,
    }, idempotencyKey: idempotencyKey),
  );

  @override
  Future<PracticeAnswerView> answer(
    String sessionId, {
    required String clientActionId,
    required QuestionView question,
    required List<String> chosen,
    required int timeMs,
  }) async => practiceAnswerFromJson(
    await _api.answerPracticeQuestion(sessionId, {
      'clientActionId': clientActionId,
      'questionId': question.id,
      'questionVersion': question.version,
      'chosenOptionIds': chosen,
      'timeMs': timeMs,
    }, idempotencyKey: clientActionId),
  );

  @override
  Future<UsageView> usage() async =>
      usageFromJson(await _api.getPracticeUsage());

  @override
  Future<MistakesView> mistakes() async {
    final page = await _api.listMyMistakes();
    final drills = await _api.listMyDrills();
    return MistakesView(
      mistakes: [for (final m in asJsonList(page['items'])) mistakeFromJson(m)],
      nextCursor: page['nextCursor'] as String?,
      drills: drillsFromJson(drills),
    );
  }

  @override
  Future<CheckView> startCheck(
    String topicId,
    CheckKind kind, {
    required String idempotencyKey,
  }) async => checkFromJson(
    await _api.startTopicCheck(
      topicId,
      kind: kind.name,
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<CheckResultView> submitCheck(
    String checkId,
    List<Map<String, Object>> answers, {
    required String idempotencyKey,
  }) async => checkResultFromJson(
    await _api.submitTopicCheck(
      checkId,
      answers,
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<RelightQueueView> relightQueue() async =>
      relightQueueFromJson(await _api.getRelightQueue());

  @override
  Future<Map<String, NextCheck>> nextChecks(String examCode) async =>
      nextChecksFromJson(await _api.listMyTopicStates(examCode));

  @override
  Future<void> report(QuestionView question, String reason) =>
      _api.reportQuestion(
        question.id,
        questionVersion: question.version,
        reason: reason,
      );
}

// ------------------------------------------------------------------ JSON → views (contract shapes)

Map<String, dynamic> _obj(Object? v) =>
    v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};

List<String> _strings(Object? v) => [
  for (final s in (v as List? ?? const [])) '$s',
];

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

SourceView sourceFromJson(Object? json) {
  final s = _obj(json);
  final pyq = s['pyq'] is Map ? _obj(s['pyq']) : null;
  return SourceView(
    citation: '${s['citation'] ?? ''}',
    url: s['url'] as String?,
    pyqExamCode: pyq?['examCode'] as String?,
    pyqYear: pyq?['year'] as int?,
    pyqNumber: pyq?['questionNumber'] as int?,
  );
}

QuestionView questionFromJson(Object? json) {
  final q = _obj(json);
  return QuestionView(
    id: '${q['id']}',
    version: q['version'] as int? ?? 1,
    topicId: '${q['topicId']}',
    stem: '${q['stem'] ?? ''}',
    options: [
      for (final o in asJsonList(q['options']))
        OptionView(id: '${o['id']}', text: '${o['text']}'),
    ],
    source: sourceFromJson(q['source']),
    difficulty: q['difficulty'] as int? ?? 1,
    tamil: q['language'] == 'ta',
    affectedNote: q['affectedNote'] as String?,
  );
}

GradedView gradedFromJson(Object? json) {
  final g = _obj(json);
  return GradedView(
    questionId: '${g['questionId']}',
    correct: g['correct'] == true,
    correctOptionIds: _strings(g['correctOptionIds']),
    chosenOptionIds: _strings(g['chosenOptionIds']),
    explanation: '${g['explanationMarkdown'] ?? ''}',
    whyChosenIsWrong: g['whyChosenIsWrong'] as String?,
    topicId: '${g['topicId']}',
    source: sourceFromJson(g['source']),
  );
}

UsageView usageFromJson(Object? json) {
  final u = _obj(json);
  return UsageView(
    istDay: '${u['istDay'] ?? ''}',
    used: u['used'] as int? ?? 0,
    limit: u['limit'] as int?,
    limitSheetShownToday: u['limitSheetShownToday'] == true,
  );
}

StudyMode _mode(Object? v) => StudyMode.values.firstWhere(
  (m) => m.name == v,
  orElse: () => StudyMode.practice,
);

PracticeSessionView practiceSessionFromJson(Map<String, dynamic> json) =>
    PracticeSessionView(
      sessionId: '${json['sessionId']}',
      mode: _mode(json['mode']),
      questions: [
        for (final q in asJsonList(json['questions'])) questionFromJson(q),
      ],
      usage: usageFromJson(json['usage']),
    );

PracticeAnswerView practiceAnswerFromJson(Map<String, dynamic> json) =>
    PracticeAnswerView(
      graded: gradedFromJson(json['graded']),
      usage: usageFromJson(json['usage']),
      weakTopicIds: _strings(json['weakTopicIds']),
    );

PracticeMistakeView mistakeFromJson(Map<String, dynamic> m) =>
    PracticeMistakeView(
      questionId: '${m['questionId']}',
      topicId: '${m['topicId']}',
      stem: '${m['stem'] ?? ''}',
      wrongCount: m['wrongCount'] as int? ?? 1,
      graded: gradedFromJson(m['graded']),
    );

DrillsView drillsFromJson(Map<String, dynamic> json) => DrillsView(
  locked: json['locked'] == true,
  items: [
    for (final d in asJsonList(json['items']))
      DrillView(
        id: '${d['id']}',
        topicId: '${d['topicId']}',
        reason: '${d['reason'] ?? ''}',
        questionCount: d['questionCount'] as int? ?? 1,
        open: d['status'] == 'open',
      ),
  ],
);

CheckKind checkKindOf(Object? v) => CheckKind.values.firstWhere(
  (k) => k.name == v,
  orElse: () => CheckKind.lit,
);

CheckView checkFromJson(Map<String, dynamic> json) => CheckView(
  checkId: '${json['checkId']}',
  topicId: '${json['topicId']}',
  kind: checkKindOf(json['kind']),
  questions: [
    for (final q in asJsonList(json['questions'])) questionFromJson(q),
  ],
  passMark: json['passMark'] as int? ?? 1,
  deadlineAt: _date(json['deadlineAt']),
  serverNow: _date(json['serverNow']),
);

/// Contract `LampRing` → design lamp.
HmLampState lampFromRing(Object? json) {
  final r = _obj(json);
  return HmLampState(
    lit: r['lit'] == true,
    steadyLevel: (r['steadyLevel'] as int? ?? 0).clamp(
      0,
      HmLampState.maxSteady,
    ),
    gold: r['gold'] == true,
    dim: switch (r['dim']) {
      'dimming' => HmLampDim.dimming,
      'dim' => HmLampDim.dim,
      _ => HmLampDim.bright,
    },
  );
}

CheckResultView checkResultFromJson(Map<String, dynamic> json) {
  final rank = json['rankUp'] is Map ? _obj(json['rankUp']) : null;
  return CheckResultView(
    kind: checkKindOf(json['kind']),
    passed: json['passed'] == true,
    correct: json['correct'] as int? ?? 0,
    total: json['total'] as int? ?? 0,
    graded: [for (final g in asJsonList(json['graded'])) gradedFromJson(g)],
    lamp: lampFromRing(_obj(json['topicState'])['ring']),
    lateAnswersIgnored: json['lateAnswersIgnored'] as int? ?? 0,
    rankUp: rank == null
        ? null
        : RankUpView(title: '${rank['title']}', note: '${rank['note']}'),
  );
}

RelightQueueView relightQueueFromJson(Map<String, dynamic> json) =>
    RelightQueueView(
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      items: [
        for (final i in asJsonList(json['items']))
          RelightItemView(
            topicId: '${i['topicId']}',
            topicName: '${i['topicName']}',
            dim: i['dim'] == 'dim' ? HmLampDim.dim : HmLampDim.dimming,
            minutes: i['minutes'] as int? ?? 2,
          ),
      ],
    );

PyqFacetsView pyqFacetsFromJson(Map<String, dynamic> json) => PyqFacetsView(
  years: [
    for (final y in asJsonList(json['years']))
      PyqYearView(
        year: y['year'] as int? ?? 0,
        count: y['count'] as int? ?? 0,
        locked: y['locked'] == true,
      ),
  ]..sort((a, b) => b.year.compareTo(a.year)),
  subjects: [
    for (final s in asJsonList(json['subjects']))
      PyqSubjectView(
        code: '${s['code']}',
        name: '${s['name']}',
        count: s['count'] as int? ?? 0,
      ),
  ],
);

PyqPageView pyqPageFromJson(Map<String, dynamic> json) => PyqPageView(
  nextCursor: json['nextCursor'] as String?,
  items: [
    for (final i in asJsonList(json['items']))
      PyqItemView(
        question: questionFromJson(i['question']),
        locked: i['locked'] == true,
      ),
  ],
);

Map<String, NextCheck> nextChecksFromJson(Map<String, dynamic> json) => {
  for (final t in asJsonList(json['items']))
    '${t['topicId']}': nextCheckOf(t['nextCheck']),
};
