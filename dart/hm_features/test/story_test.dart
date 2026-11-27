import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('the welcome scene shows the story and the beta line', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = Harness();
    await tester.pumpWidget(h.app(const OnboardingFlow()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-darkHall')), findsOneWidget);
    expect(
      find.text(
        "Tamil Nadu's study halls have gone dark. You are the new Lamplighter.",
      ),
      findsOneWidget,
    );
    expect(find.text(storyBetaLine), findsOneWidget);
    // The step itself is unchanged.
    expect(find.byKey(const Key('dob-continue')), findsOneWidget);
  });

  testWidgets('"Skip story" hides the scenes and keeps the step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = Harness();
    await tester.pumpWidget(h.app(const OnboardingFlow()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('story-skip')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-darkHall')), findsNothing);
    expect(h.container.read(storyOnProvider), isFalse);
    expect(h.state.step, OnboardingStep.dob);
    expect(find.byKey(const Key('dob-continue')), findsOneWidget);
  });

  testWidgets('the story replays all five scenes from Profile', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = Harness();
    await tester.pumpWidget(h.app(const StoryReplayScreen()));
    await tester.pumpAndSettle();

    for (final scene in StoryScene.values) {
      expect(find.text(scene.line), findsOneWidget);
      expect(
        find.text(scene == StoryScene.firstLamp ? 'Done' : 'Next scene'),
        findsOneWidget,
      );
      if (scene != StoryScene.firstLamp) {
        await tester.tap(find.byKey(const Key('story-replay-next')));
        await tester.pumpAndSettle();
      }
    }
  });
}
