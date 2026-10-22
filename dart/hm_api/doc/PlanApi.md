# hm_api.api.PlanApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMyPlan**](PlanApi.md#getmyplan) | **GET** /v1/me/plan | 
[**getPlanDays**](PlanApi.md#getplandays) | **GET** /v1/me/plan/days | Calendar view (max 62 days per request).
[**getToday**](PlanApi.md#gettoday) | **GET** /v1/me/today | 
[**putMyPlan**](PlanApi.md#putmyplan) | **PUT** /v1/me/plan | Create or change My Plan from study hours; exam dates come from `exams` (§17.1 step 9).
[**rebalanceMyPlan**](PlanApi.md#rebalancemyplan) | **POST** /v1/me/plan/rebalance | 
[**updatePlanItem**](PlanApi.md#updateplanitem) | **POST** /v1/me/plan/items/{itemId}/status | 


# **getMyPlan**
> Plan getMyPlan()



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PlanApi();

try {
    final result = api_instance.getMyPlan();
    print(result);
} catch (e) {
    print('Exception when calling PlanApi->getMyPlan: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Plan**](Plan.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlanDays**
> PlanDays getPlanDays(from, to)

Calendar view (max 62 days per request).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PlanApi();
final from = 2013-10-20; // DateTime | 
final to = 2013-10-20; // DateTime | 

try {
    final result = api_instance.getPlanDays(from, to);
    print(result);
} catch (e) {
    print('Exception when calling PlanApi->getPlanDays: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **from** | **DateTime**|  | 
 **to** | **DateTime**|  | 

### Return type

[**PlanDays**](PlanDays.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getToday**
> TodayScreen getToday()



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PlanApi();

try {
    final result = api_instance.getToday();
    print(result);
} catch (e) {
    print('Exception when calling PlanApi->getToday: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**TodayScreen**](TodayScreen.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putMyPlan**
> Plan putMyPlan(idempotencyKey, putPlanBody)

Create or change My Plan from study hours; exam dates come from `exams` (§17.1 step 9).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PlanApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final putPlanBody = PutPlanBody(); // PutPlanBody | 

try {
    final result = api_instance.putMyPlan(idempotencyKey, putPlanBody);
    print(result);
} catch (e) {
    print('Exception when calling PlanApi->putMyPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **putPlanBody** | [**PutPlanBody**](PutPlanBody.md)|  | [optional] 

### Return type

[**Plan**](Plan.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rebalanceMyPlan**
> Plan rebalanceMyPlan(idempotencyKey)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PlanApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.rebalanceMyPlan(idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling PlanApi->rebalanceMyPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 

### Return type

[**Plan**](Plan.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlanItem**
> PlanItem updatePlanItem(itemId, idempotencyKey, updatePlanItemBody)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PlanApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final updatePlanItemBody = UpdatePlanItemBody(); // UpdatePlanItemBody | 

try {
    final result = api_instance.updatePlanItem(itemId, idempotencyKey, updatePlanItemBody);
    print(result);
} catch (e) {
    print('Exception when calling PlanApi->updatePlanItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **updatePlanItemBody** | [**UpdatePlanItemBody**](UpdatePlanItemBody.md)|  | [optional] 

### Return type

[**PlanItem**](PlanItem.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

