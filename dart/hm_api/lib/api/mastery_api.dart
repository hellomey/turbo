//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class MasteryApi {
  MasteryApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// I finished the lesson or the mapped textbook pages. Opens the 3-question Lit check.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] topicId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [LessonCompleteBody] lessonCompleteBody:
  Future<Response> completeLessonWithHttpInfo(String topicId, String idempotencyKey, { LessonCompleteBody? lessonCompleteBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/topics/{topicId}/lesson-complete'
      .replaceAll('{topicId}', topicId);

    // ignore: prefer_final_locals
    Object? postBody = lessonCompleteBody;

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

  /// I finished the lesson or the mapped textbook pages. Opens the 3-question Lit check.
  ///
  /// Parameters:
  ///
  /// * [String] topicId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [LessonCompleteBody] lessonCompleteBody:
  Future<TopicState?> completeLesson(String topicId, String idempotencyKey, { LessonCompleteBody? lessonCompleteBody, }) async {
    final response = await completeLessonWithHttpInfo(topicId, idempotencyKey,  lessonCompleteBody: lessonCompleteBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TopicState',) as TopicState;
    
    }
    return null;
  }

  /// Rank (from lamps only), XP and ring counts across my exams.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getMyMasteryWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/mastery';

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

  /// Rank (from lamps only), XP and ring counts across my exams.
  Future<MasterySummary?> getMyMastery() async {
    final response = await getMyMasteryWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MasterySummary',) as MasterySummary;
    
    }
    return null;
  }

  /// Dimming lamps I can open, oldest first, with minutes (\"Relight 4 · 8 min\").
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getRelightQueueWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/relight-queue';

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

  /// Dimming lamps I can open, oldest first, with minutes (\"Relight 4 · 8 min\").
  Future<RelightQueue?> getRelightQueue() async {
    final response = await getRelightQueueWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RelightQueue',) as RelightQueue;
    
    }
    return null;
  }

  /// Authoritative lamp states for one exam's map; `since` for incremental Drift sync.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  ///
  /// * [DateTime] since:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> listMyTopicStatesWithHttpInfo(String examCode, { DateTime? since, String? cursor, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/topic-states';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'examCode', examCode));
    if (since != null) {
      queryParams.addAll(_queryParams('', 'since', since));
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

  /// Authoritative lamp states for one exam's map; `since` for incremental Drift sync.
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  ///
  /// * [DateTime] since:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<TopicStatePage?> listMyTopicStates(String examCode, { DateTime? since, String? cursor, int? limit, }) async {
    final response = await listMyTopicStatesWithHttpInfo(examCode,  since: since, cursor: cursor, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TopicStatePage',) as TopicStatePage;
    
    }
    return null;
  }

  /// Start a Lit / recall / relight / Gold check. The server picks the questions and sets any deadline.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] topicId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [StartCheckBody] startCheckBody:
  Future<Response> startTopicCheckWithHttpInfo(String topicId, String idempotencyKey, { StartCheckBody? startCheckBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/topics/{topicId}/checks'
      .replaceAll('{topicId}', topicId);

    // ignore: prefer_final_locals
    Object? postBody = startCheckBody;

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

  /// Start a Lit / recall / relight / Gold check. The server picks the questions and sets any deadline.
  ///
  /// Parameters:
  ///
  /// * [String] topicId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [StartCheckBody] startCheckBody:
  Future<TopicCheck?> startTopicCheck(String topicId, String idempotencyKey, { StartCheckBody? startCheckBody, }) async {
    final response = await startTopicCheckWithHttpInfo(topicId, idempotencyKey,  startCheckBody: startCheckBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TopicCheck',) as TopicCheck;
    
    }
    return null;
  }

  /// Grade a check on the server and move the rings. Late Gold answers are not counted.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] checkId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitCheckBody] submitCheckBody:
  Future<Response> submitTopicCheckWithHttpInfo(String checkId, String idempotencyKey, { SubmitCheckBody? submitCheckBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/checks/{checkId}/submit'
      .replaceAll('{checkId}', checkId);

    // ignore: prefer_final_locals
    Object? postBody = submitCheckBody;

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

  /// Grade a check on the server and move the rings. Late Gold answers are not counted.
  ///
  /// Parameters:
  ///
  /// * [String] checkId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitCheckBody] submitCheckBody:
  Future<CheckResult?> submitTopicCheck(String checkId, String idempotencyKey, { SubmitCheckBody? submitCheckBody, }) async {
    final response = await submitTopicCheckWithHttpInfo(checkId, idempotencyKey,  submitCheckBody: submitCheckBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CheckResult',) as CheckResult;
    
    }
    return null;
  }

  /// Offline outbox batch (§39). Each clientActionId is accepted once; returns authoritative lamp states.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SyncBatchBody] syncBatchBody:
  Future<Response> syncStudyActionsWithHttpInfo(String idempotencyKey, { SyncBatchBody? syncBatchBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sync/study-actions';

    // ignore: prefer_final_locals
    Object? postBody = syncBatchBody;

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

  /// Offline outbox batch (§39). Each clientActionId is accepted once; returns authoritative lamp states.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SyncBatchBody] syncBatchBody:
  Future<SyncBatchResult?> syncStudyActions(String idempotencyKey, { SyncBatchBody? syncBatchBody, }) async {
    final response = await syncStudyActionsWithHttpInfo(idempotencyKey,  syncBatchBody: syncBatchBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SyncBatchResult',) as SyncBatchResult;
    
    }
    return null;
  }
}
