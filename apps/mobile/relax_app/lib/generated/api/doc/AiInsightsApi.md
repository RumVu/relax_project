# relax_api_client.api.AiInsightsApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**aiInsightsControllerGetMine**](AiInsightsApi.md#aiinsightscontrollergetmine) | **GET** /v1/ai/insights/me | Get my recent AI insights and recommendations (auto-regenerates if stale).
[**aiInsightsControllerRefresh**](AiInsightsApi.md#aiinsightscontrollerrefresh) | **POST** /v1/ai/insights/me/refresh | Force regeneration of insights using the configured AI provider.
[**aiInsightsControllerSetFeedback**](AiInsightsApi.md#aiinsightscontrollersetfeedback) | **PATCH** /v1/ai/insights/me/{id}/feedback | Mark an insight as useful / not useful.


# **aiInsightsControllerGetMine**
> aiInsightsControllerGetMine(limit)

Get my recent AI insights and recommendations (auto-regenerates if stale).

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAiInsightsApi();
final num limit = 20; // num | 

try {
    api.aiInsightsControllerGetMine(limit);
} on DioException catch (e) {
    print('Exception when calling AiInsightsApi->aiInsightsControllerGetMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **num**|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **aiInsightsControllerRefresh**
> aiInsightsControllerRefresh(limit)

Force regeneration of insights using the configured AI provider.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAiInsightsApi();
final num limit = 20; // num | 

try {
    api.aiInsightsControllerRefresh(limit);
} on DioException catch (e) {
    print('Exception when calling AiInsightsApi->aiInsightsControllerRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **num**|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **aiInsightsControllerSetFeedback**
> aiInsightsControllerSetFeedback(id, feedbackInsightDto)

Mark an insight as useful / not useful.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAiInsightsApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final FeedbackInsightDto feedbackInsightDto = ; // FeedbackInsightDto | 

try {
    api.aiInsightsControllerSetFeedback(id, feedbackInsightDto);
} on DioException catch (e) {
    print('Exception when calling AiInsightsApi->aiInsightsControllerSetFeedback: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **feedbackInsightDto** | [**FeedbackInsightDto**](FeedbackInsightDto.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

