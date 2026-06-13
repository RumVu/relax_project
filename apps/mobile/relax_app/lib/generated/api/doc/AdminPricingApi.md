# relax_api_client.api.AdminPricingApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminPricingControllerClearSale**](AdminPricingApi.md#adminpricingcontrollerclearsale) | **PATCH** /v1/admin/billing/tiers/{id}/clear-sale | Drop the active sale window without touching the regular price.
[**adminPricingControllerCreate**](AdminPricingApi.md#adminpricingcontrollercreate) | **POST** /v1/admin/billing/tiers | Create a new tier.
[**adminPricingControllerDeactivate**](AdminPricingApi.md#adminpricingcontrollerdeactivate) | **DELETE** /v1/admin/billing/tiers/{id} | Soft-deactivate the tier (sets isActive&#x3D;false). Hard-delete would orphan past payments.
[**adminPricingControllerFindOne**](AdminPricingApi.md#adminpricingcontrollerfindone) | **GET** /v1/admin/billing/tiers/{id} | Fetch one tier by id.
[**adminPricingControllerList**](AdminPricingApi.md#adminpricingcontrollerlist) | **GET** /v1/admin/billing/tiers | List every subscription tier (active + inactive).
[**adminPricingControllerUpdate**](AdminPricingApi.md#adminpricingcontrollerupdate) | **PATCH** /v1/admin/billing/tiers/{id} | Update price, sale, title, display order, or activation flag of a tier.


# **adminPricingControllerClearSale**
> adminPricingControllerClearSale(id)

Drop the active sale window without touching the regular price.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminPricingApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    api.adminPricingControllerClearSale(id);
} on DioException catch (e) {
    print('Exception when calling AdminPricingApi->adminPricingControllerClearSale: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPricingControllerCreate**
> adminPricingControllerCreate(createTierDto)

Create a new tier.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminPricingApi();
final CreateTierDto createTierDto = ; // CreateTierDto | 

try {
    api.adminPricingControllerCreate(createTierDto);
} on DioException catch (e) {
    print('Exception when calling AdminPricingApi->adminPricingControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createTierDto** | [**CreateTierDto**](CreateTierDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPricingControllerDeactivate**
> adminPricingControllerDeactivate(id)

Soft-deactivate the tier (sets isActive=false). Hard-delete would orphan past payments.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminPricingApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    api.adminPricingControllerDeactivate(id);
} on DioException catch (e) {
    print('Exception when calling AdminPricingApi->adminPricingControllerDeactivate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPricingControllerFindOne**
> adminPricingControllerFindOne(id)

Fetch one tier by id.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminPricingApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    api.adminPricingControllerFindOne(id);
} on DioException catch (e) {
    print('Exception when calling AdminPricingApi->adminPricingControllerFindOne: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPricingControllerList**
> adminPricingControllerList()

List every subscription tier (active + inactive).

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminPricingApi();

try {
    api.adminPricingControllerList();
} on DioException catch (e) {
    print('Exception when calling AdminPricingApi->adminPricingControllerList: $e\n');
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

# **adminPricingControllerUpdate**
> adminPricingControllerUpdate(id, updateTierDto)

Update price, sale, title, display order, or activation flag of a tier.

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAdminPricingApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final UpdateTierDto updateTierDto = ; // UpdateTierDto | 

try {
    api.adminPricingControllerUpdate(id, updateTierDto);
} on DioException catch (e) {
    print('Exception when calling AdminPricingApi->adminPricingControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateTierDto** | [**UpdateTierDto**](UpdateTierDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

