# relax_api_client.model.UserResponseDto

## Load the model package
```dart
import 'package:relax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**email** | **String** |  | 
**name** | **String** |  | 
**avatar** | **String** |  | 
**role** | [**JsonObject**](.md) |  | 
**authProvider** | [**JsonObject**](.md) |  | 
**emailVerified** | **bool** |  | 
**isActive** | **bool** |  | 
**lastLoginAt** | [**DateTime**](DateTime.md) |  | 
**deletedAt** | [**DateTime**](DateTime.md) |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**profile** | [**UserProfileResponseDto**](UserProfileResponseDto.md) |  | [optional] 
**preferences** | [**UserPreferenceResponseDto**](UserPreferenceResponseDto.md) |  | [optional] 
**subscriptions** | [**BuiltList&lt;UserSubscriptionSummaryDto&gt;**](UserSubscriptionSummaryDto.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


