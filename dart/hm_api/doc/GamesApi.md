# hm_api.api.GamesApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDailySpin**](GamesApi.md#getdailyspin) | **GET** /v1/games/daily-spin | The published prize table with exact odds, and whether today's free spin is used.
[**getGameRules**](GamesApi.md#getgamerules) | **GET** /v1/games/rules | Game Rules & Odds: the Daily Spin prize table with exact odds, Confidence Duel scoring, limits and sleep hours.
[**spinDailySpin**](GamesApi.md#spindailyspin) | **POST** /v1/games/daily-spin | Today's one free spin (IST day). The server draws with a CSPRNG. A second call the same day returns the same prize.
[**startConfidenceDuel**](GamesApi.md#startconfidenceduel) | **GET** /v1/games/confidence-duel | Start a solo duel against the clock: 5 published practice questions (no answers) and the scoring rules.
[**submitConfidenceDuel**](GamesApi.md#submitconfidenceduel) | **POST** /v1/games/confidence-duel/{duelId}/submit | Submit answers with a confidence (1 to 3) each. The server grades and scores calibration; Points are capped per day.


# **getDailySpin**
> DailySpinState getDailySpin()

The published prize table with exact odds, and whether today's free spin is used.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GamesApi();

try {
    final result = api_instance.getDailySpin();
    print(result);
} catch (e) {
    print('Exception when calling GamesApi->getDailySpin: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DailySpinState**](DailySpinState.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGameRules**
> GameRules getGameRules()

Game Rules & Odds: the Daily Spin prize table with exact odds, Confidence Duel scoring, limits and sleep hours.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = GamesApi();

try {
    final result = api_instance.getGameRules();
    print(result);
} catch (e) {
    print('Exception when calling GamesApi->getGameRules: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GameRules**](GameRules.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **spinDailySpin**
> DailySpinResult spinDailySpin(idempotencyKey)

Today's one free spin (IST day). The server draws with a CSPRNG. A second call the same day returns the same prize.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GamesApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.spinDailySpin(idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling GamesApi->spinDailySpin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 

### Return type

[**DailySpinResult**](DailySpinResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startConfidenceDuel**
> ConfidenceDuel startConfidenceDuel(examCode)

Start a solo duel against the clock: 5 published practice questions (no answers) and the scoring rules.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GamesApi();
final examCode = examCode_example; // String | 

try {
    final result = api_instance.startConfidenceDuel(examCode);
    print(result);
} catch (e) {
    print('Exception when calling GamesApi->startConfidenceDuel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 

### Return type

[**ConfidenceDuel**](ConfidenceDuel.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitConfidenceDuel**
> DuelResult submitConfidenceDuel(duelId, idempotencyKey, submitDuelBody)

Submit answers with a confidence (1 to 3) each. The server grades and scores calibration; Points are capped per day.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GamesApi();
final duelId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final submitDuelBody = SubmitDuelBody(); // SubmitDuelBody | 

try {
    final result = api_instance.submitConfidenceDuel(duelId, idempotencyKey, submitDuelBody);
    print(result);
} catch (e) {
    print('Exception when calling GamesApi->submitConfidenceDuel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **duelId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **submitDuelBody** | [**SubmitDuelBody**](SubmitDuelBody.md)|  | [optional] 

### Return type

[**DuelResult**](DuelResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

