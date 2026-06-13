# relax_api_client.api.AmbientSoundsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**ambientSoundsControllerCreate**](AmbientSoundsApi.md#ambientsoundscontrollercreate) | **POST** /v1/ambient-sounds | Create an ambient sound
[**ambientSoundsControllerFindAll**](AmbientSoundsApi.md#ambientsoundscontrollerfindall) | **GET** /v1/ambient-sounds | List ambient sounds
[**ambientSoundsControllerFindByCategory**](AmbientSoundsApi.md#ambientsoundscontrollerfindbycategory) | **GET** /v1/ambient-sounds/category/{category} | List ambient sounds by category
[**ambientSoundsControllerRemove**](AmbientSoundsApi.md#ambientsoundscontrollerremove) | **DELETE** /v1/ambient-sounds/{id} | Delete an ambient sound
[**ambientSoundsControllerUpdate**](AmbientSoundsApi.md#ambientsoundscontrollerupdate) | **PATCH** /v1/ambient-sounds/{id} | Update an ambient sound


# **ambientSoundsControllerCreate**
> AmbientSoundResponseDto ambientSoundsControllerCreate(createAmbientSoundDto)

Create an ambient sound

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAmbientSoundsApi();
final CreateAmbientSoundDto createAmbientSoundDto = {"title":"Lo-fi Chill - Pixel Beats","description":"Nhạc nền nhẹ để thả lỏng đầu óc.","category":"music","soundUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/sounds/lofi-chill.mp3","imageUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/sounds/lofi-cover.png","duration":210,"isActive":true}; // CreateAmbientSoundDto | 

try {
    final response = api.ambientSoundsControllerCreate(createAmbientSoundDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AmbientSoundsApi->ambientSoundsControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAmbientSoundDto** | [**CreateAmbientSoundDto**](CreateAmbientSoundDto.md)|  | 

### Return type

[**AmbientSoundResponseDto**](AmbientSoundResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ambientSoundsControllerFindAll**
> AmbientSoundPageDto ambientSoundsControllerFindAll(q, category, isActive, skip, limit)

List ambient sounds

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAmbientSoundsApi();
final String q = q_example; // String | 
final String category = music; // String | 
final bool isActive = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.ambientSoundsControllerFindAll(q, category, isActive, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AmbientSoundsApi->ambientSoundsControllerFindAll: $e\n');
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

[**AmbientSoundPageDto**](AmbientSoundPageDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ambientSoundsControllerFindByCategory**
> BuiltList<AmbientSoundResponseDto> ambientSoundsControllerFindByCategory(category)

List ambient sounds by category

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAmbientSoundsApi();
final String category = music; // String | 

try {
    final response = api.ambientSoundsControllerFindByCategory(category);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AmbientSoundsApi->ambientSoundsControllerFindByCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **category** | **String**|  | 

### Return type

[**BuiltList&lt;AmbientSoundResponseDto&gt;**](AmbientSoundResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ambientSoundsControllerRemove**
> AmbientSoundResponseDto ambientSoundsControllerRemove(id)

Delete an ambient sound

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAmbientSoundsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.ambientSoundsControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AmbientSoundsApi->ambientSoundsControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**AmbientSoundResponseDto**](AmbientSoundResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ambientSoundsControllerUpdate**
> AmbientSoundResponseDto ambientSoundsControllerUpdate(id, updateAmbientSoundDto)

Update an ambient sound

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAmbientSoundsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateAmbientSoundDto updateAmbientSoundDto = {"title":"Lo-fi Chill - Pixel Beats Extended","duration":240,"isActive":true}; // UpdateAmbientSoundDto | 

try {
    final response = api.ambientSoundsControllerUpdate(id, updateAmbientSoundDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AmbientSoundsApi->ambientSoundsControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateAmbientSoundDto** | [**UpdateAmbientSoundDto**](UpdateAmbientSoundDto.md)|  | 

### Return type

[**AmbientSoundResponseDto**](AmbientSoundResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

