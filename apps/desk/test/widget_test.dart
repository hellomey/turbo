import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:heymey_desk/main.dart';

void main() {
  testWidgets('Desk opens on the sign-in step when there is no session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
          secureKeyValueProvider.overrideWithValue(MemoryKeyValue()),
        ],
        child: const HeyMeyDesk(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('HeyMey Desk'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Send code'), findsOneWidget);
  });
}
