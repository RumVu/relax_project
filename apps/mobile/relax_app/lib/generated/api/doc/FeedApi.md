# relax_api_client.api.FeedApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**feedControllerGetMyFeed**](FeedApi.md#feedcontrollergetmyfeed) | **GET** /v1/feed | 


# **feedControllerGetMyFeed**
> BuiltList<JsonObject> feedControllerGetMyFeed()



### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getFeedApi();

try {
    final response = api.feedControllerGetMyFeed();
    print(response);
} on DioException catch (e) {
    print('Exception when calling FeedApi->feedControllerGetMyFeed: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

