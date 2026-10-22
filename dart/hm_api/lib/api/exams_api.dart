//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ExamsApi {
  ExamsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Human-approved: publishes an Exam Alert (exams.notification_published) to followers. Audited.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] changeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [ApproveExamChangeBody] approveExamChangeBody:
  Future<Response> approveExamChangeWithHttpInfo(String changeId, String idempotencyKey, { ApproveExamChangeBody? approveExamChangeBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/desk/exam-changes/{changeId}/approve'
      .replaceAll('{changeId}', changeId);

    // ignore: prefer_final_locals
    Object? postBody = approveExamChangeBody;

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

  /// Human-approved: publishes an Exam Alert (exams.notification_published) to followers. Audited.
  ///
  /// Parameters:
  ///
  /// * [String] changeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [ApproveExamChangeBody] approveExamChangeBody:
  Future<ExamChange?> approveExamChange(String changeId, String idempotencyKey, { ApproveExamChangeBody? approveExamChangeBody, }) async {
    final response = await approveExamChangeWithHttpInfo(changeId, idempotencyKey,  approveExamChangeBody: approveExamChangeBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExamChange',) as ExamChange;
    
    }
    return null;
  }

  /// Eligibility Checker. A pure computation: nothing is stored. Under 18 returns UNDER_18.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [EligibilityCheckBody] eligibilityCheckBody:
  Future<Response> checkEligibilityWithHttpInfo({ EligibilityCheckBody? eligibilityCheckBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/eligibility/check';

    // ignore: prefer_final_locals
    Object? postBody = eligibilityCheckBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Eligibility Checker. A pure computation: nothing is stored. Under 18 returns UNDER_18.
  ///
  /// Parameters:
  ///
  /// * [EligibilityCheckBody] eligibilityCheckBody:
  Future<EligibilityResult?> checkEligibility({ EligibilityCheckBody? eligibilityCheckBody, }) async {
    final response = await checkEligibilityWithHttpInfo( eligibilityCheckBody: eligibilityCheckBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EligibilityResult',) as EligibilityResult;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/exams/{code}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] code (required):
  Future<Response> getExamWithHttpInfo(String code,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/exams/{code}'
      .replaceAll('{code}', code);

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
  /// * [String] code (required):
  Future<ExamDetail?> getExam(String code,) async {
    final response = await getExamWithHttpInfo(code,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExamDetail',) as ExamDetail;
    
    }
    return null;
  }

  /// Stages, papers and marking schemes (exam-agnostic, ADR-0013). Unverified schemes say so.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] code (required):
  Future<Response> getExamStructureWithHttpInfo(String code,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/exams/{code}/structure'
      .replaceAll('{code}', code);

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

  /// Stages, papers and marking schemes (exam-agnostic, ADR-0013). Unverified schemes say so.
  ///
  /// Parameters:
  ///
  /// * [String] code (required):
  Future<ExamStructure?> getExamStructure(String code,) async {
    final response = await getExamStructureWithHttpInfo(code,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExamStructure',) as ExamStructure;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/me/exams' operation and returns the [Response].
  Future<Response> getMyExamsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/exams';

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

  Future<UserExams?> getMyExams() async {
    final response = await getMyExamsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserExams',) as UserExams;
    
    }
    return null;
  }

  /// Ops queue of official-site changes waiting for a human check. Role OPS or ADMIN (checked in the handler).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ExamChangeStatus] status:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> listExamChangesWithHttpInfo({ ExamChangeStatus? status, String? cursor, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/desk/exam-changes';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
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

  /// Ops queue of official-site changes waiting for a human check. Role OPS or ADMIN (checked in the handler).
  ///
  /// Parameters:
  ///
  /// * [ExamChangeStatus] status:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<ExamChangePage?> listExamChanges({ ExamChangeStatus? status, String? cursor, int? limit, }) async {
    final response = await listExamChangesWithHttpInfo( status: status, cursor: cursor, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExamChangePage',) as ExamChangePage;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/exams' operation and returns the [Response].
  Future<Response> listExamsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/exams';

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

  Future<ExamList?> listExams() async {
    final response = await listExamsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExamList',) as ExamList;
    
    }
    return null;
  }

  /// Human-checked Exam Alerts for the exams I follow, newest first.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> listMyExamAlertsWithHttpInfo({ String? cursor, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/exam-alerts';

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

  /// Human-checked Exam Alerts for the exams I follow, newest first.
  ///
  /// Parameters:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<ExamAlertPage?> listMyExamAlerts({ String? cursor, int? limit, }) async {
    final response = await listMyExamAlertsWithHttpInfo( cursor: cursor, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExamAlertPage',) as ExamAlertPage;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /v1/me/exams' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [UserExamsBody] userExamsBody:
  Future<Response> putMyExamsWithHttpInfo(String idempotencyKey, { UserExamsBody? userExamsBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/exams';

    // ignore: prefer_final_locals
    Object? postBody = userExamsBody;

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

  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [UserExamsBody] userExamsBody:
  Future<UserExams?> putMyExams(String idempotencyKey, { UserExamsBody? userExamsBody, }) async {
    final response = await putMyExamsWithHttpInfo(idempotencyKey,  userExamsBody: userExamsBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserExams',) as UserExams;
    
    }
    return null;
  }

  /// changedetection.io site-change webhook. Stores a pending change; NOTHING is sent to users (§17.5).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xHeymeyWebhookSecret (required):
  ///
  /// * [SiteChangeWebhookBody] siteChangeWebhookBody:
  Future<Response> receiveSiteChangeWithHttpInfo(String xHeymeyWebhookSecret, { SiteChangeWebhookBody? siteChangeWebhookBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/webhooks/changedetection';

    // ignore: prefer_final_locals
    Object? postBody = siteChangeWebhookBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-heymey-webhook-secret'] = parameterToString(xHeymeyWebhookSecret);

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

  /// changedetection.io site-change webhook. Stores a pending change; NOTHING is sent to users (§17.5).
  ///
  /// Parameters:
  ///
  /// * [String] xHeymeyWebhookSecret (required):
  ///
  /// * [SiteChangeWebhookBody] siteChangeWebhookBody:
  Future<SiteChangeAck?> receiveSiteChange(String xHeymeyWebhookSecret, { SiteChangeWebhookBody? siteChangeWebhookBody, }) async {
    final response = await receiveSiteChangeWithHttpInfo(xHeymeyWebhookSecret,  siteChangeWebhookBody: siteChangeWebhookBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SiteChangeAck',) as SiteChangeAck;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/desk/exam-changes/{changeId}/reject' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] changeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RejectExamChangeBody] rejectExamChangeBody:
  Future<Response> rejectExamChangeWithHttpInfo(String changeId, String idempotencyKey, { RejectExamChangeBody? rejectExamChangeBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/desk/exam-changes/{changeId}/reject'
      .replaceAll('{changeId}', changeId);

    // ignore: prefer_final_locals
    Object? postBody = rejectExamChangeBody;

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
  /// * [String] changeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RejectExamChangeBody] rejectExamChangeBody:
  Future<ExamChange?> rejectExamChange(String changeId, String idempotencyKey, { RejectExamChangeBody? rejectExamChangeBody, }) async {
    final response = await rejectExamChangeWithHttpInfo(changeId, idempotencyKey,  rejectExamChangeBody: rejectExamChangeBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExamChange',) as ExamChange;
    
    }
    return null;
  }
}
