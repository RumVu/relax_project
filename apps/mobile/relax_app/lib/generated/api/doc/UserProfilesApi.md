# relax_api_client.api.UserProfilesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**userProfilesControllerFindByUserId**](UserProfilesApi.md#userprofilescontrollerfindbyuserid) | **GET** /v1/user-profiles/{userId} | Get a user profile by user id (admin)
[**userProfilesControllerFindMine**](UserProfilesApi.md#userprofilescontrollerfindmine) | **GET** /v1/user-profiles/me/profile | Get the current user profile
[**userProfilesControllerUpsert**](UserProfilesApi.md#userprofilescontrollerupsert) | **PATCH** /v1/user-profiles/{userId} | Upsert a user profile by user id (admin)
[**userProfilesControllerUpsertMine**](UserProfilesApi.md#userprofilescontrollerupsertmine) | **PATCH** /v1/user-profiles/me/profile | Upsert the current user profile


# **userProfilesControllerFindByUserId**
> UserProfileResponseDto userProfilesControllerFindByUserId(userId)

Get a user profile by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserProfilesApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.userProfilesControllerFindByUserId(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserProfilesApi->userProfilesControllerFindByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**UserProfileResponseDto**](UserProfileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userProfilesControllerFindMine**
> UserProfileResponseDto userProfilesControllerFindMine()

Get the current user profile

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserProfilesApi();

try {
    final response = api.userProfilesControllerFindMine();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserProfilesApi->userProfilesControllerFindMine: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserProfileResponseDto**](UserProfileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userProfilesControllerUpsert**
> UserProfileResponseDto userProfilesControllerUpsert(userId, upsertUserProfileDto)

Upsert a user profile by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserProfilesApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpsertUserProfileDto upsertUserProfileDto = {"displayName":"Thì Ai","bio":"Đang tập sống chậm lại một chút.","birthday":"2000-05-20T00:00:00.000Z"}; // UpsertUserProfileDto | 

try {
    final response = api.userProfilesControllerUpsert(userId, upsertUserProfileDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserProfilesApi->userProfilesControllerUpsert: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **upsertUserProfileDto** | [**UpsertUserProfileDto**](UpsertUserProfileDto.md)|  | 

### Return type

[**UserProfileResponseDto**](UserProfileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userProfilesControllerUpsertMine**
> UserProfileResponseDto userProfilesControllerUpsertMine(upsertUserProfileDto)

Upsert the current user profile

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserProfilesApi();
final UpsertUserProfileDto upsertUserProfileDto = {"displayName":"Thì Ai","bio":"Đang tập sống chậm lại một chút.","birthday":"2000-05-20T00:00:00.000Z"}; // UpsertUserProfileDto | 

try {
    final response = api.userProfilesControllerUpsertMine(upsertUserProfileDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserProfilesApi->userProfilesControllerUpsertMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **upsertUserProfileDto** | [**UpsertUserProfileDto**](UpsertUserProfileDto.md)|  | 

### Return type

[**UserProfileResponseDto**](UserProfileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

