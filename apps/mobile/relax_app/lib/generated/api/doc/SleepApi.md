# relax_api_client.api.SleepApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**sleepControllerCreateSession**](SleepApi.md#sleepcontrollercreatesession) | **POST** /v1/sleep/sessions | Log a sleep session
[**sleepControllerFindSessions**](SleepApi.md#sleepcontrollerfindsessions) | **GET** /v1/sleep/sessions/me | Get current user sleep history


# **sleepControllerCreateSession**
> sleepControllerCreateSession(createSleepSessionDto)

Log a sleep session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getSleepApi();
final CreateSleepSessionDto createSleepSessionDto = ; // CreateSleepSessionDto | 

try {
    api.sleepControllerCreateSession(createSleepSessionDto);
} on DioException catch (e) {
    print('Exception when calling SleepApi->sleepControllerCreateSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSleepSessionDto** | [**CreateSleepSessionDto**](CreateSleepSessionDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sleepControllerFindSessions**
> sleepControllerFindSessions()

Get current user sleep history

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getSleepApi();

try {
    api.sleepControllerFindSessions();
} on DioException catch (e) {
    print('Exception when calling SleepApi->sleepControllerFindSessions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

