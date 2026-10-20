# hm_api.model.TokenPair

## Load the model package
```dart
import 'package:hm_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accessToken** | **String** | JWT (EdDSA), 15 minutes | 
**refreshToken** | **String** | Opaque, rotates on every use. 60 days (app), 12 hours (Desk) | 
**accessTokenExpiresAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


