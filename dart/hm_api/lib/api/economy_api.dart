//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class EconomyApi {
  EconomyApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Daily check-in, once per IST day: small XP + Points. Missing a day resets nothing.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<Response> checkInWithHttpInfo(String idempotencyKey,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/check-in';

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

  /// Daily check-in, once per IST day: small XP + Points. Missing a day resets nothing.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<CheckInResult?> checkIn(String idempotencyKey,) async {
    final response = await checkInWithHttpInfo(idempotencyKey,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CheckInResult',) as CheckInResult;
    
    }
    return null;
  }

  /// XP and level (from learning only), Points (never bought) and trophies.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getMyProgressWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/progress';

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

  /// XP and level (from learning only), Points (never bought) and trophies.
  Future<MyProgress?> getMyProgress() async {
    final response = await getMyProgressWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MyProgress',) as MyProgress;
    
    }
    return null;
  }

  /// This IST week's XP. Only real users who opted in, by nickname. Guests never appear.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getWeeklyLeaderboardWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/leaderboard/weekly';

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

  /// This IST week's XP. Only real users who opted in, by nickname. Guests never appear.
  Future<WeeklyLeaderboard?> getWeeklyLeaderboard() async {
    final response = await getWeeklyLeaderboardWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WeeklyLeaderboard',) as WeeklyLeaderboard;
    
    }
    return null;
  }

  /// Join or leave the weekly leaderboard (off by default). Guests get GUEST_NOT_ALLOWED when joining.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [LeaderboardOptInBody] leaderboardOptInBody:
  Future<Response> putLeaderboardOptInWithHttpInfo(String idempotencyKey, { LeaderboardOptInBody? leaderboardOptInBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/leaderboard-opt-in';

    // ignore: prefer_final_locals
    Object? postBody = leaderboardOptInBody;

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

  /// Join or leave the weekly leaderboard (off by default). Guests get GUEST_NOT_ALLOWED when joining.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [LeaderboardOptInBody] leaderboardOptInBody:
  Future<LeaderboardOptIn?> putLeaderboardOptIn(String idempotencyKey, { LeaderboardOptInBody? leaderboardOptInBody, }) async {
    final response = await putLeaderboardOptInWithHttpInfo(idempotencyKey,  leaderboardOptInBody: leaderboardOptInBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LeaderboardOptIn',) as LeaderboardOptIn;
    
    }
    return null;
  }
}
