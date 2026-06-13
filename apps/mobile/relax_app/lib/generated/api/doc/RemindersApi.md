# relax_api_client.api.RemindersApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**remindersControllerCreateMine**](RemindersApi.md#reminderscontrollercreatemine) | **POST** /v1/reminders/me | Create current user reminder
[**remindersControllerFindOne**](RemindersApi.md#reminderscontrollerfindone) | **GET** /v1/reminders/{id} | Get one reminder by id
[**remindersControllerGetMineStats**](RemindersApi.md#reminderscontrollergetminestats) | **GET** /v1/reminders/me/stats | Get current user reminder stats
[**remindersControllerListAll**](RemindersApi.md#reminderscontrollerlistall) | **GET** /v1/reminders | List all reminders (admin)
[**remindersControllerListByUserId**](RemindersApi.md#reminderscontrollerlistbyuserid) | **GET** /v1/reminders/user/{userId} | List reminders by user id (admin)
[**remindersControllerListMine**](RemindersApi.md#reminderscontrollerlistmine) | **GET** /v1/reminders/me | List current user reminders
[**remindersControllerRemove**](RemindersApi.md#reminderscontrollerremove) | **DELETE** /v1/reminders/{id} | Delete one reminder by id
[**remindersControllerUpdate**](RemindersApi.md#reminderscontrollerupdate) | **PATCH** /v1/reminders/{id} | Update one reminder by id


# **remindersControllerCreateMine**
> ReminderResponseDto remindersControllerCreateMine(createReminderDto)

Create current user reminder

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();
final CreateReminderDto createReminderDto = {"title":"Uống nước một chút nha","message":"Một ngụm nước nhỏ cũng giúp cơ thể dịu lại.","type":"WATER","scheduledAt":"2026-05-17T09:00:00.000Z","repeatRule":"0 9 * * *","isActive":true}; // CreateReminderDto | 

try {
    final response = api.remindersControllerCreateMine(createReminderDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerCreateMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createReminderDto** | [**CreateReminderDto**](CreateReminderDto.md)|  | 

### Return type

[**ReminderResponseDto**](ReminderResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **remindersControllerFindOne**
> ReminderResponseDto remindersControllerFindOne(id)

Get one reminder by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.remindersControllerFindOne(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerFindOne: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ReminderResponseDto**](ReminderResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **remindersControllerGetMineStats**
> JsonObject remindersControllerGetMineStats()

Get current user reminder stats

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();

try {
    final response = api.remindersControllerGetMineStats();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerGetMineStats: $e\n');
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

# **remindersControllerListAll**
> ReminderPageDto remindersControllerListAll(type, isActive, from, to, skip, limit)

List all reminders (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();
final JsonObject type = Object; // JsonObject | 
final bool isActive = true; // bool | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.remindersControllerListAll(type, isActive, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerListAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | [**JsonObject**](.md)|  | [optional] 
 **isActive** | **bool**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**ReminderPageDto**](ReminderPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **remindersControllerListByUserId**
> ReminderPageDto remindersControllerListByUserId(userId, type, isActive, from, to, skip, limit)

List reminders by user id (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final JsonObject type = Object; // JsonObject | 
final bool isActive = true; // bool | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.remindersControllerListByUserId(userId, type, isActive, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerListByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **type** | [**JsonObject**](.md)|  | [optional] 
 **isActive** | **bool**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**ReminderPageDto**](ReminderPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **remindersControllerListMine**
> ReminderPageDto remindersControllerListMine(type, isActive, from, to, skip, limit)

List current user reminders

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();
final JsonObject type = Object; // JsonObject | 
final bool isActive = true; // bool | 
final DateTime from = 2026-05-11T00:00:00.000Z; // DateTime | 
final DateTime to = 2026-05-16T23:59:59.999Z; // DateTime | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.remindersControllerListMine(type, isActive, from, to, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerListMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | [**JsonObject**](.md)|  | [optional] 
 **isActive** | **bool**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**ReminderPageDto**](ReminderPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **remindersControllerRemove**
> JsonObject remindersControllerRemove(id)

Delete one reminder by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.remindersControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **remindersControllerUpdate**
> ReminderResponseDto remindersControllerUpdate(id, updateReminderDto)

Update one reminder by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRemindersApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateReminderDto updateReminderDto = {"scheduledAt":"2026-05-17T10:00:00.000Z","isActive":true}; // UpdateReminderDto | 

try {
    final response = api.remindersControllerUpdate(id, updateReminderDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RemindersApi->remindersControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateReminderDto** | [**UpdateReminderDto**](UpdateReminderDto.md)|  | 

### Return type

[**ReminderResponseDto**](ReminderResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

