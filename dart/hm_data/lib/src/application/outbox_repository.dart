import 'dart:convert';

import 'package:hm_api/api.dart' as api;
import 'package:uuid/uuid.dart';

import '../data/local_stores.dart';
import '../domain/outbox_entry.dart';
import '../domain/study_action.dart';

/// Records study actions on this phone (§39): saved to the local database first, as an outbox entry with a
/// client UUID and timestamp, so study continues offline. The [SyncEngine] sends them later.
class OutboxRepository {
  OutboxRepository({
    required OutboxStore outbox,
    required TopicStateStore topicStates,
    required DateTime Function() clock,
    String Function()? newId,
  }) : _outbox = outbox,
       _topics = topicStates,
       _clock = clock,
       _newId = newId ?? (() => const Uuid().v4());

  final OutboxStore _outbox;
  final TopicStateStore _topics;
  final DateTime Function() _clock;
  final String Function() _newId;

  /// Queues [action] and returns its `clientActionId`. Pass [clientActionId] when the caller already has one
  /// (a repeated tap with the same id is stored once).
  Future<String> record(StudyAction action, {String? clientActionId}) async {
    final id = clientActionId ?? _newId();
    await _outbox.add(
      NewOutboxEntry(
        clientActionId: id,
        kind: action.kind,
        payloadJson: jsonEncode(action.fieldsJson()),
        clientAt: _clock().toUtc(),
      ),
    );
    return id;
  }

  Future<int> pendingCount() => _outbox.pendingCount();

  /// Actions the server refused, for the "Couldn't save" list.
  Future<List<OutboxEntry>> rejected() => _outbox.rejected();

  Future<void> dismissRejected(String clientActionId) =>
      _outbox.remove([clientActionId]);

  /// Drops an entry the server already has (the online path sent it directly with the same id) or one the
  /// server refused as a whole before storing anything (for example the free daily limit). BOLT-0017.
  Future<void> markHandled(String clientActionId) =>
      _outbox.remove([clientActionId]);

  /// The server's last known lamp for [topicId] (never an optimistic local guess, §39).
  Future<api.TopicState?> topicState(String topicId) async {
    final row = await _topics.get(topicId);
    return row == null ? null : api.TopicState.fromJson(jsonDecode(row.json));
  }

  Future<List<api.TopicState>> topicStates() async => [
    for (final row in await _topics.all())
      ?api.TopicState.fromJson(jsonDecode(row.json)),
  ];
}
