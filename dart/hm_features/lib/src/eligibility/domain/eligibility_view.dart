import 'package:flutter/foundation.dart';

/// Shown on every eligibility result and exam page (§17.1 step 3, contract OFFICIAL_CONFIRM_LINE).
const officialConfirmLine = 'Always confirm with the official notification.';

/// One exam on the eligibility result.
@immutable
class ExamFit {
  const ExamFit({
    required this.code,
    required this.name,
    required this.conductingBody,
    required this.fitRank,
    required this.officialUrl,
    this.reasons = const [],
  });

  final String code;
  final String name;
  final String conductingBody;

  /// 1 = best fit.
  final int fitRank;
  final String officialUrl;

  /// Simple-English reasons from the server (e.g. age relaxation applied).
  final List<String> reasons;
}

/// The eligibility result (contract `EligibilityResult`), ordered by fit.
@immutable
class EligibilityView {
  const EligibilityView({
    required this.eligibleCount,
    required this.eligible,
    required this.disclaimer,
  });

  static const topCount = 5;

  final int eligibleCount;

  /// Eligible exams, best fit first.
  final List<ExamFit> eligible;
  final String disclaimer;

  List<ExamFit> get top => eligible.take(topCount).toList();
  List<ExamFit> get more => eligible.skip(topCount).toList();

  String get headline =>
      "You're eligible for $eligibleCount exam${eligibleCount == 1 ? '' : 's'}";

  String shareText() {
    final names = top.map((e) => '- ${e.name}').join('\n');
    final exams = 'exam${eligibleCount == 1 ? '' : 's'}';
    return 'HeyMey shows I can write $eligibleCount $exams.\n'
        'My top exams:\n$names\n$officialConfirmLine';
  }
}
