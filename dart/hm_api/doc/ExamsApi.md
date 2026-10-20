# hm_api.api.ExamsApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**checkEligibility**](ExamsApi.md#checkeligibility) | **POST** /v1/eligibility/check | Eligibility Checker. A pure computation: nothing is stored. Under 18 returns UNDER_18.
[**getExam**](ExamsApi.md#getexam) | **GET** /v1/exams/{code} | 
[**getMyExams**](ExamsApi.md#getmyexams) | **GET** /v1/me/exams | 
[**listExams**](ExamsApi.md#listexams) | **GET** /v1/exams | 
[**putMyExams**](ExamsApi.md#putmyexams) | **PUT** /v1/me/exams | 


# **checkEligibility**
> EligibilityResult checkEligibility(eligibilityCheckBody)

Eligibility Checker. A pure computation: nothing is stored. Under 18 returns UNDER_18.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ExamsApi();
final eligibilityCheckBody = EligibilityCheckBody(); // EligibilityCheckBody | 

try {
    final result = api_instance.checkEligibility(eligibilityCheckBody);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->checkEligibility: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **eligibilityCheckBody** | [**EligibilityCheckBody**](EligibilityCheckBody.md)|  | [optional] 

### Return type

[**EligibilityResult**](EligibilityResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExam**
> ExamDetail getExam(code)



### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ExamsApi();
final code = code_example; // String | 

try {
    final result = api_instance.getExam(code);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->getExam: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**|  | 

### Return type

[**ExamDetail**](ExamDetail.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyExams**
> UserExams getMyExams()



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamsApi();

try {
    final result = api_instance.getMyExams();
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->getMyExams: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserExams**](UserExams.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExams**
> ExamList listExams()



### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ExamsApi();

try {
    final result = api_instance.listExams();
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->listExams: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ExamList**](ExamList.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putMyExams**
> UserExams putMyExams(idempotencyKey, userExamsBody)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ExamsApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final userExamsBody = UserExamsBody(); // UserExamsBody | 

try {
    final result = api_instance.putMyExams(idempotencyKey, userExamsBody);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->putMyExams: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **userExamsBody** | [**UserExamsBody**](UserExamsBody.md)|  | [optional] 

### Return type

[**UserExams**](UserExams.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

