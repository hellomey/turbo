import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

/// Play (BOLT-0115): Daily Spin and the solo Confidence Duel. The server draws, grades and scores;
/// the app only shows what the server sent. Prizes are Points only.

@immutable
class SpinPrizeView {
  const SpinPrizeView({
    required this.id,
    required this.label,
    required this.kind,
    required this.amount,
    required this.percent,
  });

  factory SpinPrizeView.fromJson(Map<String, dynamic> j) => SpinPrizeView(
    id: j['id'] as String,
    label: j['label'] as String,
    kind: j['kind'] as String,
    amount: j['amount'] as int,
    percent: (j['percent'] as num).toDouble(),
  );

  final String id;
  final String label;

  /// `points` or `none` ("Better luck tomorrow").
  final String kind;
  final int amount;

  /// Exact chance, in percent.
  final double percent;

  String get percentText => percent == percent.roundToDouble()
      ? '${percent.toInt()}%'
      : '${percent.toStringAsFixed(2)}%';
}

List<SpinPrizeView> _prizes(Object? list) => [
  for (final p in (list! as List).cast<Map<String, dynamic>>())
    SpinPrizeView.fromJson(p),
];

@immutable
class DailySpinView {
  const DailySpinView({
    required this.oddsVersion,
    required this.prizes,
    required this.spunToday,
    required this.todaysPrize,
    required this.nextSpinAt,
    required this.asleep,
  });

  factory DailySpinView.fromJson(Map<String, dynamic> j) => DailySpinView(
    oddsVersion: j['oddsVersion'] as int,
    prizes: _prizes(j['prizes']),
    spunToday: j['spunToday'] as bool,
    todaysPrize: j['todaysPrize'] == null
        ? null
        : SpinPrizeView.fromJson(j['todaysPrize'] as Map<String, dynamic>),
    nextSpinAt: DateTime.parse(j['nextSpinAt'] as String),
    asleep: j['asleep'] as bool,
  );

  final int oddsVersion;
  final List<SpinPrizeView> prizes;
  final bool spunToday;
  final SpinPrizeView? todaysPrize;
  final DateTime nextSpinAt;
  final bool asleep;
}

@immutable
class SpinResultView {
  const SpinResultView({required this.prize, required this.alreadySpun});

  factory SpinResultView.fromJson(Map<String, dynamic> j) => SpinResultView(
    prize: SpinPrizeView.fromJson(j['prize'] as Map<String, dynamic>),
    alreadySpun: j['alreadySpun'] as bool,
  );

  final SpinPrizeView prize;
  final bool alreadySpun;
}

@immutable
class DuelScoringRowView {
  const DuelScoringRowView({
    required this.confidence,
    required this.label,
    required this.correctPoints,
    required this.wrongPoints,
  });

  final int confidence;
  final String label;
  final int correctPoints;
  final int wrongPoints;
}

@immutable
class DuelRulesView {
  const DuelRulesView({
    required this.questionsPerDuel,
    required this.timeLimitSeconds,
    required this.minSecondsForPoints,
    required this.graceSeconds,
    required this.dailyPointsCap,
    required this.scoring,
  });

  factory DuelRulesView.fromJson(Map<String, dynamic> j) => DuelRulesView(
    questionsPerDuel: j['questionsPerDuel'] as int,
    timeLimitSeconds: j['timeLimitSeconds'] as int,
    minSecondsForPoints: j['minSecondsForPoints'] as int,
    graceSeconds: j['graceSeconds'] as int,
    dailyPointsCap: j['dailyPointsCap'] as int,
    scoring: [
      for (final r in (j['scoring'] as List).cast<Map<String, dynamic>>())
        DuelScoringRowView(
          confidence: r['confidence'] as int,
          label: r['label'] as String,
          correctPoints: r['correctPoints'] as int,
          wrongPoints: r['wrongPoints'] as int,
        ),
    ],
  );

  final int questionsPerDuel;
  final int timeLimitSeconds;
  final int minSecondsForPoints;
  final int graceSeconds;
  final int dailyPointsCap;
  final List<DuelScoringRowView> scoring;
}

/// `GET /v1/games/rules`.
@immutable
class GameRulesView {
  const GameRulesView({
    required this.oddsVersion,
    required this.spinPrizes,
    required this.spinsPerDay,
    required this.duel,
    required this.sleepFrom,
    required this.sleepTo,
  });

  factory GameRulesView.fromJson(Map<String, dynamic> j) {
    final spin = j['dailySpin'] as Map<String, dynamic>;
    final sleep = j['sleep'] as Map<String, dynamic>;
    return GameRulesView(
      oddsVersion: spin['oddsVersion'] as int,
      spinPrizes: _prizes(spin['prizes']),
      spinsPerDay: spin['spinsPerDay'] as int,
      duel: DuelRulesView.fromJson(j['confidenceDuel'] as Map<String, dynamic>),
      sleepFrom: sleep['from'] as String,
      sleepTo: sleep['to'] as String,
    );
  }

  final int oddsVersion;
  final List<SpinPrizeView> spinPrizes;
  final int spinsPerDay;
  final DuelRulesView duel;
  final String sleepFrom;
  final String sleepTo;
}

@immutable
class DuelOptionView {
  const DuelOptionView({required this.id, required this.text});

  final String id;
  final String text;
}

@immutable
class DuelQuestionView {
  const DuelQuestionView({
    required this.id,
    required this.stem,
    required this.options,
  });

  factory DuelQuestionView.fromJson(Map<String, dynamic> j) => DuelQuestionView(
    id: j['id'] as String,
    stem: j['stem'] as String,
    options: [
      for (final o in (j['options'] as List).cast<Map<String, dynamic>>())
        DuelOptionView(id: o['id'] as String, text: o['text'] as String),
    ],
  );

  final String id;
  final String stem;
  final List<DuelOptionView> options;
}

@immutable
class DuelView {
  const DuelView({
    required this.duelId,
    required this.startedAt,
    required this.questions,
    required this.rules,
    required this.pointsToday,
  });

  factory DuelView.fromJson(Map<String, dynamic> j) => DuelView(
    duelId: j['duelId'] as String,
    startedAt: DateTime.parse(j['startedAt'] as String),
    questions: [
      for (final q in (j['questions'] as List).cast<Map<String, dynamic>>())
        DuelQuestionView.fromJson(q),
    ],
    rules: DuelRulesView.fromJson(j['rules'] as Map<String, dynamic>),
    pointsToday: j['pointsToday'] as int,
  );

  final String duelId;
  final DateTime startedAt;
  final List<DuelQuestionView> questions;
  final DuelRulesView rules;
  final int pointsToday;
}

@immutable
class DuelAnswerResultView {
  const DuelAnswerResultView({
    required this.questionId,
    required this.correct,
    required this.correctOptionIds,
    required this.chosenOptionId,
    required this.explanation,
    required this.points,
  });

  final String questionId;
  final bool correct;
  final List<String> correctOptionIds;
  final String? chosenOptionId;
  final String explanation;
  final int points;
}

@immutable
class DuelResultView {
  const DuelResultView({
    required this.results,
    required this.score,
    required this.pointsAwarded,
    required this.pointsWithheld,
    required this.pointsToday,
    required this.dailyPointsCap,
  });

  factory DuelResultView.fromJson(Map<String, dynamic> j) => DuelResultView(
    results: [
      for (final r in (j['results'] as List).cast<Map<String, dynamic>>())
        DuelAnswerResultView(
          questionId: r['questionId'] as String,
          correct: r['correct'] as bool,
          correctOptionIds: (r['correctOptionIds'] as List).cast<String>(),
          chosenOptionId: r['chosenOptionId'] as String?,
          explanation: r['explanationMarkdown'] as String,
          points: r['points'] as int,
        ),
    ],
    score: j['score'] as int,
    pointsAwarded: j['pointsAwarded'] as int,
    pointsWithheld: j['pointsWithheld'] as String?,
    pointsToday: j['pointsToday'] as int,
    dailyPointsCap: j['dailyPointsCap'] as int,
  );

  final List<DuelAnswerResultView> results;
  final int score;
  final int pointsAwarded;

  /// `too_fast`, `too_late`, `daily_cap` or null.
  final String? pointsWithheld;
  final int pointsToday;
  final int dailyPointsCap;

  /// Plain words for why some or all Points were not credited.
  String? get withheldNote => switch (pointsWithheld) {
    'too_fast' => 'Answers came in too fast to earn Points this time.',
    'too_late' => 'Time ran out, so this duel earns no Points.',
    'daily_cap' =>
      "You've reached today's $dailyPointsCap duel Points. Keep playing for practice.",
    _ => null,
  };
}

/// One answer in a duel. `confidence` is 1 (Not sure) to 3 (Certain).
typedef DuelAnswer = ({String questionId, String optionId, int confidence});

/// Games over hm_api. Overridden with a fake in widget tests.
class PlayRepository {
  const PlayRepository(this._api);

  final HmApi _api;

  Future<GameRulesView> rules() async =>
      GameRulesView.fromJson(await _api.getGameRules());

  Future<DailySpinView> dailySpin() async =>
      DailySpinView.fromJson(await _api.getDailySpin());

  Future<SpinResultView> spin() async =>
      SpinResultView.fromJson(await _api.spinDailySpin());

  Future<DuelView> startDuel(String examCode) async =>
      DuelView.fromJson(await _api.startConfidenceDuel(examCode));

  Future<DuelResultView> submitDuel(
    String duelId,
    List<DuelAnswer> answers,
  ) async => DuelResultView.fromJson(
    await _api.submitConfidenceDuel(duelId, [
      for (final a in answers)
        {
          'questionId': a.questionId,
          'optionId': a.optionId,
          'confidence': a.confidence,
        },
    ]),
  );
}

final playRepositoryProvider = Provider<PlayRepository>(
  (ref) => PlayRepository(ref.watch(hmApiProvider)),
);

final gameRulesProvider = FutureProvider.autoDispose<GameRulesView>(
  (ref) => ref.watch(playRepositoryProvider).rules(),
);

final dailySpinProvider = FutureProvider.autoDispose<DailySpinView>(
  (ref) => ref.watch(playRepositoryProvider).dailySpin(),
);
