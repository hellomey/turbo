import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';
import 'support/plan_fakes.dart';

/// BOLT-0018 goldens (§10.9, §10.7): Today, My Plan, Readiness, Sunday Report, Exam Alerts and alert settings
/// in dark, light and high contrast, plus Today in Calm Mode and Today/Readiness at 200% text.
/// Regenerate with: flutter test --update-goldens test/plan_golden_test.dart
void main() {
  final themes = [
    ('dark', HmTheme.dark()),
    ('light', HmTheme.light()),
    ('high_contrast', HmTheme.highContrast()),
  ];

  Widget todayBody({bool calm = false}) => TodayBody(
    today: AsyncData(
      sampleToday(
        stretch: StretchView.d90,
        welcomeBack: 'Welcome back. Your plan is ready for today.',
      ),
    ),
    calm: calm,
    onOpenStudyMap: () {},
    onOpenExamHall: () {},
    onOpenPlan: () {},
    onStartItem: (_) {},
    onOpenRelight: () {},
    onStartPocket: (_) {},
  );

  final screens = <(String, Widget Function())>[
    ('today', todayBody),
    (
      'my_plan',
      () =>
          MyPlanBody(days: sampleDays(), onMark: (_, _) {}, onRebalance: () {}),
    ),
    (
      'readiness',
      () => ReadinessBody(view: sampleReadiness(), onOpenReports: () {}),
    ),
    ('sunday_report', () => SundayReportBody(report: sampleReport())),
    (
      'exam_alerts',
      () => ExamAlertsBody(
        items: [
          sampleAlert('a1'),
          sampleAlert('a2', title: 'Hall ticket out'),
        ],
        onOpenOfficial: (_) {},
        hasMore: true,
        onLoadMore: () {},
      ),
    ),
    (
      'alert_settings',
      () => AlertSettingsBody(settings: sampleSettings, onChanged: (_) {}),
    ),
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
      testWidgets('$screen golden ($name)', (tester) async {
        await pump(tester, build(), theme);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/${screen}_$name.png'),
        );
      });
    }
  }

  testWidgets('today golden (calm)', (tester) async {
    await pump(tester, todayBody(calm: true), HmTheme.dark());
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/today_calm.png'),
    );
  });

  testWidgets('today golden (200% text)', (tester) async {
    await pump(
      tester,
      todayBody(),
      HmTheme.dark(),
      textScale: 2,
      size: const Size(360, 2400),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/today_large_text.png'),
    );
  });

  testWidgets('readiness golden (200% text)', (tester) async {
    await pump(
      tester,
      ReadinessBody(view: sampleReadiness()),
      HmTheme.dark(),
      textScale: 2,
      size: const Size(360, 2000),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/readiness_large_text.png'),
    );
  });
}
