# hm_api.api.ReadinessApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMyReadiness**](ReadinessApi.md#getmyreadiness) | **GET** /v1/me/readiness | Four evidence bars + a plain label. Never one overall percentage.
[**getMyReadinessTrend**](ReadinessApi.md#getmyreadinesstrend) | **GET** /v1/me/readiness/trend | 7/30/90-day trends (Pro: PRO_REQUIRED for free users).
[**getSundayReport**](ReadinessApi.md#getsundayreport) | **GET** /v1/me/sunday-reports/{reportId} | 
[**listMySundayReports**](ReadinessApi.md#listmysundayreports) | **GET** /v1/me/sunday-reports | 


# **getMyReadiness**
> ReadinessMeter getMyReadiness(examCode)

Four evidence bars + a plain label. Never one overall percentage.

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReadinessApi();
final examCode = examCode_example; // String | 

try {
    final result = api_instance.getMyReadiness(examCode);
    print(result);
} catch (e) {
    print('Exception when calling ReadinessApi->getMyReadiness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 

### Return type

[**ReadinessMeter**](ReadinessMeter.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyReadinessTrend**
> ReadinessTrend getMyReadinessTrend(examCode, days)

7/30/90-day trends (Pro: PRO_REQUIRED for free users).

### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReadinessApi();
final examCode = examCode_example; // String | 
final days = 56; // int | 

try {
    final result = api_instance.getMyReadinessTrend(examCode, days);
    print(result);
} catch (e) {
    print('Exception when calling ReadinessApi->getMyReadinessTrend: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **examCode** | **String**|  | 
 **days** | **int**|  | [optional] [default to 30]

### Return type

[**ReadinessTrend**](ReadinessTrend.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSundayReport**
> SundayReport getSundayReport(reportId)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReadinessApi();
final reportId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getSundayReport(reportId);
    print(result);
} catch (e) {
    print('Exception when calling ReadinessApi->getSundayReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reportId** | **String**|  | 

### Return type

[**SundayReport**](SundayReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMySundayReports**
> SundayReportPage listMySundayReports(cursor, limit)



### Example
```dart
import 'package:hm_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReadinessApi();
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listMySundayReports(cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling ReadinessApi->listMySundayReports: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**SundayReportPage**](SundayReportPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

