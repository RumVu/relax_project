# relax_api_client.api.SessionsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**sessionsControllerFindAll**](SessionsApi.md#sessionscontrollerfindall) | **GET** /v1/sessions | List all sessions (admin)
[**sessionsControllerFindByUserId**](SessionsApi.md#sessionscontrollerfindbyuserid) | **GET** /v1/sessions/user/{userId} | List sessions for one user (admin)
[**sessionsControllerFindMine**](SessionsApi.md#sessionscontrollerfindmine) | **GET** /v1/sessions/me | List sessions for the current user
[**sessionsControllerRevoke**](SessionsApi.md#sessionscontrollerrevoke) | **DELETE** /v1/sessions/{id} | Revoke one session (admin)
[**sessionsControllerRevokeUserSessions**](SessionsApi.md#sessionscontrollerrevokeusersessions) | **DELETE** /v1/sessions/user/{userId} | Revoke all sessions for one user (admin)


# **sessionsControllerFindAll**
> BuiltList<SessionResponseDto> sessionsControllerFindAll()

List all sessions (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getSessionsApi();

try {
    final response = api.sessionsControllerFindAll();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SessionsApi->sessionsControllerFindAll: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;SessionResponseDto&gt;**](SessionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sessionsControllerFindByUserId**
> BuiltList<SessionResponseDto> sessionsControllerFindByUserId(userId)

List sessions for one user (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getSessionsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.sessionsControllerFindByUserId(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SessionsApi->sessionsControllerFindByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**BuiltList&lt;SessionResponseDto&gt;**](SessionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sessionsControllerFindMine**
> BuiltList<SessionResponseDto> sessionsControllerFindMine()

List sessions for the current user

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getSessionsApi();

try {
    final response = api.sessionsControllerFindMine();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SessionsApi->sessionsControllerFindMine: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;SessionResponseDto&gt;**](SessionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sessionsControllerRevoke**
> SessionResponseDto sessionsControllerRevoke(id)

Revoke one session (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getSessionsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.sessionsControllerRevoke(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SessionsApi->sessionsControllerRevoke: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**SessionResponseDto**](SessionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sessionsControllerRevokeUserSessions**
> JsonObject sessionsControllerRevokeUserSessions(userId)

Revoke all sessions for one user (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getSessionsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.sessionsControllerRevokeUserSessions(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SessionsApi->sessionsControllerRevokeUserSessions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

