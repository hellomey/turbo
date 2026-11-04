import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';
import 'package:hm_features/hm_features.dart';

import 'fakes.dart';

/// BOLT-0018 fakes: plan, readiness, Sunday Reports, Exam Alerts, alert settings, push.

final todayDay = DateTime.utc(2026, 10, 20);

PlanItemView planItem(
  String id, {
  int dayOffset = 0,
  PlanItemKindView kind = PlanItemKindView.lesson,
  PlanItemStatusView status = PlanItemStatusView.pending,
  String title = 'Fundamental Rights',
  int minutes = 20,
}) => PlanItemView(
  id: id,
  day: todayDay.add(Duration(days: dayOffset)),
  kind: kind,
  examCode: 'tnpsc-group-4',
  topicId: 't-$id',
  title: title,
  minutes: minutes,
  status: status,
);

TodayView sampleToday({
  bool hasPlan = true,
  StretchView stretch = StretchView.normal,
  String? welcomeBack,
  PlanItemStatusView status = PlanItemStatusView.pending,
}) => TodayView(
  day: todayDay,
  rank: const RankView(
    level: 3,
    title: 'Village Scholar',
    xp: 340,
    xpForThisLevel: 300,
    xpForNextLevel: 400,
    note: 'From lamps and checks',
  ),
  todayCard: planItem('i1', status: status),
  relightCount: 4,
  relightMinutes: 8,
  pocketSessions: const [5, 10, 15],
  stretch: stretch,
  welcomeBack: welcomeBack,
  hasPlan: hasPlan,
);

List<PlanDayView> sampleDays() => [
  PlanDayView(
    day: todayDay,
    minutes: 45,
    items: [
      planItem('i1'),
      planItem(
        'i2',
        kind: PlanItemKindView.relight,
        title: 'Relight 3 Polity lamps',
        minutes: 10,
        status: PlanItemStatusView.done,
      ),
    ],
  ),
  PlanDayView(
    day: todayDay.add(const Duration(days: 1)),
    minutes: 30,
    items: [
      planItem(
        'i3',
        dayOffset: 1,
        kind: PlanItemKindView.practice,
        title: 'Practice: Indian Economy',
        status: PlanItemStatusView.skipped,
      ),
      planItem(
        'i4',
        dayOffset: 1,
        kind: PlanItemKindView.mock,
        title: 'Sectional mock: Aptitude',
        status: PlanItemStatusView.moved,
      ),
    ],
  ),
  PlanDayView(
    day: todayDay.add(const Duration(days: 2)),
    minutes: 0,
    items: const [],
  ),
];

class FakePlanRepository implements PlanRepository {
  TodayView todayView = sampleToday();
  List<PlanDayView> planDays = sampleDays();
  final calls = <String>[];
  Object? rebalanceError;

  @override
  Future<TodayView> today() async {
    calls.add('today');
    return todayView;
  }

  @override
  Future<List<PlanDayView>> days(DateTime from, DateTime to) async {
    calls.add('days:${isoDay(from)}..${isoDay(to)}');
    return planDays;
  }

  @override
  Future<void> rebalance({required String idempotencyKey}) async {
    calls.add('rebalance:$idempotencyKey');
    if (rebalanceError case final e?) throw e;
  }
}

ReadinessView sampleReadiness({bool noEvidence = false}) => ReadinessView(
  examCode: 'tnpsc-group-4',
  label: noEvidence ? ReadinessLabelView.notYet : ReadinessLabelView.building,
  bars: [
    ReadinessBarView(
      key: ReadinessBarKey.coverage,
      value: noEvidence ? null : 42,
      locked: false,
      evidence: '84 of 200 lamps lit',
    ),
    ReadinessBarView(
      key: ReadinessBarKey.memory,
      value: noEvidence ? null : 71,
      locked: false,
      evidence: '60 of 84 lit lamps are steady',
    ),
    const ReadinessBarView(
      key: ReadinessBarKey.examPerformance,
      locked: true,
      evidence: '',
    ),
    const ReadinessBarView(
      key: ReadinessBarKey.speed,
      locked: true,
      evidence: '',
    ),
  ],
  litPct: 42,
  steadyPct: 30,
  goldPct: 5,
  readyForFullMocks: false,
  suggestion: 'Try a sectional test on Aptitude this week.',
  computedAt: fixedNow,
);

SundayReportView sampleReport({ReportTier tier = ReportTier.full}) =>
    SundayReportView(
      id: 'r2',
      weekStart: DateTime.utc(2026, 10, 12),
      tier: tier,
      lampsLit: 12,
      steadyEarned: 5,
      goldEarned: 1,
      relit: 3,
      dimmedNow: 2,
      questionsAnswered: 140,
      accuracyPct: 68,
      mocksTaken: 1,
      studyMinutes: 310,
      lines: const [
        'You lit 12 new lamps this week.',
        '2 lamps are dimming. A short relight keeps them bright.',
      ],
      nextWeek: tier == ReportTier.full
          ? const ['Finish Indian Polity basics', 'One sectional mock']
          : null,
    );

class FakeReadinessRepository implements ReadinessRepository {
  ReadinessView meterView = sampleReadiness();

  @override
  Future<ReadinessView> meter(String examCode) async => meterView;

  @override
  Future<SundayReportPageView> reports({String? cursor}) async => sampleReports;

  @override
  Future<SundayReportView> report(String id) async => sampleReport();
}

final sampleReports = SundayReportPageView(
  items: [
    SundayReportSummaryView(
      id: 'r2',
      weekStart: DateTime.utc(2026, 10, 12),
      tier: ReportTier.full,
    ),
    SundayReportSummaryView(
      id: 'r1',
      weekStart: DateTime.utc(2026, 10, 5),
      tier: ReportTier.short,
    ),
  ],
);

ExamAlertView sampleAlert(
  String id, {
  String title = 'Group 4 notification out',
}) => ExamAlertView(
  id: id,
  examCode: 'tnpsc-group-4',
  kind: ExamAlertKindView.notification,
  title: title,
  summary: 'Applications open until 15 Nov. 6,244 posts.',
  officialUrl: 'https://tnpsc.gov.in/notifications/$id',
  publishedAt: fixedNow,
  confirmLine: 'Always confirm with the official notification.',
);

const sampleSettings = AlertSettingsView(
  studyReminders: true,
  examAlerts: true,
  offers: false,
  quietEnabled: true,
  quietStartMinute: 22 * 60,
  quietEndMinute: 7 * 60,
  morningAlertMinute: 7 * 60 + 30,
  dailyLimit: 3,
);

class FakeAlertsRepository implements AlertsRepository {
  List<ExamAlertPageView> pages = [
    ExamAlertPageView(items: [sampleAlert('a1')], nextCursor: 'c1'),
    ExamAlertPageView(items: [sampleAlert('a2', title: 'Hall ticket out')]),
  ];
  AlertSettingsView saved = sampleSettings;
  Object? saveError;
  final tokens = <String>[];

  @override
  Future<ExamAlertPageView> examAlerts({String? cursor}) async =>
      cursor == null ? pages[0] : pages[1];

  @override
  Future<AlertSettingsView> settings() async => saved;

  @override
  Future<AlertSettingsView> saveSettings(AlertSettingsView settings) async {
    if (saveError case final e?) throw e;
    return saved = settings;
  }

  @override
  Future<void> registerPushToken({
    required String deviceId,
    required String platform,
    required String token,
  }) async => tokens.add('$platform:$token');
}

class FakePushSource implements PushTokenSource {
  FakePushSource(this.value);
  final String? value;

  @override
  String get platform => 'android';

  @override
  Future<String?> token() async => value;
}

const setupOptions = PlanSetupOptions(
  mainExamCode: 'tnpsc-group-4',
  otherExamCodes: ['tnpsc-group-2'],
  exams: [
    ExamCycles(
      examCode: 'tnpsc-group-4',
      examName: 'TNPSC Group 4',
      cycles: [
        CycleOption(id: 'c-2026', name: '2026'),
        CycleOption(id: 'c-2027', name: '2027'),
      ],
    ),
  ],
);

class FakePlanSetupRepository implements PlanSetupRepository {
  final calls = <String>[];
  Object? saveError;

  @override
  Future<PlanSetupOptions> options() async => setupOptions;

  @override
  Future<void> saveCycles(
    PlanSetupOptions options,
    Map<String, String> cycles,
  ) async => calls.add('cycles:$cycles');

  @override
  Future<void> savePlan(
    PlanSetupDraft draft, {
    required String idempotencyKey,
  }) async {
    calls.add('plan:${draft.toJson()}:$idempotencyKey');
    if (saveError case final e?) throw e;
  }
}

class PlanFakes {
  final setup = FakePlanSetupRepository();
  final plan = FakePlanRepository();
  final readiness = FakeReadinessRepository();
  final alerts = FakeAlertsRepository();
  final outboxStore = MemoryOutboxStore();
  var nudges = 0;

  late final outbox = OutboxRepository(
    outbox: outboxStore,
    topicStates: MemoryTopicStateStore(),
    clock: () => fixedNow,
  );

  List<Override> get overrides => [
    planRepositoryProvider.overrideWithValue(plan),
    planSetupRepositoryProvider.overrideWithValue(setup),
    readinessRepositoryProvider.overrideWithValue(readiness),
    alertsRepositoryProvider.overrideWithValue(alerts),
    outboxRepositoryProvider.overrideWithValue(outbox),
    studySyncNudgeProvider.overrideWithValue(() async => nudges++),
    mainExamCodeProvider.overrideWith((ref) async => 'tnpsc-group-4'),
    idempotencyKeyFactoryProvider.overrideWithValue(() => 'key-1'),
    deviceIdStoreProvider.overrideWithValue(DeviceIdStore(MemoryKeyValue())),
  ];

  Harness harness({
    bool lite = false,
    bool calm = false,
    List<Override> more = const [],
  }) {
    final profile = FakeProfileRepository();
    if (calm) {
      profile.user = MeInfo(
        id: profile.user.id,
        email: profile.user.email,
        calmMode: true,
        roles: profile.user.roles,
      );
    }
    return Harness(
      lite: lite,
      profile: profile,
      extra: [...overrides, ...more],
    );
  }
}
