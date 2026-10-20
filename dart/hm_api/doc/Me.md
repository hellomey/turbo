# hm_api.model.Me

## Load the model package
```dart
import 'package:hm_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**email** | **String** |  | 
**nickname** | **String** |  | 
**district** | [**District**](District.md) |  | 
**calmMode** | **bool** |  | 
**liteMode** | **bool** | null = automatic (3 GB RAM or less) | 
**hideFromLeaderboards** | **bool** |  | 
**profile** | [**ProfileAnswers**](ProfileAnswers.md) |  | 
**roles** | [**List<Role>**](Role.md) |  | [default to const []]
**deletionScheduledFor** | [**DateTime**](DateTime.md) |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


