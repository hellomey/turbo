# hm_api.model.Plan

## Load the model package
```dart
import 'package:hm_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**weekdayMinutes** | **int** |  | 
**weekendMinutes** | **int** |  | 
**pocketMinutes** | **int** |  | 
**balance** | **int** |  | 
**exams** | [**List<PlanExam>**](PlanExam.md) |  | [default to const []]
**stretch** | [**StretchPhase**](StretchPhase.md) |  | 
**starterPathUntil** | [**DateTime**](DateTime.md) |  | 
**lastRebalancedAt** | [**DateTime**](DateTime.md) |  | 
**configVersion** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


