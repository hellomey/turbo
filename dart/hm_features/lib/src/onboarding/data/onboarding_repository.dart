import 'package:flutter/foundation.dart';
import 'package:hm_core/hm_core.dart';

import '../../eligibility/domain/eligibility_view.dart';
import '../domain/profile_draft.dart';

/// Everything onboarding needs from the server (§17.1, §38).
abstract interface class OnboardingRepository {
  /// `POST /v1/eligibility/check`: a pure computation, nothing stored.
  Future<EligibilityView> checkEligibility(ProfileDraft draft);

  /// Sends the 6-digit code; returns seconds until resend unlocks.
  Future<int> requestCode(String email);

  /// Signs in (tokens stored). Returns true for a brand-new account.
  Future<bool> verifyCode(String email, String code);

  Future<ConsentNoticeInfo> consentNotice();

  /// [choices]: purpose wire value → granted.
  Future<void> recordConsents(String noticeVersion, Map<String, bool> choices);

  Future<void> saveProfile(ProfileDraft draft);

  Future<void> saveExams(String mainExamCode, List<String> otherExamCodes);
}

class ApiOnboardingRepository implements OnboardingRepository {
  ApiOnboardingRepository(this._api, this._deviceIds);

  final HmApi _api;
  final DeviceIdStore _deviceIds;

  @override
  Future<EligibilityView> checkEligibility(ProfileDraft draft) async =>
      eligibilityFromJson(await _api.checkEligibility(draft.toInput()));

  @override
  Future<int> requestCode(String email) => _api.requestOtp(email);

  @override
  Future<bool> verifyCode(String email, String code) async {
    final outcome = await _api.verifyOtp(
      email: email,
      code: code,
      deviceId: await _deviceIds.deviceId(),
      platform: defaultTargetPlatform == TargetPlatform.iOS
          ? ClientPlatform.ios
          : ClientPlatform.android,
    );
    return switch (outcome) {
      OtpSessionOutcome(:final isNewUser) => isNewUser,
      // The app client never gets a Desk challenge; treat it as a failure.
      OtpDeskChallengeOutcome() => throw const HmApiException(
        HmApiException.unknownError,
        HmApiException.unknownMessage,
      ),
    };
  }

  @override
  Future<ConsentNoticeInfo> consentNotice() => _api.getConsentNotice();

  @override
  Future<void> recordConsents(
    String noticeVersion,
    Map<String, bool> choices,
  ) => _api.recordConsents(noticeVersion, choices);

  @override
  Future<void> saveProfile(ProfileDraft draft) =>
      _api.putProfile(draft.toInput());

  @override
  Future<void> saveExams(String mainExamCode, List<String> otherExamCodes) =>
      _api.putMyExams(mainExamCode, otherExamCodes);
}

/// Maps contract `EligibilityResult` JSON; eligible exams sorted by `fitRank`.
EligibilityView eligibilityFromJson(Map<String, dynamic> json) {
  final eligible = [
    for (final e in asJsonList(json['eligible']))
      if (e['eligible'] != false)
        ExamFit(
          code: '${e['examCode']}',
          name: '${e['examName']}',
          conductingBody: '${e['conductingBody']}',
          fitRank: e['fitRank'] as int? ?? 999,
          officialUrl: '${e['officialNotificationUrl']}',
          reasons: [
            for (final r in asJsonList(e['reasons']))
              if (r['text'] is String) r['text'] as String,
          ],
        ),
  ]..sort((a, b) => a.fitRank.compareTo(b.fitRank));
  return EligibilityView(
    eligibleCount: json['eligibleCount'] as int? ?? eligible.length,
    eligible: eligible,
    disclaimer: json['disclaimer'] as String? ?? officialConfirmLine,
  );
}
