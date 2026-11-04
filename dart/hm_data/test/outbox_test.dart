import 'package:flutter_test/flutter_test.dart';
import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Outbox + sync engine rules (blueprint §39, U-app-shell invariants 1–4). BOLT-0016.

class FakeClock {
  FakeClock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

typedef Responder =
    api.SyncBatchResult Function(List<Map<String, Object>> actions);

class FakeSyncApi implements StudySyncGateway {
  final calls = <({String key, List<Map<String, Object>> actions})>[];
  final failNext = <HmApiException>[];
  Responder respond = acceptAll;

  static api.SyncBatchResult acceptAll(List<Map<String, Object>> actions) =>
      result([
        for (final a in actions) (a['clientActionId']! as String, 'accepted'),
      ]);

  static api.SyncBatchResult result(
    List<(String, String)> statuses, {
    List<api.TopicState> topics = const [],
  }) => api.SyncBatchResult(
    results: [
      for (final (id, s) in statuses)
        api.SyncActionResult(
          clientActionId: id,
          status: api.SyncActionResultStatusEnum.fromJson(s)!,
          errorCode: s == 'rejected' ? 'TOPIC_NOT_FOUND' : null,
        ),
    ],
    topicStates: topics,
    serverNow: DateTime.utc(2026, 10, 22),
  );

  @override
  Future<api.SyncBatchResult> send({
    required String idempotencyKey,
    required String deviceId,
    required List<Map<String, Object>> actions,
  }) async {
    calls.add((key: idempotencyKey, actions: actions));
    if (failNext.isNotEmpty) throw failNext.removeAt(0);
    return respond(actions);
  }
}

api.TopicState topic(String id, {required bool lit}) =>
    api.TopicState.fromJson({
      'topicId': id,
      'ring': {'lit': lit, 'steadyLevel': 0, 'gold': false, 'dim': 'bright'},
      'litAt': null,
      'goldAt': null,
      'lessonCompletedAt': null,
      'nextDueAt': null,
      'nextCheck': 'recall',
      'updatedAt': '2026-10-22T00:00:00.000Z',
    })!;

void main() {
  late FakeClock clock;
  late MemoryOutboxStore outbox;
  late MemoryTopicStateStore topics;
  late FakeSyncApi fakeApi;
  late OutboxRepository repo;
  late SyncEngine engine;
  late int ids;

  setUp(() {
    clock = FakeClock(DateTime.utc(2026, 10, 22, 6));
    outbox = MemoryOutboxStore();
    topics = MemoryTopicStateStore();
    fakeApi = FakeSyncApi();
    ids = 0;
    repo = OutboxRepository(
      outbox: outbox,
      topicStates: topics,
      clock: clock.call,
      newId: () =>
          '00000000-0000-4000-8000-${(++ids).toString().padLeft(12, '0')}',
    );
    engine = SyncEngine(
      outbox: outbox,
      topicStates: topics,
      gateway: fakeApi,
      deviceId: () async => 'device-0001',
      clock: clock.call,
    );
  });

  StudyAction lesson(String topicId) =>
      LessonCompleteAction(topicId: topicId, via: LessonVia.lesson);

  test('records locally first with an id and client time', () async {
    final id = await repo.record(lesson('t1'));
    final pending = await outbox.pending(limit: 10);
    expect(pending.single.clientActionId, id);
    expect(pending.single.clientAt, clock.now);
    expect(pending.single.toWire(), {
      'clientActionId': id,
      'clientAt': '2026-10-22T06:00:00.000Z',
      'kind': 'lesson_complete',
      'topicId': 't1',
      'via': 'lesson',
    });
    expect(fakeApi.calls, isEmpty);
  });

  test('sends in creation order, in batches of at most 100', () async {
    for (var i = 0; i < 230; i++) {
      await repo.record(lesson('t$i'));
      clock.advance(const Duration(seconds: 1));
    }
    final report = await engine.syncNow();
    expect(fakeApi.calls.map((c) => c.actions.length), [100, 100, 30]);
    final sentTopics = [
      for (final c in fakeApi.calls)
        for (final a in c.actions) a['topicId'],
    ];
    expect(sentTopics, [for (var i = 0; i < 230; i++) 't$i']);
    expect(report.sent, 230);
    expect(report.accepted, 230);
    expect(report.remaining, 0);
  });

  test('one batch in flight: concurrent calls join the same run', () async {
    await repo.record(lesson('t1'));
    final a = engine.syncNow();
    final b = engine.syncNow();
    expect(identical(await a, await b), isTrue);
    expect(fakeApi.calls, hasLength(1));
  });

  test('dedup: the same clientActionId is stored and sent once', () async {
    await repo.record(lesson('t1'), clientActionId: 'same-id');
    await repo.record(lesson('t1'), clientActionId: 'same-id');
    expect(await repo.pendingCount(), 1);
    await engine.syncNow();
    expect(fakeApi.calls.single.actions, hasLength(1));
  });

  test(
    'duplicate from the server counts as saved and leaves the outbox',
    () async {
      final id = await repo.record(lesson('t1'));
      fakeApi.respond = (_) => FakeSyncApi.result([(id, 'duplicate')]);
      final report = await engine.syncNow();
      expect(report.accepted, 1);
      expect(await repo.pendingCount(), 0);
    },
  );

  test(
    'retry: failure backs off 5 s doubling to 10 min and reuses keys',
    () async {
      final id = await repo.record(lesson('t1'));
      fakeApi.failNext.addAll(List.filled(10, HmApiException.network()));

      final first = await engine.syncNow();
      expect(first.failed, isTrue);
      expect(first.retryAt, clock.now.add(const Duration(seconds: 5)));
      expect((await outbox.pending(limit: 1)).single.attempts, 1);

      // Inside the wait nothing is sent.
      await engine.syncNow();
      expect(fakeApi.calls, hasLength(1));

      final waits = <Duration>[];
      for (var i = 0; i < 9; i++) {
        final before = engine.retryAt!;
        clock.now = before;
        final r = await engine.syncNow();
        waits.add(r.retryAt!.difference(clock.now));
      }
      expect(waits.map((d) => d.inSeconds), [
        10, 20, 40, 80, 160, 320, 600, 600, 600, //
      ]);

      // Same batch → same Idempotency-Key and same clientActionId on every try.
      expect(fakeApi.calls.map((c) => c.key).toSet(), hasLength(1));
      expect(
        fakeApi.calls.map((c) => c.actions.single['clientActionId']).toSet(),
        {id},
      );

      clock.now = engine.retryAt!;
      final ok = await engine.syncNow();
      expect(ok.failed, isFalse);
      expect(ok.accepted, 1);
      expect(await repo.pendingCount(), 0);
    },
  );

  test('force (came online) skips the backoff wait', () async {
    await repo.record(lesson('t1'));
    fakeApi.failNext.add(HmApiException.network());
    await engine.syncNow();
    final r = await engine.syncNow(force: true);
    expect(r.accepted, 1);
  });

  test(
    '7-day cut-off: old actions are flagged and saved as study log only',
    () async {
      final oldId = await repo.record(lesson('t-old'));
      clock.advance(const Duration(days: 7, minutes: 1));
      final newId = await repo.record(lesson('t-new'));

      final pending = await outbox.pending(limit: 10);
      expect(pending.first.isPastRingWindow(clock.now), isTrue);
      expect(pending.last.isPastRingWindow(clock.now), isFalse);

      fakeApi.respond = (_) =>
          FakeSyncApi.result([(oldId, 'study_log_only'), (newId, 'accepted')]);
      final r = await engine.syncNow();
      expect(r.studyLogOnly, 1);
      expect(r.accepted, 1);
      expect(await repo.pendingCount(), 0);
      expect(
        SyncCopy.studyLogOnly,
        'Saved as study history. Rings only change for the last 7 days.',
      );
    },
  );

  test('exactly 7 days old is still inside the ring window', () async {
    await repo.record(lesson('t1'));
    clock.advance(const Duration(days: 7));
    expect(
      (await outbox.pending(limit: 1)).single.isPastRingWindow(clock.now),
      isFalse,
    );
  });

  test('rejected actions stay for the "Couldn\'t save" list', () async {
    final id = await repo.record(lesson('t1'));
    fakeApi.respond = (_) => FakeSyncApi.result([(id, 'rejected')]);
    final r = await engine.syncNow();
    expect(r.rejected, 1);
    expect(await repo.pendingCount(), 0);
    final rejected = await repo.rejected();
    expect(rejected.single.lastError, 'TOPIC_NOT_FOUND');
    await engine.syncNow();
    expect(fakeApi.calls, hasLength(1), reason: 'rejected is not resent');
    await repo.dismissRejected(id);
    expect(await repo.rejected(), isEmpty);
  });

  test('actions the server did not answer stay pending', () async {
    final a = await repo.record(lesson('t1'));
    await repo.record(lesson('t2'));
    fakeApi.respond = (_) => FakeSyncApi.result([(a, 'accepted')]);
    final r = await engine.syncNow();
    expect(r.remaining, 1);
    expect(fakeApi.calls, hasLength(1));
  });

  test('server wins: returned topic states replace local lamps', () async {
    await topics.putAll([
      TopicStateRecord(
        topicId: 't1',
        json: '{"stale":true}',
        updatedAt: DateTime.utc(2026),
      ),
    ]);
    final id = await repo.record(lesson('t1'));
    fakeApi.respond = (_) => FakeSyncApi.result(
      [(id, 'accepted')],
      topics: [topic('t1', lit: true)],
    );
    await engine.syncNow();
    final state = await repo.topicState('t1');
    expect(state!.ring.lit, isTrue);
  });

  test('stored actions round-trip to the same wire shape', () {
    const answer = PracticeAnswerAction(
      questionId: 'q1',
      questionVersion: 3,
      chosenOptionIds: ['A'],
      timeMs: 4200,
      mode: PracticeMode.pyq,
    );
    final back = StudyAction.fromStored(answer.kind, answer.fieldsJson());
    expect(back.fieldsJson(), answer.fieldsJson());
    const check = TopicCheckAction(
      topicId: 't1',
      checkKind: OfflineCheckKind.relight,
      answers: [
        {
          'questionId': 'q1',
          'chosenOptionIds': ['B'],
        },
      ],
    );
    expect(
      StudyAction.fromStored(check.kind, check.fieldsJson()).fieldsJson(),
      check.fieldsJson(),
    );
  });

  test('backoff table', () {
    expect(OutboxRules.backoff(0), Duration.zero);
    expect(OutboxRules.backoff(1), const Duration(seconds: 5));
    expect(OutboxRules.backoff(8), const Duration(minutes: 10));
    expect(OutboxRules.backoff(1000), const Duration(minutes: 10));
  });

  test('HmApi gateway: sends the batch key and reads nullable fields', () async {
    late http.Request seen;
    final gateway = HmApiSyncGateway(
      HmApi(
        config: const ApiConfig(
          baseUrl: 'http://localhost:4567',
          appVersion: '0.1.0',
        ),
        tokens: MemoryTokenStore(),
        httpClient: MockClient((req) async {
          seen = req;
          return http.Response(
            '{"results":[{"clientActionId":"a","status":"rejected","errorCode":null}],'
            '"topicStates":[{"topicId":"t1","ring":{"lit":true,"steadyLevel":1,"gold":false,'
            '"dim":"bright"},"litAt":null,"goldAt":null,"lessonCompletedAt":null,'
            '"nextDueAt":null,"nextCheck":"recall","updatedAt":"2026-10-22T00:00:00.000Z"}],'
            '"serverNow":"2026-10-22T00:00:00.000Z"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );
    final r = await gateway.send(
      idempotencyKey: 'batch-key-1',
      deviceId: 'device-0001',
      actions: const [],
    );
    expect(seen.url.path, '/v1/sync/study-actions');
    expect(seen.headers['idempotency-key'], 'batch-key-1');
    expect(r.results.single.errorCode, isNull);
    expect(r.topicStates.single.litAt, isNull);
    expect(r.topicStates.single.ring.steadyLevel, 1);
  });
}
