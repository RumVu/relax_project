# relax_api_client.api.RelaxSessionsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**relaxSessionsControllerFinish**](RelaxSessionsApi.md#relaxsessionscontrollerfinish) | **POST** /v1/relax-sessions/{id}/finish | Finish current user relax session
[**relaxSessionsControllerList**](RelaxSessionsApi.md#relaxsessionscontrollerlist) | **GET** /v1/relax-sessions/me | List current user relax sessions
[**relaxSessionsControllerStart**](RelaxSessionsApi.md#relaxsessionscontrollerstart) | **POST** /v1/relax-sessions/start | Start current user relax session
[**relaxSessionsControllerStats**](RelaxSessionsApi.md#relaxsessionscontrollerstats) | **GET** /v1/relax-sessions/me/stats | Get current user relax session stats


# **relaxSessionsControllerFinish**
> JsonObject relaxSessionsControllerFinish(id, finishRelaxSessionDto)

Finish current user relax session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxSessionsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final FinishRelaxSessionDto finishRelaxSessionDto = {"moodAfter":"CALM","reliefLevel":4,"note":"Nghe nhạc xong thấy nhẹ đầu hơn.","nextActionAccepted":"PODCAST"}; // FinishRelaxSessionDto | 

try {
    final response = api.relaxSessionsControllerFinish(id, finishRelaxSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxSessionsApi->relaxSessionsControllerFinish: $e\n');
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

# **relaxSessionsControllerList**
> RelaxSessionPageDto relaxSessionsControllerList(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone)

List current user relax sessions

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxSessionsApi();
final JsonObject activityType = MUSIC; // JsonObject | 
final String period = week; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 
final num timezoneOffsetMinutes = 420; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.relaxSessionsControllerList(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxSessionsApi->relaxSessionsControllerList: $e\n');
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

# **relaxSessionsControllerStart**
> RelaxSessionResponseDto relaxSessionsControllerStart(startRelaxSessionDto)

Start current user relax session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxSessionsApi();
final StartRelaxSessionDto startRelaxSessionDto = {"activityType":"MUSIC","resourceId":"ambient_lofi_chill","title":"Lo-fi Chill - Pixel Beats","moodBefore":"STRESSED"}; // StartRelaxSessionDto | 

try {
    final response = api.relaxSessionsControllerStart(startRelaxSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxSessionsApi->relaxSessionsControllerStart: $e\n');
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

# **relaxSessionsControllerStats**
> JsonObject relaxSessionsControllerStats(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone)

Get current user relax session stats

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRelaxSessionsApi();
final JsonObject activityType = MUSIC; // JsonObject | 
final String period = week; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 
final num timezoneOffsetMinutes = 420; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.relaxSessionsControllerStats(activityType, period, from, to, skip, limit, timezoneOffsetMinutes, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RelaxSessionsApi->relaxSessionsControllerStats: $e\n');
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

