# hm_api.api.SyllabusApi

## Load the API package
```dart
import 'package:hm_api/api.dart';
```

All URIs are relative to *https://api.heymey.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getStudyMap**](SyllabusApi.md#getstudymap) | **GET** /v1/exams/{code}/study-map | 
[**searchGlossary**](SyllabusApi.md#searchglossary) | **GET** /v1/glossary | 


# **getStudyMap**
> StudyMap getStudyMap(code)



### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = SyllabusApi();
final code = code_example; // String | 

try {
    final result = api_instance.getStudyMap(code);
    print(result);
} catch (e) {
    print('Exception when calling SyllabusApi->getStudyMap: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**|  | 

### Return type

[**StudyMap**](StudyMap.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchGlossary**
> GlossaryList searchGlossary(q)



### Example
```dart
import 'package:hm_api/api.dart';

final api_instance = SyllabusApi();
final q = q_example; // String | 

try {
    final result = api_instance.searchGlossary(q);
    print(result);
} catch (e) {
    print('Exception when calling SyllabusApi->searchGlossary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] 

### Return type

[**GlossaryList**](GlossaryList.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

