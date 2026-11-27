import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

/// Android and iOS: `heymey.sqlite` in the app support folder, on a background isolate.
QueryExecutor openHmConnection() => LazyDatabase(() async {
  final dir = await getApplicationSupportDirectory();
  return NativeDatabase.createInBackground(
    File('${dir.path}${Platform.pathSeparator}heymey.sqlite'),
  );
});

/// In memory (tests).
QueryExecutor openHmMemoryConnection() => NativeDatabase.memory();
