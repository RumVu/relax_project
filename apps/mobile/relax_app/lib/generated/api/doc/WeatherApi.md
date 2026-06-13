# relax_api_client.api.WeatherApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**weatherControllerGetCurrent**](WeatherApi.md#weathercontrollergetcurrent) | **GET** /v1/weather/current | Get current weather by coordinates
[**weatherControllerGetForecast**](WeatherApi.md#weathercontrollergetforecast) | **GET** /v1/weather/forecast | Get weather forecast by coordinates
[**weatherControllerGetMine**](WeatherApi.md#weathercontrollergetmine) | **GET** /v1/weather/me/current | Get current weather for the current user location
[**weatherControllerGetMyForecast**](WeatherApi.md#weathercontrollergetmyforecast) | **GET** /v1/weather/me/forecast | Get weather forecast for the current user location
[**weatherControllerReverseGeocode**](WeatherApi.md#weathercontrollerreversegeocode) | **GET** /v1/weather/reverse-geocode | Reverse geocode coordinates into a location name
[**weatherControllerUpdateMyLocation**](WeatherApi.md#weathercontrollerupdatemylocation) | **PATCH** /v1/weather/me/location | Save current user weather location preferences


# **weatherControllerGetCurrent**
> WeatherCurrentResponseDto weatherControllerGetCurrent(latitude, longitude, timezone)

Get current weather by coordinates

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getWeatherApi();
final num latitude = 10.7769; // num | 
final num longitude = 106.7009; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.weatherControllerGetCurrent(latitude, longitude, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WeatherApi->weatherControllerGetCurrent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latitude** | **num**|  | [optional] 
 **longitude** | **num**|  | [optional] 
 **timezone** | **String**|  | [optional] 

### Return type

[**WeatherCurrentResponseDto**](WeatherCurrentResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **weatherControllerGetForecast**
> WeatherForecastResponseDto weatherControllerGetForecast(latitude, longitude, timezone, forecastDays)

Get weather forecast by coordinates

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getWeatherApi();
final num latitude = 10.7769; // num | 
final num longitude = 106.7009; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 
final num forecastDays = 7; // num | 

try {
    final response = api.weatherControllerGetForecast(latitude, longitude, timezone, forecastDays);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WeatherApi->weatherControllerGetForecast: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latitude** | **num**|  | [optional] 
 **longitude** | **num**|  | [optional] 
 **timezone** | **String**|  | [optional] 
 **forecastDays** | **num**|  | [optional] 

### Return type

[**WeatherForecastResponseDto**](WeatherForecastResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **weatherControllerGetMine**
> WeatherCurrentResponseDto weatherControllerGetMine(latitude, longitude, timezone)

Get current weather for the current user location

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getWeatherApi();
final num latitude = 10.7769; // num | 
final num longitude = 106.7009; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.weatherControllerGetMine(latitude, longitude, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WeatherApi->weatherControllerGetMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latitude** | **num**|  | [optional] 
 **longitude** | **num**|  | [optional] 
 **timezone** | **String**|  | [optional] 

### Return type

[**WeatherCurrentResponseDto**](WeatherCurrentResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **weatherControllerGetMyForecast**
> WeatherForecastResponseDto weatherControllerGetMyForecast(latitude, longitude, timezone, forecastDays)

Get weather forecast for the current user location

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getWeatherApi();
final num latitude = 10.7769; // num | 
final num longitude = 106.7009; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 
final num forecastDays = 7; // num | 

try {
    final response = api.weatherControllerGetMyForecast(latitude, longitude, timezone, forecastDays);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WeatherApi->weatherControllerGetMyForecast: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latitude** | **num**|  | [optional] 
 **longitude** | **num**|  | [optional] 
 **timezone** | **String**|  | [optional] 
 **forecastDays** | **num**|  | [optional] 

### Return type

[**WeatherForecastResponseDto**](WeatherForecastResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **weatherControllerReverseGeocode**
> JsonObject weatherControllerReverseGeocode(latitude, longitude, localityLanguage)

Reverse geocode coordinates into a location name

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getWeatherApi();
final num latitude = 10.7769; // num | 
final num longitude = 106.7009; // num | 
final String localityLanguage = vi; // String | 

try {
    final response = api.weatherControllerReverseGeocode(latitude, longitude, localityLanguage);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WeatherApi->weatherControllerReverseGeocode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latitude** | **num**|  | 
 **longitude** | **num**|  | 
 **localityLanguage** | **String**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **weatherControllerUpdateMyLocation**
> JsonObject weatherControllerUpdateMyLocation(updateWeatherLocationDto)

Save current user weather location preferences

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getWeatherApi();
final UpdateWeatherLocationDto updateWeatherLocationDto = {"latitude":10.7769,"longitude":106.7009,"timezone":"Asia/Ho_Chi_Minh","reverseGeocode":true,"localityLanguage":"vi","weatherEnabled":true}; // UpdateWeatherLocationDto | 

try {
    final response = api.weatherControllerUpdateMyLocation(updateWeatherLocationDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WeatherApi->weatherControllerUpdateMyLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateWeatherLocationDto** | [**UpdateWeatherLocationDto**](UpdateWeatherLocationDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

