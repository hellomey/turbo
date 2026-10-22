//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PracticeApi {
  PracticeApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Grade one answer. The 31st counted answer of the IST day returns PRACTICE_DAILY_LIMIT for free users.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sessionId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PracticeAnswerBody] practiceAnswerBody:
  Future<Response> answerPracticeQuestionWithHttpInfo(String sessionId, String idempotencyKey, { PracticeAnswerBody? practiceAnswerBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/practice/sessions/{sessionId}/answers'
      .replaceAll('{sessionId}', sessionId);

    // ignore: prefer_final_locals
    Object? postBody = practiceAnswerBody;

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

  /// Grade one answer. The 31st counted answer of the IST day returns PRACTICE_DAILY_LIMIT for free users.
  ///
  /// Parameters:
  ///
  /// * [String] sessionId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PracticeAnswerBody] practiceAnswerBody:
  Future<PracticeAnswerResult?> answerPracticeQuestion(String sessionId, String idempotencyKey, { PracticeAnswerBody? practiceAnswerBody, }) async {
    final response = await answerPracticeQuestionWithHttpInfo(sessionId, idempotencyKey,  practiceAnswerBody: practiceAnswerBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PracticeAnswerResult',) as PracticeAnswerResult;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/me/practice/usage' operation and returns the [Response].
  Future<Response> getPracticeUsageWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/practice/usage';

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

  Future<PracticeUsage?> getPracticeUsage() async {
    final response = await getPracticeUsageWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PracticeUsage',) as PracticeUsage;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/pyq/facets' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<Response> getPyqFacetsWithHttpInfo(String examCode,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/pyq/facets';

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
  Future<PyqFacets?> getPyqFacets(String examCode,) async {
    final response = await getPyqFacetsWithHttpInfo(examCode,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PyqFacets',) as PyqFacets;
    
    }
    return null;
  }

  /// Concept drills from repeated mistakes (Pro, §19.6 Q60). `locked` for free users.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listMyDrillsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/drills';

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

  /// Concept drills from repeated mistakes (Pro, §19.6 Q60). `locked` for free users.
  Future<ConceptDrillList?> listMyDrills() async {
    final response = await listMyDrillsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ConceptDrillList',) as ConceptDrillList;
    
    }
    return null;
  }

  /// Mistake review: why mine was wrong, why the answer is right, which lamp to relight (§19.4 Q38).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> listMyMistakesWithHttpInfo({ String? cursor, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/mistakes';

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

  /// Mistake review: why mine was wrong, why the answer is right, which lamp to relight (§19.4 Q38).
  ///
  /// Parameters:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<MistakePage?> listMyMistakes({ String? cursor, int? limit, }) async {
    final response = await listMyMistakesWithHttpInfo( cursor: cursor, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MistakePage',) as MistakePage;
    
    }
    return null;
  }

  /// PYQ Vault. Free: latest 2 exam years held for the exam; older years come back `locked`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  ///
  /// * [int] year:
  ///
  /// * [String] subjectCode:
  ///
  /// * [String] topicId:
  ///
  /// * [int] difficulty:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> searchPyqsWithHttpInfo(String examCode, { int? year, String? subjectCode, String? topicId, int? difficulty, String? cursor, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/pyq';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'examCode', examCode));
    if (year != null) {
      queryParams.addAll(_queryParams('', 'year', year));
    }
    if (subjectCode != null) {
      queryParams.addAll(_queryParams('', 'subjectCode', subjectCode));
    }
    if (topicId != null) {
      queryParams.addAll(_queryParams('', 'topicId', topicId));
    }
    if (difficulty != null) {
      queryParams.addAll(_queryParams('', 'difficulty', difficulty));
    }
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

  /// PYQ Vault. Free: latest 2 exam years held for the exam; older years come back `locked`.
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  ///
  /// * [int] year:
  ///
  /// * [String] subjectCode:
  ///
  /// * [String] topicId:
  ///
  /// * [int] difficulty:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<PyqPage?> searchPyqs(String examCode, { int? year, String? subjectCode, String? topicId, int? difficulty, String? cursor, int? limit, }) async {
    final response = await searchPyqsWithHttpInfo(examCode,  year: year, subjectCode: subjectCode, topicId: topicId, difficulty: difficulty, cursor: cursor, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PyqPage',) as PyqPage;
    
    }
    return null;
  }

  /// Start practice, PYQ, mistakes or drill. Questions come without answers.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [StartPracticeBody] startPracticeBody:
  Future<Response> startPracticeSessionWithHttpInfo(String idempotencyKey, { StartPracticeBody? startPracticeBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/practice/sessions';

    // ignore: prefer_final_locals
    Object? postBody = startPracticeBody;

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

  /// Start practice, PYQ, mistakes or drill. Questions come without answers.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [StartPracticeBody] startPracticeBody:
  Future<PracticeSession?> startPracticeSession(String idempotencyKey, { StartPracticeBody? startPracticeBody, }) async {
    final response = await startPracticeSessionWithHttpInfo(idempotencyKey,  startPracticeBody: startPracticeBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PracticeSession',) as PracticeSession;
    
    }
    return null;
  }
}
