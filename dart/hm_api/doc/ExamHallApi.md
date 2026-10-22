# hm_api.api.ExamHallApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMockAttempt**](ExamHallApi.md#getmockattempt) | **GET** /v1/mock-attempts/{attemptId} | Resume exactly where I left off, with server remaining time (§19.8 Q76).
[**getMockReport**](ExamHallApi.md#getmockreport) | **GET** /v1/mock-attempts/{attemptId}/report | 
[**getMyStatewideRank**](ExamHallApi.md#getmystatewiderank) | **GET** /v1/mocks/{mockId}/statewide-rank | My statewide rank. Only live, online, on-time attempts are ranked (§18, §39).
[**getStateMockSunday**](ExamHallApi.md#getstatemocksunday) | **GET** /v1/state-mock-sunday | The next State Mock Sunday for an exam (1st and 3rd Sunday, IST).
[**listMocks**](ExamHallApi.md#listmocks) | **GET** /v1/mocks | 
[**listMyMockAttempts**](ExamHallApi.md#listmymockattempts) | **GET** /v1/me/mock-attempts | 
[**saveMockAnswers**](ExamHallApi.md#savemockanswers) | **PUT** /v1/mock-attempts/{attemptId}/answers | Save answers (last write per question wins until the deadline). Late answers are ignored.
[**startMockAttempt**](ExamHallApi.md#startmockattempt) | **POST** /v1/mocks/{mockId}/attempts | Start (or return my in-progress) attempt. The server sets start time and deadline.
[**submitMockAttempt**](ExamHallApi.md#submitmockattempt) | **POST** /v1/mock-attempts/{attemptId}/submit | Submit and score on the server with the paper's marking scheme.


# **getMockAttempt**
> MockAttemptState getMockAttempt(attemptId)

Resume exactly where I left off, with server remaining time (§19.8 Q76).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getMockAttempt(attemptId);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->getMockAttempt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **attemptId** | **String**|  | 

### Return type

[**MockAttemptState**](MockAttemptState.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMockReport**
> MockReport getMockReport(attemptId)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getMockReport(attemptId);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->getMockReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **attemptId** | **String**|  | 

### Return type

[**MockReport**](MockReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyStatewideRank**
> StatewideRank getMyStatewideRank(mockId)

My statewide rank. Only live, online, on-time attempts are ranked (§18, §39).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final mockId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getMyStatewideRank(mockId);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->getMyStatewideRank: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mockId** | **String**|  | 

### Return type

[**StatewideRank**](StatewideRank.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStateMockSunday**
> StateMockInfo getStateMockSunday(examCode)

The next State Mock Sunday for an exam (1st and 3rd Sunday, IST).

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ExamHallApi();
final examCode = examCode_example; // String | 

try {
    final result = api_instance.getStateMockSunday(examCode);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->getStateMockSunday: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 

### Return type

[**StateMockInfo**](StateMockInfo.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMocks**
> MockList listMocks(examCode)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final examCode = examCode_example; // String | 

try {
    final result = api_instance.listMocks(examCode);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->listMocks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 

### Return type

[**MockList**](MockList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMyMockAttempts**
> MockAttemptPage listMyMockAttempts(cursor, limit)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listMyMockAttempts(cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->listMyMockAttempts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**MockAttemptPage**](MockAttemptPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveMockAnswers**
> MockAnswersSaved saveMockAnswers(attemptId, idempotencyKey, saveMockAnswersBody)

Save answers (last write per question wins until the deadline). Late answers are ignored.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final saveMockAnswersBody = SaveMockAnswersBody(); // SaveMockAnswersBody | 

try {
    final result = api_instance.saveMockAnswers(attemptId, idempotencyKey, saveMockAnswersBody);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->saveMockAnswers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **attemptId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **saveMockAnswersBody** | [**SaveMockAnswersBody**](SaveMockAnswersBody.md)|  | [optional] 

### Return type

[**MockAnswersSaved**](MockAnswersSaved.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startMockAttempt**
> MockAttemptState startMockAttempt(mockId, idempotencyKey, startMockBody)

Start (or return my in-progress) attempt. The server sets start time and deadline.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final mockId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final startMockBody = StartMockBody(); // StartMockBody | 

try {
    final result = api_instance.startMockAttempt(mockId, idempotencyKey, startMockBody);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->startMockAttempt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mockId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **startMockBody** | [**StartMockBody**](StartMockBody.md)|  | [optional] 

### Return type

[**MockAttemptState**](MockAttemptState.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitMockAttempt**
> MockReport submitMockAttempt(attemptId, idempotencyKey)

Submit and score on the server with the paper's marking scheme.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamHallApi();
final attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.submitMockAttempt(attemptId, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling ExamHallApi->submitMockAttempt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **attemptId** | **String**|  | 
 **idempotencyKey** | **String**|  | 

### Return type

[**MockReport**](MockReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

