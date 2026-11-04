import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_data/hm_data.dart';

/// What the outbox holds right now, for the "Will sync when online" and "Couldn't save" notes (§39).
@immutable
class SyncStatus {
  const SyncStatus({this.pending = 0, this.rejected = const []});

  final int pending;

  /// Actions the server refused (shown as "Couldn't save").
  final List<OutboxEntry> rejected;

  bool get quiet => pending == 0 && rejected.isEmpty;
}

/// Watches the outbox and the sync runs. [start] wires the BOLT-0016 sync triggers (the app shell calls it
/// once signed in); failures to open local storage leave the status quiet rather than breaking the shell.
class SyncStatusController extends Notifier<SyncStatus> {
  StreamSubscription<SyncReport>? _sub;

  @override
  SyncStatus build() {
    ref.onDispose(() => _sub?.cancel());
    return const SyncStatus();
  }

  void start() {
    if (_sub != null) return;
    try {
      _sub = ref
          .read(syncTriggersProvider)
          .reports
          .listen((_) => unawaited(refresh()));
    } on Object {
      return;
    }
    unawaited(refresh());
  }

  Future<void> refresh() async {
    try {
      final outbox = ref.read(outboxRepositoryProvider);
      final pending = await outbox.pendingCount();
      final rejected = await outbox.rejected();
      if (!ref.mounted) return;
      state = SyncStatus(pending: pending, rejected: rejected);
    } on Object {
      // Local storage not ready: keep the last status.
    }
  }

  Future<void> dismiss(String clientActionId) async {
    await ref.read(outboxRepositoryProvider).dismissRejected(clientActionId);
    await refresh();
  }
}

final syncStatusProvider = NotifierProvider<SyncStatusController, SyncStatus>(
  SyncStatusController.new,
);
