//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ExamHallApi {
  ExamHallApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Resume exactly where I left off, with server remaining time (§19.8 Q76).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] attemptId (required):
  Future<Response> getMockAttemptWithHttpInfo(String attemptId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/mock-attempts/{attemptId}'
      .replaceAll('{attemptId}', attemptId);

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

  /// Resume exactly where I left off, with server remaining time (§19.8 Q76).
  ///
  /// Parameters:
  ///
  /// * [String] attemptId (required):
  Future<MockAttemptState?> getMockAttempt(String attemptId,) async {
    final response = await getMockAttemptWithHttpInfo(attemptId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MockAttemptState',) as MockAttemptState;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/mock-attempts/{attemptId}/report' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] attemptId (required):
  Future<Response> getMockReportWithHttpInfo(String attemptId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/mock-attempts/{attemptId}/report'
      .replaceAll('{attemptId}', attemptId);

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

  /// Parameters:
  ///
  /// * [String] attemptId (required):
  Future<MockReport?> getMockReport(String attemptId,) async {
    final response = await getMockReportWithHttpInfo(attemptId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MockReport',) as MockReport;
    
    }
    return null;
  }

  /// My statewide rank. Only live, online, on-time attempts are ranked (§18, §39).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] mockId (required):
  Future<Response> getMyStatewideRankWithHttpInfo(String mockId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/mocks/{mockId}/statewide-rank'
      .replaceAll('{mockId}', mockId);

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

  /// My statewide rank. Only live, online, on-time attempts are ranked (§18, §39).
  ///
  /// Parameters:
  ///
  /// * [String] mockId (required):
  Future<StatewideRank?> getMyStatewideRank(String mockId,) async {
    final response = await getMyStatewideRankWithHttpInfo(mockId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StatewideRank',) as StatewideRank;
    
    }
    return null;
  }

  /// The next State Mock Sunday for an exam (1st and 3rd Sunday, IST).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<Response> getStateMockSundayWithHttpInfo(String examCode,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/state-mock-sunday';

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

  /// The next State Mock Sunday for an exam (1st and 3rd Sunday, IST).
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<StateMockInfo?> getStateMockSunday(String examCode,) async {
    final response = await getStateMockSundayWithHttpInfo(examCode,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StateMockInfo',) as StateMockInfo;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/mocks' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<Response> listMocksWithHttpInfo(String examCode,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/mocks';

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

  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<MockList?> listMocks(String examCode,) async {
    final response = await listMocksWithHttpInfo(examCode,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MockList',) as MockList;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/me/mock-attempts' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> listMyMockAttemptsWithHttpInfo({ String? cursor, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/mock-attempts';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

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

  /// Parameters:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<MockAttemptPage?> listMyMockAttempts({ String? cursor, int? limit, }) async {
    final response = await listMyMockAttemptsWithHttpInfo( cursor: cursor, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MockAttemptPage',) as MockAttemptPage;
    
    }
    return null;
  }

  /// Save answers (last write per question wins until the deadline). Late answers are ignored.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] attemptId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SaveMockAnswersBody] saveMockAnswersBody:
  Future<Response> saveMockAnswersWithHttpInfo(String attemptId, String idempotencyKey, { SaveMockAnswersBody? saveMockAnswersBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/mock-attempts/{attemptId}/answers'
      .replaceAll('{attemptId}', attemptId);

    // ignore: prefer_final_locals
    Object? postBody = saveMockAnswersBody;

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

  /// Save answers (last write per question wins until the deadline). Late answers are ignored.
  ///
  /// Parameters:
  ///
  /// * [String] attemptId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SaveMockAnswersBody] saveMockAnswersBody:
  Future<MockAnswersSaved?> saveMockAnswers(String attemptId, String idempotencyKey, { SaveMockAnswersBody? saveMockAnswersBody, }) async {
    final response = await saveMockAnswersWithHttpInfo(attemptId, idempotencyKey,  saveMockAnswersBody: saveMockAnswersBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MockAnswersSaved',) as MockAnswersSaved;
    
    }
    return null;
  }

  /// Start (or return my in-progress) attempt. The server sets start time and deadline.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] mockId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [StartMockBody] startMockBody:
  Future<Response> startMockAttemptWithHttpInfo(String mockId, String idempotencyKey, { StartMockBody? startMockBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/mocks/{mockId}/attempts'
      .replaceAll('{mockId}', mockId);

    // ignore: prefer_final_locals
    Object? postBody = startMockBody;

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

  /// Start (or return my in-progress) attempt. The server sets start time and deadline.
  ///
  /// Parameters:
  ///
  /// * [String] mockId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [StartMockBody] startMockBody:
  Future<MockAttemptState?> startMockAttempt(String mockId, String idempotencyKey, { StartMockBody? startMockBody, }) async {
    final response = await startMockAttemptWithHttpInfo(mockId, idempotencyKey,  startMockBody: startMockBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MockAttemptState',) as MockAttemptState;
    
    }
    return null;
  }

  /// Submit and score on the server with the paper's marking scheme.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] attemptId (required):
  ///
  /// * [String] idempotencyKey (required):
  Future<Response> submitMockAttemptWithHttpInfo(String attemptId, String idempotencyKey,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/mock-attempts/{attemptId}/submit'
      .replaceAll('{attemptId}', attemptId);

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

  /// Submit and score on the server with the paper's marking scheme.
  ///
  /// Parameters:
  ///
  /// * [String] attemptId (required):
  ///
  /// * [String] idempotencyKey (required):
  Future<MockReport?> submitMockAttempt(String attemptId, String idempotencyKey,) async {
    final response = await submitMockAttemptWithHttpInfo(attemptId, idempotencyKey,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MockReport',) as MockReport;
    
    }
    return null;
  }
}
