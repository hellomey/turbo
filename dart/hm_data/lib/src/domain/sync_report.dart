import 'package:flutter/foundation.dart';

/// What one `SyncEngine.syncNow` run did. UI copy comes from these counts (simple English, §10.2).
@immutable
class SyncReport {
  const SyncReport({
    this.sent = 0,
    this.accepted = 0,
    this.studyLogOnly = 0,
    this.rejected = 0,
    this.remaining = 0,
    this.failed = false,
    this.skippedOffline = false,
    this.retryAt,
  });

  final int sent;

  /// Accepted or duplicate (already saved earlier).
  final int accepted;

  /// Older than 7 days: saved as study history only (`SYNC_ACTION_TOO_OLD`, §39).
  final int studyLogOnly;
  final int rejected;

  /// Still waiting in the outbox.
  final int remaining;

  /// The last send failed; it will be retried at [retryAt].
  final bool failed;
  final bool skippedOffline;
  final DateTime? retryAt;

  @override
  String toString() =>
      'SyncReport(sent: $sent, accepted: $accepted, studyLogOnly: $studyLogOnly, '
      'rejected: $rejected, remaining: $remaining, failed: $failed, '
      'skippedOffline: $skippedOffline, retryAt: $retryAt)';
}

/// Simple-English notes the UI shows (U-app-shell failure modes, §10.2).
abstract final class SyncCopy {
  static const willSync = 'Will sync when online';
  static const studyLogOnly =
      'Saved as study history. Rings only change for the last 7 days.';
  static const packRetry = "Download didn't finish. We'll try again on Wi-Fi.";
  static const couldNotSave = "Couldn't save";
}
