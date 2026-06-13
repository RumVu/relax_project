# relax_api_client.api.QuestsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**questsControllerGetMine**](QuestsApi.md#questscontrollergetmine) | **GET** /v1/quests/me | List my active daily quests (auto-seeded + auto-completed).
[**questsControllerReroll**](QuestsApi.md#questscontrollerreroll) | **POST** /v1/quests/me/{id}/reroll | Replace one of my active quests with a different random template I have not seen.


# **questsControllerGetMine**
> BuiltList<JsonObject> questsControllerGetMine(locale)

List my active daily quests (auto-seeded + auto-completed).

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getQuestsApi();
final String locale = locale_example; // String | 

try {
    final response = api.questsControllerGetMine(locale);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QuestsApi->questsControllerGetMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **locale** | **String**|  | [optional] 

### Return type

[**BuiltList&lt;JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **questsControllerReroll**
> JsonObject questsControllerReroll(id, locale)

Replace one of my active quests with a different random template I have not seen.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getQuestsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final String locale = locale_example; // String | 

try {
    final response = api.questsControllerReroll(id, locale);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QuestsApi->questsControllerReroll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **locale** | **String**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

