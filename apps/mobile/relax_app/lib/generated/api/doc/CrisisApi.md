# relax_api_client.api.CrisisApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**crisisControllerCheckContent**](CrisisApi.md#crisiscontrollercheckcontent) | **POST** /v1/crisis/check | Check text content for crisis indicators
[**crisisControllerGetDisclaimer**](CrisisApi.md#crisiscontrollergetdisclaimer) | **GET** /v1/crisis/disclaimer | Get safety disclaimer
[**crisisControllerGetHotlines**](CrisisApi.md#crisiscontrollergethotlines) | **GET** /v1/crisis/hotlines | Get crisis hotlines


# **crisisControllerCheckContent**
> crisisControllerCheckContent(checkContentDto)

Check text content for crisis indicators

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCrisisApi();
final CheckContentDto checkContentDto = ; // CheckContentDto | 

try {
    api.crisisControllerCheckContent(checkContentDto);
} on DioException catch (e) {
    print('Exception when calling CrisisApi->crisisControllerCheckContent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **checkContentDto** | [**CheckContentDto**](CheckContentDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **crisisControllerGetDisclaimer**
> crisisControllerGetDisclaimer()

Get safety disclaimer

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCrisisApi();

try {
    api.crisisControllerGetDisclaimer();
} on DioException catch (e) {
    print('Exception when calling CrisisApi->crisisControllerGetDisclaimer: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **crisisControllerGetHotlines**
> crisisControllerGetHotlines(country)

Get crisis hotlines

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCrisisApi();
final String country = VN; // String | 

try {
    api.crisisControllerGetHotlines(country);
} on DioException catch (e) {
    print('Exception when calling CrisisApi->crisisControllerGetHotlines: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **country** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

