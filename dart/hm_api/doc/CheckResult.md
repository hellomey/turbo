# hm_api.model.CheckResult

## Load the model package
```dart
import 'package:hm_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**checkId** | **String** |  | 
**kind** | [**CheckKind**](CheckKind.md) |  | 
**passed** | **bool** |  | 
**correct** | **int** |  | 
**total** | **int** |  | 
**lateAnswersIgnored** | **int** |  | 
**graded** | [**List<GradedAnswer>**](GradedAnswer.md) |  | [default to const []]
**topicState** | [**TopicState**](TopicState.md) |  | 
**rankUp** | [**RankChange**](RankChange.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


