/// Test-only helpers (BOLT-0022). Import from a `flutter_test_config.dart`, never from app code.
library;

import 'dart:io';

import 'package:flutter/services.dart';

import 'src/tokens.dart';

/// Loads the bundled Nunito files and the SDK Material icons so goldens show real text and
/// icons instead of the Ahem test font. Finds `dart/hm_design/assets/fonts` by walking up from
/// the current directory, so it works from any workspace member.
Future<void> loadHmTestFonts() async {
  final fonts = _findFonts();
  if (fonts != null) {
    final loader = FontLoader(HmFonts.ui);
    for (final w in ['Regular', 'SemiBold', 'Bold', 'ExtraBold', 'Black']) {
      final bytes = File('${fonts.path}/Nunito-$w.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (root != null && icons.existsSync()) {
    final l = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await l.load();
  }
}

Directory? _findFonts() {
  var dir = Directory.current.absolute;
  for (var i = 0; i < 6; i++) {
    for (final rel in [
      'assets/fonts',
      'hm_design/assets/fonts',
      'dart/hm_design/assets/fonts',
    ]) {
      final d = Directory('${dir.path}/$rel');
      if (File('${d.path}/Nunito-Regular.ttf').existsSync()) return d;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}
