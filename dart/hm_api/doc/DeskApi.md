# hm_api.api.DeskApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approveExamChange**](DeskApi.md#approveexamchange) | **POST** /v1/desk/exam-changes/{changeId}/approve | Human-approved: publishes an Exam Alert (exams.notification_published) to followers. Audited.
[**enrollDeskTotp**](DeskApi.md#enrolldesktotp) | **POST** /v1/auth/desk/totp/enroll | First Desk sign-in: create the authenticator secret for this staff/partner account.
[**listExamChanges**](DeskApi.md#listexamchanges) | **GET** /v1/desk/exam-changes | Ops queue of official-site changes waiting for a human check. Role OPS or ADMIN (checked in the handler).
[**rejectExamChange**](DeskApi.md#rejectexamchange) | **POST** /v1/desk/exam-changes/{changeId}/reject | 
[**verifyDeskTotp**](DeskApi.md#verifydesktotp) | **POST** /v1/auth/desk/totp/verify | Complete Desk sign-in with the authenticator code.


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

final api_instance = DeskApi();
final changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final approveExamChangeBody = ApproveExamChangeBody(); // ApproveExamChangeBody | 

try {
    final result = api_instance.approveExamChange(changeId, idempotencyKey, approveExamChangeBody);
    print(result);
} catch (e) {
    print('Exception when calling DeskApi->approveExamChange: $e\n');
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

# **enrollDeskTotp**
> DeskTotpEnrollResponse enrollDeskTotp(idempotencyKey, deskTotpEnrollBody)

First Desk sign-in: create the authenticator secret for this staff/partner account.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = DeskApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deskTotpEnrollBody = DeskTotpEnrollBody(); // DeskTotpEnrollBody | 

try {
    final result = api_instance.enrollDeskTotp(idempotencyKey, deskTotpEnrollBody);
    print(result);
} catch (e) {
    print('Exception when calling DeskApi->enrollDeskTotp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **deskTotpEnrollBody** | [**DeskTotpEnrollBody**](DeskTotpEnrollBody.md)|  | [optional] 

### Return type

[**DeskTotpEnrollResponse**](DeskTotpEnrollResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
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

final api_instance = DeskApi();
final status = ; // ExamChangeStatus | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listExamChanges(status, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling DeskApi->listExamChanges: $e\n');
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

final api_instance = DeskApi();
final changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final rejectExamChangeBody = RejectExamChangeBody(); // RejectExamChangeBody | 

try {
    final result = api_instance.rejectExamChange(changeId, idempotencyKey, rejectExamChangeBody);
    print(result);
} catch (e) {
    print('Exception when calling DeskApi->rejectExamChange: $e\n');
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

# **verifyDeskTotp**
> SessionGranted verifyDeskTotp(idempotencyKey, deskTotpVerifyBody)

Complete Desk sign-in with the authenticator code.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = DeskApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deskTotpVerifyBody = DeskTotpVerifyBody(); // DeskTotpVerifyBody | 

try {
    final result = api_instance.verifyDeskTotp(idempotencyKey, deskTotpVerifyBody);
    print(result);
} catch (e) {
    print('Exception when calling DeskApi->verifyDeskTotp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **deskTotpVerifyBody** | [**DeskTotpVerifyBody**](DeskTotpVerifyBody.md)|  | [optional] 

### Return type

[**SessionGranted**](SessionGranted.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

