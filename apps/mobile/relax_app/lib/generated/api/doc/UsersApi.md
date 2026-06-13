# relax_api_client.api.UsersApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**usersControllerCreate**](UsersApi.md#userscontrollercreate) | **POST** /v1/users | Create a user (admin)
[**usersControllerFindAll**](UsersApi.md#userscontrollerfindall) | **GET** /v1/users | List all users (admin)
[**usersControllerFindOne**](UsersApi.md#userscontrollerfindone) | **GET** /v1/users/{id} | Get one user by id (admin)
[**usersControllerRemove**](UsersApi.md#userscontrollerremove) | **DELETE** /v1/users/{id} | Delete a user (admin)
[**usersControllerUpdate**](UsersApi.md#userscontrollerupdate) | **PATCH** /v1/users/{id} | Update a user (admin)


# **usersControllerCreate**
> UserResponseDto usersControllerCreate(createUserDto)

Create a user (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUsersApi();
final CreateUserDto createUserDto = {"email":"friend@example.com","name":"Bạn Chill","avatar":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/avatars/friend.png","password":"Secret123!x","role":"USER","authProvider":"LOCAL","emailVerified":false,"isActive":true}; // CreateUserDto | 

try {
    final response = api.usersControllerCreate(createUserDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->usersControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createUserDto** | [**CreateUserDto**](CreateUserDto.md)|  | 

### Return type

[**UserResponseDto**](UserResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersControllerFindAll**
> UserPageDto usersControllerFindAll(search, role, status, emailVerified, includeDeleted, skip, limit)

List all users (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUsersApi();
final String search = search_example; // String | 
final JsonObject role = Object; // JsonObject | 
final JsonObject status = Object; // JsonObject | 
final bool emailVerified = true; // bool | 
final bool includeDeleted = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.usersControllerFindAll(search, role, status, emailVerified, includeDeleted, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->usersControllerFindAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**|  | [optional] 
 **role** | [**JsonObject**](.md)|  | [optional] 
 **status** | [**JsonObject**](.md)|  | [optional] 
 **emailVerified** | **bool**|  | [optional] 
 **includeDeleted** | **bool**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**UserPageDto**](UserPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersControllerFindOne**
> UserResponseDto usersControllerFindOne(id)

Get one user by id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUsersApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.usersControllerFindOne(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->usersControllerFindOne: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**UserResponseDto**](UserResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersControllerRemove**
> UserResponseDto usersControllerRemove(id)

Delete a user (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUsersApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.usersControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->usersControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**UserResponseDto**](UserResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersControllerUpdate**
> UserResponseDto usersControllerUpdate(id, updateUserDto)

Update a user (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUsersApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateUserDto updateUserDto = {"name":"Bạn Chill Updated","avatar":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/avatars/friend-updated.png","isActive":true}; // UpdateUserDto | 

try {
    final response = api.usersControllerUpdate(id, updateUserDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->usersControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateUserDto** | [**UpdateUserDto**](UpdateUserDto.md)|  | 

### Return type

[**UserResponseDto**](UserResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

