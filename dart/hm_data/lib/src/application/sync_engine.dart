import 'dart:async';
import 'dart:convert';

import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';
import 'package:uuid/uuid.dart';

import '../data/gateways.dart';
import '../data/local_stores.dart';
import '../domain/outbox_entry.dart';
import '../domain/sync_report.dart';

/// Sends the outbox to `POST /v1/sync/study-actions` (§39, U-app-shell invariants 2–4):
/// - batches of at most [OutboxRules.batchMax], in creation order, one batch in flight at a time;
/// - each batch carries an `Idempotency-Key` derived from its action ids, so a retry of the same batch
///   reuses the key, and each action keeps its own `clientActionId`;
/// - on failure, waits with backoff (5 s doubling to 10 min) before the next try;
/// - the server wins: every returned `TopicState` replaces the local lamp.
class SyncEngine {
  SyncEngine({
    required OutboxStore outbox,
    required TopicStateStore topicStates,
    required StudySyncGateway gateway,
    required Future<String> Function() deviceId,
    required DateTime Function() clock,
  }) : _outbox = outbox,
       _topics = topicStates,
       _gateway = gateway,
       _deviceId = deviceId,
       _clock = clock;

  final OutboxStore _outbox;
  final TopicStateStore _topics;
  final StudySyncGateway _gateway;
  final Future<String> Function() _deviceId;
  final DateTime Function() _clock;

  /// Namespace for batch keys (UUID v5 over the joined action ids).
  static const _batchNamespace = '6f1d3c3e-6b0a-4c55-9a51-3f0c1e7a2b10';

  int _failures = 0;
  DateTime? _retryAt;
  Future<SyncReport>? _running;

  /// When the next retry is allowed (null = now).
  DateTime? get retryAt => _retryAt;

  /// Same batch, same key (§34.3).
  static String batchKey(Iterable<String> clientActionIds) =>
      const Uuid().v5(_batchNamespace, clientActionIds.join(','));

  /// Sends everything that is pending. Calls made while a sync runs join it. During backoff nothing is
  /// sent unless [force] (for example the phone just came online).
  Future<SyncReport> syncNow({bool force = false}) {
    final running = _running;
    if (running != null) return running;
    final run = _run(force: force);
    _running = run;
    return run.whenComplete(() => _running = null);
  }

  Future<SyncReport> _run({required bool force}) async {
    final retryAt = _retryAt;
    if (!force && retryAt != null && _clock().isBefore(retryAt)) {
      return SyncReport(
        remaining: await _outbox.pendingCount(),
        failed: true,
        retryAt: retryAt,
      );
    }
    var sent = 0, accepted = 0, logOnly = 0, rejected = 0;
    while (true) {
      final batch = await _outbox.pending(limit: OutboxRules.batchMax);
      if (batch.isEmpty) break;
      final ids = [for (final e in batch) e.clientActionId];
      final api.SyncBatchResult result;
      try {
        result = await _gateway.send(
          idempotencyKey: batchKey(ids),
          deviceId: await _deviceId(),
          actions: [for (final e in batch) e.toWire()],
        );
      } on HmApiException catch (e) {
        await _outbox.recordFailure(ids, e.code);
        _failures++;
        _retryAt = _clock().add(OutboxRules.backoff(_failures));
        return SyncReport(
          sent: sent,
          accepted: accepted,
          studyLogOnly: logOnly,
          rejected: rejected,
          remaining: await _outbox.pendingCount(),
          failed: true,
          retryAt: _retryAt,
        );
      }
      _failures = 0;
      _retryAt = null;
      sent += batch.length;

      final done = <String>[];
      for (final r in result.results) {
        if (!ids.contains(r.clientActionId)) continue;
        final status = r.status;
        if (status == api.SyncActionResultStatusEnum.rejected) {
          rejected++;
          await _outbox.markRejected(
            r.clientActionId,
            r.errorCode ?? HmApiException.unknownError,
          );
        } else {
          if (status == api.SyncActionResultStatusEnum.studyLogOnly) {
            logOnly++;
          } else {
            accepted++;
          }
          done.add(r.clientActionId);
        }
      }
      await _outbox.remove(done);
      await _topics.putAll([
        for (final s in result.topicStates)
          TopicStateRecord(
            topicId: s.topicId,
            json: jsonEncode(s.toJson()),
            updatedAt: s.updatedAt,
          ),
      ]);
      // Actions the server did not answer stay pending; stop rather than resend them in a loop.
      if (done.length + result.results.where(_isRejected).length <
          batch.length) {
        break;
      }
    }
    return SyncReport(
      sent: sent,
      accepted: accepted,
      studyLogOnly: logOnly,
      rejected: rejected,
      remaining: await _outbox.pendingCount(),
    );
  }

  static bool _isRejected(api.SyncActionResult r) =>
      r.status == api.SyncActionResultStatusEnum.rejected;
}
