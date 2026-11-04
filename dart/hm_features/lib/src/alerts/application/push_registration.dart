import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import 'alerts_controller.dart' show alertsRepositoryProvider;

/// Where the phone's push token comes from (FCM / APNs). Firebase is not set up yet, so the app uses
/// [NoopPushTokenSource] and never registers a token (U-notifications invariant 9, senderMode `log_only`).
abstract interface class PushTokenSource {
  /// `android` or `ios` (contract `RegisterPushTokenBody.platform`).
  String get platform;

  /// The current token, or null when push is not available.
  Future<String?> token();
}

class NoopPushTokenSource implements PushTokenSource {
  const NoopPushTokenSource();

  @override
  String get platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  @override
  Future<String?> token() async => null;
}

final pushTokenSourceProvider = Provider<PushTokenSource>(
  (ref) => const NoopPushTokenSource(),
);

/// Registers this device's push token after sign-in (U-notifications client: after the consent step).
class PushRegistrar {
  PushRegistrar(this._ref);

  final Ref _ref;

  /// Returns true when a token was sent. Never throws: push is optional.
  Future<bool> registerIfAvailable() async {
    try {
      final source = _ref.read(pushTokenSourceProvider);
      final token = await source.token();
      if (token == null || token.isEmpty) return false;
      final deviceId = await _ref.read(deviceIdStoreProvider).deviceId();
      await _ref
          .read(alertsRepositoryProvider)
          .registerPushToken(
            deviceId: deviceId,
            platform: source.platform,
            token: token,
          );
      return true;
    } on Object {
      return false;
    }
  }
}

final pushRegistrarProvider = Provider<PushRegistrar>(PushRegistrar.new);
