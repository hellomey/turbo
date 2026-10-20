# hm_api.api.UsersApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getConsentNotice**](UsersApi.md#getconsentnotice) | **GET** /v1/consents/notice | The current DPDP notice: purposes, which are required, nothing pre-ticked.
[**getMe**](UsersApi.md#getme) | **GET** /v1/me | 
[**getMyConsents**](UsersApi.md#getmyconsents) | **GET** /v1/me/consents | 
[**putProfile**](UsersApi.md#putprofile) | **PUT** /v1/me/profile | Save the onboarding eligibility answers. Under 18 is refused (UNDER_18).
[**recordConsents**](UsersApi.md#recordconsents) | **POST** /v1/me/consents | 
[**updateMe**](UsersApi.md#updateme) | **PATCH** /v1/me | 


# **getConsentNotice**
> ConsentNotice getConsentNotice()

The current DPDP notice: purposes, which are required, nothing pre-ticked.

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = UsersApi();

try {
    final result = api_instance.getConsentNotice();
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->getConsentNotice: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ConsentNotice**](ConsentNotice.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> Me getMe()



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();

try {
    final result = api_instance.getMe();
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Me**](Me.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyConsents**
> ConsentState getMyConsents()



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();

try {
    final result = api_instance.getMyConsents();
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->getMyConsents: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ConsentState**](ConsentState.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putProfile**
> Me putProfile(idempotencyKey, profileAnswers)

Save the onboarding eligibility answers. Under 18 is refused (UNDER_18).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final profileAnswers = ProfileAnswers(); // ProfileAnswers | 

try {
    final result = api_instance.putProfile(idempotencyKey, profileAnswers);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->putProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **profileAnswers** | [**ProfileAnswers**](ProfileAnswers.md)|  | [optional] 

### Return type

[**Me**](Me.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordConsents**
> ConsentState recordConsents(idempotencyKey, consentChoicesBody)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final consentChoicesBody = ConsentChoicesBody(); // ConsentChoicesBody | 

try {
    final result = api_instance.recordConsents(idempotencyKey, consentChoicesBody);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->recordConsents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **consentChoicesBody** | [**ConsentChoicesBody**](ConsentChoicesBody.md)|  | [optional] 

### Return type

[**ConsentState**](ConsentState.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMe**
> Me updateMe(idempotencyKey, updateMeBody)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final updateMeBody = UpdateMeBody(); // UpdateMeBody | 

try {
    final result = api_instance.updateMe(idempotencyKey, updateMeBody);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->updateMe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **updateMeBody** | [**UpdateMeBody**](UpdateMeBody.md)|  | [optional] 

### Return type

[**Me**](Me.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

