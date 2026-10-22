//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ReadinessApi {
  ReadinessApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Four evidence bars + a plain label. Never one overall percentage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<Response> getMyReadinessWithHttpInfo(String examCode,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/readiness';

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

  /// Four evidence bars + a plain label. Never one overall percentage.
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  Future<ReadinessMeter?> getMyReadiness(String examCode,) async {
    final response = await getMyReadinessWithHttpInfo(examCode,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReadinessMeter',) as ReadinessMeter;
    
    }
    return null;
  }

  /// 7/30/90-day trends (Pro: PRO_REQUIRED for free users).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  ///
  /// * [int] days:
  Future<Response> getMyReadinessTrendWithHttpInfo(String examCode, { int? days, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/readiness/trend';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'examCode', examCode));
    if (days != null) {
      queryParams.addAll(_queryParams('', 'days', days));
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

  /// 7/30/90-day trends (Pro: PRO_REQUIRED for free users).
  ///
  /// Parameters:
  ///
  /// * [String] examCode (required):
  ///
  /// * [int] days:
  Future<ReadinessTrend?> getMyReadinessTrend(String examCode, { int? days, }) async {
    final response = await getMyReadinessTrendWithHttpInfo(examCode,  days: days, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReadinessTrend',) as ReadinessTrend;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/me/sunday-reports/{reportId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] reportId (required):
  Future<Response> getSundayReportWithHttpInfo(String reportId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/sunday-reports/{reportId}'
      .replaceAll('{reportId}', reportId);

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
  /// * [String] reportId (required):
  Future<SundayReport?> getSundayReport(String reportId,) async {
    final response = await getSundayReportWithHttpInfo(reportId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SundayReport',) as SundayReport;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/me/sunday-reports' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> listMySundayReportsWithHttpInfo({ String? cursor, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/sunday-reports';

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
  Future<SundayReportPage?> listMySundayReports({ String? cursor, int? limit, }) async {
    final response = await listMySundayReportsWithHttpInfo( cursor: cursor, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SundayReportPage',) as SundayReportPage;
    
    }
    return null;
  }
}
