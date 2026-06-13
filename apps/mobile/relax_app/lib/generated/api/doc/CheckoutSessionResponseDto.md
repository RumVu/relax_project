# relax_api_client.model.CheckoutSessionResponseDto

## Load the model package
```dart
import 'package:relax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**configured** | **bool** |  | 
**provider** | **String** |  | 
**tier** | [**JsonObject**](.md) | Raw SubscriptionTier row when the plan came from the DB, else null. | 
**plan** | [**CheckoutResolvedPlanDto**](CheckoutResolvedPlanDto.md) |  | 
**payment** | [**JsonObject**](.md) |  | 
**checkout** | [**CheckoutSessionStatusDto**](CheckoutSessionStatusDto.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


