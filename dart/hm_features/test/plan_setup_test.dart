import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';
import 'support/plan_fakes.dart';

/// Plan setup (BOLT-0018, INT-002-S12, contract PutPlanBody).
void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    Harness h, {
    VoidCallback? onDone,
  }) async {
    tester.view.physicalSize = const Size(412, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(h.app(PlanSetupScreen(onDone: onDone ?? () {})));
    await tester.pumpAndSettle();
  }

  testWidgets('saves cycles then the plan with an Idempotency-Key', (
    tester,
  ) async {
    final f = PlanFakes();
    final h = f.harness();
    h.container.read(planSetupPendingProvider.notifier).set(true);
    var done = 0;
    await pumpScreen(tester, h, onDone: () => done++);

    await tester.tap(find.byKey(const Key('setup-weekday-90')));
    await tester.tap(find.byKey(const Key('setup-weekend-240')));
    await tester.tap(find.byKey(const Key('setup-pocket-15')));
    await tester.tap(find.byKey(const Key('setup-cycle-tnpsc-group-4-c-2027')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setup-save')));
    await tester.pumpAndSettle();

    expect(f.setup.calls, [
      'cycles:{tnpsc-group-4: c-2027}',
      'plan:{weekdayMinutes: 90, weekendMinutes: 240, pocketMinutes: 15, balance: 0}:key-1',
    ]);
    expect(done, 1);
    expect(h.container.read(planSetupPendingProvider), isFalse);
  });

  testWidgets('shows the server error code on failure', (tester) async {
    final f = PlanFakes()
      ..setup.saveError = const HmApiException(
        'VALIDATION_FAILED',
        'Choose your main exam first.',
      );
    var done = 0;
    await pumpScreen(tester, f.harness(), onDone: () => done++);
    await tester.tap(find.byKey(const Key('setup-save')));
    await tester.pumpAndSettle();
    expect(
      find.text('Choose your main exam first. (VALIDATION_FAILED)'),
      findsOneWidget,
    );
    expect(done, 0);
  });

  test('balance dial is clamped to -2..2 and labelled', () {
    expect(const PlanSetupDraft().copyWith(balance: 5).balance, 2);
    expect(PlanSetupCopy.balance(2), 'Mostly new topics');
    expect(PlanSetupCopy.minutes(90), '1 h 30 min');
  });

  testWidgets('Today with no plan offers "Set up your plan"', (tester) async {
    final f = PlanFakes()..plan.todayView = sampleToday(hasPlan: false);
    var opened = 0;
    await tester.pumpWidget(
      f.harness().app(
        Scaffold(
          body: TodayTab(
            onOpenStudyMap: () {},
            onStartItem: (_) {},
            onSetUpPlan: () => opened++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('today-setup-plan')));
    expect(opened, 1);
  });

  group('goldens', () {
    const state = PlanSetupState(
      options: setupOptions,
      draft: PlanSetupDraft(cycles: {'tnpsc-group-4': 'c-2026'}),
    );
    final cases = [
      ('dark', HmTheme.dark(), 1.0, const Size(412, 1400)),
      ('light', HmTheme.light(), 1.0, const Size(412, 1400)),
      ('high_contrast', HmTheme.highContrast(), 1.0, const Size(412, 1400)),
      ('large_text', HmTheme.dark(), 2.0, const Size(360, 2600)),
    ];
    for (final (name, theme, scale, size) in cases) {
      testWidgets('plan setup golden ($name)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          Harness().app(
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: Scaffold(
                  body: PlanSetupBody(
                    state: state,
                    onEdit: (_) {},
                    onSave: () {},
                  ),
                ),
              ),
            ),
            theme: theme,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/plan_setup_$name.png'),
        );
      });
    }
  });
}
