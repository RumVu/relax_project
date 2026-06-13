# relax_api_client.api.RealtimeApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**realtimeControllerHealth**](RealtimeApi.md#realtimecontrollerhealth) | **GET** /v1/realtime/health | Get Socket.IO realtime status and Redis adapter mode


# **realtimeControllerHealth**
> JsonObject realtimeControllerHealth()

Get Socket.IO realtime status and Redis adapter mode

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRealtimeApi();

try {
    final response = api.realtimeControllerHealth();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RealtimeApi->realtimeControllerHealth: $e\n');
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

