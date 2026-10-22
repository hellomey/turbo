//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class NotificationsApi {
  NotificationsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'DELETE /v1/me/push-tokens/{deviceId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [String] idempotencyKey (required):
  Future<Response> deletePushTokenWithHttpInfo(String deviceId, String idempotencyKey,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/push-tokens/{deviceId}'
      .replaceAll('{deviceId}', deviceId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [String] idempotencyKey (required):
  Future<OkResponse?> deletePushToken(String deviceId, String idempotencyKey,) async {
    final response = await deletePushTokenWithHttpInfo(deviceId, idempotencyKey,);
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

  /// Performs an HTTP 'GET /v1/me/alert-settings' operation and returns the [Response].
  Future<Response> getAlertSettingsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/alert-settings';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  Future<AlertSettings?> getAlertSettings() async {
    final response = await getAlertSettingsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AlertSettings',) as AlertSettings;
    
    }
    return null;
  }

  /// Offers can be on only with the offers consent; dailyLimit is capped at 3.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PutAlertSettingsBody] putAlertSettingsBody:
  Future<Response> putAlertSettingsWithHttpInfo(String idempotencyKey, { PutAlertSettingsBody? putAlertSettingsBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/alert-settings';

    // ignore: prefer_final_locals
    Object? postBody = putAlertSettingsBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'idempotency-key'] = parameterToString(idempotencyKey);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Offers can be on only with the offers consent; dailyLimit is capped at 3.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PutAlertSettingsBody] putAlertSettingsBody:
  Future<AlertSettings?> putAlertSettings(String idempotencyKey, { PutAlertSettingsBody? putAlertSettingsBody, }) async {
    final response = await putAlertSettingsWithHttpInfo(idempotencyKey,  putAlertSettingsBody: putAlertSettingsBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AlertSettings',) as AlertSettings;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/me/push-tokens' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RegisterPushTokenBody] registerPushTokenBody:
  Future<Response> registerPushTokenWithHttpInfo(String idempotencyKey, { RegisterPushTokenBody? registerPushTokenBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/push-tokens';

    // ignore: prefer_final_locals
    Object? postBody = registerPushTokenBody;

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

  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RegisterPushTokenBody] registerPushTokenBody:
  Future<PushTokenAck?> registerPushToken(String idempotencyKey, { RegisterPushTokenBody? registerPushTokenBody, }) async {
    final response = await registerPushTokenWithHttpInfo(idempotencyKey,  registerPushTokenBody: registerPushTokenBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PushTokenAck',) as PushTokenAck;
    
    }
    return null;
  }
}
