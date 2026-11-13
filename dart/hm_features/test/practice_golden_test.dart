import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/practice_fakes.dart';

/// Study screen goldens (BOLT-0017, §10.9): dark, light, high contrast; Calm (relight, the Calm Today action)
/// and 200% text (practice feedback). Regenerate with:
/// flutter test --update-goldens test/practice_golden_test.dart
void main() {
  final themes = [
    ('dark', HmTheme.dark()),
    ('light', HmTheme.light()),
    ('high_contrast', HmTheme.highContrast()),
  ];

  PracticeState answered() => PracticeState(
    loading: false,
    session: PracticeSessionView(
      sessionId: 's',
      mode: StudyMode.practice,
      questions: [sampleQuestion('q1'), sampleQuestion('q2')],
      usage: sampleUsage(),
    ),
    usage: sampleUsage(used: 4),
    chosen: const {
      'q1': ['b'],
    },
    outcomes: {
      'q1': Graded(
        PracticeAnswerView(
          graded: graded('q1', correct: false),
          usage: sampleUsage(used: 4),
        ),
      ),
    },
  );

  PracticeBody practice() => PracticeBody(
    state: answered(),
    onChoose: (_) {},
    onCheck: () {},
    onNext: () {},
    onDone: () {},
    onRelight: (_) {},
  );

  final screens = <(String, Widget Function())>[
    ('practice', practice),
    (
      'relight',
      () => RelightQueueBody(queue: sampleRelightQueue, onRelight: (_) {}),
    ),
    (
      'mistakes',
      () => MistakesBody(
        view: sampleMistakes,
        onRelight: (_) {},
        onStartDrill: (_) {},
      ),
    ),
    (
      'pyq',
      () => PyqVaultBody(
        facets: pyqFacets,
        filter: const PyqFilter(),
        page: pyqPage,
        onFilter: (_) {},
        onPractise: () {},
      ),
    ),
    ('limit_sheet', () => LimitSheet(limit: 30, onNotNow: () {})),
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
      StudyFakes().harness().app(
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
      testWidgets('study $screen golden ($name)', (tester) async {
        await pump(tester, build(), theme);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/study_${screen}_$name.png'),
        );
      });
    }
  }

  testWidgets('study practice golden (200% text)', (tester) async {
    await pump(
      tester,
      practice(),
      HmTheme.dark(),
      textScale: 2,
      size: const Size(360, 2400),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/study_practice_large_text.png'),
    );
  });

  testWidgets('study map with lamp states golden (lite + 200% text)', (
    tester,
  ) async {
    const map = StudyMapView(
      examCode: 'tnpsc-group-4',
      totalTopics: 3,
      subjects: [
        SubjectView(
          code: 'polity',
          name: 'Indian Polity',
          order: 1,
          topics: [
            TopicView(
              id: 't-1',
              name: 'Constitution',
              order: 1,
              hasLesson: true,
              lamp: HmLampState(lit: true, steadyLevel: 2),
            ),
            TopicView(
              id: 't-2',
              name: 'Parliament',
              order: 2,
              hasLesson: true,
              lamp: HmLampState(lit: true, dim: HmLampDim.dimming),
            ),
            TopicView(
              id: 't-3',
              name: 'Judiciary',
              order: 3,
              hasLesson: true,
              lamp: HmLampState(lit: true, steadyLevel: 4, gold: true),
            ),
          ],
        ),
      ],
    );
    await pump(
      tester,
      StudyMapBody(map: map, lite: true, onOpenTopic: (_) {}),
      HmTheme.highContrast(),
      textScale: 2,
      size: const Size(360, 1400),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/study_map_lite_large_text.png'),
    );
  });
}
