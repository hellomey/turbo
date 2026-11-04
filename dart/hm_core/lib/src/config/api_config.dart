import 'package:flutter/foundation.dart';

/// Where the API lives and which app version is calling it (blueprint §37).
///
/// The base URL comes from `--dart-define=API_BASE_URL=...`. Without it, debug builds talk to the local
/// API on port 4567 (packages/config/ports.json): `10.0.2.2` from the Android emulator, `localhost`
/// everywhere else. Release builds always pass `https://api.heymey.app` (production) or the staging URL.
@immutable
class ApiConfig {
  const ApiConfig({required this.baseUrl, required this.appVersion});

  /// Production API (blueprint §21).
  static const productionBaseUrl = 'https://api.heymey.app';

  /// Local API port from packages/config/ports.json.
  static const localPort = 4567;

  /// Base URL with no trailing slash, e.g. `https://api.heymey.app`.
  final String baseUrl;

  /// This build's version (semver, e.g. `0.1.0`), compared with `X-Min-App-Version`.
  final String appVersion;

  factory ApiConfig.fromEnvironment({
    String appVersion = '1.0.0',
    TargetPlatform? platform,
    bool? isWeb,
  }) {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    return ApiConfig(
      baseUrl: resolveBaseUrl(
        fromDefine,
        platform: platform ?? defaultTargetPlatform,
        isWeb: isWeb ?? kIsWeb,
      ),
      appVersion: appVersion,
    );
  }

  /// Picks the base URL: an explicit define wins, otherwise the local default for this platform.
  static String resolveBaseUrl(
    String fromDefine, {
    required TargetPlatform platform,
    required bool isWeb,
  }) {
    if (fromDefine.isNotEmpty) {
      return fromDefine.endsWith('/')
          ? fromDefine.substring(0, fromDefine.length - 1)
          : fromDefine;
    }
    if (!isWeb && platform == TargetPlatform.android) {
      return 'http://10.0.2.2:$localPort';
    }
    return 'http://localhost:$localPort';
  }
}
