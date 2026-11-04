import 'package:flutter/foundation.dart';

/// Exam Hall feature models (§10.6 Exam Hall, INT-002-S10/S11). Pure Dart: no widgets, no I/O.

/// How the aspirant answers. It comes from the paper's answer mode, never from the exam name
/// (INT-002-S10, changed 2026-10-22).
enum AnswerMode { omr, cbt }

/// Paper answer mode (contract `ExamPaper.mode`) to the Exam Hall mode. `written` (descriptive) is
/// not built in Phase 2 (INT-002 R4), so it returns null.
AnswerMode? answerModeFromPaper(String mode) => switch (mode) {
  'omr' => AnswerMode.omr,
  'cbt' => AnswerMode.cbt,
  _ => null,
};

String answerModeName(AnswerMode mode) => switch (mode) {
  AnswerMode.omr => 'OMR sheet',
  AnswerMode.cbt => 'Computer-based test',
};

enum MockKindView { full, sectional, stateMockSunday }

@immutable
class MockItem {
  const MockItem({
    required this.id,
    required this.title,
    required this.examCode,
    required this.paperCode,
    required this.kind,
    required this.questionCount,
    required this.durationMinutes,
    required this.negativeMarking,
    required this.free,
    required this.locked,
    this.opensAt,
    this.closesAt,
    this.lastAttemptId,
  });

  final String id;
  final String title;
  final String examCode;
  final String paperCode;
  final MockKindView kind;
  final int questionCount;
  final int durationMinutes;
  final bool negativeMarking;
  final bool free;

  /// Locked for this user (Free limit reached or Pro only). Shown before tap (§19.9 Q82).
  final bool locked;
  final DateTime? opensAt;
  final DateTime? closesAt;
  final String? lastAttemptId;

  String get accessLabel => free ? 'Free' : 'Pro';

  String get facts =>
      '$questionCount questions · $durationMinutes minutes · '
      '${negativeMarking ? 'Negative marking' : 'No negative marking'}';
}

@immutable
class MockListView {
  const MockListView({
    required this.items,
    required this.freeFullMocksUsed,
    this.freeFullMocksLimit,
  });

  final List<MockItem> items;
  final int freeFullMocksUsed;

  /// Null = no limit.
  final int? freeFullMocksLimit;

  /// "Free full mocks this month: 0 of 1 used" (§11, D-2026-10-22-22: IST calendar month).
  String? get allowanceLine {
    final limit = freeFullMocksLimit;
    if (limit == null) return null;
    final used = freeFullMocksUsed.clamp(0, limit);
    return 'Free full mocks this month: $used of $limit used';
  }
}

@immutable
class ExamOption {
  const ExamOption({required this.id, required this.text});
  final String id;
  final String text;
}

@immutable
class ExamQuestion {
  const ExamQuestion({
    required this.id,
    required this.stem,
    required this.options,
  });

  final String id;
  final String stem;
  final List<ExamOption> options;
}

@immutable
class MockSection {
  const MockSection({
    required this.code,
    required this.name,
    required this.questionIds,
  });

  final String code;
  final String name;
  final List<String> questionIds;
}

@immutable
class SessionAnswer {
  const SessionAnswer({this.chosen = const [], this.marked = false});

  final List<String> chosen;
  final bool marked;

  bool get answered => chosen.isNotEmpty;
}

enum AttemptStatus { inProgress, submitted, expired }

/// Where one question stands, for the CBT palette. Each state has its own shape as well as colour (§10.9).
enum PaletteState { notAnswered, answered, marked, answeredAndMarked }

String paletteStateName(PaletteState s) => switch (s) {
  PaletteState.notAnswered => 'not answered',
  PaletteState.answered => 'answered',
  PaletteState.marked => 'marked for review',
  PaletteState.answeredAndMarked => 'answered and marked for review',
};

@immutable
class MockSession {
  const MockSession({
    required this.attemptId,
    required this.mockId,
    required this.title,
    required this.mode,
    required this.status,
    required this.deadlineAt,
    required this.serverNow,
    required this.sections,
    required this.questions,
    required this.answers,
    required this.ranked,
  });

  final String attemptId;
  final String mockId;
  final String title;
  final AnswerMode mode;
  final AttemptStatus status;

  /// Set by the server (§34.1). The countdown is always measured against this.
  final DateTime deadlineAt;

  /// Server time when this snapshot was made; used to correct the phone clock.
  final DateTime serverNow;
  final List<MockSection> sections;
  final List<ExamQuestion> questions;
  final Map<String, SessionAnswer> answers;
  final bool ranked;

  MockSession withAnswers(Map<String, SessionAnswer> next) => MockSession(
    attemptId: attemptId,
    mockId: mockId,
    title: title,
    mode: mode,
    status: status,
    deadlineAt: deadlineAt,
    serverNow: serverNow,
    sections: sections,
    questions: questions,
    answers: next,
    ranked: ranked,
  );

  SessionAnswer answerOf(String questionId) =>
      answers[questionId] ?? const SessionAnswer();

  int get answeredCount => answers.values.where((a) => a.answered).length;

  int get markedCount => answers.values.where((a) => a.marked).length;

  int get unansweredCount => questions.length - answeredCount;

  PaletteState paletteOf(String questionId) {
    final a = answerOf(questionId);
    return switch ((a.answered, a.marked)) {
      (true, true) => PaletteState.answeredAndMarked,
      (true, false) => PaletteState.answered,
      (false, true) => PaletteState.marked,
      (false, false) => PaletteState.notAnswered,
    };
  }

  String? sectionNameOf(String questionId) {
    for (final s in sections) {
      if (s.questionIds.contains(questionId)) return s.name;
    }
    return null;
  }
}

/// Time left = server deadline − (phone now + offset), where offset = serverNow − phone now at the last
/// server reply. The phone clock is never the source of truth (§34.1, INT-002-S10).
Duration timeLeft({
  required DateTime deadlineAt,
  required DateTime localNow,
  required Duration serverOffset,
}) {
  final left = deadlineAt.difference(localNow.add(serverOffset));
  return left.isNegative ? Duration.zero : left;
}

/// "1:05:09" or "05:09".
String formatClock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Screen-reader text for the clock, e.g. "1 hour 5 minutes left".
String spokenTimeLeft(Duration d) {
  if (d == Duration.zero) return 'Time is up';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final parts = <String>[
    if (h > 0) '$h ${h == 1 ? 'hour' : 'hours'}',
    if (m > 0 || h == 0) '$m ${m == 1 ? 'minute' : 'minutes'}',
  ];
  return '${parts.join(' ')} left';
}

/// Exact marks as text: 51/3 → "17", 103/3 → "34.33" (the server sends fractions).
String formatMarks(int numerator, int denominator) {
  if (denominator == 0) return '0';
  if (numerator % denominator == 0) return '${numerator ~/ denominator}';
  return (numerator / denominator).toStringAsFixed(2);
}

@immutable
class SectionScore {
  const SectionScore({
    required this.name,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.score,
    required this.maxScore,
  });

  final String name;
  final int correct;
  final int wrong;
  final int unanswered;
  final String score;
  final String maxScore;
}

@immutable
class MistakeView {
  const MistakeView({
    required this.questionId,
    required this.explanation,
    required this.topicId,
    this.whyChosenIsWrong,
  });

  final String questionId;
  final String explanation;
  final String topicId;
  final String? whyChosenIsWrong;
}

@immutable
class ReportView {
  const ReportView({
    required this.attemptId,
    required this.scoreDisplay,
    required this.maxScoreDisplay,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.sections,
    required this.mistakes,
    required this.weakTopicIds,
    required this.ranked,
    required this.fullReportLocked,
  });

  final String attemptId;
  final String scoreDisplay;
  final String maxScoreDisplay;
  final int correct;
  final int wrong;
  final int unanswered;
  final List<SectionScore> sections;
  final List<MistakeView> mistakes;
  final List<String> weakTopicIds;
  final bool ranked;

  /// Free users see the score and sections; the full report is a blurred preview (§13, D-2026-10-22-22).
  final bool fullReportLocked;
}

/// Where the State Mock Sunday is right now (D-2026-10-22-23).
enum StateMockPhase { upcoming, open, practiceOnly, closed }

@immutable
class StateMockCardView {
  const StateMockCardView({
    required this.mockId,
    required this.title,
    required this.examCode,
    required this.paperCode,
    required this.questionCount,
    required this.durationMinutes,
    required this.negativeMarking,
    required this.opensAt,
    required this.lateJoinUntil,
    required this.closesAt,
    this.rankPublishAt,
    this.lastAttemptId,
  });

  final String examCode;
  final String paperCode;
  final bool negativeMarking;

  /// The Sunday mock as a startable mock (always free, §9.9).
  MockItem get asMock => MockItem(
    id: mockId,
    title: title,
    examCode: examCode,
    paperCode: paperCode,
    kind: MockKindView.stateMockSunday,
    questionCount: questionCount,
    durationMinutes: durationMinutes,
    negativeMarking: negativeMarking,
    free: true,
    locked: false,
    opensAt: opensAt,
    closesAt: closesAt,
    lastAttemptId: lastAttemptId,
  );

  final String mockId;
  final String title;
  final int questionCount;
  final int durationMinutes;
  final DateTime opensAt;
  final DateTime lateJoinUntil;
  final DateTime closesAt;
  final DateTime? rankPublishAt;
  final String? lastAttemptId;

  /// Joining by the late-join time counts for the rank; later the same day it is practice only.
  StateMockPhase phaseAt(DateTime now) {
    if (now.isBefore(opensAt)) return StateMockPhase.upcoming;
    if (now.isBefore(lateJoinUntil)) return StateMockPhase.open;
    if (now.isBefore(closesAt)) return StateMockPhase.practiceOnly;
    return StateMockPhase.closed;
  }

  bool canStartAt(DateTime now) {
    final p = phaseAt(now);
    return p == StateMockPhase.open || p == StateMockPhase.practiceOnly;
  }
}

/// IST date and time, e.g. "Sun 1 Nov, 10:00 AM" (§37: days and times are shown in IST).
String formatIst(DateTime instant) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final ist = instant.toUtc().add(const Duration(hours: 5, minutes: 30));
  final h12 = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  final mm = ist.minute.toString().padLeft(2, '0');
  final ampm = ist.hour < 12 ? 'AM' : 'PM';
  return '${days[ist.weekday - 1]} ${ist.day} ${months[ist.month - 1]}, '
      '$h12:$mm $ampm';
}

/// Simple-English copy used by the Exam Hall (§10.2).
abstract final class ExamHallCopy {
  static const needsConnection =
      'You need an internet connection to start a mock. The server sets your start and end time.';
  static const descriptiveLater = 'This type of paper is coming later.';
  static const savedOnPhone =
      'Some answers are saved on this phone. They will be sent when you are online.';
  static const timeUp =
      'Time is up. Answers saved before the end time are kept.';
  static const lockedReport =
      'The full report, with every explanation, is part of Pro. Pro is not on sale yet.';
  static const monthlyLimit =
      'You have used your free full mock for this month. You can still take every State Mock Sunday.';
  static const notNow = 'Not now';
}
