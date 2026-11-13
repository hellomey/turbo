import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/testing.dart';

/// Loads the bundled Nunito font and Material icons before every test so goldens show real
/// text (BOLT-0022).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadHmTestFonts();
  _useHostTolerantGoldens();
  await testMain();
}

/// Goldens are canonical on Linux, where CI runs and compares pixel-exact. Other hosts
/// anti-alias glyphs a little differently, so locally up to 6% of pixels may differ; a broken
/// layout still fails.
void _useHostTolerantGoldens() {
  final current = goldenFileComparator;
  if (Platform.isLinux || current is! LocalFileComparator) return;
  goldenFileComparator = _HostTolerantComparator(
    current.basedir.resolve('flutter_test_config.dart'),
  );
}

class _HostTolerantComparator extends LocalFileComparator {
  _HostTolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= 0.06) return true;
    throw FlutterError(await generateFailureOutput(result, golden, basedir));
  }
}
