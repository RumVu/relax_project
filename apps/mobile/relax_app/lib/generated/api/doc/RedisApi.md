# relax_api_client.api.RedisApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**redisControllerHealth**](RedisApi.md#rediscontrollerhealth) | **GET** /v1/redis/health | Get Redis configuration and optional deep connectivity health


# **redisControllerHealth**
> redisControllerHealth(deep)

Get Redis configuration and optional deep connectivity health

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRedisApi();
final String deep = true; // String | Set true to run a real Redis PING.

try {
    api.redisControllerHealth(deep);
} on DioException catch (e) {
    print('Exception when calling RedisApi->redisControllerHealth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deep** | **String**| Set true to run a real Redis PING. | [optional] 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

