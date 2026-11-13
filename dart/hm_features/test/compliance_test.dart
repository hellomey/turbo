import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

/// Compliance review fixes (BOLT-0006: C1, C3, M6, M7, M8).
void main() {
  Future<Harness> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = Harness();
    h.profile.notice = const ConsentNoticeInfo(
      version: '2026-10-v2',
      purposes: [
        ConsentPurposeInfo(
          purpose: 'core_service',
          required: true,
          title: 'Run my HeyMey account',
          description: 'A longer description from the server.',
        ),
        ConsentPurposeInfo(
          purpose: 'offers_email',
          required: false,
          title: 'Email me about offers',
          description: 'At most one email a week.',
        ),
        ConsentPurposeInfo(
          purpose: 'product_research',
          required: false,
          title: 'Help improve HeyMey',
          description: 'Usage data without my name.',
        ),
      ],
    );
    await tester.pumpWidget(h.app(const Scaffold(body: ProfileTab())));
    await tester.pumpAndSettle();
    return h;
  }

  testWidgets(
    'C1: Profile shows optional choices as switches and saves ALL purposes '
    'with the current notice version',
    (tester) async {
      final h = await pumpProfile(tester);
      expect(find.text('Your data choices'), findsOneWidget);
      expect(find.byKey(const Key('data-choice-core_service')), findsNothing);
      SwitchListTile tile(String p) =>
          tester.widget<SwitchListTile>(find.byKey(Key('data-choice-$p')));
      expect(tile('offers_email').value, isFalse);
      expect(tile('product_research').value, isTrue);

      await tester.tap(find.byKey(const Key('data-choice-offers_email')));
      await tester.pumpAndSettle();

      expect(h.profile.savedConsents!.$1, '2026-10-v2');
      expect(h.profile.savedConsents!.$2, {
        'core_service': true,
        'offers_email': true,
        'product_research': true,
      });
      expect(tile('offers_email').value, isTrue);
    },
  );

  testWidgets('C1: Profile links Privacy, Terms and the grievance email', (
    tester,
  ) async {
    final h = await pumpProfile(tester);
    expect(
      find.text('Questions or complaints: grievance@heymey.app'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('privacy-link')));
    await tester.tap(find.byKey(const Key('terms-link')));
    expect(h.links.opened, [
      'https://heymey.app/legal/privacy',
      'https://heymey.app/legal/terms',
    ]);
  });

  testWidgets('M6: an empty result explains and offers Change answers', (
    tester,
  ) async {
    final h = Harness();
    var changed = 0;
    await tester.pumpWidget(
      h.app(
        Scaffold(
          body: EligibilityResultView(
            result: eligibility(count: 0),
            onOpenLink: (_) {},
            onContinue: () {},
            onChangeAnswers: () => changed++,
          ),
        ),
      ),
    );
    expect(
      find.text(
        'No exam in our list matches these answers yet. We are adding more exams. '
        'If an answer is wrong, tap Change answers.',
      ),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsNothing);
    await tester.tap(find.text('Change answers'));
    expect(changed, 1);
  });

  testWidgets(
    'M7: the confirm line appears once when the server disclaimer has it',
    (tester) async {
      final h = Harness();
      const disclaimer =
          'Rules checked on 1 October 2026. Always confirm with the official notification.';
      await tester.pumpWidget(
        h.app(
          Scaffold(
            body: EligibilityResultView(
              result: EligibilityView(
                eligibleCount: 1,
                eligible: [exam(1)],
                disclaimer: disclaimer,
              ),
              onOpenLink: (_) {},
            ),
          ),
        ),
      );
      expect(
        find.textContaining('Always confirm with the official notification.'),
        findsOneWidget,
      );
      expect(find.text(disclaimer), findsOneWidget);
    },
  );

  test('M8: share text', () {
    expect(
      eligibility(count: 2).shareText(),
      'HeyMey shows I can write 2 exams.\nMy top exams:\n'
      '- Exam number 1\n- Exam number 2\n'
      'Always confirm with the official notification.',
    );
  });

  testWidgets('special categories hint explains why we ask', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = Harness();
    await tester.pumpWidget(h.app(const OnboardingFlow()));
    h.controller.submitDateOfBirth(DateTime(2000, 1, 15));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Tap any that apply. We use this only to check age relaxations. You can skip this.',
      ),
      findsOneWidget,
    );
  });
}
