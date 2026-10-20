import 'package:hm_core/hm_core.dart';

/// HeyMey Desk sign-in: email code, then the authenticator (TOTP) second factor (§15, §38 step 5).
abstract interface class DeskAuthRepository {
  Future<int> requestCode(String email);

  /// `client: desk`, `platform: web`. Staff/partners get a challenge; aspirants get `DESK_NOT_ALLOWED`.
  Future<OtpVerifyOutcome> verifyCode(String email, String code);

  /// First sign-in only: the authenticator secret (QR + manual entry).
  Future<DeskEnrolment> enroll(String challengeToken);

  /// Completes sign-in (Desk tokens stored).
  Future<void> verifyTotp(String challengeToken, String code);

  Future<MeInfo> me();

  Future<bool> hasSession();

  Future<void> logout();
}

class ApiDeskAuthRepository implements DeskAuthRepository {
  ApiDeskAuthRepository(this._api, this._deviceIds);

  final HmApi _api;
  final DeviceIdStore _deviceIds;

  @override
  Future<int> requestCode(String email) => _api.requestOtp(email);

  @override
  Future<OtpVerifyOutcome> verifyCode(String email, String code) async =>
      _api.verifyOtp(
        email: email,
        code: code,
        deviceId: await _deviceIds.deviceId(),
        platform: ClientPlatform.web,
        client: ClientKind.desk,
      );

  @override
  Future<DeskEnrolment> enroll(String challengeToken) =>
      _api.enrollDeskTotp(challengeToken);

  @override
  Future<void> verifyTotp(String challengeToken, String code) =>
      _api.verifyDeskTotp(challengeToken, code);

  @override
  Future<MeInfo> me() => _api.getMe();

  @override
  Future<bool> hasSession() => _api.hasSession();

  @override
  Future<void> logout() => _api.logout();
}
