# relax_api_client.api.AdminDashboardApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminDashboardControllerGetOverview**](AdminDashboardApi.md#admindashboardcontrollergetoverview) | **GET** /v1/admin/analytics/overview | Get admin aggregate dashboard metrics for users, billing, retention, engagement, and operations
[**adminDashboardControllerSearch**](AdminDashboardApi.md#admindashboardcontrollersearch) | **GET** /v1/admin/search | Search indexed dashboard/admin content


# **adminDashboardControllerGetOverview**
> adminDashboardControllerGetOverview(period, from, to, timezone, timezoneOffsetMinutes)

Get admin aggregate dashboard metrics for users, billing, retention, engagement, and operations

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminDashboardApi();
final String period = week; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final String timezone = Asia/Ho_Chi_Minh; // String | 
final num timezoneOffsetMinutes = 420; // num | 

try {
    api.adminDashboardControllerGetOverview(period, from, to, timezone, timezoneOffsetMinutes);
} on DioException catch (e) {
    print('Exception when calling AdminDashboardApi->adminDashboardControllerGetOverview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **period** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **timezone** | **String**|  | [optional] 
 **timezoneOffsetMinutes** | **num**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDashboardControllerSearch**
> adminDashboardControllerSearch(q, entityType, skip, limit)

Search indexed dashboard/admin content

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminDashboardApi();
final String q = q_example; // String | 
final String entityType = entityType_example; // String | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    api.adminDashboardControllerSearch(q, entityType, skip, limit);
} on DioException catch (e) {
    print('Exception when calling AdminDashboardApi->adminDashboardControllerSearch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] 
 **entityType** | **String**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

