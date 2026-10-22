import 'package:flutter/foundation.dart';

import '../domain/content_pack.dart';
import '../domain/outbox_entry.dart';

/// Local storage contracts (§39). Implemented over Drift ([DriftOutboxStore] etc.) in the apps and in
/// memory in tests. Repositories depend on these, never on Drift directly.

/// A study action waiting to be added (the store assigns `seq`).
@immutable
class NewOutboxEntry {
  const NewOutboxEntry({
    required this.clientActionId,
    required this.kind,
    required this.payloadJson,
    required this.clientAt,
  });

  final String clientActionId;
  final String kind;
  final String payloadJson;
  final DateTime clientAt;
}

abstract interface class OutboxStore {
  /// Adds [entry] at the end of the queue. Returns false (and changes nothing) when an entry with the
  /// same `clientActionId` already exists.
  Future<bool> add(NewOutboxEntry entry);

  /// Pending entries in creation order, at most [limit].
  Future<List<OutboxEntry>> pending({required int limit});

  /// Rejected entries, oldest first (the "Couldn't save" list).
  Future<List<OutboxEntry>> rejected();

  Future<int> pendingCount();

  /// Removes entries the server accepted (or the user dismissed).
  Future<void> remove(Iterable<String> clientActionIds);

  /// Counts one failed send for each id.
  Future<void> recordFailure(Iterable<String> clientActionIds, String error);

  Future<void> markRejected(String clientActionId, String errorCode);
}

/// The server's lamp state for one topic (contract `TopicState` JSON). Server wins (§39).
@immutable
class TopicStateRecord {
  const TopicStateRecord({
    required this.topicId,
    required this.json,
    required this.updatedAt,
  });

  final String topicId;
  final String json;
  final DateTime updatedAt;
}

abstract interface class TopicStateStore {
  /// Replaces each topic's row wholesale.
  Future<void> putAll(Iterable<TopicStateRecord> states);
  Future<TopicStateRecord?> get(String topicId);
  Future<List<TopicStateRecord>> all();
}

abstract interface class PackStore {
  Future<InstalledPack?> get(String code);
  Future<List<InstalledPack>> all();
  Future<void> put(InstalledPack pack);
  Future<void> remove(String code);
}

// --------------------------------------------------------------------------- in memory

class MemoryOutboxStore implements OutboxStore {
  final _rows = <OutboxEntry>[];
  int _seq = 0;

  @override
  Future<bool> add(NewOutboxEntry entry) async {
    if (_rows.any((r) => r.clientActionId == entry.clientActionId)) {
      return false;
    }
    _rows.add(
      OutboxEntry(
        seq: ++_seq,
        clientActionId: entry.clientActionId,
        kind: entry.kind,
        payloadJson: entry.payloadJson,
        clientAt: entry.clientAt,
      ),
    );
    return true;
  }

  @override
  Future<List<OutboxEntry>> pending({required int limit}) async => _rows
      .where((r) => r.state == OutboxEntryState.pending)
      .take(limit)
      .toList();

  @override
  Future<List<OutboxEntry>> rejected() async =>
      _rows.where((r) => r.state == OutboxEntryState.rejected).toList();

  @override
  Future<int> pendingCount() async =>
      _rows.where((r) => r.state == OutboxEntryState.pending).length;

  @override
  Future<void> remove(Iterable<String> clientActionIds) async {
    final ids = clientActionIds.toSet();
    _rows.removeWhere((r) => ids.contains(r.clientActionId));
  }

  @override
  Future<void> recordFailure(
    Iterable<String> clientActionIds,
    String error,
  ) async {
    final ids = clientActionIds.toSet();
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      if (ids.contains(r.clientActionId)) {
        _rows[i] = r.copyWith(attempts: r.attempts + 1, lastError: error);
      }
    }
  }

  @override
  Future<void> markRejected(String clientActionId, String errorCode) async {
    for (var i = 0; i < _rows.length; i++) {
      if (_rows[i].clientActionId == clientActionId) {
        _rows[i] = _rows[i].copyWith(
          state: OutboxEntryState.rejected,
          lastError: errorCode,
        );
      }
    }
  }
}

class MemoryTopicStateStore implements TopicStateStore {
  final _rows = <String, TopicStateRecord>{};

  @override
  Future<void> putAll(Iterable<TopicStateRecord> states) async {
    for (final s in states) {
      _rows[s.topicId] = s;
    }
  }

  @override
  Future<TopicStateRecord?> get(String topicId) async => _rows[topicId];

  @override
  Future<List<TopicStateRecord>> all() async => _rows.values.toList();
}

class MemoryPackStore implements PackStore {
  final _rows = <String, InstalledPack>{};

  @override
  Future<InstalledPack?> get(String code) async => _rows[code];

  @override
  Future<List<InstalledPack>> all() async => _rows.values.toList();

  @override
  Future<void> put(InstalledPack pack) async => _rows[pack.code] = pack;

  @override
  Future<void> remove(String code) async => _rows.remove(code);
}
