import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/exam_hall_fakes.dart';
import 'support/fakes.dart';

/// Exam Hall goldens (BOLT-0019, §10.6, §10.9): dark, light and high contrast for the key screens, plus
/// Calm Mode (list) and 200% text (CBT). Regenerate with:
/// flutter test --update-goldens test/exam_hall_golden_test.dart
void main() {
  final themes = [
    ('dark', HmTheme.dark()),
    ('light', HmTheme.light()),
    ('high_contrast', HmTheme.highContrast()),
  ];

  Widget attempt(MockSession s) => AttemptView(
    session: s,
    index: 0,
    timeLeft: const Duration(minutes: 89, seconds: 55),
    pending: 1,
    onChoose: (_, _) {},
    onToggleMark: (_) {},
    onGoTo: (_) {},
    onSubmit: () {},
  );

  const answers = {
    'q1': SessionAnswer(chosen: ['o2']),
    'q2': SessionAnswer(marked: true),
  };

  final screens = <(String, Widget Function())>[
    (
      'list',
      () => MockListBody(
        list: mockList,
        stateMock: sundayMock,
        now: fixedNow,
        onOpenMock: (_) {},
        onResume: () {},
      ),
    ),
    ('cbt', () => attempt(sampleSession(answers: answers))),
    (
      'omr',
      () => attempt(sampleSession(mode: AnswerMode.omr, answers: answers)),
    ),
    ('report_locked', () => ReportBody(report: sampleReport(), onDone: () {})),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget body,
    ThemeData theme, {
    double textScale = 1,
    Size size = const Size(412, 915),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Harness().app(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(body: body),
          ),
        ),
        theme: theme,
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (screen, build) in screens) {
    for (final (name, theme) in themes) {
      testWidgets('exam hall $screen golden ($name)', (tester) async {
        await pump(tester, build(), theme);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/exam_hall_${screen}_$name.png'),
        );
      });
    }
  }

  testWidgets('exam hall list golden (calm)', (tester) async {
    await pump(
      tester,
      MockListBody(
        list: mockList,
        stateMock: sundayMock,
        now: fixedNow,
        calm: true,
        onOpenMock: (_) {},
      ),
      HmTheme.dark(),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/exam_hall_list_calm.png'),
    );
  });

  testWidgets('exam hall cbt golden (200% text)', (tester) async {
    await pump(
      tester,
      attempt(sampleSession(answers: answers)),
      HmTheme.dark(),
      textScale: 2,
      size: const Size(360, 1600),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/exam_hall_cbt_large_text.png'),
    );
  });
}
