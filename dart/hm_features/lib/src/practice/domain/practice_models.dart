import 'package:flutter/foundation.dart';
import 'package:hm_design/hm_design.dart';

/// Study models for practice, checks, relight and the PYQ Vault (§5.1, §10.6, §11, §19.4).
/// The server decides every grade, ring and limit (§34.1); these only carry what it said.

@immutable
class OptionView {
  const OptionView({required this.id, required this.text});
  final String id;
  final String text;
}

/// Where a question comes from (§19.4 Q32, §19.8 Q76).
@immutable
class SourceView {
  const SourceView({
    required this.citation,
    this.url,
    this.pyqExamCode,
    this.pyqYear,
    this.pyqNumber,
  });

  final String citation;
  final String? url;
  final String? pyqExamCode;
  final int? pyqYear;
  final int? pyqNumber;

  bool get isPyq => pyqYear != null;

  /// "TNPSC-GROUP-4 2024, Q 57" for previous-year questions, else the citation.
  String get line {
    final year = pyqYear;
    if (year == null) return citation;
    final exam = (pyqExamCode ?? '').toUpperCase();
    final number = pyqNumber == null ? '' : ', Q $pyqNumber';
    return '$exam $year$number'.trim();
  }
}

@immutable
class QuestionView {
  const QuestionView({
    required this.id,
    required this.version,
    required this.topicId,
    required this.stem,
    required this.options,
    required this.source,
    this.difficulty = 1,
    this.tamil = false,
    this.affectedNote,
  });

  final String id;
  final int version;
  final String topicId;
  final String stem;
  final List<OptionView> options;
  final SourceView source;
  final int difficulty;

  /// Tamil Language paper content (§1 decision 3); interface text stays English.
  final bool tamil;

  /// "Affected by a later change" note (§19.4 Q33).
  final String? affectedNote;
}

/// The server's grade for one answer (§19.4 Q32, Q38).
@immutable
class GradedView {
  const GradedView({
    required this.questionId,
    required this.correct,
    required this.correctOptionIds,
    required this.chosenOptionIds,
    required this.explanation,
    required this.topicId,
    required this.source,
    this.whyChosenIsWrong,
  });

  final String questionId;
  final bool correct;
  final List<String> correctOptionIds;
  final List<String> chosenOptionIds;
  final String explanation;
  final String? whyChosenIsWrong;

  /// The lamp to relight after a wrong answer.
  final String topicId;
  final SourceView source;
}

/// Free daily practice state (§11 "30 a day", IST).
@immutable
class UsageView {
  const UsageView({
    required this.istDay,
    required this.used,
    required this.limit,
    required this.limitSheetShownToday,
  });

  final String istDay;
  final int used;

  /// Null = no limit.
  final int? limit;
  final bool limitSheetShownToday;

  bool get limitReached => limit != null && used >= limit!;

  /// "12 of 30 free questions today" (null when there is no limit).
  String? get line =>
      limit == null ? null : '$used of $limit free questions today';
}

enum StudyMode { practice, pyq, mistakes, drill }

@immutable
class PracticeSessionView {
  const PracticeSessionView({
    required this.sessionId,
    required this.mode,
    required this.questions,
    required this.usage,
  });

  final String sessionId;
  final StudyMode mode;
  final List<QuestionView> questions;
  final UsageView usage;
}

@immutable
class PracticeAnswerView {
  const PracticeAnswerView({
    required this.graded,
    required this.usage,
    this.weakTopicIds = const [],
  });

  final GradedView graded;
  final UsageView usage;
  final List<String> weakTopicIds;
}

@immutable
class PracticeMistakeView {
  const PracticeMistakeView({
    required this.questionId,
    required this.topicId,
    required this.stem,
    required this.wrongCount,
    required this.graded,
  });

  final String questionId;
  final String topicId;
  final String stem;
  final int wrongCount;
  final GradedView graded;
}

@immutable
class DrillView {
  const DrillView({
    required this.id,
    required this.topicId,
    required this.reason,
    required this.questionCount,
    required this.open,
  });

  final String id;
  final String topicId;
  final String reason;
  final int questionCount;
  final bool open;
}

/// Concept drills (§19.6 Q60): Pro, so Free users see them locked (§19.9 Q82).
@immutable
class DrillsView {
  const DrillsView({required this.items, required this.locked});
  final List<DrillView> items;
  final bool locked;
}

@immutable
class MistakesView {
  const MistakesView({
    required this.mistakes,
    required this.drills,
    this.nextCursor,
  });

  final List<PracticeMistakeView> mistakes;
  final DrillsView drills;
  final String? nextCursor;
}

/// The checks of a lamp (§5.1).
enum CheckKind { lit, recall, relight, gold }

@immutable
class CheckView {
  const CheckView({
    required this.checkId,
    required this.topicId,
    required this.kind,
    required this.questions,
    required this.passMark,
    this.deadlineAt,
    this.serverNow,
  });

  final String checkId;
  final String topicId;
  final CheckKind kind;
  final List<QuestionView> questions;
  final int passMark;

  /// Gold only: the server deadline (§5.1).
  final DateTime? deadlineAt;
  final DateTime? serverNow;
}

/// The fixed note every rank title carries (§5.2, compliance C-P2-1).
const rankOfficialNote = 'Game title. Not an official designation.';

/// Rank-up celebration subtitle: "You are now <title>. Game title. Not an official designation."
/// Uses the server's [note] when present, else [rankOfficialNote] (§5.2).
String rankUpSubtitle(String title, [String? note]) {
  final n = (note == null || note.trim().isEmpty)
      ? rankOfficialNote
      : note.trim();
  return 'You are now $title. $n';
}

@immutable
class RankUpView {
  const RankUpView({required this.title, required this.note});
  final String title;

  /// "Game title. Not an official designation." (§5.2)
  final String note;
}

@immutable
class CheckResultView {
  const CheckResultView({
    required this.kind,
    required this.passed,
    required this.correct,
    required this.total,
    required this.graded,
    required this.lamp,
    this.lateAnswersIgnored = 0,
    this.rankUp,
  });

  final CheckKind kind;
  final bool passed;
  final int correct;
  final int total;
  final List<GradedView> graded;

  /// The server's lamp after the check (§39: server wins).
  final HmLampState lamp;
  final int lateAnswersIgnored;
  final RankUpView? rankUp;
}

@immutable
class RelightItemView {
  const RelightItemView({
    required this.topicId,
    required this.topicName,
    required this.dim,
    required this.minutes,
  });

  final String topicId;
  final String topicName;
  final HmLampDim dim;
  final int minutes;
}

@immutable
class RelightQueueView {
  const RelightQueueView({required this.items, required this.totalMinutes});
  final List<RelightItemView> items;
  final int totalMinutes;
}

@immutable
class PyqYearView {
  const PyqYearView({
    required this.year,
    required this.count,
    required this.locked,
  });
  final int year;
  final int count;

  /// Older years are Pro for Free users (§11, D-2026-10-22-20).
  final bool locked;
}

@immutable
class PyqSubjectView {
  const PyqSubjectView({
    required this.code,
    required this.name,
    required this.count,
  });
  final String code;
  final String name;
  final int count;
}

@immutable
class PyqFacetsView {
  const PyqFacetsView({required this.years, required this.subjects});
  final List<PyqYearView> years;
  final List<PyqSubjectView> subjects;
}

@immutable
class PyqItemView {
  const PyqItemView({required this.question, required this.locked});
  final QuestionView question;
  final bool locked;
}

@immutable
class PyqPageView {
  const PyqPageView({required this.items, this.nextCursor});
  final List<PyqItemView> items;
  final String? nextCursor;
}

@immutable
class PyqFilter {
  const PyqFilter({this.year, this.subjectCode, this.difficulty});
  final int? year;
  final String? subjectCode;
  final int? difficulty;

  PyqFilter copyWith({
    int? Function()? year,
    String? Function()? subjectCode,
    int? Function()? difficulty,
  }) => PyqFilter(
    year: year == null ? this.year : year(),
    subjectCode: subjectCode == null ? this.subjectCode : subjectCode(),
    difficulty: difficulty == null ? this.difficulty : difficulty(),
  );

  @override
  bool operator ==(Object other) =>
      other is PyqFilter &&
      other.year == year &&
      other.subjectCode == subjectCode &&
      other.difficulty == difficulty;

  @override
  int get hashCode => Object.hash(year, subjectCode, difficulty);
}
