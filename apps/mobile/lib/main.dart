import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'src/router.dart';
import 'src/shell.dart';

/// Keep in step with `version:` in pubspec.yaml (compared with X-Min-App-Version, §37).
const appVersion = '0.1.0';

/// HeyMey mobile app. Composition root only: screens come from hm_features. Never depends on hm_desk.
void main() {
  runApp(
    ProviderScope(
      // Errors are shown with a "Try again" button instead of silent retries.
      retry: (_, _) => null,
      overrides: [
        apiConfigProvider.overrideWithValue(
          ApiConfig.fromEnvironment(appVersion: appVersion),
        ),
        liteModeProvider.overrideWith(
          (ref) => ref.watch(sessionProvider) == SessionStatus.signedIn
              ? (ref.watch(meProvider).value?.liteMode ?? false)
              : false,
        ),
      ],
      child: const HeyMeyApp(),
    ),
  );
}

class HeyMeyApp extends ConsumerWidget {
  const HeyMeyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateRequired = ref.watch(updateRequiredProvider);
    return MaterialApp.router(
      title: 'HeyMey',
      theme: HmTheme.light(),
      darkTheme: HmTheme.dark(),
      themeMode: ThemeMode.dark, // dark is the default (§10.3)
      routerConfig: ref.watch(routerProvider),
      // Calm Mode (§10.7) and Lite Mode (§10.8) switch off celebrations and decorative motion.
      builder: (context, child) => HmModes(
        calm: ref.watch(meProvider).value?.calmMode ?? false,
        lite: ref.watch(liteModeProvider),
        child: updateRequired ? const UpdateRequiredView() : child!,
      ),
    );
  }
}
