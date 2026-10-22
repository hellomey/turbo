# hm_api.api.WebhooksApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**receiveSiteChange**](WebhooksApi.md#receivesitechange) | **POST** /v1/webhooks/changedetection | changedetection.io site-change webhook. Stores a pending change; NOTHING is sent to users (§17.5).


# **receiveSiteChange**
> SiteChangeAck receiveSiteChange(xHeymeyWebhookSecret, siteChangeWebhookBody)

changedetection.io site-change webhook. Stores a pending change; NOTHING is sent to users (§17.5).

### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = WebhooksApi();
final xHeymeyWebhookSecret = xHeymeyWebhookSecret_example; // String | 
final siteChangeWebhookBody = SiteChangeWebhookBody(); // SiteChangeWebhookBody | 

try {
    final result = api_instance.receiveSiteChange(xHeymeyWebhookSecret, siteChangeWebhookBody);
    print(result);
} catch (e) {
    print('Exception when calling WebhooksApi->receiveSiteChange: $e\n');
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

