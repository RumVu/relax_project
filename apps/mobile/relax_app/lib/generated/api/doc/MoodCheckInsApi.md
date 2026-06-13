# relax_api_client.api.MoodCheckInsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**moodCheckinsControllerCreateMine**](MoodCheckInsApi.md#moodcheckinscontrollercreatemine) | **POST** /v1/mood-checkins/me | Create current user mood check-in
[**moodCheckinsControllerFindAll**](MoodCheckInsApi.md#moodcheckinscontrollerfindall) | **GET** /v1/mood-checkins | List all mood check-ins (admin)
[**moodCheckinsControllerFindByUserId**](MoodCheckInsApi.md#moodcheckinscontrollerfindbyuserid) | **GET** /v1/mood-checkins/user/{userId} | List mood check-ins by user id (admin)
[**moodCheckinsControllerFindMine**](MoodCheckInsApi.md#moodcheckinscontrollerfindmine) | **GET** /v1/mood-checkins/me | List current user mood check-ins
[**moodCheckinsControllerFindMineLatest**](MoodCheckInsApi.md#moodcheckinscontrollerfindminelatest) | **GET** /v1/mood-checkins/me/latest | Get current user latest mood check-in
[**moodCheckinsControllerFindOne**](MoodCheckInsApi.md#moodcheckinscontrollerfindone) | **GET** /v1/mood-checkins/{id} | Get one mood check-in by id
[**moodCheckinsControllerGetAnalyticsByUserId**](MoodCheckInsApi.md#moodcheckinscontrollergetanalyticsbyuserid) | **GET** /v1/mood-checkins/user/{userId}/analytics | Get mood analytics by user id (admin)
[**moodCheckinsControllerGetMineAnalytics**](MoodCheckInsApi.md#moodcheckinscontrollergetmineanalytics) | **GET** /v1/mood-checkins/me/analytics | Get current user mood analytics timeline
[**moodCheckinsControllerGetMineDashboard**](MoodCheckInsApi.md#moodcheckinscontrollergetminedashboard) | **GET** /v1/mood-checkins/me/dashboard | Get current user mood dashboard
[**moodCheckinsControllerGetMineRecommendations**](MoodCheckInsApi.md#moodcheckinscontrollergetminerecommendations) | **GET** /v1/mood-checkins/me/recommendations | Get recommended relax actions for a mood
[**moodCheckinsControllerGetMineStats**](MoodCheckInsApi.md#moodcheckinscontrollergetminestats) | **GET** /v1/mood-checkins/me/stats | Get current user mood statistics
[**moodCheckinsControllerGetMineWeeklyStats**](MoodCheckInsApi.md#moodcheckinscontrollergetmineweeklystats) | **GET** /v1/mood-checkins/me/weekly-stats | Get current user materialized weekly mood stats
[**moodCheckinsControllerGetOptions**](MoodCheckInsApi.md#moodcheckinscontrollergetoptions) | **GET** /v1/mood-checkins/options | List mood options for the mood onboarding screen
[**moodCheckinsControllerGetStatsByUserId**](MoodCheckInsApi.md#moodcheckinscontrollergetstatsbyuserid) | **GET** /v1/mood-checkins/user/{userId}/stats | Get mood statistics by user id (admin)
[**moodCheckinsControllerGetWeeklyStatsByUserId**](MoodCheckInsApi.md#moodcheckinscontrollergetweeklystatsbyuserid) | **GET** /v1/mood-checkins/user/{userId}/weekly-stats | Get materialized weekly mood stats by user id (admin)
[**moodCheckinsControllerRecalculateMineWeeklyStats**](MoodCheckInsApi.md#moodcheckinscontrollerrecalculatemineweeklystats) | **POST** /v1/mood-checkins/me/weekly-stats/recalculate | Recalculate current user materialized weekly mood stats
[**moodCheckinsControllerRecalculateWeeklyStatsByUserId**](MoodCheckInsApi.md#moodcheckinscontrollerrecalculateweeklystatsbyuserid) | **POST** /v1/mood-checkins/user/{userId}/weekly-stats/recalculate | Recalculate weekly mood stats by user id (admin)
[**moodCheckinsControllerRemove**](MoodCheckInsApi.md#moodcheckinscontrollerremove) | **DELETE** /v1/mood-checkins/{id} | Delete one mood check-in by id
[**moodCheckinsControllerUpdate**](MoodCheckInsApi.md#moodcheckinscontrollerupdate) | **PATCH** /v1/mood-checkins/{id} | Update one mood check-in by id


# **moodCheckinsControllerCreateMine**
> MoodCheckinResponseDto moodCheckinsControllerCreateMine(createMoodCheckinDto)

Create current user mood check-in

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final CreateMoodCheckinDto createMoodCheckinDto = {"mood":"STRESSED","intensity":4,"note":"Stress quá mới tìm đến tui hở?","tags":["deadline","work"]}; // CreateMoodCheckinDto | 

try {
    final response = api.moodCheckinsControllerCreateMine(createMoodCheckinDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerCreateMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createMoodCheckinDto** | [**CreateMoodCheckinDto**](CreateMoodCheckinDto.md)|  | 

### Return type

[**MoodCheckinResponseDto**](MoodCheckinResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerFindAll**
> MoodCheckinPageDto moodCheckinsControllerFindAll(mood, from, to, skip, limit)

List all mood check-ins (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerFindAll(mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerFindAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**MoodCheckinPageDto**](MoodCheckinPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerFindByUserId**
> MoodCheckinPageDto moodCheckinsControllerFindByUserId(userId, mood, from, to, skip, limit)

List mood check-ins by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerFindByUserId(userId, mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerFindByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**MoodCheckinPageDto**](MoodCheckinPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerFindMine**
> MoodCheckinPageDto moodCheckinsControllerFindMine(mood, from, to, skip, limit)

List current user mood check-ins

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerFindMine(mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerFindMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**MoodCheckinPageDto**](MoodCheckinPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerFindMineLatest**
> MoodCheckinResponseDto moodCheckinsControllerFindMineLatest()

Get current user latest mood check-in

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();

try {
    final response = api.moodCheckinsControllerFindMineLatest();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerFindMineLatest: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MoodCheckinResponseDto**](MoodCheckinResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerFindOne**
> MoodCheckinResponseDto moodCheckinsControllerFindOne(id)

Get one mood check-in by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.moodCheckinsControllerFindOne(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerFindOne: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**MoodCheckinResponseDto**](MoodCheckinResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerGetAnalyticsByUserId**
> JsonObject moodCheckinsControllerGetAnalyticsByUserId(userId, period, from, to, compare, timezoneOffsetMinutes, timezone)

Get mood analytics by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final String period = week; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final bool compare = true; // bool | 
final num timezoneOffsetMinutes = 420; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.moodCheckinsControllerGetAnalyticsByUserId(userId, period, from, to, compare, timezoneOffsetMinutes, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetAnalyticsByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **period** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **compare** | **bool**|  | [optional] 
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

# **moodCheckinsControllerGetMineAnalytics**
> JsonObject moodCheckinsControllerGetMineAnalytics(period, from, to, compare, timezoneOffsetMinutes, timezone)

Get current user mood analytics timeline

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String period = week; // String | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final bool compare = true; // bool | 
final num timezoneOffsetMinutes = 420; // num | 
final String timezone = Asia/Ho_Chi_Minh; // String | 

try {
    final response = api.moodCheckinsControllerGetMineAnalytics(period, from, to, compare, timezoneOffsetMinutes, timezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetMineAnalytics: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **period** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **compare** | **bool**|  | [optional] 
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

# **moodCheckinsControllerGetMineDashboard**
> JsonObject moodCheckinsControllerGetMineDashboard(mood, from, to, skip, limit)

Get current user mood dashboard

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerGetMineDashboard(mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetMineDashboard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerGetMineRecommendations**
> BuiltList<String> moodCheckinsControllerGetMineRecommendations(mood)

Get recommended relax actions for a mood

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String mood = STRESSED; // String | 

try {
    final response = api.moodCheckinsControllerGetMineRecommendations(mood);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetMineRecommendations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mood** | **String**|  | [optional] 

### Return type

**BuiltList&lt;String&gt;**

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerGetMineStats**
> JsonObject moodCheckinsControllerGetMineStats(mood, from, to, skip, limit)

Get current user mood statistics

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerGetMineStats(mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetMineStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerGetMineWeeklyStats**
> BuiltList<WeeklyMoodStatResponseDto> moodCheckinsControllerGetMineWeeklyStats(mood, from, to, skip, limit)

Get current user materialized weekly mood stats

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerGetMineWeeklyStats(mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetMineWeeklyStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**BuiltList&lt;WeeklyMoodStatResponseDto&gt;**](WeeklyMoodStatResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerGetOptions**
> BuiltList<String> moodCheckinsControllerGetOptions()

List mood options for the mood onboarding screen

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();

try {
    final response = api.moodCheckinsControllerGetOptions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetOptions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**BuiltList&lt;String&gt;**

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerGetStatsByUserId**
> JsonObject moodCheckinsControllerGetStatsByUserId(userId, mood, from, to, skip, limit)

Get mood statistics by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerGetStatsByUserId(userId, mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetStatsByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerGetWeeklyStatsByUserId**
> BuiltList<WeeklyMoodStatResponseDto> moodCheckinsControllerGetWeeklyStatsByUserId(userId, mood, from, to, skip, limit)

Get materialized weekly mood stats by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final JsonObject mood = STRESSED; // JsonObject | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.moodCheckinsControllerGetWeeklyStatsByUserId(userId, mood, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerGetWeeklyStatsByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**BuiltList&lt;WeeklyMoodStatResponseDto&gt;**](WeeklyMoodStatResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerRecalculateMineWeeklyStats**
> JsonObject moodCheckinsControllerRecalculateMineWeeklyStats(recalculateWeeklyMoodStatsDto)

Recalculate current user materialized weekly mood stats

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final RecalculateWeeklyMoodStatsDto recalculateWeeklyMoodStatsDto = {"from":"2026-05-11T00:00:00.000Z","to":"2026-05-17T23:59:59.999Z","timezone":"Asia/Ho_Chi_Minh"}; // RecalculateWeeklyMoodStatsDto | 

try {
    final response = api.moodCheckinsControllerRecalculateMineWeeklyStats(recalculateWeeklyMoodStatsDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerRecalculateMineWeeklyStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **recalculateWeeklyMoodStatsDto** | [**RecalculateWeeklyMoodStatsDto**](RecalculateWeeklyMoodStatsDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerRecalculateWeeklyStatsByUserId**
> JsonObject moodCheckinsControllerRecalculateWeeklyStatsByUserId(userId, recalculateWeeklyMoodStatsDto)

Recalculate weekly mood stats by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final RecalculateWeeklyMoodStatsDto recalculateWeeklyMoodStatsDto = {"from":"2026-05-11T00:00:00.000Z","to":"2026-05-17T23:59:59.999Z","timezone":"Asia/Ho_Chi_Minh"}; // RecalculateWeeklyMoodStatsDto | 

try {
    final response = api.moodCheckinsControllerRecalculateWeeklyStatsByUserId(userId, recalculateWeeklyMoodStatsDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerRecalculateWeeklyStatsByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **recalculateWeeklyMoodStatsDto** | [**RecalculateWeeklyMoodStatsDto**](RecalculateWeeklyMoodStatsDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerRemove**
> MoodCheckinResponseDto moodCheckinsControllerRemove(id)

Delete one mood check-in by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.moodCheckinsControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**MoodCheckinResponseDto**](MoodCheckinResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moodCheckinsControllerUpdate**
> MoodCheckinResponseDto moodCheckinsControllerUpdate(id, updateMoodCheckinDto)

Update one mood check-in by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMoodCheckInsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateMoodCheckinDto updateMoodCheckinDto = {"mood":"CALM","intensity":2,"note":"Đã nhẹ hơn sau khi nghe nhạc.","tags":["music","relieved"]}; // UpdateMoodCheckinDto | 

try {
    final response = api.moodCheckinsControllerUpdate(id, updateMoodCheckinDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MoodCheckInsApi->moodCheckinsControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateMoodCheckinDto** | [**UpdateMoodCheckinDto**](UpdateMoodCheckinDto.md)|  | 

### Return type

[**MoodCheckinResponseDto**](MoodCheckinResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

