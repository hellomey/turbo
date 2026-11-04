import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';

import '../../common/ports.dart';
import '../data/exam_hall_repository.dart';
import '../domain/exam_hall_models.dart';

/// Exam Hall wiring (§10.6). Tests override the repository, the answer store and the network source.

final examHallRepositoryProvider = Provider<ExamHallRepository>(
  (ref) => ApiExamHallRepository(ref.watch(hmApiProvider)),
);

/// New Idempotency-Key per write (§34.3); the caller keeps it while retrying the same write.
final idempotencyKeyFactoryProvider = Provider<String Function()>((ref) {
  final random = Random.secure();
  return () => [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
});

final mockListProvider = FutureProvider.family<MockListView, String>(
  (ref, examCode) => ref.watch(examHallRepositoryProvider).mocks(examCode),
);

final stateMockProvider = FutureProvider.family<StateMockCardView?, String>(
  (ref, examCode) => ref.watch(examHallRepositoryProvider).stateMock(examCode),
);

enum ExamPhase { idle, starting, active, submitting, finished }

class ExamHallState {
  const ExamHallState({
    this.phase = ExamPhase.idle,
    this.session,
    this.serverOffset = Duration.zero,
    this.index = 0,
    this.pending = 0,
    this.report,
    this.message,
    this.blockedWithNotNow = false,
    this.resumableAttemptId,
    this.timeUp = false,
  });

  final ExamPhase phase;
  final MockSession? session;

  /// serverNow − phone now at the last server reply.
  final Duration serverOffset;

  /// The question on screen (CBT) / scrolled to (OMR).
  final int index;

  /// Answers saved on the phone that the server does not have yet.
  final int pending;
  final ReportView? report;

  /// A simple-English message to show (error or notice).
  final String? message;

  /// The message is a limit; show it with "Not now" (§13, D-2026-10-22-19).
  final bool blockedWithNotNow;

  /// An attempt left open when the app was closed (§19.8 Q76).
  final String? resumableAttemptId;
  final bool timeUp;

  ExamHallState copyWith({
    ExamPhase? phase,
    MockSession? session,
    Duration? serverOffset,
    int? index,
    int? pending,
    ReportView? report,
    String? Function()? message,
    bool? blockedWithNotNow,
    String? Function()? resumableAttemptId,
    bool? timeUp,
  }) => ExamHallState(
    phase: phase ?? this.phase,
    session: session ?? this.session,
    serverOffset: serverOffset ?? this.serverOffset,
    index: index ?? this.index,
    pending: pending ?? this.pending,
    report: report ?? this.report,
    message: message == null ? this.message : message(),
    blockedWithNotNow: blockedWithNotNow ?? this.blockedWithNotNow,
    resumableAttemptId: resumableAttemptId == null
        ? this.resumableAttemptId
        : resumableAttemptId(),
    timeUp: timeUp ?? this.timeUp,
  );
}

/// One mock attempt at a time: start (needs a connection), answer (phone first, then the server),
/// resume, submit, report. No business rules live in widgets.
class ExamHallController extends Notifier<ExamHallState> {
  ExamHallRepository get _repo => ref.read(examHallRepositoryProvider);
  MockAnswerStore get _store => ref.read(mockAnswerStoreProvider);
  DateTime _now() => ref.read(clockProvider)();

  bool _flushing = false;
  DateTime? _lastFlush;

  /// Sent at least this often while answers are waiting (U-exam-hall logical design: every change / 10 s).
  static const flushEvery = Duration(seconds: 10);

  @override
  ExamHallState build() => const ExamHallState();

  Duration _offsetFrom(DateTime serverNow) => serverNow.difference(_now());

  Duration get timeLeftNow {
    final s = state.session;
    if (s == null) return Duration.zero;
    return timeLeft(
      deadlineAt: s.deadlineAt,
      localNow: _now(),
      serverOffset: state.serverOffset,
    );
  }

  /// Looks for an attempt left open on this phone (the app was killed).
  Future<void> checkResume() async {
    final id = await _store.activeAttempt();
    state = state.copyWith(resumableAttemptId: () => id);
  }

  void dismissMessage() =>
      state = state.copyWith(message: () => null, blockedWithNotNow: false);

  /// Back to the list after a finished attempt.
  void reset() =>
      state = ExamHallState(resumableAttemptId: state.resumableAttemptId);

  /// Starts a mock. Needs a connection: the server issues the start time and deadline (D-2026-10-22-24).
  Future<bool> start(MockItem mock) async {
    if (state.phase == ExamPhase.starting) return false;
    state = state.copyWith(
      phase: ExamPhase.starting,
      message: () => null,
      blockedWithNotNow: false,
    );
    final network = await ref.read(networkSourceProvider).current();
    if (!network.online) {
      _fail(ExamHallCopy.needsConnection);
      return false;
    }
    try {
      final mode = await _repo.answerMode(mock.examCode, mock.paperCode);
      if (mode == null) {
        _fail(ExamHallCopy.descriptiveLater);
        return false;
      }
      final session = await _repo.start(
        mock.id,
        mode,
        idempotencyKey: ref.read(idempotencyKeyFactoryProvider)(),
      );
      await _store.setActiveAttempt(session.attemptId);
      await _open(session);
      return true;
    } on HmApiException catch (e) {
      switch (e.code) {
        case 'MOCK_MONTHLY_LIMIT':
          _fail(ExamHallCopy.monthlyLimit, notNow: true);
        case 'PAPER_TYPE_NOT_SUPPORTED':
          _fail(ExamHallCopy.descriptiveLater);
        default:
          _fail(
            e.code == HmApiException.networkError
                ? ExamHallCopy.needsConnection
                : messageOf(e),
          );
      }
      return false;
    }
  }

  /// Opens the attempt left on this phone, with the server's time left (§19.8 Q76).
  Future<bool> resume() async {
    final id = state.resumableAttemptId ?? await _store.activeAttempt();
    if (id == null) return false;
    state = state.copyWith(phase: ExamPhase.starting, message: () => null);
    try {
      final session = await _repo.attempt(id);
      if (session.status != AttemptStatus.inProgress) {
        final report = await _repo.report(id);
        await _store.clear(id);
        state = ExamHallState(phase: ExamPhase.finished, report: report);
        return true;
      }
      await _open(session);
      return true;
    } on HmApiException catch (e) {
      _fail(messageOf(e));
      return false;
    }
  }

  /// Local answers win over the server copy: they are newer or not sent yet.
  Future<void> _open(MockSession session) async {
    final local = await _store.all(session.attemptId);
    final merged = {...session.answers};
    var pending = 0;
    for (final a in local) {
      merged[a.questionId] = SessionAnswer(
        chosen: a.chosenOptionIds,
        marked: a.markedForReview,
      );
      if (!a.synced) pending++;
    }
    var index = 0;
    for (var i = 0; i < session.questions.length; i++) {
      if (!(merged[session.questions[i].id]?.answered ?? false)) {
        index = i;
        break;
      }
    }
    state = ExamHallState(
      phase: ExamPhase.active,
      session: session.withAnswers(merged),
      serverOffset: _offsetFrom(session.serverNow),
      index: index,
      pending: pending,
      resumableAttemptId: session.attemptId,
    );
    if (pending > 0) unawaited(flush());
  }

  void _fail(String message, {bool notNow = false}) => state = state.copyWith(
    phase: state.session == null ? ExamPhase.idle : state.phase,
    message: () => message,
    blockedWithNotNow: notNow,
  );

  void goTo(int index) {
    final s = state.session;
    if (s == null || index < 0 || index >= s.questions.length) return;
    state = state.copyWith(index: index);
  }

  /// One option per question (objective MCQ, Phase 2). Choosing the chosen option again clears it.
  Future<void> choose(String questionId, String optionId) async {
    final s = state.session;
    if (s == null || state.phase != ExamPhase.active || state.timeUp) return;
    final current = s.answerOf(questionId);
    final chosen = current.chosen.contains(optionId)
        ? const <String>[]
        : [optionId];
    await _save(
      questionId,
      SessionAnswer(chosen: chosen, marked: current.marked),
    );
  }

  Future<void> toggleMark(String questionId) async {
    final s = state.session;
    if (s == null || state.phase != ExamPhase.active || state.timeUp) return;
    final current = s.answerOf(questionId);
    await _save(
      questionId,
      SessionAnswer(chosen: current.chosen, marked: !current.marked),
    );
  }

  /// Phone first, then the server (§39).
  Future<void> _save(String questionId, SessionAnswer answer) async {
    final s = state.session!;
    await _store.put(
      LocalMockAnswer(
        attemptId: s.attemptId,
        questionId: questionId,
        chosenOptionIds: answer.chosen,
        markedForReview: answer.marked,
        clientAt: _now().toUtc(),
      ),
    );
    state = state.copyWith(
      session: s.withAnswers({...s.answers, questionId: answer}),
      pending: (await _store.unsynced(s.attemptId)).length,
    );
    await flush();
  }

  /// Sends every unsent answer. A failure keeps them queued on the phone.
  Future<void> flush() async {
    final s = state.session;
    if (s == null || _flushing) return;
    _flushing = true;
    _lastFlush = _now();
    try {
      final batch = await _store.unsynced(s.attemptId);
      if (batch.isEmpty) return;
      final ack = await _repo.saveAnswers(
        s.attemptId,
        batch,
        idempotencyKey: ref.read(idempotencyKeyFactoryProvider)(),
      );
      await _store.markSynced(batch);
      state = state.copyWith(
        serverOffset: _offsetFrom(ack.serverNow),
        pending: (await _store.unsynced(s.attemptId)).length,
      );
    } on HmApiException {
      state = state.copyWith(
        pending: (await _store.unsynced(s.attemptId)).length,
      );
    } finally {
      _flushing = false;
    }
  }

  /// Called once a second by the screen. Retries queued answers and handles time up.
  Future<void> tick() async {
    if (state.phase != ExamPhase.active) return;
    if (timeLeftNow == Duration.zero) {
      if (!state.timeUp) {
        state = state.copyWith(
          timeUp: true,
          message: () => ExamHallCopy.timeUp,
        );
        await submit();
      }
      return;
    }
    final last = _lastFlush;
    if (state.pending > 0 &&
        (last == null || _now().difference(last) >= flushEvery)) {
      await flush();
    }
  }

  /// Submits once (the key is stable per attempt so a retry cannot submit twice, §34.3).
  Future<void> submit() async {
    final s = state.session;
    if (s == null || state.phase == ExamPhase.submitting) return;
    state = state.copyWith(phase: ExamPhase.submitting);
    await flush();
    try {
      ReportView report;
      try {
        report = await _repo.submit(
          s.attemptId,
          idempotencyKey: 'submit-${s.attemptId}',
        );
      } on HmApiException catch (e) {
        if (e.code != 'MOCK_ALREADY_SUBMITTED' &&
            e.code != 'MOCK_DEADLINE_PASSED') {
          rethrow;
        }
        report = await _repo.report(s.attemptId);
      }
      await _store.clear(s.attemptId);
      state = ExamHallState(
        phase: ExamPhase.finished,
        session: s,
        report: report,
        message: state.timeUp ? ExamHallCopy.timeUp : null,
      );
    } on HmApiException catch (e) {
      state = state.copyWith(
        phase: ExamPhase.active,
        message: () => e.code == HmApiException.networkError
            ? 'Could not submit. You are offline. Your answers are saved on this phone. Try again when you are online.'
            : messageOf(e),
      );
    }
  }

  /// Opens the report of a past attempt.
  Future<void> openReport(String attemptId) async {
    state = state.copyWith(phase: ExamPhase.starting, message: () => null);
    try {
      final report = await _repo.report(attemptId);
      state = ExamHallState(phase: ExamPhase.finished, report: report);
    } on HmApiException catch (e) {
      _fail(messageOf(e));
    }
  }
}

final examHallControllerProvider =
    NotifierProvider<ExamHallController, ExamHallState>(ExamHallController.new);
