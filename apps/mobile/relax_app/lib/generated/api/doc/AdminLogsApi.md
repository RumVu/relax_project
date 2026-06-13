# relax_api_client.api.AdminLogsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminLogsControllerFindAll**](AdminLogsApi.md#adminlogscontrollerfindall) | **GET** /v1/admin-logs | List admin audit logs


# **adminLogsControllerFindAll**
> AdminLogPageDto adminLogsControllerFindAll(adminId, action, targetType, targetId, from, to, skip, limit)

List admin audit logs

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminLogsApi();
final String adminId = adminId_example; // String | 
final String action = action_example; // String | 
final String targetType = targetType_example; // String | 
final String targetId = targetId_example; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.adminLogsControllerFindAll(adminId, action, targetType, targetId, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminLogsApi->adminLogsControllerFindAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminId** | **String**|  | [optional] 
 **action** | **String**|  | [optional] 
 **targetType** | **String**|  | [optional] 
 **targetId** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**AdminLogPageDto**](AdminLogPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

