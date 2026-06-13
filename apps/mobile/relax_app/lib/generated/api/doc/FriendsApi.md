# relax_api_client.api.FriendsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**friendsControllerAcceptRequest**](FriendsApi.md#friendscontrolleracceptrequest) | **POST** /v1/friends/accept/{requesterId} | 
[**friendsControllerGetMyFriends**](FriendsApi.md#friendscontrollergetmyfriends) | **GET** /v1/friends/me | 
[**friendsControllerGetPendingRequests**](FriendsApi.md#friendscontrollergetpendingrequests) | **GET** /v1/friends/pending | 
[**friendsControllerSendRequest**](FriendsApi.md#friendscontrollersendrequest) | **POST** /v1/friends/request/{friendId} | 


# **friendsControllerAcceptRequest**
> friendsControllerAcceptRequest(requesterId)



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFriendsApi();
final String requesterId = requesterId_example; // String | 

try {
    api.friendsControllerAcceptRequest(requesterId);
} on DioException catch (e) {
    print('Exception when calling FriendsApi->friendsControllerAcceptRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requesterId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **friendsControllerGetMyFriends**
> friendsControllerGetMyFriends()



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFriendsApi();

try {
    api.friendsControllerGetMyFriends();
} on DioException catch (e) {
    print('Exception when calling FriendsApi->friendsControllerGetMyFriends: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **friendsControllerGetPendingRequests**
> friendsControllerGetPendingRequests()



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFriendsApi();

try {
    api.friendsControllerGetPendingRequests();
} on DioException catch (e) {
    print('Exception when calling FriendsApi->friendsControllerGetPendingRequests: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **friendsControllerSendRequest**
> friendsControllerSendRequest(friendId)



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFriendsApi();
final String friendId = friendId_example; // String | 

try {
    api.friendsControllerSendRequest(friendId);
} on DioException catch (e) {
    print('Exception when calling FriendsApi->friendsControllerSendRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **friendId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

