# relax_api_client.api.RecommendationsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**recommendationsControllerGetMyRatings**](RecommendationsApi.md#recommendationscontrollergetmyratings) | **GET** /v1/recommendations/content-ratings/me | Get my content ratings
[**recommendationsControllerGetToday**](RecommendationsApi.md#recommendationscontrollergettoday) | **GET** /v1/recommendations/me/today | Get today smart recommendations for current user
[**recommendationsControllerGetTriggerAnalytics**](RecommendationsApi.md#recommendationscontrollergettriggeranalytics) | **GET** /v1/recommendations/me/trigger-analytics | Get trigger analytics for current user
[**recommendationsControllerRateContent**](RecommendationsApi.md#recommendationscontrollerratecontent) | **POST** /v1/recommendations/content-ratings | Rate a content item
[**recommendationsControllerRefresh**](RecommendationsApi.md#recommendationscontrollerrefresh) | **POST** /v1/recommendations/me/refresh | Refresh recommendations for current user


# **recommendationsControllerGetMyRatings**
> recommendationsControllerGetMyRatings()

Get my content ratings

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRecommendationsApi();

try {
    api.recommendationsControllerGetMyRatings();
} on DioException catch (e) {
    print('Exception when calling RecommendationsApi->recommendationsControllerGetMyRatings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recommendationsControllerGetToday**
> recommendationsControllerGetToday()

Get today smart recommendations for current user

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRecommendationsApi();

try {
    api.recommendationsControllerGetToday();
} on DioException catch (e) {
    print('Exception when calling RecommendationsApi->recommendationsControllerGetToday: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recommendationsControllerGetTriggerAnalytics**
> recommendationsControllerGetTriggerAnalytics()

Get trigger analytics for current user

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRecommendationsApi();

try {
    api.recommendationsControllerGetTriggerAnalytics();
} on DioException catch (e) {
    print('Exception when calling RecommendationsApi->recommendationsControllerGetTriggerAnalytics: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recommendationsControllerRateContent**
> recommendationsControllerRateContent(rateContentDto)

Rate a content item

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRecommendationsApi();
final RateContentDto rateContentDto = ; // RateContentDto | 

try {
    api.recommendationsControllerRateContent(rateContentDto);
} on DioException catch (e) {
    print('Exception when calling RecommendationsApi->recommendationsControllerRateContent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rateContentDto** | [**RateContentDto**](RateContentDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recommendationsControllerRefresh**
> recommendationsControllerRefresh()

Refresh recommendations for current user

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getRecommendationsApi();

try {
    api.recommendationsControllerRefresh();
} on DioException catch (e) {
    print('Exception when calling RecommendationsApi->recommendationsControllerRefresh: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

