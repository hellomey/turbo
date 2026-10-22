//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PlanApi {
  PlanApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'GET /v1/me/plan' operation and returns the [Response].
  Future<Response> getMyPlanWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/plan';

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

  Future<Plan?> getMyPlan() async {
    final response = await getMyPlanWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Plan',) as Plan;
    
    }
    return null;
  }

  /// Calendar view (max 62 days per request).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  Future<Response> getPlanDaysWithHttpInfo(DateTime from, DateTime to,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/plan/days';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

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

  /// Calendar view (max 62 days per request).
  ///
  /// Parameters:
  ///
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  Future<PlanDays?> getPlanDays(DateTime from, DateTime to,) async {
    final response = await getPlanDaysWithHttpInfo(from, to,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PlanDays',) as PlanDays;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/me/today' operation and returns the [Response].
  Future<Response> getTodayWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/today';

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

  Future<TodayScreen?> getToday() async {
    final response = await getTodayWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TodayScreen',) as TodayScreen;
    
    }
    return null;
  }

  /// Create or change My Plan from study hours; exam dates come from `exams` (§17.1 step 9).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PutPlanBody] putPlanBody:
  Future<Response> putMyPlanWithHttpInfo(String idempotencyKey, { PutPlanBody? putPlanBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/plan';

    // ignore: prefer_final_locals
    Object? postBody = putPlanBody;

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

  /// Create or change My Plan from study hours; exam dates come from `exams` (§17.1 step 9).
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [PutPlanBody] putPlanBody:
  Future<Plan?> putMyPlan(String idempotencyKey, { PutPlanBody? putPlanBody, }) async {
    final response = await putMyPlanWithHttpInfo(idempotencyKey,  putPlanBody: putPlanBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Plan',) as Plan;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/me/plan/rebalance' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<Response> rebalanceMyPlanWithHttpInfo(String idempotencyKey,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/plan/rebalance';

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

  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  Future<Plan?> rebalanceMyPlan(String idempotencyKey,) async {
    final response = await rebalanceMyPlanWithHttpInfo(idempotencyKey,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Plan',) as Plan;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/me/plan/items/{itemId}/status' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [UpdatePlanItemBody] updatePlanItemBody:
  Future<Response> updatePlanItemWithHttpInfo(String itemId, String idempotencyKey, { UpdatePlanItemBody? updatePlanItemBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/plan/items/{itemId}/status'
      .replaceAll('{itemId}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = updatePlanItemBody;

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
  /// * [String] itemId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [UpdatePlanItemBody] updatePlanItemBody:
  Future<PlanItem?> updatePlanItem(String itemId, String idempotencyKey, { UpdatePlanItemBody? updatePlanItemBody, }) async {
    final response = await updatePlanItemWithHttpInfo(itemId, idempotencyKey,  updatePlanItemBody: updatePlanItemBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PlanItem',) as PlanItem;
    
    }
    return null;
  }
}
