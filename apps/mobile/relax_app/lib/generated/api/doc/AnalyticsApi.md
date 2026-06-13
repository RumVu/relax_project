# relax_api_client.api.AnalyticsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**analyticsControllerGetContracts**](AnalyticsApi.md#analyticscontrollergetcontracts) | **GET** /v1/analytics/contracts | Get analytics response contracts for app charts
[**analyticsControllerGetOverview**](AnalyticsApi.md#analyticscontrollergetoverview) | **GET** /v1/analytics/me/overview | Get current user full analytics overview


# **analyticsControllerGetContracts**
> JsonObject analyticsControllerGetContracts()

Get analytics response contracts for app charts

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAnalyticsApi();

try {
    final response = api.analyticsControllerGetContracts();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->analyticsControllerGetContracts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **analyticsControllerGetOverview**
> JsonObject analyticsControllerGetOverview(period, timezoneOffsetMinutes, timezone)

Get current user full analytics overview

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAnalyticsApi();
final String period = week; // String | 
final num timezoneOffsetMinutes = 420; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.analyticsControllerGetOverview(period, timezoneOffsetMinutes, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->analyticsControllerGetOverview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **period** | **String**|  | [optional] 
 **timezoneOffsetMinutes** | **num**|  | [optional] 
 **timezone** | **String**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

