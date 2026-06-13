# relax_api_client.model.CreateCheckoutSessionDto

## Load the model package
```dart
import 'package:relax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**planName** | **String** |  | 
**amount** | **num** | Deprecated compatibility field. The backend always prices from SubscriptionTier/fallback plan catalog and ignores client-provided amount. | [optional] 
**currency** | **String** | Deprecated compatibility field. The backend always uses the server-side plan currency. | [optional] 
**provider** | **String** |  | [optional] 
**description** | **String** |  | [optional] 
**successUrl** | **String** |  | [optional] 
**errorUrl** | **String** |  | [optional] 
**cancelUrl** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


