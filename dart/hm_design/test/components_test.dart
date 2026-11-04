import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';

import 'gallery.dart';

/// Loads the bundled Nunito files so goldens show the real font (BOLT-0021).
Future<void> loadNunito() async {
  final loader = FontLoader(HmFonts.ui);
  for (final w in ['Regular', 'SemiBold', 'Bold', 'ExtraBold', 'Black']) {
    final bytes = File('assets/fonts/Nunito-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  // Material icons from the Flutter SDK, so goldens show real icons instead of boxes.
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

void main() {
  setUpAll(loadNunito);

  group('WCAG AA contrast (BOLT-0021)', () {
    for (final (name, palette) in [
      ('light', HmPalette.light),
      ('dark', HmPalette.dark),
      ('high contrast', HmPalette.highContrast),
    ]) {
      test('$name: every text/background pair is at least 4.5:1', () {
        palette.contrastPairs.forEach((pair, colors) {
          final ratio = HmPalette.contrast(colors.$1, colors.$2);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$name $pair is ${ratio.toStringAsFixed(2)}:1',
          );
        });
      });
    }

    test('Material scheme text pairs are AA too', () {
      for (final theme in [
        HmTheme.light(),
        HmTheme.dark(),
        HmTheme.highContrast(),
      ]) {
        final s = theme.colorScheme;
        for (final (fg, bg) in [
          (s.onPrimary, s.primary),
          (s.onSurface, s.surface),
          (s.onSurfaceVariant, s.surface),
          (s.primary, s.surface),
          (s.primary, theme.scaffoldBackgroundColor),
          (s.onSecondary, s.secondary),
          (s.error, s.surface),
          (s.onError, s.error),
        ]) {
          expect(HmPalette.contrast(fg, bg), greaterThanOrEqualTo(4.5));
        }
      }
    });
  });

  group('components', () {
    Widget wrap(Widget child, {HmModes Function(Widget)? modes}) {
      final body = Scaffold(body: Center(child: child));
      return MaterialApp(
        theme: HmTheme.light(),
        home: modes == null ? body : modes(body),
      );
    }

    testWidgets('chunky button: label for screen readers, sinks on press', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        wrap(HmPrimaryButton(label: 'Start', onPressed: () => taps++)),
      );
      expect(
        tester.getSemantics(find.byType(HmChunkyButton)),
        matchesSemantics(
          label: 'Start',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSize(find.byType(HmChunkyButton)).height,
        greaterThanOrEqualTo(48),
      );
      final g = await tester.startGesture(
        tester.getCenter(find.byType(HmChunkyButton)),
      );
      await tester.pumpAndSettle();
      final pad = tester.widget<AnimatedPadding>(find.byType(AnimatedPadding));
      expect((pad.padding as EdgeInsets).top, HmElevation.buttonDepth);
      await g.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('inside HmPlain (Exam Hall) the button is flat', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          HmPlain(
            child: HmPrimaryButton(label: 'Submit', onPressed: () {}),
          ),
        ),
      );
      final pad = tester.widget<AnimatedPadding>(find.byType(AnimatedPadding));
      expect(pad.padding, EdgeInsets.zero);
    });

    testWidgets('a disabled button does nothing', (tester) async {
      await tester.pumpWidget(
        wrap(const HmPrimaryButton(label: 'Start', onPressed: null)),
      );
      await tester.tap(find.text('Start'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('celebrations are off in Calm Mode, Lite Mode and HmPlain', (
      tester,
    ) async {
      final results = <bool>[];
      Future<void> run(Widget Function(Widget) scope) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: HmTheme.dark(),
            home: scope(
              Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await HmCelebration.show(
                      context,
                      kind: HmCelebrationKind.rankUp,
                      title: 'You are now a Typist',
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
      }

      await run((c) => HmModes(calm: true, child: c));
      await run((c) => HmModes(lite: true, child: c));
      await run((c) => HmPlain(child: c));
      expect(results, [false, false, false]);
    });

    testWidgets('a celebration shows, then closes by itself within 1.2 s', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HmTheme.dark(),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => HmCelebration.show(
                context,
                kind: HmCelebrationKind.lampLit,
                title: 'Lamp lit',
              ),
              child: const Text('go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      expect(find.text('Lamp lit'), findsOneWidget);
      await tester.pump(HmMotion.celebration);
      await tester.pumpAndSettle();
      expect(find.text('Lamp lit'), findsNothing);
      expect(HmMotion.celebration, lessThanOrEqualTo(HmMotion.maxCelebration));
    });

    testWidgets('answer tile names its state for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          HmAnswerTile(
            label: 'B',
            text: 'Article 21',
            state: HmAnswerState.wrong,
            onTap: () {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(HmAnswerTile)).label,
        'Option B: Article 21, wrong',
      );
      expect(
        tester.getSize(find.byType(HmAnswerTile)).height,
        greaterThanOrEqualTo(48),
      );
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
      handle.dispose();
    });

    testWidgets('bottom nav tabs are 48 dp buttons with labels', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var picked = -1;
      await tester.pumpWidget(
        MaterialApp(
          theme: HmTheme.dark(),
          home: Scaffold(
            bottomNavigationBar: HmBottomNav(
              currentIndex: 0,
              onSelect: (i) => picked = i,
              items: const [
                HmNavItem(label: 'Today', icon: Icons.wb_sunny_outlined),
                HmNavItem(label: 'Play', icon: Icons.sports_esports_outlined),
              ],
            ),
          ),
        ),
      );
      final play = find.bySemanticsLabel('Play, tab 2 of 2');
      expect(play, findsOneWidget);
      expect(tester.getSize(play).height, greaterThanOrEqualTo(48));
      await tester.tap(play);
      expect(picked, 1);
      handle.dispose();
    });

    test('lamp status names every state', () {
      expect(HmLampStatus.values.map((s) => s.label), [
        'Unlit',
        'Lit',
        'Steady 1',
        'Steady 2',
        'Steady 3',
        'Steady 4',
        'Dimming',
        'Dim',
        'Gold',
      ]);
      for (final s in HmLampStatus.values) {
        expect(HmLampStatus.of(s.state), s);
      }
    });

    testWidgets('progress bar reads as a percent', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 200,
            child: HmProgressBar(value: 0.4, semanticLabel: 'XP to next rank'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final s = tester.getSemantics(find.byType(HmProgressBar));
      expect(s.label, 'XP to next rank');
      expect(s.value, '40 percent');
      handle.dispose();
    });
  });

  group('gallery', () {
    testWidgets('200% text on a small phone does not overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: HmTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: HmGallery(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    for (final (name, theme) in [
      ('light', HmTheme.light),
      ('dark', HmTheme.dark),
      ('high_contrast', HmTheme.highContrast),
    ]) {
      testWidgets('component gallery golden: $name', (tester) async {
        tester.view.physicalSize = const Size(420, 1900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme(),
            home: const MediaQuery(
              data: MediaQueryData(
                size: Size(420, 1900),
                disableAnimations: true,
              ),
              child: HmGallery(),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await expectLater(
          find.byType(HmGallery),
          matchesGoldenFile('goldens/gallery_$name.png'),
        );
      });
    }
  });
}
