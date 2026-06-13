# relax_api_client.api.AuthApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authControllerChangeMyPassword**](AuthApi.md#authcontrollerchangemypassword) | **PATCH** /v1/auth/me/password | Change the current local user password
[**authControllerDeleteMine**](AuthApi.md#authcontrollerdeletemine) | **DELETE** /v1/auth/me | Delete or deactivate the current account
[**authControllerDemo**](AuthApi.md#authcontrollerdemo) | **POST** /v1/auth/demo | Login as demo user with pre-populated data
[**authControllerExportMine**](AuthApi.md#authcontrollerexportmine) | **GET** /v1/auth/me/export | Export current user personal data
[**authControllerGoogle**](AuthApi.md#authcontrollergoogle) | **POST** /v1/auth/google | Exchange a Google ID token for an app session
[**authControllerLogin**](AuthApi.md#authcontrollerlogin) | **POST** /v1/auth/login | Login with email and password
[**authControllerLogout**](AuthApi.md#authcontrollerlogout) | **POST** /v1/auth/logout | Logout by revoking one refresh token
[**authControllerMe**](AuthApi.md#authcontrollerme) | **GET** /v1/auth/me | Get the current authenticated user
[**authControllerRefresh**](AuthApi.md#authcontrollerrefresh) | **POST** /v1/auth/refresh | Rotate a refresh token
[**authControllerRegister**](AuthApi.md#authcontrollerregister) | **POST** /v1/auth/register | Register a local user and create a session
[**authControllerRequestEmailVerification**](AuthApi.md#authcontrollerrequestemailverification) | **POST** /v1/auth/me/email-verification | Request current user email verification token
[**authControllerRequestPasswordReset**](AuthApi.md#authcontrollerrequestpasswordreset) | **POST** /v1/auth/password-reset/request | Request a password reset email
[**authControllerResetPassword**](AuthApi.md#authcontrollerresetpassword) | **POST** /v1/auth/password-reset/confirm | Reset password with an account token
[**authControllerVerifyEmail**](AuthApi.md#authcontrollerverifyemail) | **POST** /v1/auth/email/verify | Verify email with an account token


# **authControllerChangeMyPassword**
> AuthActionResultDto authControllerChangeMyPassword(changePasswordDto)

Change the current local user password

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final ChangePasswordDto changePasswordDto = ; // ChangePasswordDto | 

try {
    final response = api.authControllerChangeMyPassword(changePasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerChangeMyPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordDto** | [**ChangePasswordDto**](ChangePasswordDto.md)|  | 

### Return type

[**AuthActionResultDto**](AuthActionResultDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerDeleteMine**
> AuthActionResultDto authControllerDeleteMine(deleteAccountDto)

Delete or deactivate the current account

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final DeleteAccountDto deleteAccountDto = {"mode":"SOFT","password":"Secret123!x"}; // DeleteAccountDto | 

try {
    final response = api.authControllerDeleteMine(deleteAccountDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerDeleteMine: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deleteAccountDto** | [**DeleteAccountDto**](DeleteAccountDto.md)|  | 

### Return type

[**AuthActionResultDto**](AuthActionResultDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerDemo**
> AuthResponseDto authControllerDemo(demoLoginDto)

Login as demo user with pre-populated data

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final DemoLoginDto demoLoginDto = ; // DemoLoginDto | 

try {
    final response = api.authControllerDemo(demoLoginDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerDemo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **demoLoginDto** | [**DemoLoginDto**](DemoLoginDto.md)|  | 

### Return type

[**AuthResponseDto**](AuthResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerExportMine**
> JsonObject authControllerExportMine()

Export current user personal data

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();

try {
    final response = api.authControllerExportMine();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerExportMine: $e\n');
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

# **authControllerGoogle**
> AuthResponseDto authControllerGoogle(googleLoginDto)

Exchange a Google ID token for an app session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final GoogleLoginDto googleLoginDto = ; // GoogleLoginDto | 

try {
    final response = api.authControllerGoogle(googleLoginDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerGoogle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **googleLoginDto** | [**GoogleLoginDto**](GoogleLoginDto.md)|  | 

### Return type

[**AuthResponseDto**](AuthResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLogin**
> AuthResponseDto authControllerLogin(loginDto)

Login with email and password

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final LoginDto loginDto = {"email":"thiai.chill@example.com","password":"Secret123!x"}; // LoginDto | 

try {
    final response = api.authControllerLogin(loginDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginDto** | [**LoginDto**](LoginDto.md)|  | 

### Return type

[**AuthResponseDto**](AuthResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLogout**
> AuthActionResultDto authControllerLogout(refreshTokenDto)

Logout by revoking one refresh token

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final RefreshTokenDto refreshTokenDto = {"refreshToken":"2b5ad8d4-5c3f-4a3e-9f8a-8f1dbdb5d2c1"}; // RefreshTokenDto | 

try {
    final response = api.authControllerLogout(refreshTokenDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLogout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshTokenDto** | [**RefreshTokenDto**](RefreshTokenDto.md)|  | 

### Return type

[**AuthActionResultDto**](AuthActionResultDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerMe**
> UserResponseDto authControllerMe()

Get the current authenticated user

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();

try {
    final response = api.authControllerMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserResponseDto**](UserResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRefresh**
> AuthResponseDto authControllerRefresh(refreshTokenDto)

Rotate a refresh token

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final RefreshTokenDto refreshTokenDto = {"refreshToken":"2b5ad8d4-5c3f-4a3e-9f8a-8f1dbdb5d2c1"}; // RefreshTokenDto | 

try {
    final response = api.authControllerRefresh(refreshTokenDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshTokenDto** | [**RefreshTokenDto**](RefreshTokenDto.md)|  | 

### Return type

[**AuthResponseDto**](AuthResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRegister**
> AuthResponseDto authControllerRegister(registerDto)

Register a local user and create a session

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final RegisterDto registerDto = {"email":"thiai.chill@example.com","password":"Secret123!x","name":"Thì Ai"}; // RegisterDto | 

try {
    final response = api.authControllerRegister(registerDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerDto** | [**RegisterDto**](RegisterDto.md)|  | 

### Return type

[**AuthResponseDto**](AuthResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRequestEmailVerification**
> AuthActionResultDto authControllerRequestEmailVerification()

Request current user email verification token

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();

try {
    final response = api.authControllerRequestEmailVerification();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRequestEmailVerification: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthActionResultDto**](AuthActionResultDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRequestPasswordReset**
> AuthActionResultDto authControllerRequestPasswordReset(requestPasswordResetDto)

Request a password reset email

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final RequestPasswordResetDto requestPasswordResetDto = {"email":"thiai.chill@example.com"}; // RequestPasswordResetDto | 

try {
    final response = api.authControllerRequestPasswordReset(requestPasswordResetDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRequestPasswordReset: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestPasswordResetDto** | [**RequestPasswordResetDto**](RequestPasswordResetDto.md)|  | 

### Return type

[**AuthActionResultDto**](AuthActionResultDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerResetPassword**
> AuthActionResultDto authControllerResetPassword(resetPasswordDto)

Reset password with an account token

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final ResetPasswordDto resetPasswordDto = {"token":"dev-reset-token-from-request","password":"NewSecret123!x"}; // ResetPasswordDto | 

try {
    final response = api.authControllerResetPassword(resetPasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerResetPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordDto** | [**ResetPasswordDto**](ResetPasswordDto.md)|  | 

### Return type

[**AuthActionResultDto**](AuthActionResultDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerVerifyEmail**
> AuthActionResultDto authControllerVerifyEmail(verifyEmailDto)

Verify email with an account token

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getAuthApi();
final VerifyEmailDto verifyEmailDto = {"token":"dev-email-verification-token-from-request"}; // VerifyEmailDto | 

try {
    final response = api.authControllerVerifyEmail(verifyEmailDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerVerifyEmail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyEmailDto** | [**VerifyEmailDto**](VerifyEmailDto.md)|  | 

### Return type

[**AuthActionResultDto**](AuthActionResultDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

