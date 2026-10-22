# hm_api.api.MasteryApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**completeLesson**](MasteryApi.md#completelesson) | **POST** /v1/topics/{topicId}/lesson-complete | I finished the lesson or the mapped textbook pages. Opens the 3-question Lit check.
[**getMyMastery**](MasteryApi.md#getmymastery) | **GET** /v1/me/mastery | Rank (from lamps only), XP and ring counts across my exams.
[**getRelightQueue**](MasteryApi.md#getrelightqueue) | **GET** /v1/me/relight-queue | Dimming lamps I can open, oldest first, with minutes (\"Relight 4 · 8 min\").
[**listMyTopicStates**](MasteryApi.md#listmytopicstates) | **GET** /v1/me/topic-states | Authoritative lamp states for one exam's map; `since` for incremental Drift sync.
[**startTopicCheck**](MasteryApi.md#starttopiccheck) | **POST** /v1/topics/{topicId}/checks | Start a Lit / recall / relight / Gold check. The server picks the questions and sets any deadline.
[**submitTopicCheck**](MasteryApi.md#submittopiccheck) | **POST** /v1/checks/{checkId}/submit | Grade a check on the server and move the rings. Late Gold answers are not counted.
[**syncStudyActions**](MasteryApi.md#syncstudyactions) | **POST** /v1/sync/study-actions | Offline outbox batch (§39). Each clientActionId is accepted once; returns authoritative lamp states.


# **completeLesson**
> TopicState completeLesson(topicId, idempotencyKey, lessonCompleteBody)

I finished the lesson or the mapped textbook pages. Opens the 3-question Lit check.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MasteryApi();
final topicId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final lessonCompleteBody = LessonCompleteBody(); // LessonCompleteBody | 

try {
    final result = api_instance.completeLesson(topicId, idempotencyKey, lessonCompleteBody);
    print(result);
} catch (e) {
    print('Exception when calling MasteryApi->completeLesson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **topicId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **lessonCompleteBody** | [**LessonCompleteBody**](LessonCompleteBody.md)|  | [optional] 

### Return type

[**TopicState**](TopicState.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyMastery**
> MasterySummary getMyMastery()

Rank (from lamps only), XP and ring counts across my exams.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MasteryApi();

try {
    final result = api_instance.getMyMastery();
    print(result);
} catch (e) {
    print('Exception when calling MasteryApi->getMyMastery: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MasterySummary**](MasterySummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRelightQueue**
> RelightQueue getRelightQueue()

Dimming lamps I can open, oldest first, with minutes (\"Relight 4 · 8 min\").

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MasteryApi();

try {
    final result = api_instance.getRelightQueue();
    print(result);
} catch (e) {
    print('Exception when calling MasteryApi->getRelightQueue: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RelightQueue**](RelightQueue.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMyTopicStates**
> TopicStatePage listMyTopicStates(examCode, since, cursor, limit)

Authoritative lamp states for one exam's map; `since` for incremental Drift sync.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MasteryApi();
final examCode = examCode_example; // String | 
final since = 2013-10-20T19:20:30+01:00; // DateTime | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listMyTopicStates(examCode, since, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling MasteryApi->listMyTopicStates: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 
 **since** | **DateTime**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 200]

### Return type

[**TopicStatePage**](TopicStatePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startTopicCheck**
> TopicCheck startTopicCheck(topicId, idempotencyKey, startCheckBody)

Start a Lit / recall / relight / Gold check. The server picks the questions and sets any deadline.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MasteryApi();
final topicId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final startCheckBody = StartCheckBody(); // StartCheckBody | 

try {
    final result = api_instance.startTopicCheck(topicId, idempotencyKey, startCheckBody);
    print(result);
} catch (e) {
    print('Exception when calling MasteryApi->startTopicCheck: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **topicId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **startCheckBody** | [**StartCheckBody**](StartCheckBody.md)|  | [optional] 

### Return type

[**TopicCheck**](TopicCheck.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitTopicCheck**
> CheckResult submitTopicCheck(checkId, idempotencyKey, submitCheckBody)

Grade a check on the server and move the rings. Late Gold answers are not counted.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MasteryApi();
final checkId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final submitCheckBody = SubmitCheckBody(); // SubmitCheckBody | 

try {
    final result = api_instance.submitTopicCheck(checkId, idempotencyKey, submitCheckBody);
    print(result);
} catch (e) {
    print('Exception when calling MasteryApi->submitTopicCheck: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **checkId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **submitCheckBody** | [**SubmitCheckBody**](SubmitCheckBody.md)|  | [optional] 

### Return type

[**CheckResult**](CheckResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncStudyActions**
> SyncBatchResult syncStudyActions(idempotencyKey, syncBatchBody)

Offline outbox batch (§39). Each clientActionId is accepted once; returns authoritative lamp states.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MasteryApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final syncBatchBody = SyncBatchBody(); // SyncBatchBody | 

try {
    final result = api_instance.syncStudyActions(idempotencyKey, syncBatchBody);
    print(result);
} catch (e) {
    print('Exception when calling MasteryApi->syncStudyActions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **syncBatchBody** | [**SyncBatchBody**](SyncBatchBody.md)|  | [optional] 

### Return type

[**SyncBatchResult**](SyncBatchResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

