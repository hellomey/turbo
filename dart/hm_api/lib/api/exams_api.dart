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
}
