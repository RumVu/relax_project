# relax_api_client.api.AchievementsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**achievementsControllerGetMyAchievements**](AchievementsApi.md#achievementscontrollergetmyachievements) | **GET** /v1/achievements/me | 


# **achievementsControllerGetMyAchievements**
> achievementsControllerGetMyAchievements()



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAchievementsApi();

try {
    api.achievementsControllerGetMyAchievements();
} on DioException catch (e) {
    print('Exception when calling AchievementsApi->achievementsControllerGetMyAchievements: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

