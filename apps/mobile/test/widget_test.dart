import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:heymey_mobile/main.dart';

StoredTokens get _tokens => StoredTokens(
  accessToken: 'a',
  refreshToken: 'r-0123456789012345678',
  accessTokenExpiresAt: DateTime.utc(2026, 10, 20),
);

Widget _app(TokenStore tokens) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    tokenStoreProvider.overrideWithValue(tokens),
    secureKeyValueProvider.overrideWithValue(MemoryKeyValue()),
  ],
  child: const HeyMeyApp(),
);

void main() {
  testWidgets('signed in: the shell shows the five tabs (§10.5)', (
    tester,
  ) async {
    await tester.pumpWidget(_app(MemoryTokenStore(_tokens)));
    await tester.pumpAndSettle();
    for (final tab in ['Today', 'Study Map', 'Play', 'Squad', 'Profile']) {
      expect(find.text(tab), findsWidgets);
    }
    expect(find.text('Open Study Map'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Games are coming soon'), findsOneWidget);
  });

  testWidgets('signed out: onboarding starts with the date of birth', (
    tester,
  ) async {
    await tester.pumpWidget(_app(MemoryTokenStore()));
    await tester.pumpAndSettle();
    expect(find.text("Let's find your exams"), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });
}
