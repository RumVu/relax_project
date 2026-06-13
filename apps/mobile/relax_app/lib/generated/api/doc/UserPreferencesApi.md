# relax_api_client.api.UserPreferencesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**userPreferencesControllerFindByUserId**](UserPreferencesApi.md#userpreferencescontrollerfindbyuserid) | **GET** /v1/user-preferences/{userId} | Get user preferences by user id (admin)
[**userPreferencesControllerFindMine**](UserPreferencesApi.md#userpreferencescontrollerfindmine) | **GET** /v1/user-preferences/me/preferences | Get the current user preferences
[**userPreferencesControllerUpsert**](UserPreferencesApi.md#userpreferencescontrollerupsert) | **PATCH** /v1/user-preferences/{userId} | Upsert user preferences by user id (admin)
[**userPreferencesControllerUpsertMine**](UserPreferencesApi.md#userpreferencescontrollerupsertmine) | **PATCH** /v1/user-preferences/me/preferences | Upsert the current user preferences


# **userPreferencesControllerFindByUserId**
> UserPreferenceResponseDto userPreferencesControllerFindByUserId(userId)

Get user preferences by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserPreferencesApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.userPreferencesControllerFindByUserId(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserPreferencesApi->userPreferencesControllerFindByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**UserPreferenceResponseDto**](UserPreferenceResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userPreferencesControllerFindMine**
> UserPreferenceResponseDto userPreferencesControllerFindMine()

Get the current user preferences

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserPreferencesApi();

try {
    final response = api.userPreferencesControllerFindMine();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserPreferencesApi->userPreferencesControllerFindMine: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserPreferenceResponseDto**](UserPreferenceResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userPreferencesControllerUpsert**
> UserPreferenceResponseDto userPreferencesControllerUpsert(userId, upsertUserPreferenceDto)

Upsert user preferences by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserPreferencesApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpsertUserPreferenceDto upsertUserPreferenceDto = {"language":"vi","timezone":"Asia/Ho_Chi_Minh","latitude":10.7769,"longitude":106.7009,"locationName":"Ho Chi Minh City","weatherEnabled":true,"themeMode":"SYSTEM","themeId":"theme_pixel_purple","enableCompanionBubble":true,"bubbleIntervalSeconds":900,"enableSound":true,"enableHaptics":true,"pushNotificationsEnabled":true,"emailNotificationsEnabled":false}; // UpsertUserPreferenceDto | 

try {
    final response = api.userPreferencesControllerUpsert(userId, upsertUserPreferenceDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserPreferencesApi->userPreferencesControllerUpsert: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **upsertUserPreferenceDto** | [**UpsertUserPreferenceDto**](UpsertUserPreferenceDto.md)|  | 

### Return type

[**UserPreferenceResponseDto**](UserPreferenceResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userPreferencesControllerUpsertMine**
> UserPreferenceResponseDto userPreferencesControllerUpsertMine(upsertUserPreferenceDto)

Upsert the current user preferences

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserPreferencesApi();
final UpsertUserPreferenceDto upsertUserPreferenceDto = {"language":"vi","timezone":"Asia/Ho_Chi_Minh","latitude":10.7769,"longitude":106.7009,"locationName":"Ho Chi Minh City","weatherEnabled":true,"themeMode":"SYSTEM","themeId":"theme_pixel_purple","enableCompanionBubble":true,"bubbleIntervalSeconds":900,"enableSound":true,"enableHaptics":true,"pushNotificationsEnabled":true,"emailNotificationsEnabled":false}; // UpsertUserPreferenceDto | 

try {
    final response = api.userPreferencesControllerUpsertMine(upsertUserPreferenceDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserPreferencesApi->userPreferencesControllerUpsertMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **upsertUserPreferenceDto** | [**UpsertUserPreferenceDto**](UpsertUserPreferenceDto.md)|  | 

### Return type

[**UserPreferenceResponseDto**](UserPreferenceResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

