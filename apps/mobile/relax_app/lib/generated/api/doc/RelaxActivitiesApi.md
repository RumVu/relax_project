# relax_api_client.api.RelaxActivitiesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**relaxActivitiesControllerFinishSession**](RelaxActivitiesApi.md#relaxactivitiescontrollerfinishsession) | **POST** /v1/relax-activities/sessions/{id}/finish | Finish current user relax activity session
[**relaxActivitiesControllerGetActivities**](RelaxActivitiesApi.md#relaxactivitiescontrollergetactivities) | **GET** /v1/relax-activities | List relax activity options
[**relaxActivitiesControllerGetStats**](RelaxActivitiesApi.md#relaxactivitiescontrollergetstats) | **GET** /v1/relax-activities/me/stats | Get current user relax statistics
[**relaxActivitiesControllerListSessions**](RelaxActivitiesApi.md#relaxactivitiescontrollerlistsessions) | **GET** /v1/relax-activities/me/sessions | List current user finished relax sessions
[**relaxActivitiesControllerStartSession**](RelaxActivitiesApi.md#relaxactivitiescontrollerstartsession) | **POST** /v1/relax-activities/sessions/start | Start current user relax activity session


# **relaxActivitiesControllerFinishSession**
> JsonObject relaxActivitiesControllerFinishSession(id, finishRelaxSessionDto)

Finish current user relax activity session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxActivitiesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final FinishRelaxSessionDto finishRelaxSessionDto = {"moodAfter":"CALM","reliefLevel":4,"note":"Nghe nhạc xong thấy nhẹ đầu hơn.","nextActionAccepted":"PODCAST"}; // FinishRelaxSessionDto | 

try {
    final response = api.relaxActivitiesControllerFinishSession(id, finishRelaxSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxActivitiesApi->relaxActivitiesControllerFinishSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **finishRelaxSessionDto** | [**FinishRelaxSessionDto**](FinishRelaxSessionDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **relaxActivitiesControllerGetActivities**
> JsonObject relaxActivitiesControllerGetActivities()

List relax activity options

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxActivitiesApi();

try {
    final response = api.relaxActivitiesControllerGetActivities();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxActivitiesApi->relaxActivitiesControllerGetActivities: $e\n');
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

# **relaxActivitiesControllerGetStats**
> JsonObject relaxActivitiesControllerGetStats(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone)

Get current user relax statistics

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxActivitiesApi();
final JsonObject activityType = MUSIC; // JsonObject | 
final String period = week; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 
final num timezoneOffsetMinutes = 420; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.relaxActivitiesControllerGetStats(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxActivitiesApi->relaxActivitiesControllerGetStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityType** | [**JsonObject**](.md)|  | [optional] 
 **period** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 
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

# **relaxActivitiesControllerListSessions**
> RelaxSessionPageDto relaxActivitiesControllerListSessions(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone)

List current user finished relax sessions

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxActivitiesApi();
final JsonObject activityType = MUSIC; // JsonObject | 
final String period = week; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 
final num timezoneOffsetMinutes = 420; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.relaxActivitiesControllerListSessions(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxActivitiesApi->relaxActivitiesControllerListSessions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityType** | [**JsonObject**](.md)|  | [optional] 
 **period** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 
 **timezoneOffsetMinutes** | **num**|  | [optional] 
 **timezone** | **String**|  | [optional] 

### Return type

[**RelaxSessionPageDto**](RelaxSessionPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **relaxActivitiesControllerStartSession**
> RelaxSessionResponseDto relaxActivitiesControllerStartSession(startRelaxSessionDto)

Start current user relax activity session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxActivitiesApi();
final StartRelaxSessionDto startRelaxSessionDto = {"activityType":"MUSIC","resourceId":"ambient_lofi_chill","title":"Lo-fi Chill - Pixel Beats","moodBefore":"STRESSED"}; // StartRelaxSessionDto | 

try {
    final response = api.relaxActivitiesControllerStartSession(startRelaxSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxActivitiesApi->relaxActivitiesControllerStartSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startRelaxSessionDto** | [**StartRelaxSessionDto**](StartRelaxSessionDto.md)|  | 

### Return type

[**RelaxSessionResponseDto**](RelaxSessionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

