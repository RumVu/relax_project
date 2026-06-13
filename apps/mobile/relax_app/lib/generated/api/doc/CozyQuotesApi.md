# relax_api_client.api.CozyQuotesApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cozyQuotesControllerCreate**](CozyQuotesApi.md#cozyquotescontrollercreate) | **POST** /v1/cozy-quotes | Create a cozy quote
[**cozyQuotesControllerFindAll**](CozyQuotesApi.md#cozyquotescontrollerfindall) | **GET** /v1/cozy-quotes | List cozy quotes
[**cozyQuotesControllerFindByMood**](CozyQuotesApi.md#cozyquotescontrollerfindbymood) | **GET** /v1/cozy-quotes/mood/{mood} | List cozy quotes by mood
[**cozyQuotesControllerFindRandom**](CozyQuotesApi.md#cozyquotescontrollerfindrandom) | **GET** /v1/cozy-quotes/random | Get a random active cozy quote
[**cozyQuotesControllerRemove**](CozyQuotesApi.md#cozyquotescontrollerremove) | **DELETE** /v1/cozy-quotes/{id} | Delete a cozy quote
[**cozyQuotesControllerUpdate**](CozyQuotesApi.md#cozyquotescontrollerupdate) | **PATCH** /v1/cozy-quotes/{id} | Update a cozy quote


# **cozyQuotesControllerCreate**
> CozyQuoteResponseDto cozyQuotesControllerCreate(createCozyQuoteDto)

Create a cozy quote

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCozyQuotesApi();
final CreateCozyQuoteDto createCozyQuoteDto = {"content":"Không cần phải ổn hết mọi ngày, chỉ cần tốt hơn một chút so với chính mình hôm qua.","author":"Thì Ai Chill","mood":"CALM","imageUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/quotes/calm.png","isActive":true}; // CreateCozyQuoteDto | 

try {
    final response = api.cozyQuotesControllerCreate(createCozyQuoteDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CozyQuotesApi->cozyQuotesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCozyQuoteDto** | [**CreateCozyQuoteDto**](CreateCozyQuoteDto.md)|  | 

### Return type

[**CozyQuoteResponseDto**](CozyQuoteResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cozyQuotesControllerFindAll**
> CozyQuotePageDto cozyQuotesControllerFindAll(q, category, isActive, skip, limit)

List cozy quotes

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCozyQuotesApi();
final String q = q_example; // String | 
final String category = music; // String | 
final bool isActive = true; // bool | 
final num skip = 0; // num | 
final num limit = 20; // num | 

try {
    final response = api.cozyQuotesControllerFindAll(q, category, isActive, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CozyQuotesApi->cozyQuotesControllerFindAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] 
 **category** | **String**|  | [optional] 
 **isActive** | **bool**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **limit** | **num**|  | [optional] 

### Return type

[**CozyQuotePageDto**](CozyQuotePageDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cozyQuotesControllerFindByMood**
> BuiltList<CozyQuoteResponseDto> cozyQuotesControllerFindByMood(mood)

List cozy quotes by mood

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCozyQuotesApi();
final String mood = STRESSED; // String | 

try {
    final response = api.cozyQuotesControllerFindByMood(mood);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CozyQuotesApi->cozyQuotesControllerFindByMood: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mood** | **String**|  | 

### Return type

[**BuiltList&lt;CozyQuoteResponseDto&gt;**](CozyQuoteResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cozyQuotesControllerFindRandom**
> CozyQuoteResponseDto cozyQuotesControllerFindRandom(lang)

Get a random active cozy quote

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCozyQuotesApi();
final String lang = lang_example; // String | 

try {
    final response = api.cozyQuotesControllerFindRandom(lang);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CozyQuotesApi->cozyQuotesControllerFindRandom: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lang** | **String**|  | [optional] 

### Return type

[**CozyQuoteResponseDto**](CozyQuoteResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cozyQuotesControllerRemove**
> CozyQuoteResponseDto cozyQuotesControllerRemove(id)

Delete a cozy quote

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCozyQuotesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.cozyQuotesControllerRemove(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CozyQuotesApi->cozyQuotesControllerRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**CozyQuoteResponseDto**](CozyQuoteResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cozyQuotesControllerUpdate**
> CozyQuoteResponseDto cozyQuotesControllerUpdate(id, updateCozyQuoteDto)

Update a cozy quote

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getCozyQuotesApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateCozyQuoteDto updateCozyQuoteDto = {"mood":"STRESSED","isActive":true}; // UpdateCozyQuoteDto | 

try {
    final response = api.cozyQuotesControllerUpdate(id, updateCozyQuoteDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CozyQuotesApi->cozyQuotesControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateCozyQuoteDto** | [**UpdateCozyQuoteDto**](UpdateCozyQuoteDto.md)|  | 

### Return type

[**CozyQuoteResponseDto**](CozyQuoteResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

