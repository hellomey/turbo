//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ExpoApi {
  ExpoApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// My sticker code, earned by finishing the expo challenge or lighting a first lamp. null until earned.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getMyStickerCodeWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/sticker-code';

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

  /// My sticker code, earned by finishing the expo challenge or lighting a first lamp. null until earned.
  Future<MyStickerCode?> getMyStickerCode() async {
    final response = await getMyStickerCodeWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MyStickerCode',) as MyStickerCode;
    
    }
    return null;
  }

  /// Staff check a visitor's code and mark it used (one sticker per code). Role OPS, ADMIN or SUPPORT_AGENT. Audited.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RedeemStickerCodeBody] redeemStickerCodeBody:
  Future<Response> redeemStickerCodeWithHttpInfo(String idempotencyKey, { RedeemStickerCodeBody? redeemStickerCodeBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/desk/sticker-codes/redeem';

    // ignore: prefer_final_locals
    Object? postBody = redeemStickerCodeBody;

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

  /// Staff check a visitor's code and mark it used (one sticker per code). Role OPS, ADMIN or SUPPORT_AGENT. Audited.
  ///
  /// Parameters:
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [RedeemStickerCodeBody] redeemStickerCodeBody:
  Future<StickerCodeRedeemed?> redeemStickerCode(String idempotencyKey, { RedeemStickerCodeBody? redeemStickerCodeBody, }) async {
    final response = await redeemStickerCodeWithHttpInfo(idempotencyKey,  redeemStickerCodeBody: redeemStickerCodeBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StickerCodeRedeemed',) as StickerCodeRedeemed;
    
    }
    return null;
  }

  /// Start a 10-question stall challenge (guests allowed). Answers are never sent; the challenge expires in 15 minutes.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> startExpoChallengeWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/expo/challenge';

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

  /// Start a 10-question stall challenge (guests allowed). Answers are never sent; the challenge expires in 15 minutes.
  Future<ExpoChallenge?> startExpoChallenge() async {
    final response = await startExpoChallengeWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExpoChallenge',) as ExpoChallenge;
    
    }
    return null;
  }

  /// Grade once on the server. Finishing (any score) earns the user's sticker code.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] challengeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitExpoChallengeBody] submitExpoChallengeBody:
  Future<Response> submitExpoChallengeWithHttpInfo(String challengeId, String idempotencyKey, { SubmitExpoChallengeBody? submitExpoChallengeBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/expo/challenge/{challengeId}/submit'
      .replaceAll('{challengeId}', challengeId);

    // ignore: prefer_final_locals
    Object? postBody = submitExpoChallengeBody;

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

  /// Grade once on the server. Finishing (any score) earns the user's sticker code.
  ///
  /// Parameters:
  ///
  /// * [String] challengeId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///
  /// * [SubmitExpoChallengeBody] submitExpoChallengeBody:
  Future<ExpoChallengeResult?> submitExpoChallenge(String challengeId, String idempotencyKey, { SubmitExpoChallengeBody? submitExpoChallengeBody, }) async {
    final response = await submitExpoChallengeWithHttpInfo(challengeId, idempotencyKey,  submitExpoChallengeBody: submitExpoChallengeBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExpoChallengeResult',) as ExpoChallengeResult;
    
    }
    return null;
  }
}
