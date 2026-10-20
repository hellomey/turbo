# hm_api.api.ContentApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getLesson**](ContentApi.md#getlesson) | **GET** /v1/topics/{topicId}/lesson | 


# **getLesson**
> Lesson getLesson(topicId)



### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = ContentApi();
final topicId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getLesson(topicId);
    print(result);
} catch (e) {
    print('Exception when calling ContentApi->getLesson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **topicId** | **String**|  | 

### Return type

[**Lesson**](Lesson.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

