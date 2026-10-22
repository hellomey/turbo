# hm_api.api.NotificationsApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deletePushToken**](NotificationsApi.md#deletepushtoken) | **DELETE** /v1/me/push-tokens/{deviceId} | 
[**getAlertSettings**](NotificationsApi.md#getalertsettings) | **GET** /v1/me/alert-settings | 
[**putAlertSettings**](NotificationsApi.md#putalertsettings) | **PUT** /v1/me/alert-settings | Offers can be on only with the offers consent; dailyLimit is capped at 3.
[**registerPushToken**](NotificationsApi.md#registerpushtoken) | **POST** /v1/me/push-tokens | 


# **deletePushToken**
> OkResponse deletePushToken(deviceId, idempotencyKey)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = NotificationsApi();
final deviceId = deviceId_example; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.deletePushToken(deviceId, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling NotificationsApi->deletePushToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**|  | 
 **idempotencyKey** | **String**|  | 

### Return type

[**OkResponse**](OkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAlertSettings**
> AlertSettings getAlertSettings()



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = NotificationsApi();

try {
    final result = api_instance.getAlertSettings();
    print(result);
} catch (e) {
    print('Exception when calling NotificationsApi->getAlertSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AlertSettings**](AlertSettings.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putAlertSettings**
> AlertSettings putAlertSettings(idempotencyKey, putAlertSettingsBody)

Offers can be on only with the offers consent; dailyLimit is capped at 3.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = NotificationsApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final putAlertSettingsBody = PutAlertSettingsBody(); // PutAlertSettingsBody | 

try {
    final result = api_instance.putAlertSettings(idempotencyKey, putAlertSettingsBody);
    print(result);
} catch (e) {
    print('Exception when calling NotificationsApi->putAlertSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **putAlertSettingsBody** | [**PutAlertSettingsBody**](PutAlertSettingsBody.md)|  | [optional] 

### Return type

[**AlertSettings**](AlertSettings.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerPushToken**
> PushTokenAck registerPushToken(idempotencyKey, registerPushTokenBody)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = NotificationsApi();
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final registerPushTokenBody = RegisterPushTokenBody(); // RegisterPushTokenBody | 

try {
    final result = api_instance.registerPushToken(idempotencyKey, registerPushTokenBody);
    print(result);
} catch (e) {
    print('Exception when calling NotificationsApi->registerPushToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  | 
 **registerPushTokenBody** | [**RegisterPushTokenBody**](RegisterPushTokenBody.md)|  | [optional] 

### Return type

[**PushTokenAck**](PushTokenAck.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

