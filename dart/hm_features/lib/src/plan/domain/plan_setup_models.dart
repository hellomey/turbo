import 'package:flutter/foundation.dart';

/// Plan setup (INT-002-S12, §17.1 step 9, contract `PutPlanBody`). The contract has weekday and weekend
/// minutes (not a list of study days), pocket minutes 5/10/15 and a balance dial −2..+2 (+ = more new topics).

@immutable
class CycleOption {
  const CycleOption({required this.id, required this.name});
  final String id;
  final String name;
}

/// Open attempt cycles the server offers for one chosen exam (R2). Closed cycles are left out.
@immutable
class ExamCycles {
  const ExamCycles({
    required this.examCode,
    required this.examName,
    required this.cycles,
  });
  final String examCode;
  final String examName;
  final List<CycleOption> cycles;
}

@immutable
class PlanSetupOptions {
  const PlanSetupOptions({
    required this.mainExamCode,
    required this.otherExamCodes,
    required this.exams,
  });

  final String? mainExamCode;
  final List<String> otherExamCodes;

  /// Only exams with at least one open cycle.
  final List<ExamCycles> exams;
}

@immutable
class PlanSetupDraft {
  const PlanSetupDraft({
    this.weekdayMinutes = 60,
    this.weekendMinutes = 120,
    this.pocketMinutes = 10,
    this.balance = 0,
    this.cycles = const {},
  });

  final int weekdayMinutes;
  final int weekendMinutes;
  final int pocketMinutes;
  final int balance;

  /// Exam code → attempt cycle id.
  final Map<String, String> cycles;

  static const minutePresets = [30, 60, 90, 120, 180, 240];
  static const pocketPresets = [5, 10, 15];
  static const minBalance = -2;
  static const maxBalance = 2;

  PlanSetupDraft copyWith({
    int? weekdayMinutes,
    int? weekendMinutes,
    int? pocketMinutes,
    int? balance,
    Map<String, String>? cycles,
  }) => PlanSetupDraft(
    weekdayMinutes: weekdayMinutes ?? this.weekdayMinutes,
    weekendMinutes: weekendMinutes ?? this.weekendMinutes,
    pocketMinutes: pocketMinutes ?? this.pocketMinutes,
    balance: (balance ?? this.balance).clamp(minBalance, maxBalance),
    cycles: cycles ?? this.cycles,
  );

  /// Contract `PutPlanBody`.
  Map<String, Object> toJson() => {
    'weekdayMinutes': weekdayMinutes,
    'weekendMinutes': weekendMinutes,
    'pocketMinutes': pocketMinutes,
    'balance': balance,
  };
}

abstract final class PlanSetupCopy {
  static String minutes(int m) => m < 60
      ? '$m min'
      : m % 60 == 0
      ? '${m ~/ 60} h'
      : '${m ~/ 60} h ${m % 60} min';

  static String balance(int b) => switch (b) {
    -2 => 'Mostly relighting old lamps',
    -1 => 'More relighting',
    1 => 'More new topics',
    2 => 'Mostly new topics',
    _ => 'Even mix',
  };
}
