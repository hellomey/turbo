# hm_api.api.ContentApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getLesson**](ContentApi.md#getlesson) | **GET** /v1/topics/{topicId}/lesson | 
[**listContentPacks**](ContentApi.md#listcontentpacks) | **GET** /v1/content/packs | Offline packs for an exam with SHA-256 checksums (§39). Free users: free packs only.
[**reportQuestion**](ContentApi.md#reportquestion) | **POST** /v1/questions/{questionId}/reports | Report a problem with a question (§19.4 Q34). Goes to the content fix loop.


# **getLesson**
> Lesson getLesson(topicId)



### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ContentApi();
final topicId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getLesson(topicId);
    print(result);
} catch (e) {
    print('Exception when calling ContentApi->getLesson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **topicId** | **String**|  | 

### Return type

[**Lesson**](Lesson.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listContentPacks**
> ContentPackList listContentPacks(examCode)

Offline packs for an exam with SHA-256 checksums (§39). Free users: free packs only.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContentApi();
final examCode = examCode_example; // String | 

try {
    final result = api_instance.listContentPacks(examCode);
    print(result);
} catch (e) {
    print('Exception when calling ContentApi->listContentPacks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 

### Return type

[**ContentPackList**](ContentPackList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportQuestion**
> QuestionReportAck reportQuestion(questionId, idempotencyKey, questionReportBody)

Report a problem with a question (§19.4 Q34). Goes to the content fix loop.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContentApi();
final questionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final questionReportBody = QuestionReportBody(); // QuestionReportBody | 

try {
    final result = api_instance.reportQuestion(questionId, idempotencyKey, questionReportBody);
    print(result);
} catch (e) {
    print('Exception when calling ContentApi->reportQuestion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **questionId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **questionReportBody** | [**QuestionReportBody**](QuestionReportBody.md)|  | [optional] 

### Return type

[**QuestionReportAck**](QuestionReportAck.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

