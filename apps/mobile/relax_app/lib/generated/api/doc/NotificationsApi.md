# relax_api_client.api.NotificationsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**notificationsControllerCreateForUser**](NotificationsApi.md#notificationscontrollercreateforuser) | **POST** /v1/notifications/user/{userId} | Create a notification for any user (admin)
[**notificationsControllerCreateTest**](NotificationsApi.md#notificationscontrollercreatetest) | **POST** /v1/notifications/me/test | Create a test notification for current user
[**notificationsControllerGetProviderStatus**](NotificationsApi.md#notificationscontrollergetproviderstatus) | **GET** /v1/notifications/providers | Get push/email provider configuration status
[**notificationsControllerGetUnreadCount**](NotificationsApi.md#notificationscontrollergetunreadcount) | **GET** /v1/notifications/me/unread-count | Get unread notification count
[**notificationsControllerListDevices**](NotificationsApi.md#notificationscontrollerlistdevices) | **GET** /v1/notifications/me/devices | List current user push devices
[**notificationsControllerListMine**](NotificationsApi.md#notificationscontrollerlistmine) | **GET** /v1/notifications/me | List current user notifications
[**notificationsControllerMarkAllRead**](NotificationsApi.md#notificationscontrollermarkallread) | **PATCH** /v1/notifications/me/read-all | Mark all current user notifications as read
[**notificationsControllerMarkRead**](NotificationsApi.md#notificationscontrollermarkread) | **PATCH** /v1/notifications/me/{id}/read | Mark one notification as read
[**notificationsControllerRegisterDevice**](NotificationsApi.md#notificationscontrollerregisterdevice) | **POST** /v1/notifications/me/devices | Register or update current user push device
[**notificationsControllerRemoveDevice**](NotificationsApi.md#notificationscontrollerremovedevice) | **DELETE** /v1/notifications/me/devices/{id} | Remove a current user push device


# **notificationsControllerCreateForUser**
> JsonObject notificationsControllerCreateForUser(userId, createNotificationDto)

Create a notification for any user (admin)

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();
final String userId = clx_user_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final CreateNotificationDto createNotificationDto = {"title":"Đến giờ check-in rồi nè","message":"Dừng lại một chút để hỏi lòng mình đang thế nào nha.","type":"PUSH"}; // CreateNotificationDto | 

try {
    final response = api.notificationsControllerCreateForUser(userId, createNotificationDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerCreateForUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **createNotificationDto** | [**CreateNotificationDto**](CreateNotificationDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerCreateTest**
> JsonObject notificationsControllerCreateTest(createNotificationDto)

Create a test notification for current user

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();
final CreateNotificationDto createNotificationDto = {"title":"Đến giờ check-in rồi nè","message":"Dừng lại một chút để hỏi lòng mình đang thế nào nha.","type":"PUSH"}; // CreateNotificationDto | 

try {
    final response = api.notificationsControllerCreateTest(createNotificationDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerCreateTest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createNotificationDto** | [**CreateNotificationDto**](CreateNotificationDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerGetProviderStatus**
> ProviderStatusResponseDto notificationsControllerGetProviderStatus()

Get push/email provider configuration status

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();

try {
    final response = api.notificationsControllerGetProviderStatus();
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerGetProviderStatus: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProviderStatusResponseDto**](ProviderStatusResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerGetUnreadCount**
> UnreadCountResponseDto notificationsControllerGetUnreadCount()

Get unread notification count

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();

try {
    final response = api.notificationsControllerGetUnreadCount();
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerGetUnreadCount: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UnreadCountResponseDto**](UnreadCountResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerListDevices**
> BuiltList<PushDeviceResponseDto> notificationsControllerListDevices()

List current user push devices

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();

try {
    final response = api.notificationsControllerListDevices();
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerListDevices: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;PushDeviceResponseDto&gt;**](PushDeviceResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerListMine**
> NotificationPageDto notificationsControllerListMine(type, isRead, skip, limit)

List current user notifications

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();
final JsonObject type = Object; // JsonObject | 
final bool isRead = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.notificationsControllerListMine(type, isRead, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerListMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | [**JsonObject**](.md)|  | [optional] 
 **isRead** | **bool**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**NotificationPageDto**](NotificationPageDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerMarkAllRead**
> JsonObject notificationsControllerMarkAllRead()

Mark all current user notifications as read

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();

try {
    final response = api.notificationsControllerMarkAllRead();
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerMarkAllRead: $e\n');
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

# **notificationsControllerMarkRead**
> NotificationResponseDto notificationsControllerMarkRead(id)

Mark one notification as read

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.notificationsControllerMarkRead(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerMarkRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**NotificationResponseDto**](NotificationResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerRegisterDevice**
> PushDeviceResponseDto notificationsControllerRegisterDevice(registerPushDeviceDto)

Register or update current user push device

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();
final RegisterPushDeviceDto registerPushDeviceDto = {"token":"fcm-device-token-example","platform":"IOS","provider":"FCM","deviceId":"iphone-15-pro-abc","deviceName":"iPhone của Thì Ai","appVersion":"1.0.0","timezone":"Asia/Ho_Chi_Minh","enabled":true}; // RegisterPushDeviceDto | 

try {
    final response = api.notificationsControllerRegisterDevice(registerPushDeviceDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerRegisterDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerPushDeviceDto** | [**RegisterPushDeviceDto**](RegisterPushDeviceDto.md)|  | 

### Return type

[**PushDeviceResponseDto**](PushDeviceResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notificationsControllerRemoveDevice**
> JsonObject notificationsControllerRemoveDevice(id)

Remove a current user push device

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getNotificationsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.notificationsControllerRemoveDevice(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->notificationsControllerRemoveDevice: $e\n');
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

