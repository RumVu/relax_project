# relax_api_client.model.GoogleLoginDto

## Load the model package
```dart
import 'package:relax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**idToken** | **String** | Legacy GIS ID token. Kept for backwards compatibility. | [optional] 
**accessToken** | **String** | Legacy OAuth access token. Kept for backwards compatibility. | [optional] 
**authorizationCode** | **String** | OAuth authorization code returned to /auth/google/callback. Backend exchanges this using GOOGLE_CLIENT_SECRET. | [optional] 
**redirectUri** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


