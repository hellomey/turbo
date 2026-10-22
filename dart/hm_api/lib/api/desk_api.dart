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
