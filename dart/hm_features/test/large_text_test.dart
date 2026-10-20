import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

/// §10.9: text can be scaled up to 200% without breaking key screens (phone width 360 dp).
void main() {
  Future<void> pumpAt200(WidgetTester tester, Harness h, Widget home) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: MaterialApp(
          theme: HmTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding steps at 200% text', (tester) async {
    final h = Harness();
    await pumpAt200(tester, h, const OnboardingFlow());
    expect(tester.takeException(), isNull, reason: 'date of birth');

    h.controller.submitDateOfBirth(DateTime(2000, 1, 15));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'answers');

    h.controller
      ..setQualification(QualificationChoice.degree)
      ..setCommunity(CommunityChoice.mbcDnc)
      ..setPstm(true);
    await h.controller.checkEligibility();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'result');

    h.controller.continueToPickExams();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'pick exams');

    h.controller.continueToMapPreview();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'map preview');

    h.controller.continueToSave();
    await h.controller.requestCode('priya@example.com');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'code');

    await h.controller.verifyCode('123456');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'consent');
  });

  testWidgets('study map, lesson and profile at 200% text', (tester) async {
    final h = Harness();
    await pumpAt200(
      tester,
      h,
      Scaffold(body: StudyMapTab(onOpenTopic: (_) {})),
    );
    expect(tester.takeException(), isNull);
    await pumpAt200(tester, h, const LessonScreen(topicId: 't-1'));
    expect(tester.takeException(), isNull);
    await pumpAt200(tester, h, const Scaffold(body: ProfileTab()));
    expect(tester.takeException(), isNull);
    await pumpAt200(tester, h, Scaffold(body: TodayTab(onOpenStudyMap: () {})));
    expect(tester.takeException(), isNull);
  });
}
