import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';
import 'package:material_ui/material_ui.dart';

/// BOLT-0110: every named Bauhaus SVG ships, stays under 10 KB and parses.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final art in HmArtName.values) {
    test('${art.file}.svg exists, is under 10 KB and parses', () async {
      final file = File('assets/svg/${art.file}.svg');
      expect(file.existsSync(), isTrue, reason: art.asset);
      expect(file.lengthSync(), lessThan(10 * 1024));
      final source = file.readAsStringSync();
      final info = await vg.loadPicture(SvgStringLoader(source), null);
      expect(info.size.isEmpty, isFalse);
      info.picture.dispose();
    });
  }

  test('lamp art follows the lamp state', () {
    expect(
      lampArtFor(lit: false, gold: false, fading: false),
      HmArtName.lampDark,
    );
    expect(
      lampArtFor(lit: true, gold: false, fading: false),
      HmArtName.lampLit,
    );
    expect(
      lampArtFor(lit: true, gold: true, fading: true),
      HmArtName.lampFading,
    );
    expect(
      lampArtFor(lit: true, gold: true, fading: false),
      HmArtName.lampGold,
    );
  });

  testWidgets('HmArt is decorative unless it has a label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: HmTheme.light(),
        home: const Column(
          children: [
            HmArt(HmArtName.mascotWave, size: 40),
            HmArt(
              HmArtName.badgeGoldLamp,
              size: 40,
              semanticLabel: 'Gold lamp badge',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Gold lamp badge'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Beta chip tells screen readers HeyMey is in beta', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: HmTheme.light(),
        home: const Scaffold(body: Center(child: HmBetaChip())),
      ),
    );
    expect(
      find.bySemanticsLabel('Beta. HeyMey is in beta and still being built.'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(HmBetaChip)).height,
      greaterThanOrEqualTo(48),
    );
    handle.dispose();
  });

  testWidgets('bento grid falls back to one column at 200% text', (
    tester,
  ) async {
    Widget grid(double scale) => MaterialApp(
      theme: HmTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(400, 800),
          textScaler: TextScaler.linear(scale),
        ),
        child: const Scaffold(
          body: SingleChildScrollView(
            child: HmBentoGrid(
              children: [
                HmBentoTile(key: Key('a'), child: Text('A')),
                HmBentoTile(key: Key('b'), child: Text('B')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(grid(1));
    await tester.pumpAndSettle();
    final a1 = tester.getTopLeft(find.byKey(const Key('a')));
    final b1 = tester.getTopLeft(find.byKey(const Key('b')));
    expect(a1.dy, b1.dy, reason: 'two tiles share a row at 100% text');
    await tester.pumpWidget(grid(2));
    await tester.pumpAndSettle();
    final a2 = tester.getTopLeft(find.byKey(const Key('a')));
    final b2 = tester.getTopLeft(find.byKey(const Key('b')));
    expect(b2.dy, greaterThan(a2.dy), reason: 'one column at 200% text');
  });

  testWidgets('pop and shake stay still when motion is off', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HmTheme.light(),
        home: const HmModes(
          calm: true,
          child: Column(
            children: [
              HmPop(child: Text('pop')),
              HmShake(child: Text('shake')),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });
}
