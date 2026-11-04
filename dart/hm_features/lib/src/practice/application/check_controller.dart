import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../domain/practice_models.dart';
import '../domain/study_rules.dart';
import 'practice_providers.dart';

/// Which check for which lamp (§5.1). [lessonStep] = show "I've finished the lesson" first (Lit, INT-002-S01).
typedef CheckRequest = ({String topicId, CheckKind kind, bool lessonStep});

enum CheckStage { lesson, loading, answering, sending, done, failed }

@immutable
class CheckState {
  const CheckState({
    required this.stage,
    this.check,
    this.index = 0,
    this.chosen = const {},
    this.outcome,
    this.message,
    this.issuedLocal,
  });

  final CheckStage stage;
  final CheckView? check;
  final int index;
  final Map<String, List<String>> chosen;
  final SaveOutcome<CheckResultView>? outcome;

  /// Simple-English reason when [stage] is failed.
  final String? message;

  /// Local time when the server issued the check (for the Gold countdown).
  final DateTime? issuedLocal;

  QuestionView? get question {
    final qs = check?.questions ?? const [];
    return index < qs.length ? qs[index] : null;
  }

  bool get isLast => check != null && index == check!.questions.length - 1;

  CheckState copyWith({
    CheckStage? stage,
    CheckView? check,
    int? index,
    Map<String, List<String>>? chosen,
    SaveOutcome<CheckResultView>? outcome,
    String? message,
    DateTime? issuedLocal,
  }) => CheckState(
    stage: stage ?? this.stage,
    check: check ?? this.check,
    index: index ?? this.index,
    chosen: chosen ?? this.chosen,
    outcome: outcome ?? this.outcome,
    message: message ?? this.message,
    issuedLocal: issuedLocal ?? this.issuedLocal,
  );
}

/// Time left on a server-timed Gold check: the server deadline minus server time now, estimated from the
/// server's `serverNow` and how long ago (locally) the check arrived. Never the phone clock alone (§34.1).
Duration? goldTimeLeft(CheckView check, DateTime issuedLocal, DateTime now) {
  final deadline = check.deadlineAt;
  final serverNow = check.serverNow;
  if (deadline == null || serverNow == null) return null;
  final left = deadline.difference(serverNow) - now.difference(issuedLocal);
  return left.isNegative ? Duration.zero : left;
}

class CheckController extends Notifier<CheckState> {
  CheckController(this.request);

  final CheckRequest request;

  @override
  CheckState build() => CheckState(
    stage: request.lessonStep ? CheckStage.lesson : CheckStage.loading,
  );

  /// "I've finished" on the lesson step: queue lesson-complete, then load the Lit check.
  Future<void> finishLesson() async {
    state = state.copyWith(stage: CheckStage.loading);
    await ref.read(studyRecorderProvider).lessonComplete(request.topicId);
    await load();
  }

  Future<void> load() async {
    state = const CheckState(stage: CheckStage.loading);
    try {
      final check = await ref
          .read(practiceRepositoryProvider)
          .startCheck(
            request.topicId,
            request.kind,
            idempotencyKey: ref.read(clientActionIdProvider)(),
          );
      if (!ref.mounted) return;
      state = CheckState(
        stage: CheckStage.answering,
        check: check,
        issuedLocal: ref.read(clockProvider)(),
      );
    } on HmApiException catch (e) {
      if (!ref.mounted) return;
      state = CheckState(
        stage: CheckStage.failed,
        message: e.isNetwork
            ? (request.kind == CheckKind.gold
                  ? StudyCopy.goldNeedsConnection
                  : StudyCopy.checkNeedsConnection)
            : e.message,
      );
    }
  }

  void choose(String optionId) {
    final q = state.question;
    if (q == null || state.stage != CheckStage.answering) return;
    state = state.copyWith(
      chosen: {
        ...state.chosen,
        q.id: [optionId],
      },
    );
  }

  void next() {
    if (state.isLast) return;
    state = state.copyWith(index: state.index + 1);
  }

  void back() {
    if (state.index == 0) return;
    state = state.copyWith(index: state.index - 1);
  }

  Future<void> submit() async {
    final check = state.check;
    if (check == null || state.stage != CheckStage.answering) return;
    state = state.copyWith(stage: CheckStage.sending);
    final outcome = await ref
        .read(studyRecorderProvider)
        .checkResult(check, state.chosen);
    if (!ref.mounted) return;
    state = state.copyWith(stage: CheckStage.done, outcome: outcome);
    if (outcome is Graded<CheckResultView>) {
      ref.invalidate(relightQueueProvider);
    }
  }
}

final checkControllerProvider = NotifierProvider.autoDispose
    .family<CheckController, CheckState, CheckRequest>(CheckController.new);
