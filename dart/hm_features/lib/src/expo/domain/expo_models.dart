/// Expo Challenge models (BOLT-0111): a short quiz for stall visitors that ends with a sticker code.
library;

class ExpoOption {
  const ExpoOption({required this.id, required this.text});

  final String id;
  final String text;
}

class ExpoQuestion {
  const ExpoQuestion({
    required this.id,
    required this.stem,
    required this.options,
  });

  final String id;
  final String stem;
  final List<ExpoOption> options;
}

class ExpoChallenge {
  const ExpoChallenge({
    required this.challengeId,
    required this.questions,
    required this.secondsPerQuestion,
  });

  final String challengeId;
  final List<ExpoQuestion> questions;
  final int secondsPerQuestion;
}

/// One answer. [optionId] is null when the time ran out.
class ExpoAnswer {
  const ExpoAnswer({
    required this.questionId,
    required this.optionId,
    required this.ms,
  });

  final String questionId;
  final String? optionId;
  final int ms;

  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'optionId': optionId,
    'ms': ms,
  };
}

class ExpoQuestionResult {
  const ExpoQuestionResult({
    required this.questionId,
    required this.correct,
    required this.correctOptionId,
    required this.explanation,
  });

  final String questionId;
  final bool correct;
  final String correctOptionId;
  final String explanation;
}

class ExpoResult {
  const ExpoResult({
    required this.score,
    required this.total,
    required this.results,
    required this.stickerCode,
  });

  final int score;
  final int total;
  final List<ExpoQuestionResult> results;
  final String? stickerCode;
}

class StickerCode {
  const StickerCode({required this.code, required this.redeemed});

  final String? code;
  final bool redeemed;
}

/// Parses the contract JSON. Unknown or missing fields fall back to safe values.
abstract final class ExpoJson {
  static ExpoChallenge challenge(Map<String, dynamic> json) => ExpoChallenge(
    challengeId: '${json['challengeId']}',
    secondsPerQuestion: json['secondsPerQuestion'] is int
        ? json['secondsPerQuestion'] as int
        : 20,
    questions: [
      for (final q in (json['questions'] as List? ?? const []))
        if (q is Map)
          ExpoQuestion(
            id: '${q['id']}',
            stem: '${q['stem']}',
            options: [
              for (final o in (q['options'] as List? ?? const []))
                if (o is Map)
                  ExpoOption(id: '${o['id']}', text: '${o['text']}'),
            ],
          ),
    ],
  );

  static ExpoResult result(Map<String, dynamic> json) => ExpoResult(
    score: json['score'] is int ? json['score'] as int : 0,
    total: json['total'] is int ? json['total'] as int : 0,
    stickerCode: json['stickerCode'] as String?,
    results: [
      for (final r in (json['results'] as List? ?? const []))
        if (r is Map)
          ExpoQuestionResult(
            questionId: '${r['questionId']}',
            correct: r['correct'] == true,
            correctOptionId: '${r['correctOptionId']}',
            explanation: '${r['explanation'] ?? ''}',
          ),
    ],
  );

  static StickerCode sticker(Map<String, dynamic> json) => StickerCode(
    code: json['code'] as String?,
    redeemed: json['redeemed'] == true,
  );
}
