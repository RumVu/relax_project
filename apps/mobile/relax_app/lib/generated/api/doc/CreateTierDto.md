# relax_api_client.model.CreateTierDto

## Load the model package
```dart
import 'package:relax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | Unique internal code, UPPER_SNAKE only. E.g. CHILL_PLUS, CHILL_PLUS_ANNUAL. | 
**title** | **String** | Display title shown to users. Falls back to name when null. | [optional] 
**description** | **String** | Marketing copy / description. | [optional] 
**price** | **num** | List price in the smallest visible unit (e.g. VND). | 
**salePrice** | **num** | Active sale price. Effective when within sale window. | [optional] 
**saleLabel** | **String** | Short label shown beside the sale price, e.g. \"BLACK FRIDAY -20%\". | [optional] 
**saleStartsAt** | **String** | ISO datetime when the sale starts. | [optional] 
**saleEndsAt** | **String** | ISO datetime when the sale ends. | [optional] 
**currency** | **String** | ISO 4217 currency. Defaults to VND. | [optional] 
**billingCycle** | **String** |  | 
**displayOrder** | **num** | Display order, low to high. | [optional] [default to 0]
**isActive** | **bool** |  | [optional] [default to true]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


