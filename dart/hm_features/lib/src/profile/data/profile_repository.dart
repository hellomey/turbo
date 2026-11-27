import 'package:flutter/foundation.dart';
import 'package:hm_core/hm_core.dart';

/// Profile and account actions (§10.5, §38 steps 6–7).
abstract interface class ProfileRepository {
  Future<MeInfo> me();
  Future<MeInfo> setCalmMode(bool on);
  Future<MeInfo> setNickname(String name);
  Future<void> logout();
  Future<void> logoutAll();

  /// The current DPDP notice (never hard-code its version).
  Future<ConsentNoticeInfo> consentNotice();

  /// Latest choice per purpose (wire value → granted).
  Future<Map<String, bool>> myConsents();

  /// Records ALL purposes with the notice version.
  Future<void> saveConsents(String noticeVersion, Map<String, bool> choices);

  /// Guest mode: sends a sign-in code to the email the guest wants to keep progress with.
  Future<int> requestSaveProgressCode(String email);

  /// Guest mode: signs in with the code while still signed in as the guest. Returns the server's
  /// `guestProgress`: `kept` or `not_merged` (that email already had an account).
  Future<String?> saveGuestProgress(String email, String code);

  /// Sends a `delete_account` code to the signed-in email.
  Future<int> requestDeleteCode(String email);

  /// Returns when personal data will be erased.
  Future<DateTime> deleteAccount(String code);
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api, this._deviceIds);

  final HmApi _api;
  final DeviceIdStore _deviceIds;

  @override
  Future<MeInfo> me() => _api.getMe();

  @override
  Future<MeInfo> setCalmMode(bool on) => _api.updateMe(calmMode: on);

  @override
  Future<MeInfo> setNickname(String name) => _api.updateMe(nickname: name);

  @override
  Future<void> logout() => _api.logout();

  @override
  Future<void> logoutAll() => _api.logoutAll();

  @override
  Future<ConsentNoticeInfo> consentNotice() => _api.getConsentNotice();

  @override
  Future<Map<String, bool>> myConsents() => _api.getMyConsents();

  @override
  Future<void> saveConsents(String noticeVersion, Map<String, bool> choices) =>
      _api.recordConsents(noticeVersion, choices);

  @override
  Future<int> requestDeleteCode(String email) =>
      _api.requestOtp(email, purpose: OtpPurpose.deleteAccount);

  @override
  Future<DateTime> deleteAccount(String code) => _api.deleteAccount(code);

  @override
  Future<int> requestSaveProgressCode(String email) => _api.requestOtp(email);

  @override
  Future<String?> saveGuestProgress(String email, String code) async {
    final outcome = await _api.verifyOtp(
      email: email,
      code: code,
      deviceId: await _deviceIds.deviceId(),
      platform: kIsWeb
          ? ClientPlatform.web
          : defaultTargetPlatform == TargetPlatform.iOS
          ? ClientPlatform.ios
          : ClientPlatform.android,
    );
    return switch (outcome) {
      OtpSessionOutcome(:final guestProgress) => guestProgress,
      OtpDeskChallengeOutcome() => throw const HmApiException(
        HmApiException.unknownError,
        HmApiException.unknownMessage,
      ),
    };
  }
}
