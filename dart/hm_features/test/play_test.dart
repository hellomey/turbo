import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';
import 'package:material_ui/material_ui.dart';

import 'support/fakes.dart';

const _prizes = [
  SpinPrizeView(
    id: 'points_5',
    label: '5 Points',
    kind: 'points',
    amount: 5,
    percent: 40,
  ),
  SpinPrizeView(
    id: 'points_10',
    label: '10 Points',
    kind: 'points',
    amount: 10,
    percent: 30,
  ),
  SpinPrizeView(
    id: 'points_20',
    label: '20 Points',
    kind: 'points',
    amount: 20,
    percent: 15,
  ),
  SpinPrizeView(
    id: 'points_50',
    label: '50 Points',
    kind: 'points',
    amount: 50,
    percent: 5,
  ),
  SpinPrizeView(
    id: 'none',
    label: 'Better luck tomorrow',
    kind: 'none',
    amount: 0,
    percent: 10,
  ),
];

const _rules = DuelRulesView(
  questionsPerDuel: 5,
  timeLimitSeconds: 150,
  minSecondsForPoints: 10,
  graceSeconds: 60,
  dailyPointsCap: 50,
  scoring: [
    DuelScoringRowView(
      confidence: 1,
      label: 'Not sure',
      correctPoints: 2,
      wrongPoints: 1,
    ),
    DuelScoringRowView(
      confidence: 2,
      label: 'Fairly sure',
      correctPoints: 3,
      wrongPoints: 0,
    ),
    DuelScoringRowView(
      confidence: 3,
      label: 'Certain',
      correctPoints: 5,
      wrongPoints: 0,
    ),
  ],
);

DailySpinView _state({bool spun = false, bool asleep = false}) => DailySpinView(
  oddsVersion: 1,
  prizes: _prizes,
  spunToday: spun,
  todaysPrize: spun ? _prizes[2] : null,
  nextSpinAt: DateTime.utc(2026, 11, 25, 23, 30),
  asleep: asleep,
);

/// Server stand-in: records what the app sends; never decides anything the server would not.
class FakePlayRepository implements PlayRepository {
  FakePlayRepository({this.state});

  DailySpinView? state;
  int spins = 0;
  List<DuelAnswer>? sent;

  @override
  Future<DailySpinView> dailySpin() async => state ?? _state();

  @override
  Future<SpinResultView> spin() async {
    spins++;
    return const SpinResultView(
      prize: SpinPrizeView(
        id: 'points_20',
        label: '20 Points',
        kind: 'points',
        amount: 20,
        percent: 15,
      ),
      alreadySpun: false,
    );
  }

  @override
  Future<GameRulesView> rules() async => const GameRulesView(
    oddsVersion: 1,
    spinPrizes: _prizes,
    spinsPerDay: 1,
    duel: _rules,
    sleepFrom: '00:00',
    sleepTo: '05:00',
  );

  @override
  Future<DuelView> startDuel(String examCode) async => DuelView(
    duelId: 'd1',
    startedAt: DateTime.utc(2026, 11, 25, 4, 30),
    questions: const [
      DuelQuestionView(
        id: 'q1',
        stem: 'Capital of Tamil Nadu?',
        options: [
          DuelOptionView(id: 'a', text: 'Chennai'),
          DuelOptionView(id: 'b', text: 'Madurai'),
        ],
      ),
    ],
    rules: _rules,
    pointsToday: 0,
  );

  @override
  Future<DuelResultView> submitDuel(
    String duelId,
    List<DuelAnswer> answers,
  ) async {
    sent = answers;
    return DuelResultView.fromJson({
      'duelId': duelId,
      'results': [
        {
          'questionId': 'q1',
          'correct': true,
          'correctOptionIds': ['a'],
          'chosenOptionId': 'a',
          'confidence': 3,
          'explanationMarkdown': 'Chennai is the capital.',
          'points': 5,
        },
      ],
      'score': 5,
      'pointsAwarded': 0,
      'pointsWithheld': 'too_fast',
      'pointsToday': 0,
      'dailyPointsCap': 50,
    });
  }
}

/// BOLT-0115: Play hub, Daily Spin (odds on the same screen), Confidence Duel, Rules & odds.
void main() {
  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Harness harness(FakePlayRepository repo) => Harness(
    extra: [
      playRepositoryProvider.overrideWithValue(repo),
      mainExamCodeProvider.overrideWith((ref) async => 'tnpsc-group-4'),
    ],
  );

  testWidgets(
    'Play hub shows the three tiles and says prizes are Points only',
    (tester) async {
      await tester.pumpWidget(
        harness(FakePlayRepository()).app(const Scaffold(body: PlayTab())),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('play-spin')), findsOneWidget);
      expect(find.byKey(const Key('play-duel')), findsOneWidget);
      expect(find.byKey(const Key('play-rules')), findsOneWidget);
      expect(find.textContaining('Points only'), findsOneWidget);
      expect(
        find.textContaining(RegExp('casino|bet|jackpot', caseSensitive: false)),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Daily Spin shows every exact chance before spinning, then the server prize',
    (tester) async {
      tall(tester);
      final repo = FakePlayRepository();
      await tester.pumpWidget(harness(repo).app(const DailySpinScreen()));
      await tester.pumpAndSettle();
      for (final p in _prizes) {
        expect(find.byKey(Key('odds-${p.id}')), findsOneWidget);
      }
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('5%'), findsOneWidget);
      expect(find.textContaining('version 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('spin-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      double turn() =>
          (tester
                      .widget<CustomPaint>(find.byKey(const Key('spin-wheel')))
                      .painter!
                  as SpinWheelPainter)
              .turn;
      final target = -SpinWheelPainter.centreOf(_prizes, 'points_20');
      expect(
        turn(),
        isNot(closeTo(target, 0.001)),
        reason: 'turning, at most 400 ms',
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(turn(), closeTo(target, 0.001));
      await tester.pumpAndSettle();
      expect(repo.spins, 1);
      expect(find.text('You won 20 Points.'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('spin-button')))
            .onPressed,
        isNull,
      );
      // Odds stay on screen after the spin.
      expect(find.byKey(const Key('odds-none')), findsOneWidget);
    },
  );

  testWidgets('Daily Spin: already spun or asleep means no spin button', (
    tester,
  ) async {
    tall(tester);
    final repo = FakePlayRepository(state: _state(spun: true));
    final h = harness(repo);
    await tester.pumpWidget(h.app(const DailySpinScreen()));
    await tester.pumpAndSettle();
    expect(find.text('You won 20 Points.'), findsOneWidget);
    expect(find.text('Next free spin tomorrow at 5 AM'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('spin-button')))
          .onPressed,
      isNull,
    );

    repo.state = _state(asleep: true);
    h.container.invalidate(dailySpinProvider);
    await tester.pumpAndSettle();
    expect(find.text('Games are sleeping until 5 AM'), findsOneWidget);
  });

  testWidgets('Daily Spin under reduce-motion lands with no animation', (
    tester,
  ) async {
    tall(tester);
    final repo = FakePlayRepository();
    await tester.pumpWidget(
      harness(repo).app(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const DailySpinScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('spin-button')));
    await tester.pump();
    await tester.pump();
    // The wheel is already on the prize: no turn in between.
    final wheel = tester.widget<CustomPaint>(
      find.byKey(const Key('spin-wheel')),
    );
    expect(
      (wheel.painter! as SpinWheelPainter).turn,
      -SpinWheelPainter.centreOf(_prizes, 'points_20'),
    );
    expect(find.text('You won 20 Points.'), findsOneWidget);
  });

  testWidgets(
    'Confidence Duel: rules card first, then answers with confidence, then the server result',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = FakePlayRepository();
      await tester.pumpWidget(harness(repo).app(const ConfidenceDuelScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('duel-rules')), findsOneWidget);
      expect(find.text('Certain'), findsOneWidget);

      await tester.tap(find.byKey(const Key('duel-start')));
      await tester.pump();
      await tester.pump();
      expect(find.text('1. Capital of Tamil Nadu?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('duel-q-0-a')));
      await tester.tap(find.byKey(const Key('duel-q-0-c3')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('duel-submit')));
      await tester.pump();
      await tester.pump();
      expect(repo.sent, [(questionId: 'q1', optionId: 'a', confidence: 3)]);
      expect(find.text('You scored 5. +0 Points.'), findsOneWidget);
      expect(find.byKey(const Key('duel-withheld')), findsOneWidget);
      expect(find.text('Chennai is the capital.'), findsOneWidget);
    },
  );

  testWidgets('Rules & odds lists every chance and the duel scoring', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      harness(FakePlayRepository()).app(const GameRulesScreen()),
    );
    await tester.pumpAndSettle();
    for (final p in _prizes) {
      expect(find.byKey(Key('rules-odds-${p.id}')), findsOneWidget);
    }
    expect(find.byKey(const Key('duel-rules')), findsOneWidget);
    expect(find.textContaining('00:00 to 05:00'), findsOneWidget);
  });

  testWidgets('Play screens hold at 200% text on a phone', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = harness(FakePlayRepository());
    for (final screen in const <Widget>[
      Scaffold(body: PlayTab()),
      DailySpinScreen(),
      ConfidenceDuelScreen(),
      GameRulesScreen(),
    ]) {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: MaterialApp(
            theme: HmTheme.dark(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: screen.runtimeType.toString(),
      );
    }
  });

  test('withheld notes are plain words', () {
    DuelResultView r(String? w) => DuelResultView(
      results: const [],
      score: 0,
      pointsAwarded: 0,
      pointsWithheld: w,
      pointsToday: 50,
      dailyPointsCap: 50,
    );
    expect(r(null).withheldNote, isNull);
    expect(r('daily_cap').withheldNote, contains('50 duel Points'));
    expect(r('too_late').withheldNote, contains('Time ran out'));
  });

  test('percent text is exact', () {
    expect(_prizes.first.percentText, '40%');
    expect(
      const SpinPrizeView(
        id: 'x',
        label: 'x',
        kind: 'points',
        amount: 1,
        percent: 12.5,
      ).percentText,
      '12.50%',
    );
  });
}
