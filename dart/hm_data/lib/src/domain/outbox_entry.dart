import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'study_action.dart';

/// Rules of the offline outbox (blueprint §39, contract `sync.ts`, U-app-shell logical design).
abstract final class OutboxRules {
  /// Contract `SYNC_BATCH_MAX`.
  static const batchMax = 100;

  /// An action older than this when synced is a study log only: rings do not change (§39).
  static const ringWindow = Duration(days: 7);

  /// Retry backoff: 5 s, doubling, capped at 10 min.
  static const firstRetry = Duration(seconds: 5);
  static const maxRetry = Duration(minutes: 10);

  static Duration backoff(int failures) {
    if (failures <= 0) return Duration.zero;
    final shift = failures - 1 > 20 ? 20 : failures - 1;
    final ms = firstRetry.inMilliseconds * (1 << shift);
    return ms >= maxRetry.inMilliseconds
        ? maxRetry
        : Duration(milliseconds: ms);
  }
}

enum OutboxEntryState { pending, rejected }

/// One queued study action. [clientActionId] is the per-action idempotency key and never changes
/// across retries (§34.3, §39).
@immutable
class OutboxEntry {
  const OutboxEntry({
    required this.seq,
    required this.clientActionId,
    required this.kind,
    required this.payloadJson,
    required this.clientAt,
    this.attempts = 0,
    this.lastError,
    this.state = OutboxEntryState.pending,
  });

  /// Creation order (assigned by the store). Batches go out in this order.
  final int seq;
  final String clientActionId;
  final String kind;

  /// [StudyAction.fieldsJson] as JSON text.
  final String payloadJson;

  /// When the user did it (UTC).
  final DateTime clientAt;
  final int attempts;

  /// Error code of the last failed send, or the server's code when rejected.
  final String? lastError;
  final OutboxEntryState state;

  StudyAction get action => StudyAction.fromStored(
    kind,
    (jsonDecode(payloadJson) as Map).cast<String, dynamic>(),
  );

  /// True when syncing now can only save it as study history (older than 7 days, §39).
  bool isPastRingWindow(DateTime now) =>
      now.difference(clientAt) > OutboxRules.ringWindow;

  /// Contract `SyncAction` JSON.
  Map<String, Object> toWire() => {
    'clientActionId': clientActionId,
    'clientAt': clientAt.toUtc().toIso8601String(),
    'kind': kind,
    ...(jsonDecode(payloadJson) as Map).cast<String, Object>(),
  };

  OutboxEntry copyWith({
    int? attempts,
    String? lastError,
    OutboxEntryState? state,
  }) => OutboxEntry(
    seq: seq,
    clientActionId: clientActionId,
    kind: kind,
    payloadJson: payloadJson,
    clientAt: clientAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError ?? this.lastError,
    state: state ?? this.state,
  );
}
