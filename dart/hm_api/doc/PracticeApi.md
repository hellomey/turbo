# hm_api.api.PracticeApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**answerPracticeQuestion**](PracticeApi.md#answerpracticequestion) | **POST** /v1/practice/sessions/{sessionId}/answers | Grade one answer. The 31st counted answer of the IST day returns PRACTICE_DAILY_LIMIT for free users.
[**getPracticeUsage**](PracticeApi.md#getpracticeusage) | **GET** /v1/me/practice/usage | 
[**getPyqFacets**](PracticeApi.md#getpyqfacets) | **GET** /v1/pyq/facets | 
[**listMyDrills**](PracticeApi.md#listmydrills) | **GET** /v1/me/drills | Concept drills from repeated mistakes (Pro, §19.6 Q60). `locked` for free users.
[**listMyMistakes**](PracticeApi.md#listmymistakes) | **GET** /v1/me/mistakes | Mistake review: why mine was wrong, why the answer is right, which lamp to relight (§19.4 Q38).
[**searchPyqs**](PracticeApi.md#searchpyqs) | **GET** /v1/pyq | PYQ Vault. Free: latest 2 exam years held for the exam; older years come back `locked`.
[**startPracticeSession**](PracticeApi.md#startpracticesession) | **POST** /v1/practice/sessions | Start practice, PYQ, mistakes or drill. Questions come without answers.


# **answerPracticeQuestion**
> PracticeAnswerResult answerPracticeQuestion(sessionId, idempotencyKey, practiceAnswerBody)

Grade one answer. The 31st counted answer of the IST day returns PRACTICE_DAILY_LIMIT for free users.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PracticeApi();
final sessionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final practiceAnswerBody = PracticeAnswerBody(); // PracticeAnswerBody | 

try {
    final result = api_instance.answerPracticeQuestion(sessionId, idempotencyKey, practiceAnswerBody);
    print(result);
} catch (e) {
    print('Exception when calling PracticeApi->answerPracticeQuestion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **practiceAnswerBody** | [**PracticeAnswerBody**](PracticeAnswerBody.md)|  | [optional] 

### Return type

[**PracticeAnswerResult**](PracticeAnswerResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPracticeUsage**
> PracticeUsage getPracticeUsage()



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PracticeApi();

try {
    final result = api_instance.getPracticeUsage();
    print(result);
} catch (e) {
    print('Exception when calling PracticeApi->getPracticeUsage: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PracticeUsage**](PracticeUsage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPyqFacets**
> PyqFacets getPyqFacets(examCode)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PracticeApi();
final examCode = examCode_example; // String | 

try {
    final result = api_instance.getPyqFacets(examCode);
    print(result);
} catch (e) {
    print('Exception when calling PracticeApi->getPyqFacets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 

### Return type

[**PyqFacets**](PyqFacets.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMyDrills**
> ConceptDrillList listMyDrills()

Concept drills from repeated mistakes (Pro, §19.6 Q60). `locked` for free users.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PracticeApi();

try {
    final result = api_instance.listMyDrills();
    print(result);
} catch (e) {
    print('Exception when calling PracticeApi->listMyDrills: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ConceptDrillList**](ConceptDrillList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMyMistakes**
> MistakePage listMyMistakes(cursor, limit)

Mistake review: why mine was wrong, why the answer is right, which lamp to relight (§19.4 Q38).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PracticeApi();
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listMyMistakes(cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PracticeApi->listMyMistakes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**MistakePage**](MistakePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchPyqs**
> PyqPage searchPyqs(examCode, year, subjectCode, topicId, difficulty, cursor, limit)

PYQ Vault. Free: latest 2 exam years held for the exam; older years come back `locked`.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PracticeApi();
final examCode = examCode_example; // String | 
final year = 56; // int | 
final subjectCode = subjectCode_example; // String | 
final topicId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final difficulty = 56; // int | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.searchPyqs(examCode, year, subjectCode, topicId, difficulty, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PracticeApi->searchPyqs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 
 **year** | **int**|  | [optional] 
 **subjectCode** | **String**|  | [optional] 
 **topicId** | **String**|  | [optional] 
 **difficulty** | **int**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**PyqPage**](PyqPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startPracticeSession**
> PracticeSession startPracticeSession(idempotencyKey, startPracticeBody)

Start practice, PYQ, mistakes or drill. Questions come without answers.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PracticeApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final startPracticeBody = StartPracticeBody(); // StartPracticeBody | 

try {
    final result = api_instance.startPracticeSession(idempotencyKey, startPracticeBody);
    print(result);
} catch (e) {
    print('Exception when calling PracticeApi->startPracticeSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **startPracticeBody** | [**StartPracticeBody**](StartPracticeBody.md)|  | [optional] 

### Return type

[**PracticeSession**](PracticeSession.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

