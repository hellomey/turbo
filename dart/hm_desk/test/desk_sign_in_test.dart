import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_desk/hm_desk.dart';
import 'package:qr_flutter/qr_flutter.dart';

const deskNotAllowed =
    'HeyMey Desk is only for partners and staff. Please use the HeyMey app.';

class FakeDeskAuth implements DeskAuthRepository {
  FakeDeskAuth({
    this.outcome,
    this.verifyError,
    this.roles = const ['REVIEWER'],
  });

  OtpVerifyOutcome? outcome;
  HmApiException? verifyError;
  HmApiException? totpError;
  List<String> roles;
  bool session = false;
  final calls = <String>[];

  @override
  Future<int> requestCode(String email) async {
    calls.add('request:$email');
    return 60;
  }

  @override
  Future<OtpVerifyOutcome> verifyCode(String email, String code) async {
    calls.add('verify:$code');
    final e = verifyError;
    if (e != null) throw e;
    return outcome!;
  }

  @override
  Future<DeskEnrolment> enroll(String challengeToken) async {
    calls.add('enroll:$challengeToken');
    return const DeskEnrolment(
      otpauthUri:
          'otpauth://totp/HeyMey%20Desk:staff@heymey.app?secret=JBSWY3DPEHPK3PXP&issuer=HeyMey%20Desk',
      secret: 'JBSWY3DPEHPK3PXP',
    );
  }

  @override
  Future<void> verifyTotp(String challengeToken, String code) async {
    calls.add('totp:$challengeToken:$code');
    final e = totpError;
    if (e != null) throw e;
    session = true;
  }

  @override
  Future<MeInfo> me() async =>
      MeInfo(id: 'u', email: 'staff@heymey.app', calmMode: false, roles: roles);

  @override
  Future<bool> hasSession() async => session;

  @override
  Future<void> logout() async {
    calls.add('logout');
    session = false;
  }
}

Future<void> pumpDesk(WidgetTester tester, FakeDeskAuth fake) async {
  tester.view.physicalSize = const Size(1280, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [deskAuthRepositoryProvider.overrideWithValue(fake)],
      retry: (_, _) => null,
      child: MaterialApp(theme: HmTheme.dark(), home: const DeskSignInFlow()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('desk-email')),
    'staff@heymey.app',
  );
  await tester.tap(find.byKey(const Key('desk-send-code')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('hm-code-field')), '123456');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an aspirant is refused with the server message', (tester) async {
    final fake = FakeDeskAuth(
      verifyError: const HmApiException(
        'DESK_NOT_ALLOWED',
        deskNotAllowed,
        statusCode: 403,
      ),
    );
    await pumpDesk(tester, fake);
    expect(find.text(deskNotAllowed), findsOneWidget);
    expect(find.byType(DeskHome), findsNothing);
    expect(fake.calls, isNot(contains(startsWith('enroll'))));
  });

  testWidgets(
    'first sign-in: enrol shows the QR code and the key, then TOTP → home',
    (tester) async {
      final fake = FakeDeskAuth(
        outcome: const OtpDeskChallengeOutcome(
          challengeToken: 'chal',
          totpEnrolled: false,
        ),
      );
      await pumpDesk(tester, fake);
      expect(fake.calls, contains('enroll:chal'));
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byKey(const Key('desk-qr')), findsOneWidget);
      expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
      expect(
        find.bySemanticsLabel('QR code for your authenticator app'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('desk-enrolled')));
      await tester.pumpAndSettle();
      expect(find.text('Enter your authenticator code'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('hm-code-field')), '654321');
      await tester.pumpAndSettle();

      expect(fake.calls, contains('totp:chal:654321'));
      expect(find.byType(DeskHome), findsOneWidget);
      expect(find.text('Your role: Reviewer'), findsOneWidget);
      for (final area in deskAreas) {
        expect(find.text(area.$1), findsOneWidget);
      }
    },
  );

  testWidgets('enrolled staff go straight to the authenticator code', (
    tester,
  ) async {
    final fake = FakeDeskAuth(
      outcome: const OtpDeskChallengeOutcome(
        challengeToken: 'c2',
        totpEnrolled: true,
      ),
      roles: const ['OPS', 'ADMIN'],
    );
    await pumpDesk(tester, fake);
    expect(find.byType(QrImageView), findsNothing);
    expect(fake.calls, isNot(contains(startsWith('enroll'))));
    await tester.enterText(find.byKey(const Key('hm-code-field')), '111111');
    await tester.pumpAndSettle();
    expect(find.text('Your role: Ops, Admin'), findsOneWidget);

    await tester.tap(find.byKey(const Key('desk-logout')));
    await tester.pumpAndSettle();
    expect(fake.calls.last, 'logout');
    expect(find.byKey(const Key('desk-email')), findsOneWidget);
  });

  testWidgets('a wrong authenticator code shows the server message', (
    tester,
  ) async {
    final fake =
        FakeDeskAuth(
            outcome: const OtpDeskChallengeOutcome(
              challengeToken: 'c3',
              totpEnrolled: true,
            ),
          )
          ..totpError = const HmApiException(
            'TOTP_INVALID',
            'That authenticator code is not right. Please try again.',
          );
    await pumpDesk(tester, fake);
    await tester.enterText(find.byKey(const Key('hm-code-field')), '000000');
    await tester.pumpAndSettle();
    expect(
      find.text('That authenticator code is not right. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(DeskHome), findsNothing);
  });
}
