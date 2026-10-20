# hm_api.api.AuthApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteAccount**](AuthApi.md#deleteaccount) | **POST** /v1/auth/delete-account | Confirm account deletion with a `delete_account` code. 7-day grace period (§38.7).
[**enrollDeskTotp**](AuthApi.md#enrolldesktotp) | **POST** /v1/auth/desk/totp/enroll | First Desk sign-in: create the authenticator secret for this staff/partner account.
[**logout**](AuthApi.md#logout) | **POST** /v1/auth/logout | End this session.
[**logoutAll**](AuthApi.md#logoutall) | **POST** /v1/auth/logout-all | Log out of all devices.
[**refreshSession**](AuthApi.md#refreshsession) | **POST** /v1/auth/refresh | Rotate the refresh token. Re-using an old one revokes the whole session family.
[**requestOtp**](AuthApi.md#requestotp) | **POST** /v1/auth/otp/request | Send a 6-digit code. Always 200: never reveals whether the email has an account.
[**verifyDeskTotp**](AuthApi.md#verifydesktotp) | **POST** /v1/auth/desk/totp/verify | Complete Desk sign-in with the authenticator code.
[**verifyOtp**](AuthApi.md#verifyotp) | **POST** /v1/auth/otp/verify | Exchange email + code for a session bound to this device (or a Desk 2FA challenge).


# **deleteAccount**
> DeleteAccountResponse deleteAccount(idempotencyKey, deleteAccountBody)

Confirm account deletion with a `delete_account` code. 7-day grace period (§38.7).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deleteAccountBody = DeleteAccountBody(); // DeleteAccountBody | 

try {
    final result = api_instance.deleteAccount(idempotencyKey, deleteAccountBody);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->deleteAccount: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **deleteAccountBody** | [**DeleteAccountBody**](DeleteAccountBody.md)|  | [optional] 

### Return type

[**DeleteAccountResponse**](DeleteAccountResponse.md)

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

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deskTotpEnrollBody = DeskTotpEnrollBody(); // DeskTotpEnrollBody | 

try {
    final result = api_instance.enrollDeskTotp(idempotencyKey, deskTotpEnrollBody);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->enrollDeskTotp: $e\n');
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

# **logout**
> OkResponse logout(idempotencyKey)

End this session.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.logout(idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->logout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 

### Return type

[**OkResponse**](OkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutAll**
> OkResponse logoutAll(idempotencyKey)

Log out of all devices.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.logoutAll(idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->logoutAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 

### Return type

[**OkResponse**](OkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshSession**
> TokenPair refreshSession(idempotencyKey, refreshBody)

Rotate the refresh token. Re-using an old one revokes the whole session family.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final refreshBody = RefreshBody(); // RefreshBody | 

try {
    final result = api_instance.refreshSession(idempotencyKey, refreshBody);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->refreshSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **refreshBody** | [**RefreshBody**](RefreshBody.md)|  | [optional] 

### Return type

[**TokenPair**](TokenPair.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestOtp**
> OtpRequestResponse requestOtp(idempotencyKey, otpRequestBody)

Send a 6-digit code. Always 200: never reveals whether the email has an account.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final otpRequestBody = OtpRequestBody(); // OtpRequestBody | 

try {
    final result = api_instance.requestOtp(idempotencyKey, otpRequestBody);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->requestOtp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **otpRequestBody** | [**OtpRequestBody**](OtpRequestBody.md)|  | [optional] 

### Return type

[**OtpRequestResponse**](OtpRequestResponse.md)

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

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deskTotpVerifyBody = DeskTotpVerifyBody(); // DeskTotpVerifyBody | 

try {
    final result = api_instance.verifyDeskTotp(idempotencyKey, deskTotpVerifyBody);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->verifyDeskTotp: $e\n');
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

# **verifyOtp**
> OtpVerifyResponse verifyOtp(idempotencyKey, otpVerifyBody)

Exchange email + code for a session bound to this device (or a Desk 2FA challenge).

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = AuthApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final otpVerifyBody = OtpVerifyBody(); // OtpVerifyBody | 

try {
    final result = api_instance.verifyOtp(idempotencyKey, otpVerifyBody);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->verifyOtp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **otpVerifyBody** | [**OtpVerifyBody**](OtpVerifyBody.md)|  | [optional] 

### Return type

[**OtpVerifyResponse**](OtpVerifyResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

