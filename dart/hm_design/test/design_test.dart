import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: HmTheme.dark(),
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  group('Lamp (§5.1, §10.9)', () {
    test('semantics label names every ring', () {
      expect(
        lampSemanticsLabel('Indian Polity', HmLampState.unlit),
        'Indian Polity. Lit ring: off. Steady ring: 0 of 4. Gold ring: off.',
      );
      expect(
        lampSemanticsLabel(
          'Ancient History',
          const HmLampState(
            lit: true,
            steadyLevel: 3,
            gold: true,
            dim: HmLampDim.dimming,
          ),
        ),
        'Ancient History. Lit ring: on. Steady ring: 3 of 4. Gold ring: on. '
        'Dimming, relight soon.',
      );
    });

    testWidgets('a tappable lamp is a 48 dp button with its label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          Center(
            child: Lamp(label: 'Indian Polity', size: 24, onTap: () => taps++),
          ),
        ),
      );
      final lamp = find.byType(Lamp);
      expect(tester.getSize(lamp).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(lamp).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(lamp),
        matchesSemantics(
          label:
              'Indian Polity. Lit ring: off. Steady ring: 0 of 4. Gold ring: off.',
          isButton: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(lamp);
      expect(taps, 1);
      handle.dispose();
    });

    test('ring states', () {
      const s = HmLampState(lit: true, steadyLevel: 0);
      expect(s.isOn(LampRing.lit), isTrue);
      expect(s.isOn(LampRing.steady), isFalse);
      expect(s.isOn(LampRing.gold), isFalse);
      expect(s, const HmLampState(lit: true));
    });
  });

  group('buttons', () {
    testWidgets('primary and secondary buttons are at least 48 dp tall', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              HmPrimaryButton(label: 'Start', onPressed: () {}),
              HmSecondaryButton(label: 'Not now', onPressed: () {}),
            ],
          ),
        ),
      );
      for (final b in find.byType(HmChunkyButton).evaluate()) {
        expect(
          tester.getSize(find.byWidget(b.widget)).height,
          greaterThanOrEqualTo(48),
        );
      }
      expect(find.byType(HmChunkyButton), findsNWidgets(2));
    });

    testWidgets('error view shows the message and a retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        _wrap(
          HmErrorView(
            message: 'No internet connection. Please check and try again.',
            onRetry: () => retries++,
          ),
        ),
      );
      expect(
        find.text('No internet connection. Please check and try again.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });
  });

  group('HmCodeEntry (§17.1 step 7)', () {
    test('a pasted message keeps only the 6 digits', () {
      expect(
        DigitsOnlyFormatter.clean('Your HeyMey code is 482 913.', 6),
        '482913',
      );
      expect(DigitsOnlyFormatter.clean('12345678', 6), '123456');
    });

    testWidgets('resend is locked for 60 s, then unlocks', (tester) async {
      var resent = 0;
      await tester.pumpWidget(
        _wrap(HmCodeEntry(onSubmit: (_) {}, onResend: () async => resent++)),
      );
      HmChunkyButton resend() => tester.widget<HmChunkyButton>(
        find.descendant(
          of: find.byKey(const Key('hm-code-resend')),
          matching: find.byType(HmChunkyButton),
        ),
      );
      expect(resend().onPressed, isNull);
      expect(find.text('Resend code in 60 s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 59));
      expect(resend().onPressed, isNull);
      expect(find.text('Resend code in 1 s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(resend().onPressed, isNotNull);
      await tester.tap(find.text('Resend code'));
      await tester.pump();
      expect(resent, 1);
      expect(resend().onPressed, isNull, reason: 'locked again after resend');
    });

    testWidgets('pasting 6 digits submits the code', (tester) async {
      String? submitted;
      await tester.pumpWidget(
        _wrap(HmCodeEntry(onSubmit: (c) => submitted = c)),
      );
      await tester.enterText(
        find.byKey(const Key('hm-code-field')),
        'Your HeyMey code is 482913. It expires in 10 minutes.',
      );
      await tester.pump();
      expect(submitted, '482913');
      expect(find.text("Didn't get it? Check spam."), findsOneWidget);
    });

    testWidgets('typing fewer than 6 digits keeps Continue disabled', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(HmCodeEntry(onSubmit: (_) {})));
      await tester.enterText(find.byKey(const Key('hm-code-field')), '12a3');
      await tester.pump();
      expect(find.text('123'), findsOneWidget);
      expect(
        tester.widget<HmChunkyButton>(find.byType(HmChunkyButton)).onPressed,
        isNull,
      );
      // Keep the analyzer honest about the services import used by formatters.
      expect(const DigitsOnlyFormatter(6), isA<TextInputFormatter>());
    });
  });
}
