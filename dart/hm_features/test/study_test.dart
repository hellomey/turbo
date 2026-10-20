import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

void main() {
  group('Study Map (§5.1, §10.6)', () {
    testWidgets('renders subjects as islands and topics as unlit lamps', (
      tester,
    ) async {
      final h = Harness();
      final opened = <String>[];
      await tester.pumpWidget(
        h.app(
          Scaffold(body: StudyMapTab(onOpenTopic: (t) => opened.add(t.id))),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Indian Polity'), findsOneWidget);
      expect(find.text('History of Tamil Nadu'), findsOneWidget);
      expect(find.byType(Lamp), findsNWidgets(3));
      for (final lamp in tester.widgetList<Lamp>(find.byType(Lamp))) {
        expect(lamp.state, HmLampState.unlit, reason: 'Phase 1: all unlit');
      }
      expect(
        find.bySemanticsLabel(
          'Constitution. Lit ring: off. Steady ring: 0 of 4. Gold ring: off.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('lamp-t-1')));
      expect(opened, ['t-1']);

      await tester.tap(find.byKey(const Key('lamp-t-2')));
      await tester.pump();
      expect(opened, ['t-1'], reason: 'no lesson yet');
      expect(find.text('Lesson coming soon.'), findsOneWidget);
    });

    testWidgets('Lite Mode shows a static list', (tester) async {
      final h = Harness(lite: true);
      await tester.pumpWidget(
        h.app(Scaffold(body: StudyMapTab(onOpenTopic: (_) {}))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Lamp), findsNothing);
      expect(find.byKey(const Key('lite-topic-t-1')), findsOneWidget);
      expect(find.text('Lesson coming soon'), findsOneWidget);
    });

    testWidgets('no main exam yet asks the user to pick one', (tester) async {
      final h = Harness(study: FakeStudyRepository()..main = null);
      await tester.pumpWidget(
        h.app(Scaffold(body: StudyMapTab(onOpenTopic: (_) {}))),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Pick your main exam to see your Study Map.'),
        findsOneWidget,
      );
    });

    test('maps contract JSON in order with ring state', () {
      final map = studyMapFromJson({
        'examCode': 'tnpsc-group-4',
        'totalTopics': 2,
        'subjects': [
          {'code': 'b', 'name': 'Second', 'order': 2, 'topics': <Object>[]},
          {
            'code': 'a',
            'name': 'First',
            'order': 1,
            'topics': [
              {
                'id': 'x2',
                'code': 'x2',
                'name': 'Later',
                'order': 2,
                'examCodes': ['tnpsc-group-4'],
                'hasLesson': false,
                'ring': {
                  'lit': false,
                  'steadyLevel': 0,
                  'gold': false,
                  'dim': 'bright',
                },
              },
              {
                'id': 'x1',
                'code': 'x1',
                'name': 'Sooner',
                'order': 1,
                'examCodes': <Object>[],
                'hasLesson': true,
                'ring': {
                  'lit': true,
                  'steadyLevel': 2,
                  'gold': false,
                  'dim': 'dimming',
                },
              },
            ],
          },
        ],
      });
      expect(map.subjects.map((s) => s.name), ['First', 'Second']);
      expect(map.subjects.first.topics.map((t) => t.name), ['Sooner', 'Later']);
      expect(
        map.subjects.first.topics.first.lamp,
        const HmLampState(lit: true, steadyLevel: 2, dim: HmLampDim.dimming),
      );
    });
  });

  group('Lesson + Listen Mode (§10.6, §19.3)', () {
    testWidgets('renders the reading view, refs and source; Listen and Stop', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.app(const LessonScreen(topicId: 't-1')));
      await tester.pumpAndSettle();

      expect(find.text('The Constitution'), findsOneWidget);
      expect(find.text('4 min read'), findsOneWidget);
      expect(find.text('What it is'), findsOneWidget);
      expect(
        find.text(
          'The Constitution is the main law of India.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.text('It came into force in 1950.', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.text('Class 10 Social Science, Chapter 3, pages 41-45'),
        findsOneWidget,
      );
      expect(
        find.text('Tamil Nadu State Board, Class 10 Social Science (2024).'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('lesson-listen')));
      await tester.pump();
      expect(h.tts.spoken.single, startsWith('The Constitution.'));
      expect(h.tts.spoken.single, isNot(contains('**')));
      expect(h.tts.spoken.single, isNot(contains('#')));
      expect(find.byKey(const Key('lesson-stop')), findsOneWidget);

      await tester.tap(find.byKey(const Key('lesson-stop')));
      await tester.pump();
      expect(h.tts.stops, greaterThanOrEqualTo(1));
      expect(find.byKey(const Key('lesson-listen')), findsOneWidget);

      // Speech ending on its own resets the button.
      await tester.tap(find.byKey(const Key('lesson-listen')));
      await tester.pump();
      h.tts.finish();
      await tester.pump();
      expect(find.byKey(const Key('lesson-listen')), findsOneWidget);
    });

    test('markdown: headings, paragraphs, bullets, bold', () {
      final blocks = parseMarkdown(
        '## Title\nLine one\nline two with **bold**.\n\n* item one\n1. item two',
      );
      expect(blocks, hasLength(4));
      expect(blocks[0], isA<MdHeading>().having((h) => h.level, 'level', 2));
      expect(blocks[1].text, 'Line one line two with bold.');
      expect(blocks[1].spans[1], const MdSpan('bold', bold: true));
      expect(blocks[2], isA<MdBullet>());
      expect(blocks[3].text, 'item two');
    });
  });

  group('Today, Play, Squad', () {
    testWidgets('Today leads to the Study Map; Play/Squad are calm', (
      tester,
    ) async {
      final h = Harness();
      var opened = 0;
      await tester.pumpWidget(
        h.app(Scaffold(body: TodayTab(onOpenStudyMap: () => opened++))),
      );
      await tester.tap(find.byKey(const Key('today-open-map')));
      expect(opened, 1);

      await tester.pumpWidget(h.app(const Scaffold(body: PlayTab())));
      expect(find.text('Games are coming soon'), findsOneWidget);
      await tester.pumpWidget(h.app(const Scaffold(body: SquadTab())));
      expect(find.text('Squads are coming soon'), findsOneWidget);
    });
  });

  group('Profile (§10.5, §38)', () {
    testWidgets('shows the user, toggles Calm Mode, logs out', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final h = Harness();
      h.container.read(sessionProvider.notifier).markSignedIn();
      await tester.pumpWidget(h.app(const Scaffold(body: ProfileTab())));
      await tester.pumpAndSettle();

      expect(find.text('priya@example.com'), findsOneWidget);
      await tester.tap(find.byKey(const Key('calm-mode')));
      await tester.pumpAndSettle();
      expect(h.profile.calls, ['calm:true']);
      expect(
        tester.widget<SwitchListTile>(find.byKey(const Key('calm-mode'))).value,
        isTrue,
      );

      await tester.tap(find.byKey(const Key('logout-all')));
      await tester.pumpAndSettle();
      expect(h.profile.calls.last, 'logoutAll');
      expect(h.container.read(sessionProvider), SessionStatus.signedOut);
    });

    testWidgets('delete account explains 7 days, sends a code, schedules', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(
        h.app(const DeleteAccountScreen(email: 'priya@example.com')),
      );
      expect(find.textContaining('we wait 7 days first'), findsOneWidget);
      await tester.tap(find.byKey(const Key('delete-send-code')));
      await tester.pumpAndSettle();
      expect(h.profile.calls, ['deleteCode:priya@example.com']);

      await tester.enterText(find.byKey(const Key('hm-code-field')), '654321');
      await tester.pumpAndSettle();
      expect(h.profile.calls.last, 'delete:654321');
      expect(
        find.text(
          'Your account will be deleted on 27 October 2026. '
          'Sign in before then if you change your mind.',
        ),
        findsOneWidget,
      );
    });
  });
}
