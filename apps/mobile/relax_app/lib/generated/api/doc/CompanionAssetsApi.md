# relax_api_client.api.CompanionAssetsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**companionAssetsControllerCreate**](CompanionAssetsApi.md#companionassetscontrollercreate) | **POST** /v1/companion-assets | Create a companion asset
[**companionAssetsControllerFindAll**](CompanionAssetsApi.md#companionassetscontrollerfindall) | **GET** /v1/companion-assets | List companion assets
[**companionAssetsControllerFindDefault**](CompanionAssetsApi.md#companionassetscontrollerfinddefault) | **GET** /v1/companion-assets/default | Get the default companion asset
[**companionAssetsControllerRemove**](CompanionAssetsApi.md#companionassetscontrollerremove) | **DELETE** /v1/companion-assets/{id} | Delete a companion asset
[**companionAssetsControllerUpdate**](CompanionAssetsApi.md#companionassetscontrollerupdate) | **PATCH** /v1/companion-assets/{id} | Update a companion asset


# **companionAssetsControllerCreate**
> CompanionAssetResponseDto companionAssetsControllerCreate(createCompanionAssetDto)

Create a companion asset

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionAssetsApi();
final CreateCompanionAssetDto createCompanionAssetDto = {"name":"Pixel Cat Default","type":"CAT","description":"Pet pixel mặc định cho màn hình home.","previewImageUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/companions/pixel-cat/preview.png","spriteSheetUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/companions/pixel-cat/sprite.png","idleAnimationUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/companions/pixel-cat/idle.gif","sleepAnimationUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/companions/pixel-cat/sleep.gif","walkAnimationUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/companions/pixel-cat/walk.gif","primaryColor":"#7C5CFF","secondaryColor":"#BCA8FF","accentColor":"#FFB4A8","isDefault":true,"isActive":true}; // CreateCompanionAssetDto | 

try {
    final response = api.companionAssetsControllerCreate(createCompanionAssetDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionAssetsApi->companionAssetsControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCompanionAssetDto** | [**CreateCompanionAssetDto**](CreateCompanionAssetDto.md)|  | 

### Return type

[**CompanionAssetResponseDto**](CompanionAssetResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionAssetsControllerFindAll**
> CompanionAssetPageDto companionAssetsControllerFindAll(q, category, isActive, skip, limit)

List companion assets

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionAssetsApi();
final String q = q_example; // String | 
final String category = music; // String | 
final bool isActive = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.companionAssetsControllerFindAll(q, category, isActive, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionAssetsApi->companionAssetsControllerFindAll: $e\n');
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

[**CompanionAssetPageDto**](CompanionAssetPageDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionAssetsControllerFindDefault**
> CompanionAssetResponseDto companionAssetsControllerFindDefault()

Get the default companion asset

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionAssetsApi();

try {
    final response = api.companionAssetsControllerFindDefault();
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionAssetsApi->companionAssetsControllerFindDefault: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CompanionAssetResponseDto**](CompanionAssetResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionAssetsControllerRemove**
> CompanionAssetResponseDto companionAssetsControllerRemove(id)

Delete a companion asset

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionAssetsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.companionAssetsControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionAssetsApi->companionAssetsControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**CompanionAssetResponseDto**](CompanionAssetResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionAssetsControllerUpdate**
> CompanionAssetResponseDto companionAssetsControllerUpdate(id, updateCompanionAssetDto)

Update a companion asset

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionAssetsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateCompanionAssetDto updateCompanionAssetDto = {"name":"Pixel Cat Night","sleepAnimationUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/companions/pixel-cat/sleep-night.gif","isActive":true}; // UpdateCompanionAssetDto | 

try {
    final response = api.companionAssetsControllerUpdate(id, updateCompanionAssetDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionAssetsApi->companionAssetsControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateCompanionAssetDto** | [**UpdateCompanionAssetDto**](UpdateCompanionAssetDto.md)|  | 

### Return type

[**CompanionAssetResponseDto**](CompanionAssetResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

