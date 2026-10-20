import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

const under18 = 'HeyMey is for 18+. See you on your 18th birthday.';

Future<Harness> pumpFlow(WidgetTester tester, {Harness? harness}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = harness ?? Harness();
  await tester.pumpWidget(h.app(const OnboardingFlow()));
  await tester.pumpAndSettle();
  return h;
}

/// Fills step 2 with taps only.
Future<void> answerProfile(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('qualification-degree')));
  await tester.pump();
  await tester.ensureVisible(find.byKey(const Key('community-BC')));
  await tester.tap(find.byKey(const Key('community-BC')));
  await tester.pump();
  await tester.ensureVisible(find.byKey(const Key('pstm-yes')));
  await tester.tap(find.byKey(const Key('pstm-yes')));
  await tester.pump();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('AgeGate (§17.1 step 1, IST)', () {
    test('17 years 364 days is blocked; 18 today is allowed', () {
      // fixedNow = 20 Oct 2026 in IST.
      expect(AgeGate.isAdult(DateTime(2008, 10, 21), fixedNow), isFalse);
      expect(AgeGate.isAdult(DateTime(2008, 10, 20), fixedNow), isTrue);
      expect(AgeGate.isAdult(DateTime(1990, 1, 1), fixedNow), isTrue);
    });

    test('uses the IST date, not UTC: 00:30 IST is already the next day', () {
      final justAfterIstMidnight = DateTime.utc(2026, 10, 19, 19, 0);
      expect(AgeGate.istToday(justAfterIstMidnight), DateTime(2026, 10, 20));
      expect(
        AgeGate.isAdult(DateTime(2008, 10, 20), justAfterIstMidnight),
        isTrue,
      );
      final justBeforeIstMidnight = DateTime.utc(2026, 10, 19, 18, 29);
      expect(
        AgeGate.isAdult(DateTime(2008, 10, 20), justBeforeIstMidnight),
        isFalse,
      );
    });

    test('rejects dates that do not exist', () {
      expect(AgeGate.isRealDate(2001, 2, 29), isFalse);
      expect(AgeGate.isRealDate(2000, 2, 29), isTrue);
    });
  });

  group('DOB gate', () {
    testWidgets(
      '17 years 364 days shows the exact message and stores nothing',
      (tester) async {
        final h = await pumpFlow(tester);
        expect(find.text("Let's find your exams"), findsOneWidget);
        h.controller.submitDateOfBirth(DateTime(2008, 10, 21));
        await tester.pumpAndSettle();

        expect(find.text(under18), findsOneWidget);
        expect(h.state.step, OnboardingStep.under18);
        expect(h.state.draft.dateOfBirth, isNull, reason: 'draft wiped');
        expect(h.onboarding.calls, isEmpty, reason: 'nothing sent');
        expect(await h.tokens.read(), isNull, reason: 'nothing stored');
      },
    );

    testWidgets('18 today continues to the questions', (tester) async {
      final h = await pumpFlow(tester);
      h.controller.submitDateOfBirth(DateTime(2008, 10, 20));
      await tester.pumpAndSettle();
      expect(find.text('About your studies'), findsOneWidget);
      expect(find.text(under18), findsNothing);
    });

    testWidgets('the server UNDER_18 also shows the 18+ screen', (
      tester,
    ) async {
      final h = Harness(
        onboarding: FakeOnboardingRepository(
          eligibilityError: const HmApiException(
            'UNDER_18',
            under18,
            statusCode: 422,
          ),
        ),
      );
      await pumpFlow(tester, harness: h);
      h.controller.submitDateOfBirth(DateTime(2000, 1, 1));
      await tester.pumpAndSettle();
      await answerProfile(tester);
      await tapKey(tester, 'answers-check');
      expect(find.text(under18), findsOneWidget);
      expect(h.state.draft.isComplete, isFalse);
    });

    testWidgets('picking day, month and year with taps', (tester) async {
      final h = await pumpFlow(tester);
      Future<void> pick(String key, String item) async {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.text(item).last);
        await tester.pumpAndSettle();
      }

      await pick('dob-day', '5');
      await pick('dob-month', 'March');
      await pick('dob-year', '2026');
      await tapKey(tester, 'dob-continue');
      // Born this year: under 18.
      expect(find.text(under18), findsOneWidget);
      expect(h.onboarding.calls, isEmpty);
    });
  });

  group('profile answers (§17.1 step 2)', () {
    testWidgets(
      'one-tap answers; degree subject only for degree/PG; body sent',
      (tester) async {
        final h = await pumpFlow(tester);
        h.controller.submitDateOfBirth(DateTime(2000, 1, 15));
        await tester.pumpAndSettle();

        final check = find.byKey(const Key('answers-check'));
        FilledButton button() => tester.widget<FilledButton>(
          find.descendant(of: check, matching: find.byType(FilledButton)),
        );
        expect(button().onPressed, isNull, reason: 'incomplete');

        await tester.tap(find.byKey(const Key('qualification-hsc')));
        await tester.pump();
        expect(find.byKey(const Key('degree-subject')), findsNothing);

        await answerProfile(tester); // switches to degree
        expect(find.byKey(const Key('degree-subject')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('degree-subject')),
          'Mathematics',
        );
        await tester.ensureVisible(find.byKey(const Key('special-PWD')));
        await tester.tap(find.byKey(const Key('special-PWD')));
        await tester.pump();
        expect(button().onPressed, isNotNull);

        await tapKey(tester, 'answers-check');
        final input = h.onboarding.checkedDraft!.toInput().toJson();
        expect(input, {
          'dateOfBirth': '2000-01-15',
          'qualification': 'degree',
          'degreeSubject': 'Mathematics',
          'community': 'BC',
          'pstm': true,
          'specialCategories': ['PWD'],
        });
        expect(find.text("You're eligible for 7 exams"), findsOneWidget);
      },
    );
  });

  group('eligibility result (§17.1 step 3)', () {
    testWidgets('shows N, the top 5 highlighted, the disclaimer and links', (
      tester,
    ) async {
      final h = Harness();
      final result = eligibility(count: 7);
      await tester.pumpWidget(
        h.app(
          Scaffold(
            body: EligibilityResultView(
              result: result,
              onOpenLink: (e) => h.links.open(e.officialUrl),
              onShare: () => h.share.shareText(result.shareText()),
              onContinue: () {},
            ),
          ),
        ),
      );
      expect(find.text("You're eligible for 7 exams"), findsOneWidget);
      expect(
        find.text('Always confirm with the official notification.'),
        findsOneWidget,
      );
      expect(find.text('Your top 5'), findsOneWidget);
      expect(find.text('Age relaxation applied for BC.'), findsOneWidget);
      for (var i = 1; i <= 5; i++) {
        final card = tester.widget<HmCard>(find.byKey(Key('exam-exam-$i')));
        expect(card.highlighted, isTrue, reason: 'top $i');
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('exam-exam-6')),
        200,
      );
      expect(
        tester.widget<HmCard>(find.byKey(const Key('exam-exam-6'))).highlighted,
        isFalse,
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('official-exam-1')),
        -200,
      );
      await tester.tap(find.byKey(const Key('official-exam-1')));
      expect(h.links.opened, ['https://example.gov.in/exam-1']);

      await tester.scrollUntilVisible(find.text('Share'), 300);
      await tester.tap(find.text('Share'));
      expect(
        h.share.shared.single,
        startsWith('HeyMey shows I can write 7 exams.'),
      );
      expect(
        h.share.shared.single,
        contains('Always confirm with the official notification.'),
      );
    });

    testWidgets('one exam reads "1 exam"', (tester) async {
      final h = Harness();
      await tester.pumpWidget(
        h.app(
          Scaffold(
            body: EligibilityResultView(
              result: eligibility(count: 1),
              onOpenLink: (_) {},
            ),
          ),
        ),
      );
      expect(find.text("You're eligible for 1 exam"), findsOneWidget);
    });
  });

  group('sign in + consent (§17.1 steps 4–8)', () {
    Future<Harness> toEmail(WidgetTester tester) async {
      final h = await pumpFlow(tester);
      h.controller.submitDateOfBirth(DateTime(2000, 1, 15));
      await tester.pumpAndSettle();
      await answerProfile(tester);
      await tapKey(tester, 'answers-check');
      h.controller.continueToPickExams();
      await tester.pumpAndSettle();
      // main = best fit by default; add two more, a third is refused.
      h.controller.toggleOtherExam('exam-2');
      h.controller.toggleOtherExam('exam-3');
      h.controller.toggleOtherExam('exam-4');
      expect(h.state.otherExams, ['exam-2', 'exam-3']);
      await tester.pumpAndSettle();
      await tapKey(tester, 'exams-continue');
      expect(find.text('Your Study Map'), findsOneWidget);
      expect(find.text('Indian Polity'), findsOneWidget);
      await tapKey(tester, 'save-progress');
      await tester.enterText(
        find.byKey(const Key('email-field')),
        'priya@example.com',
      );
      await tapKey(tester, 'send-code');
      expect(h.onboarding.calls, contains('requestCode:priya@example.com'));
      return h;
    }

    testWidgets('code screen: resend locked 60 s, paste submits', (
      tester,
    ) async {
      final h = await toEmail(tester);
      expect(find.text('Enter your code'), findsOneWidget);
      expect(find.text("Didn't get it? Check spam."), findsOneWidget);
      expect(find.text('Resend code in 60 s'), findsOneWidget);
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Resend code in 30 s'), findsOneWidget);
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Resend code'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('hm-code-field')),
        'Code: 482 913',
      );
      await tester.pumpAndSettle();
      expect(h.onboarding.verifiedCode, '482913');
      expect(find.text('Your data, your choice'), findsOneWidget);
    });

    testWidgets(
      'consent: nothing pre-ticked, required item gates, then saves',
      (tester) async {
        final h = await toEmail(tester);
        await tester.enterText(
          find.byKey(const Key('hm-code-field')),
          '123456',
        );
        await tester.pumpAndSettle();

        for (final p in ['core_service', 'offers_email', 'product_research']) {
          final box = tester.widget<CheckboxListTile>(
            find.byKey(Key('consent-$p')),
          );
          expect(box.value, isFalse, reason: '$p must not be pre-ticked');
        }
        expect(find.text('Optional choices'), findsOneWidget);
        expect(
          find.text(
            'You can change these choices any time in Profile. '
            'Questions or complaints: grievance@heymey.app.',
          ),
          findsOneWidget,
        );
        expect(find.text('Save my choices and continue'), findsOneWidget);
        expect(find.text('Agree and continue'), findsNothing);
        await tapKey(tester, 'consent-privacy');
        expect(h.links.opened, ['https://heymey.app/legal/privacy']);
        FilledButton agree() => tester.widget<FilledButton>(
          find.descendant(
            of: find.byKey(const Key('consent-continue')),
            matching: find.byType(FilledButton),
          ),
        );
        expect(agree().onPressed, isNull);

        await tapKey(tester, 'consent-product_research');
        expect(
          agree().onPressed,
          isNull,
          reason: 'optional alone is not enough',
        );
        await tapKey(tester, 'consent-core_service');
        expect(agree().onPressed, isNotNull);

        expect(
          h.container.read(sessionProvider),
          isNot(SessionStatus.signedIn),
        );
        await tester.tap(find.byKey(const Key('consent-continue')));
        await tester.pump();
        await tester.pump();

        expect(h.onboarding.recordedVersion, 'v1');
        expect(h.onboarding.recordedConsents, {
          'core_service': true,
          'offers_email': false,
          'product_research': true,
        });
        expect(
          h.onboarding.calls.sublist(
            h.onboarding.calls.indexOf('recordConsents'),
          ),
          ['recordConsents', 'saveProfile', 'saveExams'],
        );
        expect(h.onboarding.savedExams!.$1, 'exam-1');
        expect(h.onboarding.savedExams!.$2, ['exam-2', 'exam-3']);
        expect(
          h.onboarding.savedDraft!.qualification,
          QualificationChoice.degree,
        );
        expect(h.state.step, OnboardingStep.done);
        expect(h.container.read(sessionProvider), SessionStatus.signedIn);
      },
    );

    testWidgets('a wrong code shows the server message', (tester) async {
      final h = await toEmail(tester);
      h.onboarding.verifyError = const HmApiException(
        'OTP_INVALID',
        'That code is not right. Please check your email and try again.',
      );
      await tester.enterText(find.byKey(const Key('hm-code-field')), '000000');
      await tester.pumpAndSettle();
      expect(
        find.text(
          'That code is not right. Please check your email and try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('"I already have an account" signs in without onboarding', (
      tester,
    ) async {
      final h = await pumpFlow(tester);
      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('email-field')),
        'priya@example.com',
      );
      await tapKey(tester, 'send-code');
      await tester.enterText(find.byKey(const Key('hm-code-field')), '123456');
      await tester.pump();
      await tester.pump();
      expect(h.state.step, OnboardingStep.done);
      expect(h.onboarding.calls, isNot(contains('saveProfile')));
      expect(h.container.read(sessionProvider), SessionStatus.signedIn);
    });

    testWidgets('an invalid email is caught before sending', (tester) async {
      final h = await pumpFlow(tester);
      h.controller.startSignIn();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('email-field')),
        'not-an-email',
      );
      await tapKey(tester, 'send-code');
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(h.onboarding.calls, isEmpty);
    });
  });
}
