# hm_api.api.EconomyApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**checkIn**](EconomyApi.md#checkin) | **POST** /v1/me/check-in | Daily check-in, once per IST day: small XP + Points. Missing a day resets nothing.
[**getMyProgress**](EconomyApi.md#getmyprogress) | **GET** /v1/me/progress | XP and level (from learning only), Points (never bought) and trophies.
[**getWeeklyLeaderboard**](EconomyApi.md#getweeklyleaderboard) | **GET** /v1/leaderboard/weekly | This IST week's XP. Only real users who opted in, by nickname. Guests never appear.
[**putLeaderboardOptIn**](EconomyApi.md#putleaderboardoptin) | **PUT** /v1/me/leaderboard-opt-in | Join or leave the weekly leaderboard (off by default). Guests get GUEST_NOT_ALLOWED when joining.


# **checkIn**
> CheckInResult checkIn(idempotencyKey)

Daily check-in, once per IST day: small XP + Points. Missing a day resets nothing.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = EconomyApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.checkIn(idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling EconomyApi->checkIn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 

### Return type

[**CheckInResult**](CheckInResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyProgress**
> MyProgress getMyProgress()

XP and level (from learning only), Points (never bought) and trophies.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = EconomyApi();

try {
    final result = api_instance.getMyProgress();
    print(result);
} catch (e) {
    print('Exception when calling EconomyApi->getMyProgress: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MyProgress**](MyProgress.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getWeeklyLeaderboard**
> WeeklyLeaderboard getWeeklyLeaderboard()

This IST week's XP. Only real users who opted in, by nickname. Guests never appear.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = EconomyApi();

try {
    final result = api_instance.getWeeklyLeaderboard();
    print(result);
} catch (e) {
    print('Exception when calling EconomyApi->getWeeklyLeaderboard: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**WeeklyLeaderboard**](WeeklyLeaderboard.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putLeaderboardOptIn**
> LeaderboardOptIn putLeaderboardOptIn(idempotencyKey, leaderboardOptInBody)

Join or leave the weekly leaderboard (off by default). Guests get GUEST_NOT_ALLOWED when joining.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = EconomyApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final leaderboardOptInBody = LeaderboardOptInBody(); // LeaderboardOptInBody | 

try {
    final result = api_instance.putLeaderboardOptIn(idempotencyKey, leaderboardOptInBody);
    print(result);
} catch (e) {
    print('Exception when calling EconomyApi->putLeaderboardOptIn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **leaderboardOptInBody** | [**LeaderboardOptInBody**](LeaderboardOptInBody.md)|  | [optional] 

### Return type

[**LeaderboardOptIn**](LeaderboardOptIn.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

