import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

/// Test stand-in for the Expo API. Option `a` is right on every question.
class FakeExpoRepository implements ExpoRepository {
  FakeExpoRepository({
    this.stickerCode = 'HM-7K2Q',
    this.failSubmitOnce = false,
  });

  final String? stickerCode;
  bool failSubmitOnce;
  final submits = <(String, List<ExpoAnswer>, String)>[];
  var _keys = 0;

  @override
  Future<ExpoChallenge> fetchChallenge() async => ExpoChallenge(
    challengeId: 'challenge-1',
    secondsPerQuestion: 20,
    questions: [
      for (var i = 1; i <= 10; i++)
        ExpoQuestion(
          id: 'q$i',
          stem: 'Question stem $i',
          options: const [
            ExpoOption(id: 'a', text: 'Option A'),
            ExpoOption(id: 'b', text: 'Option B'),
          ],
        ),
    ],
  );

  @override
  Future<ExpoResult> submit(
    String challengeId,
    List<ExpoAnswer> answers, {
    required String idempotencyKey,
  }) async {
    submits.add((challengeId, answers, idempotencyKey));
    if (failSubmitOnce) {
      failSubmitOnce = false;
      throw HmApiException.network();
    }
    return ExpoResult(
      score: answers.where((a) => a.optionId == 'a').length,
      total: answers.length,
      stickerCode: stickerCode,
      results: [
        for (final a in answers)
          ExpoQuestionResult(
            questionId: a.questionId,
            correct: a.optionId == 'a',
            correctOptionId: 'a',
            explanation: 'Explanation for ${a.questionId}.',
          ),
      ],
    );
  }

  @override
  Future<StickerCode> myStickerCode() async =>
      StickerCode(code: stickerCode, redeemed: false);

  @override
  String newIdempotencyKey() => 'key-${++_keys}';
}

Future<Harness> pumpExpo(WidgetTester tester, FakeExpoRepository repo) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = Harness(extra: [expoRepositoryProvider.overrideWithValue(repo)]);
  await tester.pumpWidget(h.app(const ExpoChallengeScreen()));
  await tester.pump();
  await tester.pump();
  return h;
}

Future<void> pick(WidgetTester tester, String optionId) async {
  await tester.tap(find.byKey(Key('expo-option-$optionId')));
  await tester.pump();
  expect(find.text('Answer locked in.'), findsOneWidget);
  await tester.pump(expoFeedbackPause);
  await tester.pump();
}

void main() {
  testWidgets(
    'Expo Challenge: answer, time out, score, then the sticker code',
    (tester) async {
      final repo = FakeExpoRepository();
      await pumpExpo(tester, repo);

      expect(find.text('Question 1 of 10'), findsOneWidget);
      expect(find.byKey(const Key('expo-timer-bar')), findsOneWidget);
      await pick(tester, 'a');

      // Question 2: let the 20 s bar run out.
      expect(find.text('Question 2 of 10'), findsOneWidget);
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();
      expect(find.text("Time's up. On to the next one."), findsOneWidget);
      await tester.pump(expoFeedbackPause);
      await tester.pump();

      for (var i = 3; i <= 10; i++) {
        expect(find.text('Question $i of 10'), findsOneWidget);
        await pick(tester, i.isEven ? 'a' : 'b');
      }
      await tester.pumpAndSettle();

      expect(repo.submits, hasLength(1));
      final answers = repo.submits.single.$2;
      expect(answers, hasLength(10));
      expect(answers[1].optionId, isNull);
      expect(answers[0].optionId, 'a');
      // q1 and q4, q6, q8, q10 were right.
      expect(find.text('You got 5 of 10'), findsOneWidget);
      expect(find.text('Explanation for q1.'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('expo-collect-sticker')));
      await tester.tap(find.byKey(const Key('expo-collect-sticker')));
      await tester.pumpAndSettle();
      expect(find.text('HM-7K2Q'), findsOneWidget);
      expect(find.text('Show this at the HeyMey stall.'), findsOneWidget);
    },
  );

  testWidgets('a failed submit retries with the same Idempotency-Key', (
    tester,
  ) async {
    final repo = FakeExpoRepository(failSubmitOnce: true);
    await pumpExpo(tester, repo);
    for (var i = 1; i <= 10; i++) {
      await pick(tester, 'a');
    }
    await tester.pumpAndSettle();
    expect(find.text('Send again'), findsOneWidget);

    await tester.tap(find.text('Send again'));
    await tester.pumpAndSettle();
    expect(repo.submits, hasLength(2));
    expect(repo.submits[0].$3, repo.submits[1].$3);
    expect(find.text('You got 10 of 10'), findsOneWidget);
  });

  testWidgets('sticker screen without a code explains how to get one', (
    tester,
  ) async {
    final repo = FakeExpoRepository(stickerCode: null);
    final h = Harness(extra: [expoRepositoryProvider.overrideWithValue(repo)]);
    await tester.pumpWidget(h.app(const StickerScreen()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sticker-none')), findsOneWidget);
  });

  test('parses the contract JSON', () {
    final c = ExpoJson.challenge({
      'challengeId': 'c1',
      'secondsPerQuestion': 20,
      'questions': [
        {
          'id': 'q1',
          'stem': 'Stem',
          'options': [
            {'id': 'o1', 'text': 'One'},
          ],
        },
      ],
    });
    expect(c.questions.single.options.single.text, 'One');
    final r = ExpoJson.result({
      'score': 1,
      'total': 1,
      'stickerCode': null,
      'results': [
        {
          'questionId': 'q1',
          'correct': true,
          'correctOptionId': 'o1',
          'explanation': 'Why',
        },
      ],
    });
    expect(r.stickerCode, isNull);
    expect(r.results.single.correct, isTrue);
    expect(
      ExpoJson.sticker({'code': 'HM-7K2Q', 'redeemed': true}).redeemed,
      isTrue,
    );
  });
}
