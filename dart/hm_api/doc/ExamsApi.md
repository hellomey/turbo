# hm_api.api.ExamsApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approveExamChange**](ExamsApi.md#approveexamchange) | **POST** /v1/desk/exam-changes/{changeId}/approve | Human-approved: publishes an Exam Alert (exams.notification_published) to followers. Audited.
[**checkEligibility**](ExamsApi.md#checkeligibility) | **POST** /v1/eligibility/check | Eligibility Checker. A pure computation: nothing is stored. Under 18 returns UNDER_18.
[**getExam**](ExamsApi.md#getexam) | **GET** /v1/exams/{code} | 
[**getExamStructure**](ExamsApi.md#getexamstructure) | **GET** /v1/exams/{code}/structure | Stages, papers and marking schemes (exam-agnostic, ADR-0013). Unverified schemes say so.
[**getMyExams**](ExamsApi.md#getmyexams) | **GET** /v1/me/exams | 
[**listExamChanges**](ExamsApi.md#listexamchanges) | **GET** /v1/desk/exam-changes | Ops queue of official-site changes waiting for a human check. Role OPS or ADMIN (checked in the handler).
[**listExams**](ExamsApi.md#listexams) | **GET** /v1/exams | 
[**listMyExamAlerts**](ExamsApi.md#listmyexamalerts) | **GET** /v1/me/exam-alerts | Human-checked Exam Alerts for the exams I follow, newest first.
[**putMyExams**](ExamsApi.md#putmyexams) | **PUT** /v1/me/exams | 
[**receiveSiteChange**](ExamsApi.md#receivesitechange) | **POST** /v1/webhooks/changedetection | changedetection.io site-change webhook. Stores a pending change; NOTHING is sent to users (§17.5).
[**rejectExamChange**](ExamsApi.md#rejectexamchange) | **POST** /v1/desk/exam-changes/{changeId}/reject | 


# **approveExamChange**
> ExamChange approveExamChange(changeId, idempotencyKey, approveExamChangeBody)

Human-approved: publishes an Exam Alert (exams.notification_published) to followers. Audited.

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
final changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final approveExamChangeBody = ApproveExamChangeBody(); // ApproveExamChangeBody | 

try {
    final result = api_instance.approveExamChange(changeId, idempotencyKey, approveExamChangeBody);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->approveExamChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **approveExamChangeBody** | [**ApproveExamChangeBody**](ApproveExamChangeBody.md)|  | [optional] 

### Return type

[**ExamChange**](ExamChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

# **getExamStructure**
> ExamStructure getExamStructure(code)

Stages, papers and marking schemes (exam-agnostic, ADR-0013). Unverified schemes say so.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ExamsApi();
final code = code_example; // String | 

try {
    final result = api_instance.getExamStructure(code);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->getExamStructure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**|  | 

### Return type

[**ExamStructure**](ExamStructure.md)

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

# **listExamChanges**
> ExamChangePage listExamChanges(status, cursor, limit)

Ops queue of official-site changes waiting for a human check. Role OPS or ADMIN (checked in the handler).

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
final status = ; // ExamChangeStatus | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listExamChanges(status, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->listExamChanges: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**ExamChangeStatus**](.md)|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ExamChangePage**](ExamChangePage.md)

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

# **listMyExamAlerts**
> ExamAlertPage listMyExamAlerts(cursor, limit)

Human-checked Exam Alerts for the exams I follow, newest first.

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
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listMyExamAlerts(cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->listMyExamAlerts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ExamAlertPage**](ExamAlertPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

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

# **receiveSiteChange**
> SiteChangeAck receiveSiteChange(xHeymeyWebhookSecret, siteChangeWebhookBody)

changedetection.io site-change webhook. Stores a pending change; NOTHING is sent to users (§17.5).

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ExamsApi();
final xHeymeyWebhookSecret = xHeymeyWebhookSecret_example; // String | 
final siteChangeWebhookBody = SiteChangeWebhookBody(); // SiteChangeWebhookBody | 

try {
    final result = api_instance.receiveSiteChange(xHeymeyWebhookSecret, siteChangeWebhookBody);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->receiveSiteChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xHeymeyWebhookSecret** | **String**|  | 
 **siteChangeWebhookBody** | [**SiteChangeWebhookBody**](SiteChangeWebhookBody.md)|  | [optional] 

### Return type

[**SiteChangeAck**](SiteChangeAck.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectExamChange**
> ExamChange rejectExamChange(changeId, idempotencyKey, rejectExamChangeBody)



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
final changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final rejectExamChangeBody = RejectExamChangeBody(); // RejectExamChangeBody | 

try {
    final result = api_instance.rejectExamChange(changeId, idempotencyKey, rejectExamChangeBody);
    print(result);
} catch (e) {
    print('Exception when calling ExamsApi->rejectExamChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **rejectExamChangeBody** | [**RejectExamChangeBody**](RejectExamChangeBody.md)|  | [optional] 

### Return type

[**ExamChange**](ExamChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

