# hm_api.api.ExpoApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMyStickerCode**](ExpoApi.md#getmystickercode) | **GET** /v1/me/sticker-code | My sticker code, earned by finishing the expo challenge or lighting a first lamp. null until earned.
[**redeemStickerCode**](ExpoApi.md#redeemstickercode) | **POST** /v1/desk/sticker-codes/redeem | Staff check a visitor's code and mark it used (one sticker per code). Role OPS, ADMIN or SUPPORT_AGENT. Audited.
[**startExpoChallenge**](ExpoApi.md#startexpochallenge) | **GET** /v1/expo/challenge | Start a 10-question stall challenge (guests allowed). Answers are never sent; the challenge expires in 15 minutes.
[**submitExpoChallenge**](ExpoApi.md#submitexpochallenge) | **POST** /v1/expo/challenge/{challengeId}/submit | Grade once on the server. Finishing (any score) earns the user's sticker code.


# **getMyStickerCode**
> MyStickerCode getMyStickerCode()

My sticker code, earned by finishing the expo challenge or lighting a first lamp. null until earned.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExpoApi();

try {
    final result = api_instance.getMyStickerCode();
    print(result);
} catch (e) {
    print('Exception when calling ExpoApi->getMyStickerCode: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MyStickerCode**](MyStickerCode.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **redeemStickerCode**
> StickerCodeRedeemed redeemStickerCode(idempotencyKey, redeemStickerCodeBody)

Staff check a visitor's code and mark it used (one sticker per code). Role OPS, ADMIN or SUPPORT_AGENT. Audited.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExpoApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final redeemStickerCodeBody = RedeemStickerCodeBody(); // RedeemStickerCodeBody | 

try {
    final result = api_instance.redeemStickerCode(idempotencyKey, redeemStickerCodeBody);
    print(result);
} catch (e) {
    print('Exception when calling ExpoApi->redeemStickerCode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **redeemStickerCodeBody** | [**RedeemStickerCodeBody**](RedeemStickerCodeBody.md)|  | [optional] 

### Return type

[**StickerCodeRedeemed**](StickerCodeRedeemed.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startExpoChallenge**
> ExpoChallenge startExpoChallenge()

Start a 10-question stall challenge (guests allowed). Answers are never sent; the challenge expires in 15 minutes.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExpoApi();

try {
    final result = api_instance.startExpoChallenge();
    print(result);
} catch (e) {
    print('Exception when calling ExpoApi->startExpoChallenge: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ExpoChallenge**](ExpoChallenge.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitExpoChallenge**
> ExpoChallengeResult submitExpoChallenge(challengeId, idempotencyKey, submitExpoChallengeBody)

Grade once on the server. Finishing (any score) earns the user's sticker code.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExpoApi();
final challengeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final submitExpoChallengeBody = SubmitExpoChallengeBody(); // SubmitExpoChallengeBody | 

try {
    final result = api_instance.submitExpoChallenge(challengeId, idempotencyKey, submitExpoChallengeBody);
    print(result);
} catch (e) {
    print('Exception when calling ExpoApi->submitExpoChallenge: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **challengeId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **submitExpoChallengeBody** | [**SubmitExpoChallengeBody**](SubmitExpoChallengeBody.md)|  | [optional] 

### Return type

[**ExpoChallengeResult**](ExpoChallengeResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

