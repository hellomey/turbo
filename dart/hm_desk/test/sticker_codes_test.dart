import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_desk/hm_desk.dart';

Future<List<String>> pumpScreen(
  WidgetTester tester,
  Future<void> Function(String) redeem,
) async {
  final calls = <String>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        stickerCodeRedeemerProvider.overrideWithValue((code) {
          calls.add(code);
          return redeem(code);
        }),
      ],
      child: MaterialApp(
        theme: HmTheme.dark(),
        home: const StickerCodesScreen(),
      ),
    ),
  );
  return calls;
}

Future<void> check(WidgetTester tester, String code) async {
  await tester.enterText(find.byKey(const Key('sticker-code-input')), code);
  await tester.tap(find.byKey(const Key('sticker-code-redeem')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a valid code says Give a sticker', (tester) async {
    final calls = await pumpScreen(tester, (_) async {});
    await check(tester, ' hm-7kqx ');
    expect(calls, ['hm-7kqx']);
    expect(find.text('Give a sticker'), findsOneWidget);
  });

  testWidgets('a used code says why there is no sticker', (tester) async {
    await pumpScreen(
      tester,
      (_) async => throw const HmApiException(
        'STICKER_CODE_ALREADY_REDEEMED',
        'This sticker code was already used.',
        statusCode: 409,
      ),
    );
    await check(tester, 'HM-7KQX');
    expect(find.text('Give a sticker'), findsNothing);
    expect(
      find.text('No sticker. This code was already used for a sticker.'),
      findsOneWidget,
    );
  });

  testWidgets('an unknown code says it does not exist', (tester) async {
    await pumpScreen(
      tester,
      (_) async => throw const HmApiException(
        'STICKER_CODE_NOT_FOUND',
        'This sticker code is not valid.',
        statusCode: 404,
      ),
    );
    await check(tester, 'HM-2222');
    expect(find.textContaining('does not exist'), findsOneWidget);
  });
}
