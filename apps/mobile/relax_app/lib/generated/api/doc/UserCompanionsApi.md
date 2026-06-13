# relax_api_client.api.UserCompanionsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**userCompanionsControllerChat**](UserCompanionsApi.md#usercompanionscontrollerchat) | **POST** /v1/user-companions/me/chat | Chat with user companion using AI
[**userCompanionsControllerGetChatHistory**](UserCompanionsApi.md#usercompanionscontrollergetchathistory) | **GET** /v1/user-companions/me/chat/history | Get companion chat history
[**userCompanionsControllerGetMine**](UserCompanionsApi.md#usercompanionscontrollergetmine) | **GET** /v1/user-companions/me | Get current user companion
[**userCompanionsControllerGetPersonalizationOptions**](UserCompanionsApi.md#usercompanionscontrollergetpersonalizationoptions) | **GET** /v1/user-companions/me/personalization-options | Get companion personalization options
[**userCompanionsControllerGetStats**](UserCompanionsApi.md#usercompanionscontrollergetstats) | **GET** /v1/user-companions/me/stats | Get current user companion stats
[**userCompanionsControllerInteract**](UserCompanionsApi.md#usercompanionscontrollerinteract) | **POST** /v1/user-companions/me/interactions | Create companion interaction
[**userCompanionsControllerSwitchPersonalization**](UserCompanionsApi.md#usercompanionscontrollerswitchpersonalization) | **PATCH** /v1/user-companions/me/personalization-mode | Switch companion personalization mode while preserving or resetting progress
[**userCompanionsControllerUpsertMine**](UserCompanionsApi.md#usercompanionscontrollerupsertmine) | **PATCH** /v1/user-companions/me | Upsert current user companion


# **userCompanionsControllerChat**
> JsonObject userCompanionsControllerChat(companionChatDto)

Chat with user companion using AI

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();
final CompanionChatDto companionChatDto = ; // CompanionChatDto | 

try {
    final response = api.userCompanionsControllerChat(companionChatDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerChat: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **companionChatDto** | [**CompanionChatDto**](CompanionChatDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userCompanionsControllerGetChatHistory**
> JsonObject userCompanionsControllerGetChatHistory()

Get companion chat history

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();

try {
    final response = api.userCompanionsControllerGetChatHistory();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerGetChatHistory: $e\n');
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

# **userCompanionsControllerGetMine**
> UserCompanionResponseDto userCompanionsControllerGetMine()

Get current user companion

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();

try {
    final response = api.userCompanionsControllerGetMine();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerGetMine: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserCompanionResponseDto**](UserCompanionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userCompanionsControllerGetPersonalizationOptions**
> JsonObject userCompanionsControllerGetPersonalizationOptions()

Get companion personalization options

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();

try {
    final response = api.userCompanionsControllerGetPersonalizationOptions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerGetPersonalizationOptions: $e\n');
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

# **userCompanionsControllerGetStats**
> JsonObject userCompanionsControllerGetStats()

Get current user companion stats

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();

try {
    final response = api.userCompanionsControllerGetStats();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerGetStats: $e\n');
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

# **userCompanionsControllerInteract**
> JsonObject userCompanionsControllerInteract(createCompanionInteractionDto)

Create companion interaction

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();
final CreateCompanionInteractionDto createCompanionInteractionDto = {"type":"PET","metadata":{"source":"home","mood":"STRESSED"}}; // CreateCompanionInteractionDto | 

try {
    final response = api.userCompanionsControllerInteract(createCompanionInteractionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerInteract: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCompanionInteractionDto** | [**CreateCompanionInteractionDto**](CreateCompanionInteractionDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userCompanionsControllerSwitchPersonalization**
> JsonObject userCompanionsControllerSwitchPersonalization(switchCompanionPersonalizationDto)

Switch companion personalization mode while preserving or resetting progress

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();
final SwitchCompanionPersonalizationDto switchCompanionPersonalizationDto = {"personalizationMode":"CHINESE_ZODIAC","preserveProgress":true,"resetVisualState":true}; // SwitchCompanionPersonalizationDto | 

try {
    final response = api.userCompanionsControllerSwitchPersonalization(switchCompanionPersonalizationDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerSwitchPersonalization: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **switchCompanionPersonalizationDto** | [**SwitchCompanionPersonalizationDto**](SwitchCompanionPersonalizationDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userCompanionsControllerUpsertMine**
> UserCompanionResponseDto userCompanionsControllerUpsertMine(upsertUserCompanionDto)

Upsert current user companion

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getUserCompanionsApi();
final UpsertUserCompanionDto upsertUserCompanionDto = {"assetId":"asset_pixel_cat_default","name":"Mon Leo","type":"CAT","personalizationMode":"CHINESE_ZODIAC","mood":"CHILL","action":"IDLE","level":3,"affection":72,"energy":88}; // UpsertUserCompanionDto | 

try {
    final response = api.userCompanionsControllerUpsertMine(upsertUserCompanionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserCompanionsApi->userCompanionsControllerUpsertMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **upsertUserCompanionDto** | [**UpsertUserCompanionDto**](UpsertUserCompanionDto.md)|  | 

### Return type

[**UserCompanionResponseDto**](UserCompanionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

