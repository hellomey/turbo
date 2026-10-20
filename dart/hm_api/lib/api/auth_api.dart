//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Confirm account deletion with a `delete_account` code. 7-day grace period (§38.7).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DeleteAccountBody] deleteAccountBody:
  Future<Response> deleteAccountWithHttpInfo(String idempotencyKey, { DeleteAccountBody? deleteAccountBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/delete-account';

    // ignore: prefer_final_locals
    Object? postBody = deleteAccountBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Confirm account deletion with a `delete_account` code. 7-day grace period (§38.7).
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DeleteAccountBody] deleteAccountBody:
  Future<DeleteAccountResponse?> deleteAccount(String idempotencyKey, { DeleteAccountBody? deleteAccountBody, }) async {
    final response = await deleteAccountWithHttpInfo(idempotencyKey,  deleteAccountBody: deleteAccountBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DeleteAccountResponse',) as DeleteAccountResponse;
    
    }
    return null;
  }

  /// First Desk sign-in: create the authenticator secret for this staff/partner account.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DeskTotpEnrollBody] deskTotpEnrollBody:
  Future<Response> enrollDeskTotpWithHttpInfo(String idempotencyKey, { DeskTotpEnrollBody? deskTotpEnrollBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/desk/totp/enroll';

    // ignore: prefer_final_locals
    Object? postBody = deskTotpEnrollBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// First Desk sign-in: create the authenticator secret for this staff/partner account.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DeskTotpEnrollBody] deskTotpEnrollBody:
  Future<DeskTotpEnrollResponse?> enrollDeskTotp(String idempotencyKey, { DeskTotpEnrollBody? deskTotpEnrollBody, }) async {
    final response = await enrollDeskTotpWithHttpInfo(idempotencyKey,  deskTotpEnrollBody: deskTotpEnrollBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DeskTotpEnrollResponse',) as DeskTotpEnrollResponse;
    
    }
    return null;
  }

  /// End this session.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<Response> logoutWithHttpInfo(String idempotencyKey,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// End this session.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<OkResponse?> logout(String idempotencyKey,) async {
    final response = await logoutWithHttpInfo(idempotencyKey,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OkResponse',) as OkResponse;
    
    }
    return null;
  }

  /// Log out of all devices.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<Response> logoutAllWithHttpInfo(String idempotencyKey,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/logout-all';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Log out of all devices.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<OkResponse?> logoutAll(String idempotencyKey,) async {
    final response = await logoutAllWithHttpInfo(idempotencyKey,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OkResponse',) as OkResponse;
    
    }
    return null;
  }

  /// Rotate the refresh token. Re-using an old one revokes the whole session family.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RefreshBody] refreshBody:
  Future<Response> refreshSessionWithHttpInfo(String idempotencyKey, { RefreshBody? refreshBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Rotate the refresh token. Re-using an old one revokes the whole session family.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RefreshBody] refreshBody:
  Future<TokenPair?> refreshSession(String idempotencyKey, { RefreshBody? refreshBody, }) async {
    final response = await refreshSessionWithHttpInfo(idempotencyKey,  refreshBody: refreshBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenPair',) as TokenPair;
    
    }
    return null;
  }

  /// Send a 6-digit code. Always 200: never reveals whether the email has an account.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [OtpRequestBody] otpRequestBody:
  Future<Response> requestOtpWithHttpInfo(String idempotencyKey, { OtpRequestBody? otpRequestBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/otp/request';

    // ignore: prefer_final_locals
    Object? postBody = otpRequestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Send a 6-digit code. Always 200: never reveals whether the email has an account.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [OtpRequestBody] otpRequestBody:
  Future<OtpRequestResponse?> requestOtp(String idempotencyKey, { OtpRequestBody? otpRequestBody, }) async {
    final response = await requestOtpWithHttpInfo(idempotencyKey,  otpRequestBody: otpRequestBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OtpRequestResponse',) as OtpRequestResponse;
    
    }
    return null;
  }

  /// Complete Desk sign-in with the authenticator code.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DeskTotpVerifyBody] deskTotpVerifyBody:
  Future<Response> verifyDeskTotpWithHttpInfo(String idempotencyKey, { DeskTotpVerifyBody? deskTotpVerifyBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/desk/totp/verify';

    // ignore: prefer_final_locals
    Object? postBody = deskTotpVerifyBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Complete Desk sign-in with the authenticator code.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [DeskTotpVerifyBody] deskTotpVerifyBody:
  Future<SessionGranted?> verifyDeskTotp(String idempotencyKey, { DeskTotpVerifyBody? deskTotpVerifyBody, }) async {
    final response = await verifyDeskTotpWithHttpInfo(idempotencyKey,  deskTotpVerifyBody: deskTotpVerifyBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SessionGranted',) as SessionGranted;
    
    }
    return null;
  }

  /// Exchange email + code for a session bound to this device (or a Desk 2FA challenge).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [OtpVerifyBody] otpVerifyBody:
  Future<Response> verifyOtpWithHttpInfo(String idempotencyKey, { OtpVerifyBody? otpVerifyBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/otp/verify';

    // ignore: prefer_final_locals
    Object? postBody = otpVerifyBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Exchange email + code for a session bound to this device (or a Desk 2FA challenge).
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [OtpVerifyBody] otpVerifyBody:
  Future<OtpVerifyResponse?> verifyOtp(String idempotencyKey, { OtpVerifyBody? otpVerifyBody, }) async {
    final response = await verifyOtpWithHttpInfo(idempotencyKey,  otpVerifyBody: otpVerifyBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OtpVerifyResponse',) as OtpVerifyResponse;
    
    }
    return null;
  }
}
