import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/testing.dart';

/// Loads the bundled Nunito font and Material icons before every test so goldens show real
/// text (BOLT-0022).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadHmTestFonts();
  await testMain();
}
