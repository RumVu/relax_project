# relax_api_client.api.QueuesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**queuesControllerHealth**](QueuesApi.md#queuescontrollerhealth) | **GET** /v1/queues/health | Get Redis-backed queue health and registered queue names


# **queuesControllerHealth**
> JsonObject queuesControllerHealth(deep)

Get Redis-backed queue health and registered queue names

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getQueuesApi();
final String deep = true; // String | Set true to run a real Redis PING for queue infrastructure.

try {
    final response = api.queuesControllerHealth(deep);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QueuesApi->queuesControllerHealth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deep** | **String**| Set true to run a real Redis PING for queue infrastructure. | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

