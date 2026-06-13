# relax_api_client.api.AdminUsersApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminUserPlanControllerGetCurrent**](AdminUsersApi.md#adminuserplancontrollergetcurrent) | **GET** /v1/admin/users/{userId}/subscription | Read a user&#39;s current active subscription.
[**adminUserPlanControllerSetPlan**](AdminUsersApi.md#adminuserplancontrollersetplan) | **POST** /v1/admin/users/{userId}/plan | Admin-set the user&#39;s plan immediately, without going through payment. Cancels any active subscription and provisions a fresh ACTIVE one for the chosen tier.


# **adminUserPlanControllerGetCurrent**
> adminUserPlanControllerGetCurrent(userId)

Read a user's current active subscription.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminUsersApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    api.adminUserPlanControllerGetCurrent(userId);
} on DioException catch (e) {
    print('Exception when calling AdminUsersApi->adminUserPlanControllerGetCurrent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUserPlanControllerSetPlan**
> adminUserPlanControllerSetPlan(userId, setUserPlanDto)

Admin-set the user's plan immediately, without going through payment. Cancels any active subscription and provisions a fresh ACTIVE one for the chosen tier.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminUsersApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final SetUserPlanDto setUserPlanDto = ; // SetUserPlanDto | 

try {
    api.adminUserPlanControllerSetPlan(userId, setUserPlanDto);
} on DioException catch (e) {
    print('Exception when calling AdminUsersApi->adminUserPlanControllerSetPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **setUserPlanDto** | [**SetUserPlanDto**](SetUserPlanDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

