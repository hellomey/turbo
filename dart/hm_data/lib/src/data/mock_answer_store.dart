import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'hm_database.dart';

/// One Exam Hall answer kept on the phone until the server has it (§39, D-2026-10-22-24).
@immutable
class LocalMockAnswer {
  const LocalMockAnswer({
    required this.attemptId,
    required this.questionId,
    required this.chosenOptionIds,
    required this.markedForReview,
    required this.clientAt,
    this.synced = false,
  });

  final String attemptId;
  final String questionId;
  final List<String> chosenOptionIds;
  final bool markedForReview;
  final DateTime clientAt;

  /// True once a `PUT answers` that carried exactly this version succeeded.
  final bool synced;

  LocalMockAnswer copyWith({bool? synced}) => LocalMockAnswer(
    attemptId: attemptId,
    questionId: questionId,
    chosenOptionIds: chosenOptionIds,
    markedForReview: markedForReview,
    clientAt: clientAt,
    synced: synced ?? this.synced,
  );
}

/// Local-first store for mock answers and the attempt in progress (resume after the app is killed, §19.8 Q76).
abstract interface class MockAnswerStore {
  /// Saves (replaces) the answer for one question, not yet synced.
  Future<void> put(LocalMockAnswer answer);
  Future<List<LocalMockAnswer>> all(String attemptId);
  Future<List<LocalMockAnswer>> unsynced(String attemptId);

  /// Marks the given versions as synced; a newer local change to the same question stays unsynced.
  Future<void> markSynced(Iterable<LocalMockAnswer> sent);
  Future<String?> activeAttempt();
  Future<void> setActiveAttempt(String? attemptId);

  /// Forgets everything about an attempt (after submit).
  Future<void> clear(String attemptId);
}

class MemoryMockAnswerStore implements MockAnswerStore {
  final _rows = <String, LocalMockAnswer>{};
  String? _active;

  static String _key(String a, String q) => '$a|$q';

  @override
  Future<void> put(LocalMockAnswer answer) async =>
      _rows[_key(answer.attemptId, answer.questionId)] = answer.copyWith(
        synced: false,
      );

  @override
  Future<List<LocalMockAnswer>> all(String attemptId) async =>
      _rows.values.where((r) => r.attemptId == attemptId).toList();

  @override
  Future<List<LocalMockAnswer>> unsynced(String attemptId) async =>
      _rows.values.where((r) => r.attemptId == attemptId && !r.synced).toList();

  @override
  Future<void> markSynced(Iterable<LocalMockAnswer> sent) async {
    for (final s in sent) {
      final k = _key(s.attemptId, s.questionId);
      final row = _rows[k];
      if (row != null && row.clientAt == s.clientAt) {
        _rows[k] = row.copyWith(synced: true);
      }
    }
  }

  @override
  Future<String?> activeAttempt() async => _active;

  @override
  Future<void> setActiveAttempt(String? attemptId) async => _active = attemptId;

  @override
  Future<void> clear(String attemptId) async {
    _rows.removeWhere((_, r) => r.attemptId == attemptId);
    if (_active == attemptId) _active = null;
  }
}

class DriftMockAnswerStore implements MockAnswerStore {
  DriftMockAnswerStore(this._db);
  final HmDatabase _db;

  static LocalMockAnswer _row(QueryRow r) => LocalMockAnswer(
    attemptId: r.read<String>('attempt_id'),
    questionId: r.read<String>('question_id'),
    chosenOptionIds: [
      for (final o in jsonDecode(r.read<String>('chosen')) as List) '$o',
    ],
    markedForReview: r.read<int>('marked') == 1,
    clientAt: DateTime.fromMillisecondsSinceEpoch(
      r.read<int>('client_at'),
      isUtc: true,
    ),
    synced: r.read<int>('synced') == 1,
  );

  @override
  Future<void> put(LocalMockAnswer a) => _db.customStatement(
    'INSERT OR REPLACE INTO mock_answers '
    '(attempt_id, question_id, chosen, marked, client_at, synced) VALUES (?, ?, ?, ?, ?, 0)',
    [
      a.attemptId,
      a.questionId,
      jsonEncode(a.chosenOptionIds),
      a.markedForReview ? 1 : 0,
      a.clientAt.toUtc().millisecondsSinceEpoch,
    ],
  );

  Future<List<LocalMockAnswer>> _select(String sql, String attemptId) async {
    final rows = await _db
        .customSelect(sql, variables: [Variable.withString(attemptId)])
        .get();
    return rows.map(_row).toList();
  }

  @override
  Future<List<LocalMockAnswer>> all(String attemptId) =>
      _select('SELECT * FROM mock_answers WHERE attempt_id = ?', attemptId);

  @override
  Future<List<LocalMockAnswer>> unsynced(String attemptId) => _select(
    'SELECT * FROM mock_answers WHERE attempt_id = ? AND synced = 0',
    attemptId,
  );

  @override
  Future<void> markSynced(Iterable<LocalMockAnswer> sent) =>
      _db.transaction(() async {
        for (final s in sent) {
          await _db.customStatement(
            'UPDATE mock_answers SET synced = 1 '
            'WHERE attempt_id = ? AND question_id = ? AND client_at = ?',
            [
              s.attemptId,
              s.questionId,
              s.clientAt.toUtc().millisecondsSinceEpoch,
            ],
          );
        }
      });

  @override
  Future<String?> activeAttempt() async {
    final row = await _db
        .customSelect("SELECT value FROM kv WHERE key = 'mock_active'")
        .getSingleOrNull();
    return row?.read<String>('value');
  }

  @override
  Future<void> setActiveAttempt(String? attemptId) => attemptId == null
      ? _db.customStatement("DELETE FROM kv WHERE key = 'mock_active'")
      : _db.customStatement(
          "INSERT OR REPLACE INTO kv (key, value) VALUES ('mock_active', ?)",
          [attemptId],
        );

  @override
  Future<void> clear(String attemptId) => _db.transaction(() async {
    await _db.customStatement('DELETE FROM mock_answers WHERE attempt_id = ?', [
      attemptId,
    ]);
    await _db.customStatement(
      "DELETE FROM kv WHERE key = 'mock_active' AND value = ?",
      [attemptId],
    );
  });
}
