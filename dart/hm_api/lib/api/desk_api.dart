//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DeskApi {
  DeskApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

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
}
