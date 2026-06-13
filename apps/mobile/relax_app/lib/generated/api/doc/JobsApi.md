# relax_api_client.api.JobsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**jobsControllerEnqueueWeeklyMoodStats**](JobsApi.md#jobscontrollerenqueueweeklymoodstats) | **POST** /v1/jobs/weekly-mood-stats/enqueue | Enqueue weekly mood stats materialization job (admin)
[**jobsControllerGetStatus**](JobsApi.md#jobscontrollergetstatus) | **GET** /v1/jobs/status | Get backend job status (admin)
[**jobsControllerRunWeeklyMoodStats**](JobsApi.md#jobscontrollerrunweeklymoodstats) | **POST** /v1/jobs/weekly-mood-stats/run | Run weekly mood stats materialization job (admin)


# **jobsControllerEnqueueWeeklyMoodStats**
> JsonObject jobsControllerEnqueueWeeklyMoodStats(runWeeklyMoodStatsJobDto)

Enqueue weekly mood stats materialization job (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJobsApi();
final RunWeeklyMoodStatsJobDto runWeeklyMoodStatsJobDto = {"userId":"clx_user_01hv7q6y8e9r0t1y2u3i4o5p","from":"2026-05-11T00:00:00.000Z","to":"2026-05-17T23:59:59.999Z","timezone":"Asia/Ho_Chi_Minh","limit":100}; // RunWeeklyMoodStatsJobDto | 

try {
    final response = api.jobsControllerEnqueueWeeklyMoodStats(runWeeklyMoodStatsJobDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JobsApi->jobsControllerEnqueueWeeklyMoodStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runWeeklyMoodStatsJobDto** | [**RunWeeklyMoodStatsJobDto**](RunWeeklyMoodStatsJobDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **jobsControllerGetStatus**
> JsonObject jobsControllerGetStatus()

Get backend job status (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJobsApi();

try {
    final response = api.jobsControllerGetStatus();
    print(response);
} on DioException catch (e) {
    print('Exception when calling JobsApi->jobsControllerGetStatus: $e\n');
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

# **jobsControllerRunWeeklyMoodStats**
> JsonObject jobsControllerRunWeeklyMoodStats(runWeeklyMoodStatsJobDto)

Run weekly mood stats materialization job (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJobsApi();
final RunWeeklyMoodStatsJobDto runWeeklyMoodStatsJobDto = {"userId":"clx_user_01hv7q6y8e9r0t1y2u3i4o5p","from":"2026-05-11T00:00:00.000Z","to":"2026-05-17T23:59:59.999Z","timezone":"Asia/Ho_Chi_Minh","limit":100}; // RunWeeklyMoodStatsJobDto | 

try {
    final response = api.jobsControllerRunWeeklyMoodStats(runWeeklyMoodStatsJobDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JobsApi->jobsControllerRunWeeklyMoodStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runWeeklyMoodStatsJobDto** | [**RunWeeklyMoodStatsJobDto**](RunWeeklyMoodStatsJobDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

