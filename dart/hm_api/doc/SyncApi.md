# hm_api.api.SyncApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**syncStudyActions**](SyncApi.md#syncstudyactions) | **POST** /v1/sync/study-actions | Offline outbox batch (§39). Each clientActionId is accepted once; returns authoritative lamp states.


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

final api_instance = SyncApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final syncBatchBody = SyncBatchBody(); // SyncBatchBody | 

try {
    final result = api_instance.syncStudyActions(idempotencyKey, syncBatchBody);
    print(result);
} catch (e) {
    print('Exception when calling SyncApi->syncStudyActions: $e\n');
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

