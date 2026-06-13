# relax_api_client.api.OnboardingSlidesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**onboardingSlidesControllerCreate**](OnboardingSlidesApi.md#onboardingslidescontrollercreate) | **POST** /v1/onboarding-slides | Create an onboarding slide
[**onboardingSlidesControllerFindAll**](OnboardingSlidesApi.md#onboardingslidescontrollerfindall) | **GET** /v1/onboarding-slides | List onboarding slides
[**onboardingSlidesControllerRemove**](OnboardingSlidesApi.md#onboardingslidescontrollerremove) | **DELETE** /v1/onboarding-slides/{id} | Delete an onboarding slide
[**onboardingSlidesControllerUpdate**](OnboardingSlidesApi.md#onboardingslidescontrollerupdate) | **PATCH** /v1/onboarding-slides/{id} | Update an onboarding slide


# **onboardingSlidesControllerCreate**
> OnboardingSlideResponseDto onboardingSlidesControllerCreate(createOnboardingSlideDto)

Create an onboarding slide

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getOnboardingSlidesApi();
final CreateOnboardingSlideDto createOnboardingSlideDto = {"title":"Chào mừng quay lại","subtitle":"Một góc nhỏ để bạn nghỉ nhẹ.","description":"Check-in cảm xúc, chọn hoạt động thư giãn và theo dõi tiến trình mỗi ngày.","imageUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/onboarding/welcome.png","animationUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/onboarding/welcome.json","displayOrder":1,"isActive":true}; // CreateOnboardingSlideDto | 

try {
    final response = api.onboardingSlidesControllerCreate(createOnboardingSlideDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OnboardingSlidesApi->onboardingSlidesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createOnboardingSlideDto** | [**CreateOnboardingSlideDto**](CreateOnboardingSlideDto.md)|  | 

### Return type

[**OnboardingSlideResponseDto**](OnboardingSlideResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **onboardingSlidesControllerFindAll**
> OnboardingSlidePageDto onboardingSlidesControllerFindAll(q, category, isActive, skip, limit)

List onboarding slides

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getOnboardingSlidesApi();
final String q = q_example; // String | 
final String category = music; // String | 
final bool isActive = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.onboardingSlidesControllerFindAll(q, category, isActive, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OnboardingSlidesApi->onboardingSlidesControllerFindAll: $e\n');
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

[**OnboardingSlidePageDto**](OnboardingSlidePageDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **onboardingSlidesControllerRemove**
> OnboardingSlideResponseDto onboardingSlidesControllerRemove(id)

Delete an onboarding slide

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getOnboardingSlidesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.onboardingSlidesControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OnboardingSlidesApi->onboardingSlidesControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**OnboardingSlideResponseDto**](OnboardingSlideResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **onboardingSlidesControllerUpdate**
> OnboardingSlideResponseDto onboardingSlidesControllerUpdate(id, updateOnboardingSlideDto)

Update an onboarding slide

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getOnboardingSlidesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateOnboardingSlideDto updateOnboardingSlideDto = {"title":"Chào mừng quay lại nhé","displayOrder":2,"isActive":true}; // UpdateOnboardingSlideDto | 

try {
    final response = api.onboardingSlidesControllerUpdate(id, updateOnboardingSlideDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OnboardingSlidesApi->onboardingSlidesControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateOnboardingSlideDto** | [**UpdateOnboardingSlideDto**](UpdateOnboardingSlideDto.md)|  | 

### Return type

[**OnboardingSlideResponseDto**](OnboardingSlideResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

