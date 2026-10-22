//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ContentApi {
  ContentApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'GET /v1/topics/{topicId}/lesson' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] topicId (required):
  Future<Response> getLessonWithHttpInfo(String topicId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/topics/{topicId}/lesson'
      .replaceAll('{topicId}', topicId);

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
  /// * [String] topicId (required):
  Future<Lesson?> getLesson(String topicId,) async {
    final response = await getLessonWithHttpInfo(topicId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Lesson',) as Lesson;
    
    }
    return null;
  }

  /// Offline packs for an exam with SHA-256 checksums (§39). Free users: free packs only.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<Response> listContentPacksWithHttpInfo(String examCode,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/content/packs';

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

  /// Offline packs for an exam with SHA-256 checksums (§39). Free users: free packs only.
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<ContentPackList?> listContentPacks(String examCode,) async {
    final response = await listContentPacksWithHttpInfo(examCode,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ContentPackList',) as ContentPackList;
    
    }
    return null;
  }

  /// Report a problem with a question (§19.4 Q34). Goes to the content fix loop.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] questionId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [QuestionReportBody] questionReportBody:
  Future<Response> reportQuestionWithHttpInfo(String questionId, String idempotencyKey, { QuestionReportBody? questionReportBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/questions/{questionId}/reports'
      .replaceAll('{questionId}', questionId);

    // ignore: prefer_final_locals
    Object? postBody = questionReportBody;

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

  /// Report a problem with a question (§19.4 Q34). Goes to the content fix loop.
  ///
  /// Parameters:
  ///
  /// * [String] questionId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [QuestionReportBody] questionReportBody:
  Future<QuestionReportAck?> reportQuestion(String questionId, String idempotencyKey, { QuestionReportBody? questionReportBody, }) async {
    final response = await reportQuestionWithHttpInfo(questionId, idempotencyKey,  questionReportBody: questionReportBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'QuestionReportAck',) as QuestionReportAck;
    
    }
    return null;
  }
}
