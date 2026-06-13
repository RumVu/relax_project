# relax_api_client.api.CompanionMessagesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**companionMessagesControllerCreate**](CompanionMessagesApi.md#companionmessagescontrollercreate) | **POST** /v1/companion-messages | Create a companion message
[**companionMessagesControllerFindAll**](CompanionMessagesApi.md#companionmessagescontrollerfindall) | **GET** /v1/companion-messages | List companion messages
[**companionMessagesControllerFindRandom**](CompanionMessagesApi.md#companionmessagescontrollerfindrandom) | **GET** /v1/companion-messages/random | Get a random active companion message
[**companionMessagesControllerRemove**](CompanionMessagesApi.md#companionmessagescontrollerremove) | **DELETE** /v1/companion-messages/{id} | Delete a companion message
[**companionMessagesControllerUpdate**](CompanionMessagesApi.md#companionmessagescontrollerupdate) | **PATCH** /v1/companion-messages/{id} | Update a companion message


# **companionMessagesControllerCreate**
> CompanionMessageResponseDto companionMessagesControllerCreate(createCompanionMessageDto)

Create a companion message

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionMessagesApi();
final CreateCompanionMessageDto createCompanionMessageDto = {"content":"Stress quá mới tìm đến tui hở? Bạn kể tui nghe đi nè!","triggerType":"AFTER_CHECKIN","mood":"STRESSED","companionMood":"CURIOUS","minHour":6,"maxHour":23,"weight":10,"isActive":true}; // CreateCompanionMessageDto | 

try {
    final response = api.companionMessagesControllerCreate(createCompanionMessageDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionMessagesApi->companionMessagesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCompanionMessageDto** | [**CreateCompanionMessageDto**](CreateCompanionMessageDto.md)|  | 

### Return type

[**CompanionMessageResponseDto**](CompanionMessageResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionMessagesControllerFindAll**
> CompanionMessagePageDto companionMessagesControllerFindAll(q, category, isActive, skip, limit)

List companion messages

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionMessagesApi();
final String q = q_example; // String | 
final String category = music; // String | 
final bool isActive = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.companionMessagesControllerFindAll(q, category, isActive, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionMessagesApi->companionMessagesControllerFindAll: $e\n');
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

[**CompanionMessagePageDto**](CompanionMessagePageDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionMessagesControllerFindRandom**
> CompanionMessageResponseDto companionMessagesControllerFindRandom()

Get a random active companion message

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionMessagesApi();

try {
    final response = api.companionMessagesControllerFindRandom();
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionMessagesApi->companionMessagesControllerFindRandom: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CompanionMessageResponseDto**](CompanionMessageResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionMessagesControllerRemove**
> CompanionMessageResponseDto companionMessagesControllerRemove(id)

Delete a companion message

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionMessagesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.companionMessagesControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionMessagesApi->companionMessagesControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**CompanionMessageResponseDto**](CompanionMessageResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **companionMessagesControllerUpdate**
> CompanionMessageResponseDto companionMessagesControllerUpdate(id, updateCompanionMessageDto)

Update a companion message

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCompanionMessagesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateCompanionMessageDto updateCompanionMessageDto = {"content":"Mình ở đây nghe bạn nè.","companionMood":"CALM","weight":8,"isActive":true}; // UpdateCompanionMessageDto | 

try {
    final response = api.companionMessagesControllerUpdate(id, updateCompanionMessageDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompanionMessagesApi->companionMessagesControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateCompanionMessageDto** | [**UpdateCompanionMessageDto**](UpdateCompanionMessageDto.md)|  | 

### Return type

[**CompanionMessageResponseDto**](CompanionMessageResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

