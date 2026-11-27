import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../../common/ports.dart';
import '../data/expo_repository.dart';
import '../domain/expo_models.dart';

final expoRepositoryProvider = Provider<ExpoRepository>(
  (ref) => ApiExpoRepository(ref.watch(hmApiProvider)),
);

enum ExpoPhase { loading, error, question, submitting, result }

class ExpoState {
  const ExpoState({
    this.phase = ExpoPhase.loading,
    this.challenge,
    this.index = 0,
    this.answers = const [],
    this.result,
    this.error,
  });

  final ExpoPhase phase;
  final ExpoChallenge? challenge;

  /// The question on screen.
  final int index;
  final List<ExpoAnswer> answers;
  final ExpoResult? result;
  final String? error;

  ExpoQuestion? get current {
    final c = challenge;
    if (c == null || index >= c.questions.length) return null;
    return c.questions[index];
  }

  /// The option the visitor picked on the current question, once picked.
  String? get pickedOnCurrent {
    final q = current;
    if (q == null) return null;
    for (final a in answers) {
      if (a.questionId == q.id) return a.optionId;
    }
    return null;
  }

  bool get answeredCurrent {
    final q = current;
    return q != null && answers.any((a) => a.questionId == q.id);
  }

  ExpoState copyWith({
    ExpoPhase? phase,
    ExpoChallenge? challenge,
    int? index,
    List<ExpoAnswer>? answers,
    ExpoResult? result,
    String? error,
  }) => ExpoState(
    phase: phase ?? this.phase,
    challenge: challenge ?? this.challenge,
    index: index ?? this.index,
    answers: answers ?? this.answers,
    result: result ?? this.result,
    error: error,
  );
}

/// Drives one Expo Challenge: load, answer each question (or let its time run out), submit once.
class ExpoController extends Notifier<ExpoState> {
  ExpoRepository get _repo => ref.read(expoRepositoryProvider);
  String? _submitKey;

  @override
  ExpoState build() => const ExpoState();

  Future<void> start() async {
    _submitKey = null;
    state = const ExpoState();
    try {
      final c = await _repo.fetchChallenge();
      state = ExpoState(phase: ExpoPhase.question, challenge: c);
    } on Exception catch (e) {
      state = ExpoState(phase: ExpoPhase.error, error: messageOf(e));
    }
  }

  /// Records the answer for the current question. [optionId] null = time ran out. A second answer to
  /// the same question is ignored.
  void answer(String? optionId, int ms) {
    final q = state.current;
    if (state.phase != ExpoPhase.question || q == null) return;
    if (state.answeredCurrent) return;
    state = state.copyWith(
      answers: [
        ...state.answers,
        ExpoAnswer(questionId: q.id, optionId: optionId, ms: ms),
      ],
    );
  }

  /// Moves on after the feedback moment; submits after the last question.
  Future<void> next() async {
    final c = state.challenge;
    if (c == null || !state.answeredCurrent) return;
    if (state.index + 1 < c.questions.length) {
      state = state.copyWith(index: state.index + 1);
      return;
    }
    await submit();
  }

  /// Sends the answers. Safe to call again after an error: the same Idempotency-Key is reused.
  Future<void> submit() async {
    final c = state.challenge;
    if (c == null) return;
    _submitKey ??= _repo.newIdempotencyKey();
    state = state.copyWith(phase: ExpoPhase.submitting);
    try {
      final r = await _repo.submit(
        c.challengeId,
        state.answers,
        idempotencyKey: _submitKey!,
      );
      state = state.copyWith(phase: ExpoPhase.result, result: r);
    } on Exception catch (e) {
      state = state.copyWith(phase: ExpoPhase.submitting, error: messageOf(e));
    }
  }
}

final expoControllerProvider =
    NotifierProvider.autoDispose<ExpoController, ExpoState>(
      ExpoController.new,
    );

/// The visitor's sticker code (`GET /v1/me/sticker-code`).
final stickerCodeProvider = FutureProvider.autoDispose<StickerCode>(
  (ref) => ref.watch(expoRepositoryProvider).myStickerCode(),
);
