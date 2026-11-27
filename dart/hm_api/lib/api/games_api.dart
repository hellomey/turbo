//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class GamesApi {
  GamesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// The published prize table with exact odds, and whether today's free spin is used.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getDailySpinWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/games/daily-spin';

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

  /// The published prize table with exact odds, and whether today's free spin is used.
  Future<DailySpinState?> getDailySpin() async {
    final response = await getDailySpinWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DailySpinState',) as DailySpinState;
    
    }
    return null;
  }

  /// Game Rules & Odds: the Daily Spin prize table with exact odds, Confidence Duel scoring, limits and sleep hours.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getGameRulesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/games/rules';

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

  /// Game Rules & Odds: the Daily Spin prize table with exact odds, Confidence Duel scoring, limits and sleep hours.
  Future<GameRules?> getGameRules() async {
    final response = await getGameRulesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GameRules',) as GameRules;
    
    }
    return null;
  }

  /// Today's one free spin (IST day). The server draws with a CSPRNG. A second call the same day returns the same prize.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<Response> spinDailySpinWithHttpInfo(String idempotencyKey,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/games/daily-spin';

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

  /// Today's one free spin (IST day). The server draws with a CSPRNG. A second call the same day returns the same prize.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<DailySpinResult?> spinDailySpin(String idempotencyKey,) async {
    final response = await spinDailySpinWithHttpInfo(idempotencyKey,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DailySpinResult',) as DailySpinResult;
    
    }
    return null;
  }

  /// Start a solo duel against the clock: 5 published practice questions (no answers) and the scoring rules.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<Response> startConfidenceDuelWithHttpInfo(String examCode,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/games/confidence-duel';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'examCode', examCode));

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

  /// Start a solo duel against the clock: 5 published practice questions (no answers) and the scoring rules.
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<ConfidenceDuel?> startConfidenceDuel(String examCode,) async {
    final response = await startConfidenceDuelWithHttpInfo(examCode,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ConfidenceDuel',) as ConfidenceDuel;
    
    }
    return null;
  }

  /// Submit answers with a confidence (1 to 3) each. The server grades and scores calibration; Points are capped per day.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] duelId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitDuelBody] submitDuelBody:
  Future<Response> submitConfidenceDuelWithHttpInfo(String duelId, String idempotencyKey, { SubmitDuelBody? submitDuelBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/games/confidence-duel/{duelId}/submit'
      .replaceAll('{duelId}', duelId);

    // ignore: prefer_final_locals
    Object? postBody = submitDuelBody;

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

  /// Submit answers with a confidence (1 to 3) each. The server grades and scores calibration; Points are capped per day.
  ///
  /// Parameters:
  ///
  /// * [String] duelId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitDuelBody] submitDuelBody:
  Future<DuelResult?> submitConfidenceDuel(String duelId, String idempotencyKey, { SubmitDuelBody? submitDuelBody, }) async {
    final response = await submitConfidenceDuelWithHttpInfo(duelId, idempotencyKey,  submitDuelBody: submitDuelBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DuelResult',) as DuelResult;
    
    }
    return null;
  }
}
