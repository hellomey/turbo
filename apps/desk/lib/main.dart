import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_desk/hm_desk.dart';

/// Keep in step with `version:` in pubspec.yaml (compared with X-Min-App-Version, §37).
const appVersion = '0.1.0';

/// HeyMey Desk (web). Partners and staff only; aspirants are refused by the server (blueprint §15).
/// Desk sessions are short and kept in memory first, backed by secure storage.
void main() {
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        apiConfigProvider.overrideWithValue(
          ApiConfig.fromEnvironment(appVersion: appVersion),
        ),
        tokenStoreProvider.overrideWith(
          (ref) => CachedTokenStore(
            SecureTokenStore(
              ref.watch(secureKeyValueProvider),
              key: 'hm.desk.tokens',
            ),
          ),
        ),
      ],
      child: const HeyMeyDesk(),
    ),
  );
}

final deskRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const DeskSignInFlow())],
);

class HeyMeyDesk extends ConsumerWidget {
  const HeyMeyDesk({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateRequired = ref.watch(updateRequiredProvider);
    return MaterialApp.router(
      title: 'HeyMey Desk',
      theme: HmTheme.light(),
      darkTheme: HmTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: deskRouter,
      builder: (context, child) => updateRequired
          ? const Scaffold(
              body: HmErrorView(message: 'Please update HeyMey to continue.'),
            )
          : child!,
    );
  }
}
