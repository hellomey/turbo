# hm_api.model.MockReport

## Load the model package
```dart
import 'package:hm_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**attemptId** | **String** |  | 
**mockId** | **String** |  | 
**examCode** | **String** |  | 
**submittedAt** | [**DateTime**](DateTime.md) |  | 
**score** | [**Marks**](Marks.md) |  | 
**maxScore** | [**Marks**](Marks.md) |  | 
**scoreDisplay** | **String** |  | 
**markingSchemeVersion** | **int** |  | 
**correct** | **int** |  | 
**wrong** | **int** |  | 
**unanswered** | **int** |  | 
**sections** | [**List<SectionResult>**](SectionResult.md) |  | [default to const []]
**mistakes** | [**List<GradedAnswer>**](GradedAnswer.md) |  | [default to const []]
**weakTopicIds** | **List<String>** |  | [default to const []]
**ranked** | **bool** |  | 
**fullReportLocked** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


