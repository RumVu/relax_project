# relax_api_client.api.BillingApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**billingControllerConfirmPayment**](BillingApi.md#billingcontrollerconfirmpayment) | **POST** /v1/billing/me/payments/{id}/confirm | Confirm a pending payment and activate the subscription
[**billingControllerCreateCheckoutSession**](BillingApi.md#billingcontrollercreatecheckoutsession) | **POST** /v1/billing/me/checkout-session | Create a checkout session intent
[**billingControllerGetMine**](BillingApi.md#billingcontrollergetmine) | **GET** /v1/billing/me | Get current user billing state
[**billingControllerGetMyPayments**](BillingApi.md#billingcontrollergetmypayments) | **GET** /v1/billing/me/payments | Get current user payment history
[**billingControllerGetPayment**](BillingApi.md#billingcontrollergetpayment) | **GET** /v1/billing/me/payments/{id} | Get a single payment status
[**billingControllerGetPlans**](BillingApi.md#billingcontrollergetplans) | **GET** /v1/billing/plans | List available subscription plans
[**billingControllerGetProviderStatus**](BillingApi.md#billingcontrollergetproviderstatus) | **GET** /v1/billing/providers | Get billing/payment provider status
[**sepayControllerHandleWebhook**](BillingApi.md#sepaycontrollerhandlewebhook) | **POST** /v1/billing/sepay/webhook | SePay webhook payment callback
[**sepayLegacyControllerHandleWebhook**](BillingApi.md#sepaylegacycontrollerhandlewebhook) | **POST** /billing/webhooks/sepay | SePay legacy webhook payment callback


# **billingControllerConfirmPayment**
> ConfirmPaymentResponseDto billingControllerConfirmPayment(id, confirmPaymentDto)

Confirm a pending payment and activate the subscription

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 
final ConfirmPaymentDto confirmPaymentDto = ; // ConfirmPaymentDto | 

try {
    final response = api.billingControllerConfirmPayment(id, confirmPaymentDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->billingControllerConfirmPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **confirmPaymentDto** | [**ConfirmPaymentDto**](ConfirmPaymentDto.md)|  | 

### Return type

[**ConfirmPaymentResponseDto**](ConfirmPaymentResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **billingControllerCreateCheckoutSession**
> CheckoutSessionResponseDto billingControllerCreateCheckoutSession(createCheckoutSessionDto)

Create a checkout session intent

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();
final CreateCheckoutSessionDto createCheckoutSessionDto = {"planName":"CHILL_PLUS","provider":"STRIPE","description":"Upgrade to Chill Plus monthly"}; // CreateCheckoutSessionDto | 

try {
    final response = api.billingControllerCreateCheckoutSession(createCheckoutSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->billingControllerCreateCheckoutSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCheckoutSessionDto** | [**CreateCheckoutSessionDto**](CreateCheckoutSessionDto.md)|  | 

### Return type

[**CheckoutSessionResponseDto**](CheckoutSessionResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **billingControllerGetMine**
> BillingMeResponseDto billingControllerGetMine()

Get current user billing state

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();

try {
    final response = api.billingControllerGetMine();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->billingControllerGetMine: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BillingMeResponseDto**](BillingMeResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **billingControllerGetMyPayments**
> JsonObject billingControllerGetMyPayments()

Get current user payment history

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();

try {
    final response = api.billingControllerGetMyPayments();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->billingControllerGetMyPayments: $e\n');
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

# **billingControllerGetPayment**
> JsonObject billingControllerGetPayment(id)

Get a single payment status

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.billingControllerGetPayment(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->billingControllerGetPayment: $e\n');
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

# **billingControllerGetPlans**
> BuiltList<BillingPlanResponseDto> billingControllerGetPlans()

List available subscription plans

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();

try {
    final response = api.billingControllerGetPlans();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->billingControllerGetPlans: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;BillingPlanResponseDto&gt;**](BillingPlanResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **billingControllerGetProviderStatus**
> ProviderStatusResponseDto billingControllerGetProviderStatus()

Get billing/payment provider status

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();

try {
    final response = api.billingControllerGetProviderStatus();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->billingControllerGetProviderStatus: $e\n');
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

# **sepayControllerHandleWebhook**
> JsonObject sepayControllerHandleWebhook(authorization)

SePay webhook payment callback

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();
final String authorization = authorization_example; // String | 

try {
    final response = api.sepayControllerHandleWebhook(authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->sepayControllerHandleWebhook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sepayLegacyControllerHandleWebhook**
> JsonObject sepayLegacyControllerHandleWebhook(authorization)

SePay legacy webhook payment callback

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getBillingApi();
final String authorization = authorization_example; // String | 

try {
    final response = api.sepayLegacyControllerHandleWebhook(authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->sepayLegacyControllerHandleWebhook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

