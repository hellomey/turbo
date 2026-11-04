import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';
import 'package:hm_features/hm_features.dart';

import 'fakes.dart';

const mockFull = MockItem(
  id: 'm-1',
  title: 'Group 4 Full Mock 1',
  examCode: 'tnpsc-group-4',
  paperCode: 'g4-paper-1',
  kind: MockKindView.full,
  questionCount: 200,
  durationMinutes: 180,
  negativeMarking: false,
  free: true,
  locked: false,
);

const mockPro = MockItem(
  id: 'm-2',
  title: 'Group 4 Full Mock 2',
  examCode: 'tnpsc-group-4',
  paperCode: 'g4-paper-1',
  kind: MockKindView.full,
  questionCount: 200,
  durationMinutes: 180,
  negativeMarking: true,
  free: false,
  locked: true,
);

const mockList = MockListView(
  items: [mockFull, mockPro],
  freeFullMocksUsed: 0,
  freeFullMocksLimit: 1,
);

/// Opens at fixedNow - 10 min (10:00 IST on a Sunday-like slot); late join until +20 min.
final sundayMock = StateMockCardView(
  mockId: 'sms-1',
  title: 'TNPSC State Mock, 1st Sunday',
  examCode: 'tnpsc-group-4',
  paperCode: 'g4-paper-1',
  questionCount: 200,
  durationMinutes: 180,
  negativeMarking: false,
  opensAt: fixedNow.subtract(const Duration(minutes: 10)),
  lateJoinUntil: fixedNow.add(const Duration(minutes: 20)),
  closesAt: fixedNow.add(const Duration(hours: 13)),
  rankPublishAt: fixedNow.add(const Duration(hours: 10)),
);

MockSession sampleSession({
  AnswerMode mode = AnswerMode.cbt,
  Map<String, SessionAnswer> answers = const {},
  AttemptStatus status = AttemptStatus.inProgress,
}) => MockSession(
  attemptId: 'a-1',
  mockId: 'm-1',
  title: 'Group 4 Full Mock 1',
  mode: mode,
  status: status,
  // Server clock is 5 s ahead of the phone.
  serverNow: fixedNow.add(const Duration(seconds: 5)),
  deadlineAt: fixedNow.add(const Duration(minutes: 90)),
  sections: const [
    MockSection(code: 'gs', name: 'General Studies', questionIds: ['q1', 'q2']),
    MockSection(code: 'apt', name: 'Aptitude', questionIds: ['q3']),
  ],
  questions: const [
    ExamQuestion(
      id: 'q1',
      stem: 'Which article of the Constitution abolishes untouchability?',
      options: [
        ExamOption(id: 'o1', text: 'Article 14'),
        ExamOption(id: 'o2', text: 'Article 17'),
        ExamOption(id: 'o3', text: 'Article 21'),
        ExamOption(id: 'o4', text: 'Article 32'),
      ],
    ),
    ExamQuestion(
      id: 'q2',
      stem: 'The Sangam age is known for which kind of literature?',
      options: [
        ExamOption(id: 'o1', text: 'Poetry'),
        ExamOption(id: 'o2', text: 'Drama'),
        ExamOption(id: 'o3', text: 'Plays'),
        ExamOption(id: 'o4', text: 'None of these'),
      ],
    ),
    ExamQuestion(
      id: 'q3',
      stem: 'What is 15% of 240?',
      options: [
        ExamOption(id: 'o1', text: '24'),
        ExamOption(id: 'o2', text: '36'),
        ExamOption(id: 'o3', text: '40'),
        ExamOption(id: 'o4', text: '48'),
      ],
    ),
  ],
  answers: answers,
  ranked: true,
);

ReportView sampleReport({bool locked = true}) => ReportView(
  attemptId: 'a-1',
  scoreDisplay: '1.5',
  maxScoreDisplay: '3',
  correct: 1,
  wrong: 1,
  unanswered: 1,
  sections: const [
    SectionScore(
      name: 'General Studies',
      correct: 1,
      wrong: 1,
      unanswered: 0,
      score: '1',
      maxScore: '2',
    ),
    SectionScore(
      name: 'Aptitude',
      correct: 0,
      wrong: 0,
      unanswered: 1,
      score: '0',
      maxScore: '1',
    ),
  ],
  mistakes: locked
      ? const []
      : const [
          MistakeView(
            questionId: 'q2',
            explanation: 'Sangam literature is mostly poetry.',
            topicId: 't-3',
            whyChosenIsWrong: 'Drama came much later.',
          ),
        ],
  weakTopicIds: const ['t-3'],
  ranked: true,
  fullReportLocked: locked,
);

class FakeExamHallRepository implements ExamHallRepository {
  final calls = <String>[];
  AnswerMode? mode = AnswerMode.cbt;
  MockSession session = sampleSession();
  HmApiException? startError;
  HmApiException? saveError;
  HmApiException? submitError;
  ReportView reportView = sampleReport();
  final saved = <List<LocalMockAnswer>>[];
  StateMockCardView? sunday = sundayMock;

  @override
  Future<MockListView> mocks(String examCode) async => mockList;

  @override
  Future<StateMockCardView?> stateMock(String examCode) async => sunday;

  @override
  Future<AnswerMode?> answerMode(String examCode, String paperCode) async {
    calls.add('answerMode:$paperCode');
    return mode;
  }

  @override
  Future<MockSession> start(
    String mockId,
    AnswerMode mode, {
    required String idempotencyKey,
  }) async {
    calls.add('start:$mockId:${mode.name}');
    final e = startError;
    if (e != null) throw e;
    return session;
  }

  @override
  Future<MockSession> attempt(String attemptId) async {
    calls.add('attempt:$attemptId');
    return session;
  }

  @override
  Future<SaveAck> saveAnswers(
    String attemptId,
    List<LocalMockAnswer> answers, {
    required String idempotencyKey,
  }) async {
    calls.add('save:${answers.length}');
    final e = saveError;
    if (e != null) throw e;
    saved.add(answers);
    return SaveAck(
      serverNow: fixedNow.add(const Duration(seconds: 5)),
      ignoredAfterDeadline: 0,
    );
  }

  @override
  Future<ReportView> submit(
    String attemptId, {
    required String idempotencyKey,
  }) async {
    calls.add('submit:$idempotencyKey');
    final e = submitError;
    if (e != null) throw e;
    return reportView;
  }

  @override
  Future<ReportView> report(String attemptId) async {
    calls.add('report:$attemptId');
    return reportView;
  }
}

class FakeNetworkSource implements NetworkSource {
  FakeNetworkSource({this.online = true});
  bool online;

  @override
  Future<NetworkState> current() async =>
      NetworkState(online: online, wifi: online);

  @override
  Stream<NetworkState> changes() => const Stream.empty();
}

class ExamHallFakes {
  ExamHallFakes({FakeExamHallRepository? repo, MockAnswerStore? store})
    : repo = repo ?? FakeExamHallRepository(),
      store = store ?? MemoryMockAnswerStore();

  final FakeExamHallRepository repo;
  final MockAnswerStore store;
  final network = FakeNetworkSource();

  List<Override> get overrides => [
    examHallRepositoryProvider.overrideWithValue(repo),
    mockAnswerStoreProvider.overrideWithValue(store),
    networkSourceProvider.overrideWithValue(network),
    idempotencyKeyFactoryProvider.overrideWithValue(() => 'key'),
  ];

  Harness harness({bool lite = false}) => Harness(lite: lite, extra: overrides);
}
