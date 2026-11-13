import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/exam_hall_fakes.dart' show FakeNetworkSource;
import 'support/fakes.dart';
import 'support/practice_fakes.dart';

const _network = HmApiException(
  HmApiException.networkError,
  HmApiException.networkMessage,
);
const _limit = HmApiException(
  'PRACTICE_DAILY_LIMIT',
  "You've used today's 30 free questions.",
  statusCode: 403,
);

void main() {
  group('study rules (§5.1, §10.9, §13)', () {
    test('lamp words name every state, not only colour', () {
      expect(lampWords(HmLampState.unlit), 'Not lit yet');
      expect(lampWords(const HmLampState(lit: true)), 'Lit');
      expect(
        lampWords(const HmLampState(lit: true, steadyLevel: 2)),
        'Steady 2 of 4',
      );
      expect(
        lampWords(const HmLampState(lit: true, gold: true, dim: HmLampDim.dim)),
        'Gold · Dim, relight it',
      );
      expect(
        lampWords(const HmLampState(lit: true, dim: HmLampDim.dimming)),
        'Lit · Dimming',
      );
    });

    test('limit sheet shows at most once per IST day', () {
      expect(
        shouldShowLimitSheet(lastUsage: sampleUsage(), shownOnIstDay: null),
        isTrue,
      );
      expect(
        shouldShowLimitSheet(
          lastUsage: sampleUsage(shown: true),
          shownOnIstDay: null,
        ),
        isFalse,
        reason: 'server says it was shown today',
      );
      expect(
        shouldShowLimitSheet(
          lastUsage: sampleUsage(),
          shownOnIstDay: '2026-10-20',
        ),
        isFalse,
      );
      expect(
        shouldShowLimitSheet(
          lastUsage: sampleUsage(),
          shownOnIstDay: '2026-10-19',
        ),
        isTrue,
      );
    });

    test('limit copy has no price and no urgency (D-2026-10-22-19)', () {
      final all = '${StudyCopy.limitTitle(30)} ${StudyCopy.limitBody}';
      expect(all, contains('30 free questions'));
      for (final banned in [
        '₹',
        'Rs',
        'price',
        'only today',
        'hurry',
        'left!',
      ]) {
        expect(all.toLowerCase(), isNot(contains(banned.toLowerCase())));
      }
      expect(StudyCopy.notNow, 'Not now');
    });

    test(
      'Gold time left uses the server offset, not the phone clock alone',
      () {
        final check = CheckView(
          checkId: 'c',
          topicId: 't',
          kind: CheckKind.gold,
          questions: const [],
          passMark: 8,
          serverNow: DateTime.utc(2026, 1, 1, 10),
          deadlineAt: DateTime.utc(2026, 1, 1, 10, 10),
        );
        // Phone clock is 1 hour ahead; 2 minutes have passed locally.
        final issued = DateTime.utc(2026, 1, 1, 11);
        expect(
          goldTimeLeft(check, issued, issued.add(const Duration(minutes: 2))),
          const Duration(minutes: 8),
        );
        expect(
          goldTimeLeft(check, issued, issued.add(const Duration(hours: 1))),
          Duration.zero,
        );
      },
    );
  });

  group('contract JSON mapping', () {
    test('check result with no rank-up and the server lamp', () {
      final r = checkResultFromJson({
        'checkId': 'c',
        'kind': 'recall',
        'passed': true,
        'correct': 3,
        'total': 3,
        'lateAnswersIgnored': 0,
        'graded': <Object>[],
        'topicState': {
          'ring': {
            'lit': true,
            'steadyLevel': 2,
            'gold': false,
            'dim': 'bright',
          },
        },
        'rankUp': null,
      });
      expect(r.kind, CheckKind.recall);
      expect(r.rankUp, isNull);
      expect(r.lamp, const HmLampState(lit: true, steadyLevel: 2));
    });

    test('PYQ facets newest year first; Tamil content flagged', () {
      final f = pyqFacetsFromJson({
        'years': [
          {'year': 2022, 'count': 1, 'locked': true},
          {'year': 2024, 'count': 1, 'locked': false},
        ],
        'subjects': <Object>[],
      });
      expect(f.years.map((y) => y.year), [2024, 2022]);
      final q = questionFromJson({
        'id': 'q',
        'version': 2,
        'topicId': 't',
        'language': 'ta',
        'stem': 'x',
        'options': <Object>[],
        'source': {
          'citation': 'c',
          'url': null,
          'pyq': {
            'examCode': 'tnpsc-group-4',
            'year': 2024,
            'questionNumber': 5,
          },
        },
        'affectedNote': null,
      });
      expect(q.tamil, isTrue);
      expect(q.source.line, 'TNPSC-GROUP-4 2024, Q 5');
    });

    test('usage limit null means no limit line', () {
      final u = usageFromJson({
        'istDay': '2026-10-20',
        'used': 4,
        'limit': null,
        'limitSheetShownToday': false,
      });
      expect(u.line, isNull);
      expect(u.limitReached, isFalse);
    });
  });

  group('local-first writes (§39)', () {
    test(
      'online answer: queued first, sent with the same id, then cleared',
      () async {
        final f = StudyFakes();
        final h = f.harness();
        final r = h.container.read(studyRecorderProvider);
        final out = await r.practiceAnswer(
          sessionId: 's-1',
          mode: StudyMode.practice,
          question: sampleQuestion('q1'),
          chosen: const ['a'],
          timeMs: 1000,
        );
        expect(out, isA<Graded<PracticeAnswerView>>());
        expect(f.repo.calls, ['answer:q1:id-1']);
        expect(await f.outbox.pendingCount(), 0);
      },
    );

    test(
      'offline answer stays in the outbox (Will sync when online)',
      () async {
        final f = StudyFakes()..repo.answerError = _network;
        final r = f.harness().container.read(studyRecorderProvider);
        final out = await r.practiceAnswer(
          sessionId: 's-1',
          mode: StudyMode.practice,
          question: sampleQuestion('q1'),
          chosen: const ['a'],
          timeMs: 1000,
        );
        expect(out, isA<SavedOffline<PracticeAnswerView>>());
        final pending = await f.outboxStore.pending(limit: 10);
        expect(pending.single.kind, 'practice_answer');
        expect(pending.single.clientActionId, 'id-1');
      },
    );

    test('daily limit: nothing stored, sheet once', () async {
      final f = StudyFakes()..repo.answerError = _limit;
      final r = f.harness().container.read(studyRecorderProvider);
      final out = await r.practiceAnswer(
        sessionId: 's-1',
        mode: StudyMode.practice,
        question: sampleQuestion('q1'),
        chosen: const ['a'],
        timeMs: 1000,
        lastUsage: sampleUsage(used: 30),
      );
      expect(out, isA<LimitReached<PracticeAnswerView>>());
      expect((out as LimitReached).showSheet, isTrue);
      expect(await f.outbox.pendingCount(), 0);
    });

    test('server refusal: Couldn\'t save, not retried', () async {
      final f = StudyFakes()
        ..repo.answerError = const HmApiException(
          'PRACTICE_SESSION_CLOSED',
          'This session has ended.',
          statusCode: 409,
        );
      final r = f.harness().container.read(studyRecorderProvider);
      final out = await r.practiceAnswer(
        sessionId: 's-1',
        mode: StudyMode.practice,
        question: sampleQuestion('q1'),
        chosen: const ['a'],
        timeMs: 1,
      );
      expect((out as NotSaved).message, 'This session has ended.');
      expect(await f.outbox.pendingCount(), 0);
    });

    CheckView check(CheckKind k) => CheckView(
      checkId: 'c-1',
      topicId: 't-1',
      kind: k,
      questions: [sampleQuestion('q1')],
      passMark: 1,
    );

    test('Lit / relight check offline is queued as topic_check', () async {
      final f = StudyFakes()..repo.submitError = _network;
      final r = f.harness().container.read(studyRecorderProvider);
      final out = await r.checkResult(check(CheckKind.relight), {
        'q1': ['a'],
      });
      expect(out, isA<SavedOffline<CheckResultView>>());
      final e = (await f.outboxStore.pending(limit: 5)).single;
      expect(e.kind, 'topic_check');
      expect(e.payloadJson, contains('"checkKind":"relight"'));
    });

    test('Gold is online only and never queued', () async {
      final f = StudyFakes()..repo.submitError = _network;
      final r = f.harness().container.read(studyRecorderProvider);
      final out = await r.checkResult(check(CheckKind.gold), {
        'q1': ['a'],
      });
      expect((out as NotSaved).message, StudyCopy.goldNeedsConnection);
      expect(await f.outbox.pendingCount(), 0);
    });

    test('lesson complete is queued and nudges the sync', () async {
      final f = StudyFakes();
      final r = f.harness().container.read(studyRecorderProvider);
      await r.lessonComplete('t-1');
      expect(
        (await f.outboxStore.pending(limit: 5)).single.kind,
        'lesson_complete',
      );
      expect(f.nudges, 1);
    });
  });

  group('screens', () {
    const request = (
      mode: StudyMode.practice,
      examCode: 'tnpsc-group-4',
      topicId: null,
      subjectCode: null,
      drillId: null,
    );

    testWidgets('practice: choose, check, feedback with source, next', (
      tester,
    ) async {
      final f = StudyFakes()..repo.answerCorrect = false;
      final relit = <String>[];
      await tester.pumpWidget(
        f.harness().app(PracticeScreen(request: request, onRelight: relit.add)),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 of 30 free questions today'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Option A: 26 January 1950'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('option-b')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('practice-check')));
      await tester.pumpAndSettle();
      expect(find.text('Not quite'), findsOneWidget);
      expect(find.text('15 August 1947 is Independence Day.'), findsOneWidget);
      expect(find.text('Source: TNPSC-GROUP-4 2024, Q 57'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('feedback-relight')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('feedback-relight')));
      expect(relit, ['t-1']);
      await tester.ensureVisible(find.byKey(const Key('practice-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('practice-next')));
      await tester.pumpAndSettle();
      expect(find.text('Question 2 of 2'), findsOneWidget);
    });

    testWidgets('offline answer shows Will sync when online', (tester) async {
      final f = StudyFakes()..repo.answerError = _network;
      await tester.pumpWidget(
        f.harness().app(const PracticeScreen(request: request)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('option-a')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('practice-check')));
      await tester.pumpAndSettle();
      expect(find.text(StudyCopy.willSync), findsOneWidget);
    });

    testWidgets('limit sheet: message + Not now, no price, once a day', (
      tester,
    ) async {
      final f = StudyFakes()..repo.answerError = _limit;
      final h = f.harness();
      await tester.pumpWidget(h.app(const PracticeScreen(request: request)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('option-a')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('practice-check')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('limit-sheet')), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.textContaining('₹'), findsNothing);
      await tester.tap(find.byKey(const Key('limit-not-now')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('limit-sheet')), findsNothing);
      expect(h.container.read(limitSheetShownDayProvider), '2026-10-20');
      expect(
        shouldShowLimitSheet(
          lastUsage: sampleUsage(),
          shownOnIstDay: h.container.read(limitSheetShownDayProvider),
        ),
        isFalse,
      );
    });

    testWidgets('lesson step, then the 3-question Lit check', (tester) async {
      final f = StudyFakes();
      await tester.pumpWidget(
        f.harness().app(
          const CheckScreen(
            request: (topicId: 't-1', kind: CheckKind.lit, lessonStep: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lesson-finished')));
      await tester.pumpAndSettle();
      expect(f.nudges, 1);
      expect(
        find.text('Answer 3 questions. Get 2 right to light this lamp.'),
        findsOneWidget,
      );
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('option-a')));
        await tester.tap(find.byKey(const Key('check-next')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('option-a')));
      await tester.tap(find.byKey(const Key('check-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Lamp lit.'), findsOneWidget);
      expect(find.text('3 of 3 right · Lit'), findsOneWidget);
    });

    Future<void> passLitCheck(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('lesson-finished')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('option-a')));
        await tester.tap(find.byKey(const Key('check-next')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('option-a')));
      await tester.tap(find.byKey(const Key('check-submit')));
      await tester.pumpAndSettle();
    }

    test('rank-up subtitle carries the official-designation note (C-P2-1)', () {
      expect(
        rankUpSubtitle('Scholar', 'Game title. Not an official designation.'),
        'You are now Scholar. Game title. Not an official designation.',
      );
      expect(
        rankUpSubtitle('Scholar', ''),
        'You are now Scholar. Game title. Not an official designation.',
      );
    });

    testWidgets('rank-up overlay subtitle includes the note (C-P2-1)', (
      tester,
    ) async {
      final f = StudyFakes()
        ..repo.rankUp = const RankUpView(
          title: 'Scholar',
          note: 'Game title. Not an official designation.',
        );
      await tester.pumpWidget(
        f.harness().app(
          const CheckScreen(
            request: (topicId: 't-1', kind: CheckKind.lit, lessonStep: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lesson-finished')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('option-a')));
        await tester.tap(find.byKey(const Key('check-next')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('option-a')));
      await tester.tap(find.byKey(const Key('check-submit')));
      // The overlays close themselves; step frames until the rank-up one shows.
      final subtitle = find.text(
        'You are now Scholar. Game title. Not an official designation.',
      );
      var seen = false;
      for (var i = 0; i < 200 && !seen; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        seen = subtitle.evaluate().isNotEmpty;
      }
      expect(seen, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('rank card is hidden in Calm Mode (C-P2-3)', (tester) async {
      final f = StudyFakes()
        ..repo.rankUp = const RankUpView(
          title: 'Scholar',
          note: 'Game title. Not an official designation.',
        );
      final h = f.harness();
      await h.profile.setCalmMode(true);
      await tester.pumpWidget(
        h.app(
          const CheckScreen(
            request: (topicId: 't-1', kind: CheckKind.lit, lessonStep: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await passLitCheck(tester);
      expect(find.text('Lamp lit.'), findsOneWidget);
      expect(find.textContaining('New rank'), findsNothing);
    });

    testWidgets('Gold check offline explains it needs a connection', (
      tester,
    ) async {
      final f = StudyFakes()..repo.checkError = _network;
      await tester.pumpWidget(
        f.harness().app(
          const CheckScreen(
            request: (topicId: 't-1', kind: CheckKind.gold, lessonStep: false),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(StudyCopy.goldNeedsConnection), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'relight queue lists lamps with minutes and a labelled button',
      (tester) async {
        final f = StudyFakes();
        final opened = <String>[];
        await tester.pumpWidget(
          f.harness().app(RelightQueueScreen(onRelight: opened.add)),
        );
        await tester.pumpAndSettle();
        expect(find.text('2 lamps to relight · about 7 min'), findsOneWidget);
        expect(find.bySemanticsLabel('Relight Sangam Age'), findsOneWidget);
        await tester.tap(find.byKey(const Key('relight-t-3')));
        expect(opened, ['t-3']);
      },
    );

    testWidgets('mistakes: drill locked for Free, relight link', (
      tester,
    ) async {
      final f = StudyFakes();
      final relit = <String>[];
      await tester.pumpWidget(
        f.harness().app(
          MistakesScreen(onRelight: relit.add, onStartDrill: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('drill-locked')), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('Why yours was wrong'), findsOneWidget);
      await tester.tap(find.byKey(const Key('feedback-relight')));
      expect(relit, ['t-1']);
    });

    testWidgets(
      'PYQ Vault: Pro marked before tap; locked year blocks practise',
      (tester) async {
        final f = StudyFakes();
        await tester.pumpWidget(
          f.harness().app(
            PyqVaultScreen(examCode: 'tnpsc-group-4', onPractise: (_) {}),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('2022 · Pro'), findsOneWidget);
        expect(find.byKey(const Key('pyq-practise')), findsOneWidget);
        await tester.tap(find.byKey(const Key('pyq-year-2022')));
        await tester.pumpAndSettle();
        expect(f.pyq.searches.last.year, 2022);
        expect(find.byKey(const Key('pyq-practise')), findsNothing);
        expect(find.text(StudyCopy.pyqLocked), findsOneWidget);
      },
    );

    testWidgets('Study Map Lite list names the lamp state', (tester) async {
      final h = StudyFakes().harness(lite: true);
      await tester.pumpWidget(
        h.app(Scaffold(body: StudyMapTab(onOpenTopic: (_) {}))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Not lit yet'), findsNWidgets(2));
    });
  });

  group('lamp sheet: recall and Gold from the Study Map (§5.1)', () {
    test('actions follow nextCheck; Gold for Lit or above, never twice', () {
      List<String> labels(NextCheck n, HmLampState l) => [
        for (final a in topicActions(next: n, lamp: l, hasLesson: true))
          a.label,
      ];
      expect(labels(NextCheck.recall, const HmLampState(lit: true)), [
        'Start recall',
        'Try Gold',
        'Read the lesson',
      ]);
      expect(labels(NextCheck.lesson, HmLampState.unlit), ['Read the lesson']);
      expect(labels(NextCheck.none, const HmLampState(lit: true, gold: true)), [
        'Read the lesson',
      ]);
      expect(
        topicActions(
          next: NextCheck.gold,
          lamp: const HmLampState(lit: true),
          hasLesson: false,
        ).single.needsConnection,
        isTrue,
      );
    });

    test('topic-states JSON maps nextCheck per topic', () {
      expect(
        nextChecksFromJson({
          'items': [
            {'topicId': 'a', 'nextCheck': 'recall'},
            {'topicId': 'b', 'nextCheck': 'weird'},
          ],
        }),
        {'a': NextCheck.recall, 'b': NextCheck.none},
      );
    });

    Future<List<(String, CheckKind)>> openSheet(
      WidgetTester tester, {
      required bool online,
    }) async {
      final f = StudyFakes();
      final net = FakeNetworkSource(online: online);
      final h = Harness(
        study: LitStudyRepository(),
        extra: [...f.overrides, networkSourceProvider.overrideWithValue(net)],
      );
      final started = <(String, CheckKind)>[];
      await tester.pumpWidget(
        h.app(
          Scaffold(
            body: StudyMapTab(
              onOpenTopic: (_) {},
              onStartCheck: (t, k) => started.add((t.id, k)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lamp-t-1')));
      await tester.pumpAndSettle();
      return started;
    }

    testWidgets(
      'lit lamp with a due recall: Start recall first, then Try Gold',
      (tester) async {
        final started = await openSheet(tester, online: true);
        expect(find.byKey(const Key('lamp-sheet')), findsOneWidget);
        expect(find.text('Lit'), findsOneWidget);
        expect(find.text('Start recall'), findsOneWidget);
        await tester.tap(find.byKey(const Key('lamp-action-recall')));
        await tester.pumpAndSettle();
        expect(started, [('t-1', CheckKind.recall)]);
      },
    );

    testWidgets('Try Gold starts the Gold check when online', (tester) async {
      final started = await openSheet(tester, online: true);
      await tester.tap(find.byKey(const Key('lamp-action-gold')));
      await tester.pumpAndSettle();
      expect(started, [('t-1', CheckKind.gold)]);
    });

    testWidgets('offline: Try Gold is disabled with the reason', (
      tester,
    ) async {
      final started = await openSheet(tester, online: false);
      expect(find.text(StudyCopy.goldNeedsConnection), findsOneWidget);
      await tester.tap(find.byKey(const Key('lamp-action-gold')));
      await tester.pumpAndSettle();
      expect(started, isEmpty);
      expect(find.bySemanticsLabel('Try Gold'), findsOneWidget);
    });
  });
}

/// The sample map with t-1 Lit.
class LitStudyRepository extends FakeStudyRepository {
  @override
  Future<StudyMapView> studyMap(String examCode) async => StudyMapView(
    examCode: sampleMap.examCode,
    totalTopics: sampleMap.totalTopics,
    subjects: [
      for (final s in sampleMap.subjects)
        SubjectView(
          code: s.code,
          name: s.name,
          order: s.order,
          topics: [
            for (final t in s.topics)
              TopicView(
                id: t.id,
                name: t.name,
                order: t.order,
                hasLesson: t.hasLesson,
                lamp: t.id == 't-1' ? const HmLampState(lit: true) : t.lamp,
              ),
          ],
        ),
    ],
  );
}
