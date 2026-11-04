import 'dart:async';

import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';

import '../data/practice_repository.dart';
import '../domain/practice_models.dart';
import '../domain/study_rules.dart';

/// Local-first study writes (§39, INT-002-S18):
/// 1. every practice answer, Lit / recall / relight result and lesson completion is written to the phone's
///    outbox first, with a client UUID;
/// 2. when online, the same write is sent straight away with that UUID as its Idempotency-Key, so the server
///    stores it once (§34.3) and the app can show the grade at once;
/// 3. if the network fails, the entry stays in the outbox and the sync triggers send it later
///    ("Will sync when online").
///
/// Gold is timed by the server, so it is online only and never queued (U-app-shell invariant 5).
class StudyRecorder {
  StudyRecorder({
    required OutboxRepository outbox,
    required PracticeRepository repository,
    required Future<void> Function() nudge,
    required String Function() newId,
    void Function()? onLocalChange,
  }) : _outbox = outbox,
       _repo = repository,
       _nudge = nudge,
       _newId = newId,
       _changed = onLocalChange ?? _noop;

  static void _noop() {}

  final OutboxRepository _outbox;
  final PracticeRepository _repo;
  final Future<void> Function() _nudge;
  final String Function() _newId;
  final void Function() _changed;

  static const limitCode = 'PRACTICE_DAILY_LIMIT';

  /// Server refusals of a single write that must not be retried by the outbox.
  static bool _refused(HmApiException e) =>
      !e.isNetwork && (e.statusCode == null || e.statusCode! < 500);

  Future<SaveOutcome<PracticeAnswerView>> practiceAnswer({
    required String sessionId,
    required StudyMode mode,
    required QuestionView question,
    required List<String> chosen,
    required int timeMs,
    UsageView? lastUsage,
    String? sheetShownOnIstDay,
  }) async {
    final id = _newId();
    await _outbox.record(
      PracticeAnswerAction(
        questionId: question.id,
        questionVersion: question.version,
        chosenOptionIds: chosen,
        timeMs: timeMs,
        mode: PracticeMode.values.byName(mode.name),
      ),
      clientActionId: id,
    );
    try {
      final result = await _repo.answer(
        sessionId,
        clientActionId: id,
        question: question,
        chosen: chosen,
        timeMs: timeMs,
      );
      await _outbox.markHandled(id);
      return Graded(result);
    } on HmApiException catch (e) {
      if (!_refused(e)) return const SavedOffline();
      await _outbox.markHandled(id);
      if (e.code == limitCode) {
        return LimitReached(
          showSheet: shouldShowLimitSheet(
            lastUsage: lastUsage,
            shownOnIstDay: sheetShownOnIstDay,
          ),
          usage: lastUsage,
        );
      }
      return NotSaved(e.message);
    } finally {
      _changed();
    }
  }

  /// Sends a finished Lit / recall / relight / Gold check.
  Future<SaveOutcome<CheckResultView>> checkResult(
    CheckView check,
    Map<String, List<String>> chosen,
  ) async {
    final answers = <Map<String, Object>>[
      for (final q in check.questions)
        {
          'questionId': q.id,
          'chosenOptionIds': chosen[q.id] ?? const <String>[],
        },
    ];
    final id = _newId();
    if (check.kind == CheckKind.gold) {
      try {
        return Graded(
          await _repo.submitCheck(check.checkId, answers, idempotencyKey: id),
        );
      } on HmApiException catch (e) {
        return NotSaved(
          e.isNetwork ? StudyCopy.goldNeedsConnection : e.message,
        );
      }
    }
    await _outbox.record(
      TopicCheckAction(
        topicId: check.topicId,
        checkKind: OfflineCheckKind.values.byName(check.kind.name),
        answers: answers,
      ),
      clientActionId: id,
    );
    try {
      final result = await _repo.submitCheck(
        check.checkId,
        answers,
        idempotencyKey: id,
      );
      await _outbox.markHandled(id);
      return Graded(result);
    } on HmApiException catch (e) {
      if (!_refused(e)) return const SavedOffline();
      await _outbox.markHandled(id);
      return NotSaved(e.message);
    } finally {
      _changed();
    }
  }

  /// "I've finished this lesson" (§5.1): queued, then sent at once when online so the Lit check can open.
  Future<void> lessonComplete(String topicId) async {
    await _outbox.record(
      LessonCompleteAction(topicId: topicId, via: LessonVia.lesson),
      clientActionId: _newId(),
    );
    _changed();
    try {
      await _nudge();
    } on Object {
      // The outbox keeps it; the sync triggers retry (§39).
    }
    _changed();
  }
}
