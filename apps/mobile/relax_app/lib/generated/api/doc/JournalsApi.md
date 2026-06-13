# relax_api_client.api.JournalsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**journalsControllerCreateMine**](JournalsApi.md#journalscontrollercreatemine) | **POST** /v1/journals/me | Create current user journal
[**journalsControllerFindByUserId**](JournalsApi.md#journalscontrollerfindbyuserid) | **GET** /v1/journals/user/{userId} | List journals by user id (admin)
[**journalsControllerFindMine**](JournalsApi.md#journalscontrollerfindmine) | **GET** /v1/journals/me | List current user journals
[**journalsControllerFindOne**](JournalsApi.md#journalscontrollerfindone) | **GET** /v1/journals/{id} | Get one journal by id
[**journalsControllerGetMineStats**](JournalsApi.md#journalscontrollergetminestats) | **GET** /v1/journals/me/stats | Get current user journal stats
[**journalsControllerRemove**](JournalsApi.md#journalscontrollerremove) | **DELETE** /v1/journals/{id} | Delete one journal by id
[**journalsControllerUpdate**](JournalsApi.md#journalscontrollerupdate) | **PATCH** /v1/journals/{id} | Update one journal by id


# **journalsControllerCreateMine**
> JournalResponseDto journalsControllerCreateMine(createJournalDto)

Create current user journal

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJournalsApi();
final CreateJournalDto createJournalDto = {"title":"Một chút nhẹ lòng","content":"Hôm nay mình đã nghỉ lại vài phút và thấy dễ thở hơn.","mood":"CALM","tags":["self-care","evening"],"isPrivate":true,"isFavorite":false}; // CreateJournalDto | 

try {
    final response = api.journalsControllerCreateMine(createJournalDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JournalsApi->journalsControllerCreateMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createJournalDto** | [**CreateJournalDto**](CreateJournalDto.md)|  | 

### Return type

[**JournalResponseDto**](JournalResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **journalsControllerFindByUserId**
> JournalPageDto journalsControllerFindByUserId(userId, q, mood, tag, isFavorite, from, to, skip, limit)

List journals by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJournalsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final String q = q_example; // String | 
final JsonObject mood = STRESSED; // JsonObject | 
final String tag = self-care; // String | 
final bool isFavorite = true; // bool | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.journalsControllerFindByUserId(userId, q, mood, tag, isFavorite, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JournalsApi->journalsControllerFindByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **q** | **String**|  | [optional] 
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **tag** | **String**|  | [optional] 
 **isFavorite** | **bool**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**JournalPageDto**](JournalPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **journalsControllerFindMine**
> JournalPageDto journalsControllerFindMine(q, mood, tag, isFavorite, from, to, skip, limit)

List current user journals

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJournalsApi();
final String q = q_example; // String | 
final JsonObject mood = STRESSED; // JsonObject | 
final String tag = self-care; // String | 
final bool isFavorite = true; // bool | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.journalsControllerFindMine(q, mood, tag, isFavorite, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JournalsApi->journalsControllerFindMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] 
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **tag** | **String**|  | [optional] 
 **isFavorite** | **bool**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**JournalPageDto**](JournalPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **journalsControllerFindOne**
> JournalResponseDto journalsControllerFindOne(id)

Get one journal by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJournalsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.journalsControllerFindOne(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JournalsApi->journalsControllerFindOne: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**JournalResponseDto**](JournalResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **journalsControllerGetMineStats**
> JsonObject journalsControllerGetMineStats(q, mood, tag, isFavorite, from, to, skip, limit)

Get current user journal stats

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJournalsApi();
final String q = q_example; // String | 
final JsonObject mood = STRESSED; // JsonObject | 
final String tag = self-care; // String | 
final bool isFavorite = true; // bool | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.journalsControllerGetMineStats(q, mood, tag, isFavorite, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JournalsApi->journalsControllerGetMineStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] 
 **mood** | [**JsonObject**](.md)|  | [optional] 
 **tag** | **String**|  | [optional] 
 **isFavorite** | **bool**|  | [optional] 
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

# **journalsControllerRemove**
> JournalResponseDto journalsControllerRemove(id)

Delete one journal by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJournalsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.journalsControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JournalsApi->journalsControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**JournalResponseDto**](JournalResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **journalsControllerUpdate**
> JournalResponseDto journalsControllerUpdate(id, updateJournalDto)

Update one journal by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getJournalsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateJournalDto updateJournalDto = {"title":"Một chút nhẹ lòng hơn","content":"Mình thử viết thêm vài dòng sau buổi thư giãn.","mood":"CALM","tags":["self-care","music"],"isFavorite":true}; // UpdateJournalDto | 

try {
    final response = api.journalsControllerUpdate(id, updateJournalDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling JournalsApi->journalsControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateJournalDto** | [**UpdateJournalDto**](UpdateJournalDto.md)|  | 

### Return type

[**JournalResponseDto**](JournalResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

