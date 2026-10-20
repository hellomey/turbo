import 'package:hm_core/hm_core.dart';

/// Profile and account actions (§10.5, §38 steps 6–7).
abstract interface class ProfileRepository {
  Future<MeInfo> me();
  Future<MeInfo> setCalmMode(bool on);
  Future<void> logout();
  Future<void> logoutAll();

  /// The current DPDP notice (never hard-code its version).
  Future<ConsentNoticeInfo> consentNotice();

  /// Latest choice per purpose (wire value → granted).
  Future<Map<String, bool>> myConsents();

  /// Records ALL purposes with the notice version.
  Future<void> saveConsents(String noticeVersion, Map<String, bool> choices);

  /// Sends a `delete_account` code to the signed-in email.
  Future<int> requestDeleteCode(String email);

  /// Returns when personal data will be erased.
  Future<DateTime> deleteAccount(String code);
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);

  final HmApi _api;

  @override
  Future<MeInfo> me() => _api.getMe();

  @override
  Future<MeInfo> setCalmMode(bool on) => _api.updateMe(calmMode: on);

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
}
