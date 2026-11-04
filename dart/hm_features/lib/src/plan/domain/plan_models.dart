import 'package:flutter/foundation.dart';

/// Plan and Today models (INT-002-S12/S13, §10.6 Today). The server decides every value (§34.1); these only
/// shape it for the screens.

enum PlanItemKindView {
  lesson,
  litCheck,
  relight,
  practice,
  pyq,
  gold,
  mock,
  mistakeReview,
  checklist,
}

enum PlanItemStatusView { pending, done, skipped, moved }

/// Final Stretch phase from days left to the nearest exam (§17.3).
enum StretchView { normal, d90, d60, d30, d7 }

@immutable
class PlanItemView {
  const PlanItemView({
    required this.id,
    required this.day,
    required this.kind,
    required this.examCode,
    required this.title,
    required this.minutes,
    required this.status,
    this.topicId,
  });

  final String id;

  /// IST calendar day (date only).
  final DateTime day;
  final PlanItemKindView kind;
  final String examCode;
  final String? topicId;
  final String title;
  final int minutes;
  final PlanItemStatusView status;

  /// Only a pending item can be marked done or skipped (U-plan: status moves from pending).
  bool get canMark => status == PlanItemStatusView.pending;

  PlanItemView withStatus(PlanItemStatusView s) => PlanItemView(
    id: id,
    day: day,
    kind: kind,
    examCode: examCode,
    topicId: topicId,
    title: title,
    minutes: minutes,
    status: s,
  );
}

/// The rank badge + XP bar (Career Ladder, §10.6 Today).
@immutable
class RankView {
  const RankView({
    required this.level,
    required this.title,
    required this.xp,
    required this.xpForThisLevel,
    required this.note,
    this.xpForNextLevel,
  });

  final int level;
  final String title;
  final int xp;
  final int xpForThisLevel;

  /// Null at the top level.
  final int? xpForNextLevel;
  final String note;

  /// 0..1 progress inside this level; 1 at the top level.
  double get progress {
    final next = xpForNextLevel;
    if (next == null || next <= xpForThisLevel) return 1;
    return ((xp - xpForThisLevel) / (next - xpForThisLevel)).clamp(0, 1);
  }

  /// XP still needed for the next level, or null at the top.
  int? get xpToNext {
    final next = xpForNextLevel;
    return next == null ? null : (next - xp).clamp(0, next);
  }
}

@immutable
class TodayView {
  const TodayView({
    required this.day,
    required this.rank,
    required this.todayCard,
    required this.relightCount,
    required this.relightMinutes,
    required this.pocketSessions,
    required this.stretch,
    required this.hasPlan,
    this.welcomeBack,
  });

  final DateTime day;
  final RankView rank;
  final PlanItemView todayCard;
  final int relightCount;
  final int relightMinutes;

  /// Pocket-session lengths in minutes (§19.2 Q15).
  final List<int> pocketSessions;
  final StretchView stretch;
  final String? welcomeBack;
  final bool hasPlan;
}

@immutable
class PlanDayView {
  const PlanDayView({
    required this.day,
    required this.minutes,
    required this.items,
  });

  final DateTime day;
  final int minutes;
  final List<PlanItemView> items;
}

/// Simple-English copy for the plan screens (§10.2).
abstract final class PlanCopy {
  static const noPlan = 'Set up your plan first.';
  static const savedOffline = 'Saved. It will sync when you are online.';
  static const rebalanced = 'Your plan is updated.';

  static String kind(PlanItemKindView k) => switch (k) {
    PlanItemKindView.lesson => 'Lesson',
    PlanItemKindView.litCheck => 'Lamp check',
    PlanItemKindView.relight => 'Relight',
    PlanItemKindView.practice => 'Practice',
    PlanItemKindView.pyq => 'Past questions',
    PlanItemKindView.gold => 'Gold check',
    PlanItemKindView.mock => 'Mock test',
    PlanItemKindView.mistakeReview => 'Mistake review',
    PlanItemKindView.checklist => 'Checklist',
  };

  static String status(PlanItemStatusView s) => switch (s) {
    PlanItemStatusView.pending => 'To do',
    PlanItemStatusView.done => 'Done',
    PlanItemStatusView.skipped => 'Skipped',
    PlanItemStatusView.moved => 'Moved',
  };

  /// Null in the normal phase (no chip).
  static String? stretch(StretchView s) => switch (s) {
    StretchView.normal => null,
    StretchView.d90 => 'Final Stretch: 90 days',
    StretchView.d60 => 'Final Stretch: 60 days',
    StretchView.d30 => 'Final Stretch: 30 days',
    StretchView.d7 => 'Final Stretch: last 7 days',
  };
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// A calendar day as "Tue 20 Oct" (the date is already an IST day from the server, §37).
String formatDay(DateTime day) =>
    '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';

/// `YYYY-MM-DD` for a calendar day.
String isoDay(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// Calendar day only (drops any time and zone).
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);
