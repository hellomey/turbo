import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/content_pack.dart';
import '../domain/outbox_entry.dart';
import 'local_stores.dart';

/// The local SQLite database (§39), on Drift.
///
/// Tables are declared in plain SQL and read with `customSelect`, so there is no build_runner step and no
/// generated file to keep in sync. Migrations are additive only (U-app-shell logical design); bump
/// [schemaVersion] and add a step to [_steps] for every change.
class HmDatabase extends GeneratedDatabase {
  HmDatabase(super.executor);

  /// Opens `heymey.sqlite` in the app support folder, on a background isolate.
  factory HmDatabase.open() => HmDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      return NativeDatabase.createInBackground(
        File('${dir.path}${Platform.pathSeparator}heymey.sqlite'),
      );
    }),
  );

  /// In memory (tests).
  factory HmDatabase.memory() => HmDatabase(NativeDatabase.memory());

  /// Step `n` upgrades version `n` to `n + 1`; step 0 creates version 1.
  static const List<List<String>> _steps = [
    [
      'CREATE TABLE IF NOT EXISTS outbox ('
          'seq INTEGER PRIMARY KEY AUTOINCREMENT, '
          'client_action_id TEXT NOT NULL UNIQUE, '
          'kind TEXT NOT NULL, '
          'payload TEXT NOT NULL, '
          'client_at INTEGER NOT NULL, '
          'attempts INTEGER NOT NULL DEFAULT 0, '
          'last_error TEXT, '
          "state TEXT NOT NULL DEFAULT 'pending')",
      'CREATE TABLE IF NOT EXISTS topic_states ('
          'topic_id TEXT PRIMARY KEY, '
          'json TEXT NOT NULL, '
          'updated_at INTEGER NOT NULL)',
      'CREATE TABLE IF NOT EXISTS packs ('
          'code TEXT PRIMARY KEY, '
          'version INTEGER NOT NULL, '
          'sha256 TEXT NOT NULL, '
          'path TEXT NOT NULL, '
          'size_bytes INTEGER NOT NULL, '
          'tier TEXT NOT NULL)',
    ],
  ];

  @override
  int get schemaVersion => _steps.length;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (final step in _steps) {
        for (final sql in step) {
          await customStatement(sql);
        }
      }
    },
    onUpgrade: (m, from, to) async {
      for (var v = from; v < to; v++) {
        for (final sql in _steps[v]) {
          await customStatement(sql);
        }
      }
    },
  );
}

class DriftOutboxStore implements OutboxStore {
  DriftOutboxStore(this._db);
  final HmDatabase _db;

  static OutboxEntry _row(QueryRow r) => OutboxEntry(
    seq: r.read<int>('seq'),
    clientActionId: r.read<String>('client_action_id'),
    kind: r.read<String>('kind'),
    payloadJson: r.read<String>('payload'),
    clientAt: DateTime.fromMillisecondsSinceEpoch(
      r.read<int>('client_at'),
      isUtc: true,
    ),
    attempts: r.read<int>('attempts'),
    lastError: r.readNullable<String>('last_error'),
    state: OutboxEntryState.values.byName(r.read<String>('state')),
  );

  @override
  Future<bool> add(NewOutboxEntry entry) => _db.transaction(() async {
    final existing = await _db
        .customSelect(
          'SELECT 1 FROM outbox WHERE client_action_id = ?',
          variables: [Variable.withString(entry.clientActionId)],
        )
        .getSingleOrNull();
    if (existing != null) return false;
    await _db.customStatement(
      'INSERT INTO outbox (client_action_id, kind, payload, client_at) '
      'VALUES (?, ?, ?, ?)',
      [
        entry.clientActionId,
        entry.kind,
        entry.payloadJson,
        entry.clientAt.toUtc().millisecondsSinceEpoch,
      ],
    );
    return true;
  });

  @override
  Future<List<OutboxEntry>> pending({required int limit}) async {
    final rows = await _db
        .customSelect(
          "SELECT * FROM outbox WHERE state = 'pending' ORDER BY seq LIMIT ?",
          variables: [Variable.withInt(limit)],
        )
        .get();
    return rows.map(_row).toList();
  }

  @override
  Future<List<OutboxEntry>> rejected() async {
    final rows = await _db
        .customSelect(
          "SELECT * FROM outbox WHERE state = 'rejected' ORDER BY seq",
        )
        .get();
    return rows.map(_row).toList();
  }

  @override
  Future<int> pendingCount() async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS n FROM outbox WHERE state = 'pending'",
        )
        .getSingle();
    return row.read<int>('n');
  }

  @override
  Future<void> remove(Iterable<String> clientActionIds) =>
      _db.transaction(() async {
        for (final id in clientActionIds) {
          await _db.customStatement(
            'DELETE FROM outbox WHERE client_action_id = ?',
            [id],
          );
        }
      });

  @override
  Future<void> recordFailure(Iterable<String> clientActionIds, String error) =>
      _db.transaction(() async {
        for (final id in clientActionIds) {
          await _db.customStatement(
            'UPDATE outbox SET attempts = attempts + 1, last_error = ? '
            'WHERE client_action_id = ?',
            [error, id],
          );
        }
      });

  @override
  Future<void> markRejected(String clientActionId, String errorCode) =>
      _db.customStatement(
        "UPDATE outbox SET state = 'rejected', last_error = ? "
        'WHERE client_action_id = ?',
        [errorCode, clientActionId],
      );
}

class DriftTopicStateStore implements TopicStateStore {
  DriftTopicStateStore(this._db);
  final HmDatabase _db;

  static TopicStateRecord _row(QueryRow r) => TopicStateRecord(
    topicId: r.read<String>('topic_id'),
    json: r.read<String>('json'),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      r.read<int>('updated_at'),
      isUtc: true,
    ),
  );

  @override
  Future<void> putAll(Iterable<TopicStateRecord> states) =>
      _db.transaction(() async {
        for (final s in states) {
          await _db.customStatement(
            'INSERT OR REPLACE INTO topic_states (topic_id, json, updated_at) '
            'VALUES (?, ?, ?)',
            [s.topicId, s.json, s.updatedAt.toUtc().millisecondsSinceEpoch],
          );
        }
      });

  @override
  Future<TopicStateRecord?> get(String topicId) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM topic_states WHERE topic_id = ?',
          variables: [Variable.withString(topicId)],
        )
        .getSingleOrNull();
    return row == null ? null : _row(row);
  }

  @override
  Future<List<TopicStateRecord>> all() async {
    final rows = await _db.customSelect('SELECT * FROM topic_states').get();
    return rows.map(_row).toList();
  }
}

class DriftPackStore implements PackStore {
  DriftPackStore(this._db);
  final HmDatabase _db;

  static InstalledPack _row(QueryRow r) => InstalledPack(
    code: r.read<String>('code'),
    version: r.read<int>('version'),
    sha256: r.read<String>('sha256'),
    path: r.read<String>('path'),
    sizeBytes: r.read<int>('size_bytes'),
    tier: PackTier.values.byName(r.read<String>('tier')),
  );

  @override
  Future<InstalledPack?> get(String code) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM packs WHERE code = ?',
          variables: [Variable.withString(code)],
        )
        .getSingleOrNull();
    return row == null ? null : _row(row);
  }

  @override
  Future<List<InstalledPack>> all() async {
    final rows = await _db.customSelect('SELECT * FROM packs').get();
    return rows.map(_row).toList();
  }

  @override
  Future<void> put(InstalledPack pack) => _db.customStatement(
    'INSERT OR REPLACE INTO packs (code, version, sha256, path, size_bytes, tier) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    [
      pack.code,
      pack.version,
      pack.sha256,
      pack.path,
      pack.sizeBytes,
      pack.tier.name,
    ],
  );

  @override
  Future<void> remove(String code) =>
      _db.customStatement('DELETE FROM packs WHERE code = ?', [code]);
}
