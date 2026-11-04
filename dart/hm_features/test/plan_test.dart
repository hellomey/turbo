import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_features/hm_features.dart';

import 'support/plan_fakes.dart';

/// BOLT-0018: Today, My Plan, rank bar, Readiness, Sunday Reports, Exam Alerts, alert settings, push.
void main() {
  group('domain', () {
    test('rank progress inside the level and XP to the next level', () {
      final r = sampleToday().rank;
      expect(r.progress, closeTo(0.4, 1e-9));
      expect(r.xpToNext, 60);
      const top = RankView(
        level: 10,
        title: 'Top',
        xp: 9000,
        xpForThisLevel: 8000,
        note: '',
      );
      expect(top.progress, 1);
      expect(top.xpToNext, isNull);
    });

    test('only pending items can be marked', () {
      expect(planItem('a').canMark, isTrue);
      expect(planItem('a', status: PlanItemStatusView.done).canMark, isFalse);
    });

    test('alert settings clamp the daily limit to 3 and keep quiet hours', () {
      final s = sampleSettings.copyWith(dailyLimit: 9);
      expect(s.dailyLimit, 3);
      final json = s.toJson();
      expect(json['quietHours'], {
        'enabled': true,
        'startMinute': 1320,
        'endMinute': 420,
      });
      expect(formatMinuteOfDay(1320), '10:00 PM');
      expect(formatMinuteOfDay(0), '12:00 AM');
    });

    test('readiness has no overall percentage and knows "no evidence"', () {
      expect(sampleReadiness().noEvidence, isFalse);
      expect(sampleReadiness(noEvidence: true).noEvidence, isTrue);
    });
  });

  group('plan controller', () {
    test(
      'marking an item writes plan_item_status to the outbox first',
      () async {
        final f = PlanFakes();
        final c = f.harness().container;
        final ok = await c
            .read(planControllerProvider.notifier)
            .mark(planItem('i1'), PlanItemStatusView.done);
        expect(ok, isTrue);
        final pending = await f.outboxStore.pending(limit: 10);
        expect(pending.single.kind, 'plan_item_status');
        expect(pending.single.payloadJson, contains('"status":"done"'));
        expect(
          c.read(planControllerProvider).apply(planItem('i1')).status,
          PlanItemStatusView.done,
        );
        await Future<void>.delayed(Duration.zero);
        expect(f.nudges, 1);
      },
    );

    test('a done item is not marked again', () async {
      final f = PlanFakes();
      final c = f.harness().container;
      final ok = await c
          .read(planControllerProvider.notifier)
          .mark(
            planItem('i2', status: PlanItemStatusView.done),
            PlanItemStatusView.skipped,
          );
      expect(ok, isFalse);
      expect(await f.outboxStore.pendingCount(), 0);
    });

    test('My Plan asks for 14 days from the server day', () async {
      final f = PlanFakes();
      final c = f.harness().container;
      await c.read(planDaysProvider.future);
      expect(f.plan.calls, contains('days:2026-10-20..2026-11-02'));
    });

    test(
      'rebalance sends an Idempotency-Key and reports errors simply',
      () async {
        final f = PlanFakes();
        final c = f.harness().container;
        expect(
          await c.read(planControllerProvider.notifier).rebalance(),
          isTrue,
        );
        expect(f.plan.calls, contains('rebalance:key-1'));
        expect(c.read(planControllerProvider).message, PlanCopy.rebalanced);

        f.plan.rebalanceError = HmApiException.network();
        expect(
          await c.read(planControllerProvider.notifier).rebalance(),
          isFalse,
        );
        expect(
          c.read(planControllerProvider).message,
          HmApiException.network().message,
        );
      },
    );
  });

  group('Today', () {
    Widget today(List<Object> log) => Scaffold(
      body: TodayTab(
        onOpenStudyMap: () => log.add('map'),
        onOpenExamHall: () => log.add('exam'),
        onOpenPlan: () => log.add('plan'),
        onStartItem: (i) => log.add('start:${i.id}'),
        onOpenRelight: () => log.add('relight'),
        onStartPocket: (m) => log.add('pocket:$m'),
      ),
    );

    testWidgets('shows rank bar, Today Card, relight and pocket sessions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(412, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final f = PlanFakes();
      final log = <Object>[];
      await tester.pumpWidget(f.harness().app(today(log)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rank-bar')), findsOneWidget);
      expect(find.text('Relight 4 · 8 min'), findsOneWidget);
      expect(find.byKey(const Key('today-pocket-10')), findsOneWidget);
      expect(find.byKey(const Key('today-open-exam-hall')), findsOneWidget);

      await tester.tap(find.byKey(const Key('today-card-start')));
      await tester.ensureVisible(find.byKey(const Key('today-open-plan')));
      await tester.tap(find.byKey(const Key('today-open-plan')));
      expect(log, ['start:i1', 'plan']);
      expect(
        tester.getSemantics(find.byKey(const Key('rank-bar'))).label,
        contains('level 3'),
      );
    });

    testWidgets('Mark as done goes to the outbox and the card shows Done', (
      tester,
    ) async {
      final f = PlanFakes();
      await tester.pumpWidget(f.harness().app(today([])));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('today-card-done')));
      await tester.pumpAndSettle();
      expect(find.text('Done. Well done.'), findsOneWidget);
      expect(await f.outboxStore.pendingCount(), 1);
    });

    testWidgets('Calm Mode: only Today Card, Study and Relight', (
      tester,
    ) async {
      final f = PlanFakes();
      await tester.pumpWidget(f.harness(calm: true).app(today([])));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rank-bar')), findsNothing);
      expect(find.byKey(const Key('today-pocket-5')), findsNothing);
      expect(find.byKey(const Key('today-open-plan')), findsNothing);
      expect(find.byKey(const Key('today-card')), findsOneWidget);
      expect(find.byKey(const Key('today-relight')), findsOneWidget);
      expect(find.byKey(const Key('today-open-map')), findsOneWidget);
    });

    testWidgets('no plan shows a simple line', (tester) async {
      final f = PlanFakes()..plan.todayView = sampleToday(hasPlan: false);
      await tester.pumpWidget(f.harness().app(today([])));
      await tester.pumpAndSettle();
      expect(find.text(PlanCopy.noPlan), findsOneWidget);
    });
  });

  group('My Plan', () {
    testWidgets('14-day list with status and Done/Skip on pending items', (
      tester,
    ) async {
      final f = PlanFakes();
      await tester.pumpWidget(f.harness().app(const MyPlanScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Today, Tue 20 Oct'), findsOneWidget);
      expect(find.byKey(const Key('plan-done-i1')), findsOneWidget);
      expect(find.byKey(const Key('plan-done-i2')), findsNothing);

      await tester.tap(find.byKey(const Key('plan-skip-i1')));
      await tester.pumpAndSettle();
      expect(find.text(PlanCopy.savedOffline), findsOneWidget);
      expect(find.byKey(const Key('plan-skip-i1')), findsNothing);

      await tester.tap(find.byKey(const Key('plan-rebalance')));
      await tester.pumpAndSettle();
      expect(f.plan.calls, contains('rebalance:key-1'));
    });
  });

  group('Readiness and reports', () {
    testWidgets('Coverage and Memory show values; the others are locked Pro', (
      tester,
    ) async {
      final f = PlanFakes();
      await tester.pumpWidget(f.harness().app(const ReadinessScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Readiness: Building'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
      expect(find.text('Lit 42% · Steady 30% · Gold 5%'), findsOneWidget);
      expect(find.text('Pro'), findsNWidgets(2));
      expect(
        tester.getSemantics(find.byKey(const Key('readiness-bar-speed'))).label,
        contains('locked'),
      );
    });

    testWidgets('no evidence shows the simple line', (tester) async {
      final f = PlanFakes()
        ..readiness.meterView = sampleReadiness(noEvidence: true);
      await tester.pumpWidget(f.harness().app(const ReadinessScreen()));
      await tester.pumpAndSettle();
      expect(find.text(ReadinessCopy.noEvidence), findsOneWidget);
      expect(find.text('Readiness: Not yet'), findsOneWidget);
    });

    testWidgets('report list opens a report; detail shows server lines', (
      tester,
    ) async {
      final f = PlanFakes();
      String? opened;
      await tester.pumpWidget(
        f.harness().app(
          SundayReportListScreen(onOpenReport: (id) => opened = id),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('report-r1')));
      expect(opened, 'r1');

      await tester.pumpWidget(
        f.harness().app(const SundayReportScreen(reportId: 'r2')),
      );
      await tester.pumpAndSettle();
      expect(find.text('You lit 12 new lamps this week.'), findsOneWidget);
      expect(find.text('Next week'), findsOneWidget);
      expect(find.textContaining('selected'), findsNothing);
    });
  });

  group('Alerts', () {
    testWidgets('Exam Alerts open the official notice and load older ones', (
      tester,
    ) async {
      final f = PlanFakes();
      final h = f.harness();
      await tester.pumpWidget(h.app(const ExamAlertsScreen()));
      await tester.pumpAndSettle();
      expect(
        find.text('Always confirm with the official notification.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('exam-alert-open-a1')));
      await tester.pumpAndSettle();
      expect(h.links.opened, ['https://tnpsc.gov.in/notifications/a1']);
      await tester.tap(find.byKey(const Key('exam-alerts-more')));
      await tester.pumpAndSettle();
      expect(find.text('Hall ticket out'), findsOneWidget);
      expect(find.byKey(const Key('exam-alerts-more')), findsNothing);
    });

    testWidgets('settings save at once; a failure restores the saved value', (
      tester,
    ) async {
      final f = PlanFakes();
      await tester.pumpWidget(f.harness().app(const AlertSettingsScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('alerts-limit-1')));
      await tester.pumpAndSettle();
      expect(f.alerts.saved.dailyLimit, 1);

      f.alerts.saveError = const HmApiException(
        'CONSENT_REQUIRED',
        'Turn on offers consent in Privacy first.',
      );
      await tester.tap(find.byKey(const Key('alerts-offers')));
      await tester.pumpAndSettle();
      expect(f.alerts.saved.offers, isFalse);
      expect(
        find.text('Turn on offers consent in Privacy first.'),
        findsOneWidget,
      );
      final offers = tester.widget<SwitchListTile>(
        find.byKey(const Key('alerts-offers')),
      );
      expect(offers.value, isFalse);
    });

    test('push: the no-op source never registers; a real token does', () async {
      final f = PlanFakes();
      expect(
        await f
            .harness()
            .container
            .read(pushRegistrarProvider)
            .registerIfAvailable(),
        isFalse,
      );
      expect(f.alerts.tokens, isEmpty);
      final h = f.harness(
        more: [
          pushTokenSourceProvider.overrideWithValue(FakePushSource('tok')),
        ],
      );
      expect(
        await h.container.read(pushRegistrarProvider).registerIfAvailable(),
        isTrue,
      );
      expect(f.alerts.tokens, ['android:tok']);
    });
  });

  group('200% text', () {
    final screens = <(String, Widget)>[
      (
        'today',
        Scaffold(
          body: TodayTab(
            onOpenStudyMap: () {},
            onOpenPlan: () {},
            onStartItem: (_) {},
            onOpenRelight: () {},
            onStartPocket: (_) {},
            onOpenExamHall: () {},
          ),
        ),
      ),
      ('plan', const MyPlanScreen()),
      ('readiness', const ReadinessScreen()),
      ('reports', SundayReportListScreen(onOpenReport: (_) {})),
      ('report', const SundayReportScreen(reportId: 'r2')),
      ('alerts', const ExamAlertsScreen()),
      ('settings', const AlertSettingsScreen()),
    ];
    for (final (name, screen) in screens) {
      testWidgets('$name has no overflow at 200%', (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final f = PlanFakes();
        await tester.pumpWidget(
          f.harness().app(
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: screen,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
