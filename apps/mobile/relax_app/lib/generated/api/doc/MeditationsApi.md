# relax_api_client.api.MeditationsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**meditationsControllerCreateSession**](MeditationsApi.md#meditationscontrollercreatesession) | **POST** /v1/meditations/sessions | Log a meditation session
[**meditationsControllerFindGuides**](MeditationsApi.md#meditationscontrollerfindguides) | **GET** /v1/meditations/guides | Get active guided meditations
[**meditationsControllerFindSessions**](MeditationsApi.md#meditationscontrollerfindsessions) | **GET** /v1/meditations/sessions/me | Get current user meditation sessions history


# **meditationsControllerCreateSession**
> JsonObject meditationsControllerCreateSession(createMeditationSessionDto)

Log a meditation session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMeditationsApi();
final CreateMeditationSessionDto createMeditationSessionDto = ; // CreateMeditationSessionDto | 

try {
    final response = api.meditationsControllerCreateSession(createMeditationSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeditationsApi->meditationsControllerCreateSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createMeditationSessionDto** | [**CreateMeditationSessionDto**](CreateMeditationSessionDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meditationsControllerFindGuides**
> meditationsControllerFindGuides(difficulty, focusArea)

Get active guided meditations

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMeditationsApi();
final String difficulty = difficulty_example; // String | 
final String focusArea = focusArea_example; // String | 

try {
    api.meditationsControllerFindGuides(difficulty, focusArea);
} on DioException catch (e) {
    print('Exception when calling MeditationsApi->meditationsControllerFindGuides: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **difficulty** | **String**|  | [optional] 
 **focusArea** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meditationsControllerFindSessions**
> BuiltList<JsonObject> meditationsControllerFindSessions()

Get current user meditation sessions history

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getMeditationsApi();

try {
    final response = api.meditationsControllerFindSessions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeditationsApi->meditationsControllerFindSessions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;JsonObject&gt;**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

