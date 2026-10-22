# hm_api.model.MockAttemptState

## Load the model package
```dart
import 'package:hm_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**attemptId** | **String** |  | 
**mock** | [**MockSummary**](MockSummary.md) |  | 
**mode** | [**MockMode**](MockMode.md) |  | 
**status** | **String** |  | 
**startedAt** | [**DateTime**](DateTime.md) |  | 
**deadlineAt** | [**DateTime**](DateTime.md) |  | 
**serverNow** | [**DateTime**](DateTime.md) |  | 
**sections** | [**List<MockSectionView>**](MockSectionView.md) |  | [default to const []]
**questions** | [**List<Question>**](Question.md) |  | [default to const []]
**answers** | [**List<SavedMockAnswer>**](SavedMockAnswer.md) |  | [default to const []]
**ranked** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


