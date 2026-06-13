# relax_api_client.api.BreathingExercisesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**breathingExercisesControllerCreate**](BreathingExercisesApi.md#breathingexercisescontrollercreate) | **POST** /v1/breathing-exercises | Create a breathing exercise
[**breathingExercisesControllerFindAll**](BreathingExercisesApi.md#breathingexercisescontrollerfindall) | **GET** /v1/breathing-exercises | List breathing exercises
[**breathingExercisesControllerRemove**](BreathingExercisesApi.md#breathingexercisescontrollerremove) | **DELETE** /v1/breathing-exercises/{id} | Delete a breathing exercise
[**breathingExercisesControllerUpdate**](BreathingExercisesApi.md#breathingexercisescontrollerupdate) | **PATCH** /v1/breathing-exercises/{id} | Update a breathing exercise


# **breathingExercisesControllerCreate**
> BreathingExerciseResponseDto breathingExercisesControllerCreate(createBreathingExerciseDto)

Create a breathing exercise

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBreathingExercisesApi();
final CreateBreathingExerciseDto createBreathingExerciseDto = {"title":"Box Breathing","description":"Hít vào, giữ, thở ra đều nhịp để cơ thể dịu xuống.","inhaleSeconds":4,"holdSeconds":4,"exhaleSeconds":4,"cycles":6,"duration":72,"imageUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/breathing/box.png","isActive":true}; // CreateBreathingExerciseDto | 

try {
    final response = api.breathingExercisesControllerCreate(createBreathingExerciseDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BreathingExercisesApi->breathingExercisesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createBreathingExerciseDto** | [**CreateBreathingExerciseDto**](CreateBreathingExerciseDto.md)|  | 

### Return type

[**BreathingExerciseResponseDto**](BreathingExerciseResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **breathingExercisesControllerFindAll**
> BreathingExercisePageDto breathingExercisesControllerFindAll(q, category, isActive, skip, limit)

List breathing exercises

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBreathingExercisesApi();
final String q = q_example; // String | 
final String category = music; // String | 
final bool isActive = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.breathingExercisesControllerFindAll(q, category, isActive, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BreathingExercisesApi->breathingExercisesControllerFindAll: $e\n');
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

[**BreathingExercisePageDto**](BreathingExercisePageDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **breathingExercisesControllerRemove**
> BreathingExerciseResponseDto breathingExercisesControllerRemove(id)

Delete a breathing exercise

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBreathingExercisesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.breathingExercisesControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BreathingExercisesApi->breathingExercisesControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**BreathingExerciseResponseDto**](BreathingExerciseResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **breathingExercisesControllerUpdate**
> BreathingExerciseResponseDto breathingExercisesControllerUpdate(id, updateBreathingExerciseDto)

Update a breathing exercise

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBreathingExercisesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateBreathingExerciseDto updateBreathingExerciseDto = {"title":"Box Breathing 4-4-4","cycles":8,"duration":96,"isActive":true}; // UpdateBreathingExerciseDto | 

try {
    final response = api.breathingExercisesControllerUpdate(id, updateBreathingExerciseDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BreathingExercisesApi->breathingExercisesControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateBreathingExerciseDto** | [**UpdateBreathingExerciseDto**](UpdateBreathingExerciseDto.md)|  | 

### Return type

[**BreathingExerciseResponseDto**](BreathingExerciseResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

