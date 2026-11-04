import 'package:flutter/foundation.dart';

/// Exam Alerts + alert settings (INT-002-S16/S17, §19.8 Q78).

enum ExamAlertKindView {
  notification,
  dateChange,
  admitCard,
  result,
  answerKey,
  other,
}

@immutable
class ExamAlertView {
  const ExamAlertView({
    required this.id,
    required this.examCode,
    required this.kind,
    required this.title,
    required this.summary,
    required this.officialUrl,
    required this.publishedAt,
    required this.confirmLine,
  });

  final String id;
  final String examCode;
  final ExamAlertKindView kind;
  final String title;
  final String summary;
  final String officialUrl;
  final DateTime publishedAt;

  /// "Always confirm with the official notification." from the server (S17).
  final String confirmLine;
}

@immutable
class ExamAlertPageView {
  const ExamAlertPageView({required this.items, this.nextCursor});

  final List<ExamAlertView> items;
  final String? nextCursor;
}

@immutable
class AlertSettingsView {
  const AlertSettingsView({
    required this.studyReminders,
    required this.examAlerts,
    required this.offers,
    required this.quietEnabled,
    required this.quietStartMinute,
    required this.quietEndMinute,
    required this.morningAlertMinute,
    required this.dailyLimit,
  });

  final bool studyReminders;
  final bool examAlerts;

  /// Opt-in only; the server refuses it without offers consent (U-notifications invariant 8).
  final bool offers;
  final bool quietEnabled;

  /// Minutes after IST midnight (0..1439).
  final int quietStartMinute;
  final int quietEndMinute;
  final int morningAlertMinute;

  /// Non-exam alerts per day, 0..3 (server clamps, §19.8 Q78).
  final int dailyLimit;

  static const maxDailyLimit = 3;

  AlertSettingsView copyWith({
    bool? studyReminders,
    bool? examAlerts,
    bool? offers,
    bool? quietEnabled,
    int? quietStartMinute,
    int? quietEndMinute,
    int? morningAlertMinute,
    int? dailyLimit,
  }) => AlertSettingsView(
    studyReminders: studyReminders ?? this.studyReminders,
    examAlerts: examAlerts ?? this.examAlerts,
    offers: offers ?? this.offers,
    quietEnabled: quietEnabled ?? this.quietEnabled,
    quietStartMinute: quietStartMinute ?? this.quietStartMinute,
    quietEndMinute: quietEndMinute ?? this.quietEndMinute,
    morningAlertMinute: morningAlertMinute ?? this.morningAlertMinute,
    dailyLimit: (dailyLimit ?? this.dailyLimit).clamp(0, maxDailyLimit),
  );

  Map<String, Object> toJson() => {
    'studyReminders': studyReminders,
    'examAlerts': examAlerts,
    'offers': offers,
    'quietHours': {
      'enabled': quietEnabled,
      'startMinute': quietStartMinute,
      'endMinute': quietEndMinute,
    },
    'morningAlertMinute': morningAlertMinute,
    'dailyLimit': dailyLimit,
  };
}

/// "9:30 PM" for minutes after midnight (IST, §37).
String formatMinuteOfDay(int minute) {
  final h = (minute ~/ 60) % 24;
  final m = (minute % 60).toString().padLeft(2, '0');
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:$m ${h < 12 ? 'AM' : 'PM'}';
}

abstract final class AlertCopy {
  static const noAlerts =
      'No exam alerts yet. We tell you when your exam has official news.';

  static String kind(ExamAlertKindView k) => switch (k) {
    ExamAlertKindView.notification => 'Notification',
    ExamAlertKindView.dateChange => 'Date change',
    ExamAlertKindView.admitCard => 'Hall ticket',
    ExamAlertKindView.result => 'Result',
    ExamAlertKindView.answerKey => 'Answer key',
    ExamAlertKindView.other => 'Update',
  };
}
