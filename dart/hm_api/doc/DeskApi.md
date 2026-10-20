# hm_api.api.DeskApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**enrollDeskTotp**](DeskApi.md#enrolldesktotp) | **POST** /v1/auth/desk/totp/enroll | First Desk sign-in: create the authenticator secret for this staff/partner account.
[**verifyDeskTotp**](DeskApi.md#verifydesktotp) | **POST** /v1/auth/desk/totp/verify | Complete Desk sign-in with the authenticator code.


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

