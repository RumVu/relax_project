# relax_api_client.model.UpsertUserProfileDto

## Load the model package
```dart
import 'package:relax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**displayName** | **String** |  | [optional] 
**bio** | **String** |  | [optional] 
**birthday** | [**DateTime**](DateTime.md) |  | [optional] 
**avatar** | **String** | Public URL of the user's avatar (typically Supabase public-asset URL after uploading via /storage/signed-upload-url). Lives on the User record, not UserProfile — service syncs both for convenience. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


