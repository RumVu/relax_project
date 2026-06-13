# relax_api_client.model.WeatherForecastResponseDto

## Load the model package
```dart
import 'package:relax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**configured** | **bool** |  | 
**reason** | **String** |  | [optional] 
**greeting** | [**WeatherGreetingDto**](WeatherGreetingDto.md) |  | [optional] 
**provider** | **String** |  | [optional] 
**location** | [**WeatherLocationDto**](WeatherLocationDto.md) |  | [optional] 
**reverseGeocode** | [**JsonObject**](.md) |  | [optional] 
**current** | [**WeatherCurrentDataDto**](WeatherCurrentDataDto.md) |  | [optional] 
**forecast** | [**BuiltList&lt;WeatherForecastDayDto&gt;**](WeatherForecastDayDto.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


