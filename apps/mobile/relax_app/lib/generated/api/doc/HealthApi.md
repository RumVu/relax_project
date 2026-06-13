# relax_api_client.api.HealthApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**appControllerGetApiIndex**](HealthApi.md#appcontrollergetapiindex) | **GET** / | Get API index and exposed module map
[**appControllerGetApiIndexAlias**](HealthApi.md#appcontrollergetapiindexalias) | **GET** /api | Get API index alias
[**appControllerGetHealth**](HealthApi.md#appcontrollergethealth) | **GET** /health | Get shallow API liveness status
[**appControllerGetOps**](HealthApi.md#appcontrollergetops) | **GET** /v1/ops | Get full ops status for admin dashboard
[**appControllerGetReady**](HealthApi.md#appcontrollergetready) | **GET** /ready | Get deep API readiness status


# **appControllerGetApiIndex**
> JsonObject appControllerGetApiIndex()

Get API index and exposed module map

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getHealthApi();

try {
    final response = api.appControllerGetApiIndex();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->appControllerGetApiIndex: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appControllerGetApiIndexAlias**
> JsonObject appControllerGetApiIndexAlias()

Get API index alias

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getHealthApi();

try {
    final response = api.appControllerGetApiIndexAlias();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->appControllerGetApiIndexAlias: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appControllerGetHealth**
> JsonObject appControllerGetHealth(deep)

Get shallow API liveness status

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getHealthApi();
final String deep = true; // String | Set true to include database/storage readiness without changing the /ready contract.

try {
    final response = api.appControllerGetHealth(deep);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->appControllerGetHealth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deep** | **String**| Set true to include database/storage readiness without changing the /ready contract. | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appControllerGetOps**
> appControllerGetOps()

Get full ops status for admin dashboard

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getHealthApi();

try {
    api.appControllerGetOps();
} on DioException catch (e) {
    print('Exception when calling HealthApi->appControllerGetOps: $e\n');
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

# **appControllerGetReady**
> JsonObject appControllerGetReady()

Get deep API readiness status

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getHealthApi();

try {
    final response = api.appControllerGetReady();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->appControllerGetReady: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

