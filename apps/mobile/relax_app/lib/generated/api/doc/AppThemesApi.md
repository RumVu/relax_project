# relax_api_client.api.AppThemesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**appThemesControllerCreate**](AppThemesApi.md#appthemescontrollercreate) | **POST** /v1/app-themes | Create an app theme
[**appThemesControllerFindAll**](AppThemesApi.md#appthemescontrollerfindall) | **GET** /v1/app-themes | List app themes
[**appThemesControllerFindDefault**](AppThemesApi.md#appthemescontrollerfinddefault) | **GET** /v1/app-themes/default | Get the default app theme
[**appThemesControllerRemove**](AppThemesApi.md#appthemescontrollerremove) | **DELETE** /v1/app-themes/{id} | Delete an app theme
[**appThemesControllerUpdate**](AppThemesApi.md#appthemescontrollerupdate) | **PATCH** /v1/app-themes/{id} | Update an app theme


# **appThemesControllerCreate**
> AppThemeResponseDto appThemesControllerCreate(createAppThemeDto)

Create an app theme

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAppThemesApi();
final CreateAppThemeDto createAppThemeDto = {"name":"Pixel Purple Light","mode":"LIGHT","backgroundColor":"#F8F6FF","surfaceColor":"#FFFFFF","primaryColor":"#6D5DFB","secondaryColor":"#BCA8FF","accentColor":"#FFB4A8","textColor":"#261D55","mutedTextColor":"#7E76A6","isDefault":true,"isActive":true}; // CreateAppThemeDto | 

try {
    final response = api.appThemesControllerCreate(createAppThemeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AppThemesApi->appThemesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAppThemeDto** | [**CreateAppThemeDto**](CreateAppThemeDto.md)|  | 

### Return type

[**AppThemeResponseDto**](AppThemeResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appThemesControllerFindAll**
> AppThemePageDto appThemesControllerFindAll(q, category, isActive, skip, limit)

List app themes

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAppThemesApi();
final String q = q_example; // String | 
final String category = music; // String | 
final bool isActive = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.appThemesControllerFindAll(q, category, isActive, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AppThemesApi->appThemesControllerFindAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] 
 **category** | **String**|  | [optional] 
 **isActive** | **bool**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**AppThemePageDto**](AppThemePageDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appThemesControllerFindDefault**
> AppThemeResponseDto appThemesControllerFindDefault()

Get the default app theme

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAppThemesApi();

try {
    final response = api.appThemesControllerFindDefault();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AppThemesApi->appThemesControllerFindDefault: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AppThemeResponseDto**](AppThemeResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appThemesControllerRemove**
> AppThemeResponseDto appThemesControllerRemove(id)

Delete an app theme

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAppThemesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.appThemesControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AppThemesApi->appThemesControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**AppThemeResponseDto**](AppThemeResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appThemesControllerUpdate**
> AppThemeResponseDto appThemesControllerUpdate(id, updateAppThemeDto)

Update an app theme

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAppThemesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateAppThemeDto updateAppThemeDto = {"primaryColor":"#7C5CFF","accentColor":"#FFB4A8","isDefault":true}; // UpdateAppThemeDto | 

try {
    final response = api.appThemesControllerUpdate(id, updateAppThemeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AppThemesApi->appThemesControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateAppThemeDto** | [**UpdateAppThemeDto**](UpdateAppThemeDto.md)|  | 

### Return type

[**AppThemeResponseDto**](AppThemeResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

