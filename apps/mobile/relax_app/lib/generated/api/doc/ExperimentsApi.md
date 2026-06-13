# relax_api_client.api.ExperimentsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**experimentsControllerCreate**](ExperimentsApi.md#experimentscontrollercreate) | **POST** /v1/experiments | Create an experiment (admin)
[**experimentsControllerDelete**](ExperimentsApi.md#experimentscontrollerdelete) | **DELETE** /v1/experiments/{key} | Delete an experiment (admin)
[**experimentsControllerFindAll**](ExperimentsApi.md#experimentscontrollerfindall) | **GET** /v1/experiments | List all experiments (admin)
[**experimentsControllerGetAssignment**](ExperimentsApi.md#experimentscontrollergetassignment) | **GET** /v1/experiments/me/{key} | Get my assignment for a specific experiment
[**experimentsControllerGetMyAssignments**](ExperimentsApi.md#experimentscontrollergetmyassignments) | **GET** /v1/experiments/me/assignments | Get all my experiment assignments
[**experimentsControllerLogEvent**](ExperimentsApi.md#experimentscontrollerlogevent) | **POST** /v1/experiments/me/events | Log an experiment event
[**experimentsControllerUpdate**](ExperimentsApi.md#experimentscontrollerupdate) | **PATCH** /v1/experiments/{key} | Update an experiment (admin)


# **experimentsControllerCreate**
> experimentsControllerCreate(createExperimentDto)

Create an experiment (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getExperimentsApi();
final CreateExperimentDto createExperimentDto = ; // CreateExperimentDto | 

try {
    api.experimentsControllerCreate(createExperimentDto);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->experimentsControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createExperimentDto** | [**CreateExperimentDto**](CreateExperimentDto.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **experimentsControllerDelete**
> experimentsControllerDelete(key)

Delete an experiment (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getExperimentsApi();
final String key = key_example; // String | 

try {
    api.experimentsControllerDelete(key);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->experimentsControllerDelete: $e\n');
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

# **experimentsControllerFindAll**
> experimentsControllerFindAll()

List all experiments (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getExperimentsApi();

try {
    api.experimentsControllerFindAll();
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->experimentsControllerFindAll: $e\n');
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

# **experimentsControllerGetAssignment**
> experimentsControllerGetAssignment(key)

Get my assignment for a specific experiment

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getExperimentsApi();
final String key = key_example; // String | 

try {
    api.experimentsControllerGetAssignment(key);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->experimentsControllerGetAssignment: $e\n');
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

# **experimentsControllerGetMyAssignments**
> experimentsControllerGetMyAssignments()

Get all my experiment assignments

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getExperimentsApi();

try {
    api.experimentsControllerGetMyAssignments();
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->experimentsControllerGetMyAssignments: $e\n');
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

# **experimentsControllerLogEvent**
> experimentsControllerLogEvent(logExperimentEventDto)

Log an experiment event

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getExperimentsApi();
final LogExperimentEventDto logExperimentEventDto = ; // LogExperimentEventDto | 

try {
    api.experimentsControllerLogEvent(logExperimentEventDto);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->experimentsControllerLogEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logExperimentEventDto** | [**LogExperimentEventDto**](LogExperimentEventDto.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **experimentsControllerUpdate**
> experimentsControllerUpdate(key, updateExperimentDto)

Update an experiment (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getExperimentsApi();
final String key = key_example; // String | 
final UpdateExperimentDto updateExperimentDto = ; // UpdateExperimentDto | 

try {
    api.experimentsControllerUpdate(key, updateExperimentDto);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->experimentsControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **updateExperimentDto** | [**UpdateExperimentDto**](UpdateExperimentDto.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

