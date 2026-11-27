import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web: SQLite compiled to WebAssembly, stored in OPFS or IndexedDB (whichever the browser supports).
/// `sqlite3.wasm` and `drift_worker.js` ship in `apps/mobile/web/`.
QueryExecutor openHmConnection() => LazyDatabase(() async {
  final result = await WasmDatabase.open(
    databaseName: 'heymey',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
});

/// Tests run on the Dart VM, never on web.
QueryExecutor openHmMemoryConnection() =>
    throw UnsupportedError('In-memory database is not available on web');
