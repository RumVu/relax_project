# relax_api_client.api.FeatureFlagsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**featureFlagsControllerDelete**](FeatureFlagsApi.md#featureflagscontrollerdelete) | **DELETE** /v1/feature-flags/{key} | 
[**featureFlagsControllerFindAll**](FeatureFlagsApi.md#featureflagscontrollerfindall) | **GET** /v1/feature-flags | 
[**featureFlagsControllerFindByKey**](FeatureFlagsApi.md#featureflagscontrollerfindbykey) | **GET** /v1/feature-flags/{key} | 
[**featureFlagsControllerSeed**](FeatureFlagsApi.md#featureflagscontrollerseed) | **POST** /v1/feature-flags/seed | 
[**featureFlagsControllerToggle**](FeatureFlagsApi.md#featureflagscontrollertoggle) | **PATCH** /v1/feature-flags/{key}/toggle | 
[**featureFlagsControllerUpsert**](FeatureFlagsApi.md#featureflagscontrollerupsert) | **POST** /v1/feature-flags | 


# **featureFlagsControllerDelete**
> featureFlagsControllerDelete(key)



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFeatureFlagsApi();
final String key = key_example; // String | 

try {
    api.featureFlagsControllerDelete(key);
} on DioException catch (e) {
    print('Exception when calling FeatureFlagsApi->featureFlagsControllerDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **featureFlagsControllerFindAll**
> featureFlagsControllerFindAll()



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFeatureFlagsApi();

try {
    api.featureFlagsControllerFindAll();
} on DioException catch (e) {
    print('Exception when calling FeatureFlagsApi->featureFlagsControllerFindAll: $e\n');
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

# **featureFlagsControllerFindByKey**
> JsonObject featureFlagsControllerFindByKey(key)



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFeatureFlagsApi();
final String key = key_example; // String | 

try {
    final response = api.featureFlagsControllerFindByKey(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FeatureFlagsApi->featureFlagsControllerFindByKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **featureFlagsControllerSeed**
> featureFlagsControllerSeed()



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFeatureFlagsApi();

try {
    api.featureFlagsControllerSeed();
} on DioException catch (e) {
    print('Exception when calling FeatureFlagsApi->featureFlagsControllerSeed: $e\n');
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

# **featureFlagsControllerToggle**
> JsonObject featureFlagsControllerToggle(key)



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFeatureFlagsApi();
final String key = key_example; // String | 

try {
    final response = api.featureFlagsControllerToggle(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FeatureFlagsApi->featureFlagsControllerToggle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **featureFlagsControllerUpsert**
> featureFlagsControllerUpsert(upsertFeatureFlagDto)



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFeatureFlagsApi();
final UpsertFeatureFlagDto upsertFeatureFlagDto = ; // UpsertFeatureFlagDto | 

try {
    api.featureFlagsControllerUpsert(upsertFeatureFlagDto);
} on DioException catch (e) {
    print('Exception when calling FeatureFlagsApi->featureFlagsControllerUpsert: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **upsertFeatureFlagDto** | [**UpsertFeatureFlagDto**](UpsertFeatureFlagDto.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

