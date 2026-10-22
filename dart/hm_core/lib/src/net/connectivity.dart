import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the phone is connected to right now (§39: sync when online; packs on Wi-Fi by default).
@immutable
class NetworkState {
  const NetworkState({required this.online, required this.wifi});

  static const offline = NetworkState(online: false, wifi: false);

  final bool online;

  /// Wi-Fi or Ethernet: unmetered, so content packs may download.
  final bool wifi;

  @override
  bool operator ==(Object other) =>
      other is NetworkState && other.online == online && other.wifi == wifi;

  @override
  int get hashCode => Object.hash(online, wifi);

  @override
  String toString() => 'NetworkState(online: $online, wifi: $wifi)';
}

/// Source of [NetworkState]. The default reads `connectivity_plus`; tests pass a fake.
abstract interface class NetworkSource {
  Future<NetworkState> current();
  Stream<NetworkState> changes();
}

class ConnectivityPlusNetworkSource implements NetworkSource {
  ConnectivityPlusNetworkSource([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static NetworkState fromResults(List<ConnectivityResult> results) {
    final wifi =
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
    final online = results.any((r) => r != ConnectivityResult.none);
    return NetworkState(online: online, wifi: wifi);
  }

  @override
  Future<NetworkState> current() async =>
      fromResults(await _connectivity.checkConnectivity());

  @override
  Stream<NetworkState> changes() =>
      _connectivity.onConnectivityChanged.map(fromResults);
}

final networkSourceProvider = Provider<NetworkSource>(
  (ref) => ConnectivityPlusNetworkSource(),
);

/// Current network state; emits on every change. "Online" here only means a network is attached;
/// a failed request still counts as offline for the caller (§39).
final networkStateProvider = StreamProvider<NetworkState>((ref) async* {
  final source = ref.watch(networkSourceProvider);
  yield await source.current();
  yield* source.changes().distinct();
});
