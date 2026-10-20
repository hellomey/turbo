import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'config/api_config.dart';
import 'net/hm_api.dart';
import 'session/token_store.dart';

/// Overridden in tests and by each app (version, platform).
final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(),
);

final secureKeyValueProvider = Provider<SecureKeyValue>(
  (ref) => FlutterSecureKeyValue(),
);

/// The app keeps tokens in secure storage; HeyMey Desk overrides this with a [CachedTokenStore].
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => SecureTokenStore(ref.watch(secureKeyValueProvider)),
);

final deviceIdStoreProvider = Provider<DeviceIdStore>(
  (ref) => DeviceIdStore(ref.watch(secureKeyValueProvider)),
);

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

/// "Now". Day logic uses IST (§37); tests override this.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final hmApiProvider = Provider<HmApi>((ref) {
  final api = HmApi(
    config: ref.watch(apiConfigProvider),
    tokens: ref.watch(tokenStoreProvider),
    httpClient: ref.watch(httpClientProvider),
    onSignedOut: () => ref.read(sessionProvider.notifier).markSignedOut(),
  );
  ref.onDispose(api.dispose);
  return api;
});

enum SessionStatus { unknown, signedOut, signedIn }

/// Whether this install has a session. Changes only when sign-in finishes or the user is signed out,
/// so onboarding can finish its last steps (consent, saving answers) before the app shell opens.
class SessionController extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    unawaited(_load());
    return SessionStatus.unknown;
  }

  Future<void> _load() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    if (state == SessionStatus.unknown) {
      state = tokens == null ? SessionStatus.signedOut : SessionStatus.signedIn;
    }
  }

  void markSignedIn() => state = SessionStatus.signedIn;

  void markSignedOut() => state = SessionStatus.signedOut;
}

final sessionProvider = NotifierProvider<SessionController, SessionStatus>(
  SessionController.new,
);

/// True when the server requires a newer app (X-Min-App-Version, §37).
class UpdateRequiredController extends Notifier<bool> {
  @override
  bool build() {
    final signal = ref.watch(hmApiProvider).updateRequired;
    void listener() => state = signal.value;
    signal.addListener(listener);
    ref.onDispose(() => signal.removeListener(listener));
    return signal.value;
  }
}

final updateRequiredProvider = NotifierProvider<UpdateRequiredController, bool>(
  UpdateRequiredController.new,
);
