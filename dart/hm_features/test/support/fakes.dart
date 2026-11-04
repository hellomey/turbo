import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

/// 20 Oct 2026, 10:00 IST.
final fixedNow = DateTime.utc(2026, 10, 20, 4, 30);

ExamFit exam(int rank, {String? code}) => ExamFit(
  code: code ?? 'exam-$rank',
  name: 'Exam number $rank',
  conductingBody: rank.isEven ? 'TNPSC' : 'SSC',
  fitRank: rank,
  officialUrl: 'https://example.gov.in/exam-$rank',
  reasons: rank == 1 ? const ['Age relaxation applied for BC.'] : const [],
);

EligibilityView eligibility({int count = 7}) => EligibilityView(
  eligibleCount: count,
  eligible: [for (var i = 1; i <= count; i++) exam(i)],
  disclaimer: officialConfirmLine,
);

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({EligibilityView? result, this.eligibilityError})
    : result = result ?? eligibility();

  EligibilityView result;
  HmApiException? eligibilityError;
  HmApiException? verifyError;
  final calls = <String>[];
  ProfileDraft? checkedDraft;
  ProfileDraft? savedDraft;
  String? verifiedCode;
  Map<String, bool>? recordedConsents;
  String? recordedVersion;
  (String, List<String>)? savedExams;

  ConsentNoticeInfo notice = const ConsentNoticeInfo(
    version: 'v1',
    purposes: [
      ConsentPurposeInfo(
        purpose: 'core_service',
        required: true,
        title: 'Run my HeyMey account',
        description: 'Store my answers and progress so the app works.',
      ),
      ConsentPurposeInfo(
        purpose: 'offers_email',
        required: false,
        title: 'Email me about offers',
        description: 'At most one email a week.',
      ),
      ConsentPurposeInfo(
        purpose: 'product_research',
        required: false,
        title: 'Help improve HeyMey',
        description: 'Use my usage data, without my name, to improve the app.',
      ),
    ],
  );

  @override
  Future<EligibilityView> checkEligibility(ProfileDraft draft) async {
    calls.add('checkEligibility');
    checkedDraft = draft;
    final e = eligibilityError;
    if (e != null) throw e;
    return result;
  }

  @override
  Future<int> requestCode(String email) async {
    calls.add('requestCode:$email');
    return 60;
  }

  @override
  Future<bool> verifyCode(String email, String code) async {
    calls.add('verifyCode');
    verifiedCode = code;
    final e = verifyError;
    if (e != null) throw e;
    return true;
  }

  @override
  Future<ConsentNoticeInfo> consentNotice() async {
    calls.add('consentNotice');
    return notice;
  }

  @override
  Future<void> recordConsents(
    String noticeVersion,
    Map<String, bool> choices,
  ) async {
    calls.add('recordConsents');
    recordedVersion = noticeVersion;
    recordedConsents = choices;
  }

  @override
  Future<void> saveProfile(ProfileDraft draft) async {
    calls.add('saveProfile');
    savedDraft = draft;
  }

  @override
  Future<void> saveExams(
    String mainExamCode,
    List<String> otherExamCodes,
  ) async {
    calls.add('saveExams');
    savedExams = (mainExamCode, otherExamCodes);
  }
}

const sampleMap = StudyMapView(
  examCode: 'tnpsc-group-4',
  totalTopics: 3,
  subjects: [
    SubjectView(
      code: 'polity',
      name: 'Indian Polity',
      order: 1,
      topics: [
        TopicView(id: 't-1', name: 'Constitution', order: 1, hasLesson: true),
        TopicView(id: 't-2', name: 'Parliament', order: 2, hasLesson: false),
      ],
    ),
    SubjectView(
      code: 'history',
      name: 'History of Tamil Nadu',
      order: 2,
      topics: [
        TopicView(id: 't-3', name: 'Sangam Age', order: 1, hasLesson: true),
      ],
    ),
  ],
);

final sampleLesson = LessonView(
  id: 'l-1',
  topicId: 't-1',
  title: 'The Constitution',
  blocks: parseMarkdown(
    '# What it is\nThe **Constitution** is the main law of India.\n\n- It came into force in 1950.\n- It has a Preamble.',
  ),
  readingMinutes: 4,
  textbookRefs: const [
    TextbookRefView(
      book: 'Social Science',
      classLevel: 10,
      chapter: '3',
      pages: '41-45',
    ),
  ],
  citation: 'Tamil Nadu State Board, Class 10 Social Science (2024).',
);

class FakeStudyRepository implements StudyRepository {
  String? main = 'tnpsc-group-4';

  @override
  Future<String?> mainExamCode() async => main;

  @override
  Future<StudyMapView> studyMap(String examCode) async => sampleMap;

  @override
  Future<LessonView> lesson(String topicId) async => sampleLesson;
}

class FakeTts implements TtsPort {
  final spoken = <String>[];
  var stops = 0;
  void Function()? _done;

  @override
  set onDone(void Function()? callback) => _done = callback;

  void finish() => _done?.call();

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async => stops++;
}

class FakeLinks implements LinkOpener {
  final opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return true;
  }
}

class FakeShare implements ShareService {
  final shared = <String>[];

  @override
  Future<void> shareText(String text) async => shared.add(text);
}

class FakeProfileRepository implements ProfileRepository {
  MeInfo user = const MeInfo(
    id: 'u-1',
    email: 'priya@example.com',
    calmMode: false,
    roles: ['ASPIRANT'],
  );
  final calls = <String>[];

  @override
  Future<MeInfo> me() async => user;

  @override
  Future<MeInfo> setCalmMode(bool on) async {
    calls.add('calm:$on');
    return user = MeInfo(
      id: user.id,
      email: user.email,
      calmMode: on,
      roles: user.roles,
    );
  }

  @override
  Future<void> logout() async => calls.add('logout');

  @override
  Future<void> logoutAll() async => calls.add('logoutAll');

  ConsentNoticeInfo notice = FakeOnboardingRepository().notice;
  Map<String, bool> consents = {
    'core_service': true,
    'offers_email': false,
    'product_research': true,
  };
  (String, Map<String, bool>)? savedConsents;

  @override
  Future<ConsentNoticeInfo> consentNotice() async => notice;

  @override
  Future<Map<String, bool>> myConsents() async => consents;

  @override
  Future<void> saveConsents(
    String noticeVersion,
    Map<String, bool> choices,
  ) async {
    calls.add('saveConsents');
    savedConsents = (noticeVersion, choices);
    consents = choices;
  }

  @override
  Future<int> requestDeleteCode(String email) async {
    calls.add('deleteCode:$email');
    return 60;
  }

  @override
  Future<DateTime> deleteAccount(String code) async {
    calls.add('delete:$code');
    return DateTime.utc(2026, 10, 27, 4, 30);
  }
}

/// A ProviderScope + MaterialApp with fakes for every port. Returns the container for assertions.
class Harness {
  Harness({
    FakeOnboardingRepository? onboarding,
    FakeStudyRepository? study,
    FakeProfileRepository? profile,
    this.lite = false,
    DateTime? now,
    this.extra = const [],
  }) : onboarding = onboarding ?? FakeOnboardingRepository(),
       study = study ?? FakeStudyRepository(),
       profile = profile ?? FakeProfileRepository(),
       now = now ?? fixedNow;

  final FakeOnboardingRepository onboarding;
  final FakeStudyRepository study;
  final FakeProfileRepository profile;
  final tts = FakeTts();
  final links = FakeLinks();
  final share = FakeShare();
  final tokens = MemoryTokenStore();
  final bool lite;
  final DateTime now;

  /// Feature-specific overrides (e.g. the Exam Hall fakes).
  final List<Override> extra;

  List<Override> get overrides => [
    onboardingRepositoryProvider.overrideWithValue(onboarding),
    studyRepositoryProvider.overrideWithValue(study),
    profileRepositoryProvider.overrideWithValue(profile),
    ttsProvider.overrideWithValue(tts),
    linkOpenerProvider.overrideWithValue(links),
    shareServiceProvider.overrideWithValue(share),
    tokenStoreProvider.overrideWithValue(tokens),
    clockProvider.overrideWithValue(() => now),
    liteModeProvider.overrideWithValue(lite),
    ...extra,
  ];

  late final ProviderContainer container = ProviderContainer(
    overrides: overrides,
    retry: (_, _) => null,
  );

  Widget app(Widget home, {ThemeData? theme}) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: theme ?? HmTheme.dark(), home: home),
  );

  OnboardingController get controller =>
      container.read(onboardingControllerProvider.notifier);

  OnboardingState get state => container.read(onboardingControllerProvider);
}
