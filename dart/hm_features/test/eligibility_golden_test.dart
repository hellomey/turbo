import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

/// Goldens for the eligibility result (§10.6) in the dark (default) and light themes.
/// Uses the default test font, so the images are stable across machines of the same platform.
/// Regenerate with: flutter test --update-goldens test/eligibility_golden_test.dart
void main() {
  for (final (name, theme) in [
    ('dark', HmTheme.dark()),
    ('light', HmTheme.light()),
  ]) {
    testWidgets('eligibility result golden ($name)', (tester) async {
      tester.view.physicalSize = const Size(412, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final h = Harness();
      await tester.pumpWidget(
        h.app(
          Scaffold(
            body: EligibilityResultView(
              result: eligibility(count: 6),
              onOpenLink: (_) {},
              onShare: () {},
              onContinue: () {},
            ),
          ),
          theme: theme,
        ),
      );
      await expectLater(
        find.byType(EligibilityResultView),
        matchesGoldenFile('goldens/eligibility_result_$name.png'),
      );
    });
  }
}
