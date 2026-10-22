# hm_api.model.Question

## Load the model package
```dart
import 'package:hm_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**version** | **int** |  | 
**topicId** | **String** |  | 
**kind** | [**QuestionKind**](QuestionKind.md) |  | 
**language** | [**ContentLanguage**](ContentLanguage.md) |  | 
**stem** | **String** |  | 
**options** | [**List<QuestionOption>**](QuestionOption.md) |  | [default to const []]
**difficulty** | **int** |  | 
**source_** | [**QuestionSource**](QuestionSource.md) |  | 
**affectedNote** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


