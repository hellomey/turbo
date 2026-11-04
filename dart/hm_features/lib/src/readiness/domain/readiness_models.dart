import 'package:flutter/foundation.dart';

/// Readiness Meter and Sunday Report models (INT-002-S14/S15, §19.5 Q42/Q46). There is no overall
/// percentage anywhere (U-readiness invariant 4).

enum ReadinessLabelView { notYet, building, close, mockReady }

enum ReadinessBarKey { coverage, memory, examPerformance, speed }

@immutable
class ReadinessBarView {
  const ReadinessBarView({
    required this.key,
    required this.locked,
    required this.evidence,
    this.value,
  });

  final ReadinessBarKey key;

  /// 0..100, or null when locked or when there is no evidence yet.
  final int? value;

  /// Pro-only bar for a free user (§11, §19.5 Q46).
  final bool locked;
  final String evidence;
}

@immutable
class ReadinessView {
  const ReadinessView({
    required this.examCode,
    required this.label,
    required this.bars,
    required this.litPct,
    required this.steadyPct,
    required this.goldPct,
    required this.readyForFullMocks,
    required this.computedAt,
    this.suggestion,
  });

  final String examCode;
  final ReadinessLabelView label;
  final List<ReadinessBarView> bars;
  final int litPct;
  final int steadyPct;
  final int goldPct;
  final bool readyForFullMocks;
  final String? suggestion;
  final DateTime computedAt;

  /// True when no bar has evidence yet (U-readiness failure mode "No evidence").
  bool get noEvidence => bars.every((b) => b.locked || b.value == null);
}

enum ReportTier { short, full }

@immutable
class SundayReportSummaryView {
  const SundayReportSummaryView({
    required this.id,
    required this.weekStart,
    required this.tier,
  });

  final String id;
  final DateTime weekStart;
  final ReportTier tier;
}

@immutable
class SundayReportPageView {
  const SundayReportPageView({required this.items, this.nextCursor});

  final List<SundayReportSummaryView> items;
  final String? nextCursor;
}

@immutable
class SundayReportView {
  const SundayReportView({
    required this.id,
    required this.weekStart,
    required this.tier,
    required this.lampsLit,
    required this.steadyEarned,
    required this.goldEarned,
    required this.relit,
    required this.dimmedNow,
    required this.questionsAnswered,
    required this.mocksTaken,
    required this.studyMinutes,
    required this.lines,
    this.accuracyPct,
    this.nextWeek,
  });

  final String id;
  final DateTime weekStart;
  final ReportTier tier;
  final int lampsLit;
  final int steadyEarned;
  final int goldEarned;
  final int relit;
  final int dimmedNow;
  final int questionsAnswered;
  final int? accuracyPct;
  final int mocksTaken;
  final int studyMinutes;

  /// Server-written lines (templates from server data only, §19.10 Q100).
  final List<String> lines;

  /// Full (Pro) reports only.
  final List<String>? nextWeek;
}

/// Simple-English copy (§10.2).
abstract final class ReadinessCopy {
  static const noEvidence = 'Light a few lamps to see your readiness.';
  static const proBar = 'Pro';
  static const proBarHint = 'Shown with HeyMey Pro.';

  static String label(ReadinessLabelView l) => switch (l) {
    ReadinessLabelView.notYet => 'Not yet',
    ReadinessLabelView.building => 'Building',
    ReadinessLabelView.close => 'Close',
    ReadinessLabelView.mockReady => 'Mock-ready',
  };

  static String bar(ReadinessBarKey k) => switch (k) {
    ReadinessBarKey.coverage => 'Coverage',
    ReadinessBarKey.memory => 'Memory',
    ReadinessBarKey.examPerformance => 'Exam performance',
    ReadinessBarKey.speed => 'Speed',
  };

  static String tier(ReportTier t) =>
      t == ReportTier.full ? 'Full report' : 'Short report';
}
