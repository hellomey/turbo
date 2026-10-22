import 'dart:async';

import 'package:hm_core/hm_core.dart';

import '../domain/sync_report.dart';
import 'sync_engine.dart';

/// When the outbox is sent (§39): when the phone comes online, right after a study action is recorded while
/// online, and when a backoff wait ends. Ranked play and purchases never go through here.
class SyncTriggers {
  SyncTriggers({
    required SyncEngine engine,
    required Stream<NetworkState> network,
    required DateTime Function() clock,
    Timer Function(Duration, void Function())? timer,
  }) : _engine = engine,
       _clock = clock,
       _timer = timer ?? Timer.new {
    _sub = network.listen(_onNetwork);
  }

  final SyncEngine _engine;
  final DateTime Function() _clock;
  final Timer Function(Duration, void Function()) _timer;
  late final StreamSubscription<NetworkState> _sub;
  Timer? _retry;
  bool _online = false;
  final _reports = StreamController<SyncReport>.broadcast();

  /// Every finished sync run (for the "Will sync when online" note and analytics counts).
  Stream<SyncReport> get reports => _reports.stream;

  bool get online => _online;

  void _onNetwork(NetworkState state) {
    final cameOnline = state.online && !_online;
    _online = state.online;
    if (cameOnline) unawaited(_sync(force: true));
    if (!state.online) _cancelRetry();
  }

  /// Call after a study action was recorded.
  Future<SyncReport?> actionRecorded() async =>
      _online ? _sync(force: false) : null;

  Future<SyncReport> _sync({required bool force}) async {
    _cancelRetry();
    final report = await _engine.syncNow(force: force);
    final retryAt = report.retryAt;
    if (report.failed && retryAt != null && _online) {
      final wait = retryAt.difference(_clock());
      _retry = _timer(
        wait.isNegative ? Duration.zero : wait,
        () => unawaited(_sync(force: false)),
      );
    }
    if (!_reports.isClosed) _reports.add(report);
    return report;
  }

  void _cancelRetry() {
    _retry?.cancel();
    _retry = null;
  }

  Future<void> dispose() async {
    _cancelRetry();
    await _sub.cancel();
    await _reports.close();
  }
}
