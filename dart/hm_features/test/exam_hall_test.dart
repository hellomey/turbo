import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/exam_hall_fakes.dart';
import 'support/fakes.dart';

/// Exam Hall app screens (BOLT-0019, INT-002-S10/S11, §10.6).
void main() {
  group('domain', () {
    test(
      'countdown uses the server deadline and server offset, never the phone alone',
      () {
        final left = timeLeft(
          deadlineAt: fixedNow.add(const Duration(minutes: 90)),
          localNow: fixedNow,
          serverOffset: const Duration(seconds: 5),
        );
        expect(left, const Duration(minutes: 89, seconds: 55));
        expect(formatClock(left), '1:29:55');
        expect(spokenTimeLeft(left), '1 hour 29 minutes left');
        expect(
          timeLeft(
            deadlineAt: fixedNow,
            localNow: fixedNow,
            serverOffset: const Duration(seconds: 1),
          ),
          Duration.zero,
        );
        expect(formatClock(const Duration(minutes: 5, seconds: 9)), '05:09');
      },
    );

    test('answer mode comes from the paper; written is not built yet', () {
      expect(answerModeFromPaper('omr'), AnswerMode.omr);
      expect(answerModeFromPaper('cbt'), AnswerMode.cbt);
      expect(answerModeFromPaper('written'), isNull);
    });

    test('marks and allowance text', () {
      expect(formatMarks(51, 3), '17');
      expect(formatMarks(103, 3), '34.33');
      expect(mockList.allowanceLine, 'Free full mocks this month: 0 of 1 used');
      expect(mockFull.accessLabel, 'Free');
      expect(mockPro.accessLabel, 'Pro');
    });

    test('State Mock Sunday phases', () {
      expect(
        sundayMock.phaseAt(fixedNow.subtract(const Duration(hours: 1))),
        StateMockPhase.upcoming,
      );
      expect(sundayMock.phaseAt(fixedNow), StateMockPhase.open);
      expect(
        sundayMock.phaseAt(fixedNow.add(const Duration(hours: 1))),
        StateMockPhase.practiceOnly,
      );
      expect(
        sundayMock.phaseAt(fixedNow.add(const Duration(days: 1))),
        StateMockPhase.closed,
      );
      expect(sundayMock.asMock.free, isTrue);
      expect(sundayMock.asMock.paperCode, 'g4-paper-1');
    });

    test('palette states', () {
      final s = sampleSession(
        answers: const {
          'q1': SessionAnswer(chosen: ['o2']),
          'q2': SessionAnswer(marked: true),
          'q3': SessionAnswer(chosen: ['o2'], marked: true),
        },
      );
      expect(s.paletteOf('q1'), PaletteState.answered);
      expect(s.paletteOf('q2'), PaletteState.marked);
      expect(s.paletteOf('q3'), PaletteState.answeredAndMarked);
      expect(s.answeredCount, 2);
      expect(s.unansweredCount, 1);
    });
  });

  group('controller', () {
    test('starting needs a connection', () async {
      final f = ExamHallFakes();
      f.network.online = false;
      final h = f.harness();
      final ok = await h.container
          .read(examHallControllerProvider.notifier)
          .start(mockFull);
      expect(ok, isFalse);
      expect(
        h.container.read(examHallControllerProvider).message,
        ExamHallCopy.needsConnection,
      );
      expect(f.repo.calls.where((c) => c.startsWith('start')), isEmpty);
    });

    test(
      'start uses the paper answer mode and remembers the attempt',
      () async {
        final f = ExamHallFakes()..repo.mode = AnswerMode.omr;
        final h = f.harness();
        final ok = await h.container
            .read(examHallControllerProvider.notifier)
            .start(mockFull);
        expect(ok, isTrue);
        expect(f.repo.calls, ['answerMode:g4-paper-1', 'start:m-1:omr']);
        expect(await f.store.activeAttempt(), 'a-1');
        final state = h.container.read(examHallControllerProvider);
        expect(state.phase, ExamPhase.active);
        expect(state.serverOffset, const Duration(seconds: 5));
        expect(
          h.container.read(examHallControllerProvider.notifier).timeLeftNow,
          const Duration(minutes: 89, seconds: 55),
        );
      },
    );

    test('a written paper is refused with simple English', () async {
      final f = ExamHallFakes()..repo.mode = null;
      final h = f.harness();
      await h.container
          .read(examHallControllerProvider.notifier)
          .start(mockFull);
      expect(
        h.container.read(examHallControllerProvider).message,
        ExamHallCopy.descriptiveLater,
      );
    });

    test('second free mock in a month: limit with Not now', () async {
      final f = ExamHallFakes()
        ..repo.startError = const HmApiException(
          'MOCK_MONTHLY_LIMIT',
          'limit',
          statusCode: 409,
        );
      final h = f.harness();
      await h.container
          .read(examHallControllerProvider.notifier)
          .start(mockFull);
      final state = h.container.read(examHallControllerProvider);
      expect(state.blockedWithNotNow, isTrue);
      expect(state.message, ExamHallCopy.monthlyLimit);
    });

    test(
      'answers are saved on the phone first and queued when a save fails',
      () async {
        final f = ExamHallFakes();
        final h = f.harness();
        final c = h.container.read(examHallControllerProvider.notifier);
        await c.start(mockFull);

        f.repo.saveError = HmApiException.network();
        await c.choose('q1', 'o2');
        var state = h.container.read(examHallControllerProvider);
        expect(state.session!.answerOf('q1').chosen, ['o2']);
        expect(state.pending, 1);
        expect((await f.store.unsynced('a-1')).single.chosenOptionIds, ['o2']);

        f.repo.saveError = null;
        await c.toggleMark('q1');
        state = h.container.read(examHallControllerProvider);
        expect(state.pending, 0);
        expect(f.repo.saved.last.single.markedForReview, isTrue);
        expect(await f.store.unsynced('a-1'), isEmpty);
      },
    );

    test(
      'resume after the app is killed keeps local answers and server time',
      () async {
        final store = MemoryMockAnswerStore();
        await store.setActiveAttempt('a-1');
        await store.put(
          LocalMockAnswer(
            attemptId: 'a-1',
            questionId: 'q1',
            chosenOptionIds: const ['o3'],
            markedForReview: false,
            clientAt: fixedNow,
          ),
        );
        final f = ExamHallFakes(store: store)
          ..repo.session = sampleSession(
            answers: const {
              'q1': SessionAnswer(chosen: ['o1']),
              'q2': SessionAnswer(chosen: ['o1']),
            },
          );
        final h = f.harness();
        final c = h.container.read(examHallControllerProvider.notifier);
        await c.checkResume();
        expect(
          h.container.read(examHallControllerProvider).resumableAttemptId,
          'a-1',
        );
        expect(await c.resume(), isTrue);
        await Future<void>.delayed(Duration.zero);
        final state = h.container.read(examHallControllerProvider);
        expect(state.session!.answerOf('q1').chosen, [
          'o3',
        ], reason: 'local wins');
        expect(state.session!.answerOf('q2').chosen, ['o1']);
        expect(state.index, 2, reason: 'first unanswered question');
        expect(f.repo.calls, contains('save:1'));
      },
    );

    test(
      'submit sends queued answers, then shows the report and clears the phone',
      () async {
        final f = ExamHallFakes();
        final h = f.harness();
        final c = h.container.read(examHallControllerProvider.notifier);
        await c.start(mockFull);
        f.repo.saveError = HmApiException.network();
        await c.choose('q1', 'o2');
        f.repo.saveError = null;
        await c.submit();
        final state = h.container.read(examHallControllerProvider);
        expect(state.phase, ExamPhase.finished);
        expect(state.report, isNotNull);
        expect(f.repo.calls, contains('submit:submit-a-1'));
        expect(f.repo.saved.last.single.questionId, 'q1');
        expect(await f.store.activeAttempt(), isNull);
      },
    );

    test('submit offline keeps the attempt open', () async {
      final f = ExamHallFakes();
      final h = f.harness();
      final c = h.container.read(examHallControllerProvider.notifier);
      await c.start(mockFull);
      f.repo.submitError = HmApiException.network();
      await c.submit();
      final state = h.container.read(examHallControllerProvider);
      expect(state.phase, ExamPhase.active);
      expect(state.message, contains('offline'));
      expect(await f.store.activeAttempt(), 'a-1');
    });

    test('already submitted falls back to the report', () async {
      final f = ExamHallFakes()
        ..repo.submitError = const HmApiException(
          'MOCK_ALREADY_SUBMITTED',
          'done',
          statusCode: 409,
        );
      final h = f.harness();
      final c = h.container.read(examHallControllerProvider.notifier);
      await c.start(mockFull);
      await c.submit();
      expect(
        h.container.read(examHallControllerProvider).phase,
        ExamPhase.finished,
      );
      expect(f.repo.calls, contains('report:a-1'));
    });
  });

  group('screens', () {
    testWidgets('mock list shows Free/Pro before tap and the State Mock card', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(412, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final f = ExamHallFakes();
      final h = f.harness();
      await tester.pumpWidget(h.app(const ExamHallScreen()));
      await tester.pumpAndSettle();
      expect(find.text('State Mock Sunday'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(
        find.text('Free full mocks this month: 0 of 1 used'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'^Group 4 Full Mock 2\. Full mock\. Pro\. Locked\.'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('mock-m-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mock-start')), findsNothing);
      expect(find.byKey(const Key('mock-not-now')), findsOneWidget);
      expect(find.textContaining('₹'), findsNothing);
      await tester.tap(find.byKey(const Key('mock-not-now')));
      await tester.pumpAndSettle();
      expect(find.byType(MockListBody), findsOneWidget);
    });

    testWidgets('Calm Mode hides rank talk on the State Mock card', (
      tester,
    ) async {
      await tester.pumpWidget(
        Harness().app(
          Scaffold(
            body: StateMockSundayCard(
              info: sundayMock,
              now: fixedNow,
              calm: true,
              onStart: () {},
            ),
          ),
        ),
      );
      expect(find.textContaining('rank'), findsNothing);
    });

    testWidgets('offline start shows the connection message', (tester) async {
      final f = ExamHallFakes();
      f.network.online = false;
      final h = f.harness();
      await tester.pumpWidget(h.app(const MockStartScreen(mock: mockFull)));
      await tester.tap(find.byKey(const Key('mock-start')));
      await tester.pumpAndSettle();
      expect(find.text(ExamHallCopy.needsConnection), findsOneWidget);
    });

    testWidgets(
      'CBT: answer, mark, palette, confirm submit, locked report with Not now',
      (tester) async {
        tester.view.physicalSize = const Size(412, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final f = ExamHallFakes();
        final h = f.harness();
        await tester.pumpWidget(h.app(const MockStartScreen(mock: mockFull)));
        await tester.tap(find.byKey(const Key('mock-start')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('cbt-view')), findsOneWidget);
        expect(find.text('1:29:55'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Time left: 1 hour 29 minutes left'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('cbt-option-o2')));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel('Question 1, answered. Go to question'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('cbt-mark')));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(
            'Question 1, answered and marked for review. Go to question',
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('palette-2')));
        await tester.pumpAndSettle();
        expect(find.text('Question 3 of 3'), findsOneWidget);

        // One second later the clock is redrawn from the same server deadline.
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.text('1:29:55'),
          findsOneWidget,
          reason: 'clock comes from the injected clock',
        );

        await tester.tap(find.byKey(const Key('attempt-submit')));
        await tester.pumpAndSettle();
        expect(find.text('Submit this mock?'), findsOneWidget);
        await tester.tap(find.byKey(const Key('submit-confirm')));
        await tester.pumpAndSettle();

        expect(find.text('Your report'), findsOneWidget);
        expect(find.byKey(const Key('report-locked')), findsOneWidget);
        expect(find.byKey(const Key('report-not-now')), findsOneWidget);
        expect(find.textContaining('₹'), findsNothing);
        expect(find.textContaining('Buy'), findsNothing);
      },
    );

    testWidgets('OMR: bubbles have screen-reader labels and fill when chosen', (
      tester,
    ) async {
      final f = ExamHallFakes()..repo.mode = AnswerMode.omr;
      f.repo.session = sampleSession(mode: AnswerMode.omr);
      final h = f.harness();
      await h.container
          .read(examHallControllerProvider.notifier)
          .start(mockFull);
      await tester.pumpWidget(h.app(const MockAttemptScreen()));
      await tester.pump();
      expect(find.byKey(const Key('omr-sheet')), findsOneWidget);
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byKey(const Key('omr-q1-o2'))),
        matchesSemantics(
          label: 'Question 1, option B: Article 17',
          isButton: true,
          hasCheckedState: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.byKey(const Key('omr-q1-o2')));
      await tester.pump();
      expect(
        tester.getSemantics(find.byKey(const Key('omr-q1-o2'))),
        matchesSemantics(
          label: 'Question 1, option B: Article 17',
          isButton: true,
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('full report for Pro users lists mistakes', (tester) async {
      await tester.pumpWidget(
        Harness().app(
          Scaffold(
            body: ReportBody(
              report: sampleReport(locked: false),
              onDone: () {},
            ),
          ),
        ),
      );
      expect(find.text('Sangam literature is mostly poetry.'), findsOneWidget);
      expect(find.byKey(const Key('report-not-now')), findsNothing);
    });

    testWidgets('Exam Hall is reachable from Today', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        Harness().app(
          Scaffold(
            body: TodayTab(
              onOpenStudyMap: () {},
              onOpenExamHall: () => opened = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('today-open-exam-hall')));
      expect(opened, isTrue);
    });
  });

  group('200% text (§10.9)', () {
    Future<void> pumpAt200(WidgetTester tester, Harness h, Widget home) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        h.app(
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: home,
            ),
          ),
          theme: HmTheme.highContrast(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('list, start, CBT, OMR and report do not overflow', (
      tester,
    ) async {
      final f = ExamHallFakes();
      final h = f.harness();
      await pumpAt200(tester, h, const ExamHallScreen());
      expect(tester.takeException(), isNull, reason: 'list');
      await pumpAt200(tester, h, const MockStartScreen(mock: mockPro));
      expect(tester.takeException(), isNull, reason: 'start');
      await pumpAt200(tester, h, Scaffold(body: _attempt(sampleSession())));
      expect(tester.takeException(), isNull, reason: 'cbt');
      await pumpAt200(
        tester,
        h,
        Scaffold(body: _attempt(sampleSession(mode: AnswerMode.omr))),
      );
      expect(tester.takeException(), isNull, reason: 'omr');
      await pumpAt200(
        tester,
        h,
        Scaffold(
          body: ReportBody(report: sampleReport(), onDone: () {}),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'report');
    });
  });
}

Widget _attempt(MockSession s) => AttemptView(
  session: s,
  index: 0,
  timeLeft: const Duration(minutes: 89, seconds: 55),
  pending: 1,
  onChoose: (_, _) {},
  onToggleMark: (_) {},
  onGoTo: (_) {},
  onSubmit: () {},
);
