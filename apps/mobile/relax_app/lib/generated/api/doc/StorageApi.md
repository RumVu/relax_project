# relax_api_client.api.StorageApi

## Load the API package
```dart
import 'package:relax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**storageControllerCreateAdminSignedUploadUrl**](StorageApi.md#storagecontrollercreateadminsigneduploadurl) | **POST** /v1/storage/admin/signed-upload-url | Create a signed upload URL for catalog/admin paths
[**storageControllerCreateAdminSignedUrl**](StorageApi.md#storagecontrollercreateadminsignedurl) | **GET** /v1/storage/admin/signed-url | Create a signed read URL for an admin/catalog storage object
[**storageControllerCreateSignedUploadUrl**](StorageApi.md#storagecontrollercreatesigneduploadurl) | **POST** /v1/storage/signed-upload-url | Create a signed Supabase upload URL
[**storageControllerCreateSignedUrl**](StorageApi.md#storagecontrollercreatesignedurl) | **GET** /v1/storage/signed-url | Create a signed read URL for a storage object
[**storageControllerFindFiles**](StorageApi.md#storagecontrollerfindfiles) | **GET** /v1/storage/files | List registered storage file metadata
[**storageControllerFindMyFiles**](StorageApi.md#storagecontrollerfindmyfiles) | **GET** /v1/storage/me/files | List current user storage file metadata
[**storageControllerGetAdminPublicUrl**](StorageApi.md#storagecontrollergetadminpublicurl) | **GET** /v1/storage/admin/public-url | Get the public URL for an admin/catalog object
[**storageControllerGetCdnStrategy**](StorageApi.md#storagecontrollergetcdnstrategy) | **GET** /v1/storage/cdn-strategy | Get storage/CDN path and access strategy
[**storageControllerGetHealth**](StorageApi.md#storagecontrollergethealth) | **GET** /v1/storage/health | Get storage configuration and optional deep connectivity health
[**storageControllerGetMyStorageHealth**](StorageApi.md#storagecontrollergetmystoragehealth) | **GET** /v1/storage/me/health | Get upload storage readiness for current user
[**storageControllerGetPublicUrl**](StorageApi.md#storagecontrollergetpublicurl) | **GET** /v1/storage/public-url | Get the public URL for a storage object
[**storageControllerRegisterFile**](StorageApi.md#storagecontrollerregisterfile) | **POST** /v1/storage/files | Register storage file metadata
[**storageControllerRemoveFileMetadata**](StorageApi.md#storagecontrollerremovefilemetadata) | **DELETE** /v1/storage/files/{id} | Delete storage file metadata by id
[**storageControllerRemoveObjects**](StorageApi.md#storagecontrollerremoveobjects) | **DELETE** /v1/storage/objects | Delete one or more objects from Supabase storage
[**storageControllerUploadAdminFile**](StorageApi.md#storagecontrolleruploadadminfile) | **POST** /v1/storage/admin/upload | Upload an admin/catalog file through the API
[**storageControllerUploadAvatar**](StorageApi.md#storagecontrolleruploadavatar) | **POST** /v1/storage/me/avatar | Upload the current user avatar through the API


# **storageControllerCreateAdminSignedUploadUrl**
> JsonObject storageControllerCreateAdminSignedUploadUrl(createSignedUploadUrlDto)

Create a signed upload URL for catalog/admin paths

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final CreateSignedUploadUrlDto createSignedUploadUrlDto = {"path":"avatars/avatar.png","upsert":false}; // CreateSignedUploadUrlDto | 

try {
    final response = api.storageControllerCreateAdminSignedUploadUrl(createSignedUploadUrlDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerCreateAdminSignedUploadUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSignedUploadUrlDto** | [**CreateSignedUploadUrlDto**](CreateSignedUploadUrlDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerCreateAdminSignedUrl**
> JsonObject storageControllerCreateAdminSignedUrl(path, expiresIn)

Create a signed read URL for an admin/catalog storage object

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final String path = companions/pixel-cat.png; // String | 
final num expiresIn = 3600; // num | 

try {
    final response = api.storageControllerCreateAdminSignedUrl(path, expiresIn);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerCreateAdminSignedUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **path** | **String**|  | 
 **expiresIn** | **num**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerCreateSignedUploadUrl**
> JsonObject storageControllerCreateSignedUploadUrl(createSignedUploadUrlDto)

Create a signed Supabase upload URL

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final CreateSignedUploadUrlDto createSignedUploadUrlDto = {"path":"avatars/avatar.png","upsert":false}; // CreateSignedUploadUrlDto | 

try {
    final response = api.storageControllerCreateSignedUploadUrl(createSignedUploadUrlDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerCreateSignedUploadUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSignedUploadUrlDto** | [**CreateSignedUploadUrlDto**](CreateSignedUploadUrlDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerCreateSignedUrl**
> JsonObject storageControllerCreateSignedUrl(path, expiresIn)

Create a signed read URL for a storage object

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final String path = companions/pixel-cat.png; // String | 
final num expiresIn = 3600; // num | 

try {
    final response = api.storageControllerCreateSignedUrl(path, expiresIn);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerCreateSignedUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **path** | **String**|  | 
 **expiresIn** | **num**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerFindFiles**
> BuiltList<StorageFileResponseDto> storageControllerFindFiles()

List registered storage file metadata

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();

try {
    final response = api.storageControllerFindFiles();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerFindFiles: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;StorageFileResponseDto&gt;**](StorageFileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerFindMyFiles**
> BuiltList<StorageFileResponseDto> storageControllerFindMyFiles()

List current user storage file metadata

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();

try {
    final response = api.storageControllerFindMyFiles();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerFindMyFiles: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;StorageFileResponseDto&gt;**](StorageFileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerGetAdminPublicUrl**
> JsonObject storageControllerGetAdminPublicUrl(path)

Get the public URL for an admin/catalog object

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final String path = companions/pixel-cat.png; // String | 

try {
    final response = api.storageControllerGetAdminPublicUrl(path);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerGetAdminPublicUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **path** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerGetCdnStrategy**
> JsonObject storageControllerGetCdnStrategy()

Get storage/CDN path and access strategy

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();

try {
    final response = api.storageControllerGetCdnStrategy();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerGetCdnStrategy: $e\n');
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

# **storageControllerGetHealth**
> JsonObject storageControllerGetHealth(deep)

Get storage configuration and optional deep connectivity health

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final bool deep = true; // bool | 

try {
    final response = api.storageControllerGetHealth(deep);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerGetHealth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deep** | **bool**|  | [optional] 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerGetMyStorageHealth**
> JsonObject storageControllerGetMyStorageHealth()

Get upload storage readiness for current user

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();

try {
    final response = api.storageControllerGetMyStorageHealth();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerGetMyStorageHealth: $e\n');
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

# **storageControllerGetPublicUrl**
> JsonObject storageControllerGetPublicUrl(path)

Get the public URL for a storage object

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final String path = companions/pixel-cat.png; // String | 

try {
    final response = api.storageControllerGetPublicUrl(path);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerGetPublicUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **path** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerRegisterFile**
> StorageFileResponseDto storageControllerRegisterFile(registerStorageFileDto)

Register storage file metadata

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final RegisterStorageFileDto registerStorageFileDto = {"filename":"avatar.png","mimetype":"image/png","size":245760,"path":"avatars/avatar.png","publicUrl":"https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/user-uploads/clx_user_01hv7q6y8e9r0t1y2u3i4o5p/avatars/avatar.png","isPublic":true,"metadata":{"domain":"profile","state":"avatar"}}; // RegisterStorageFileDto | 

try {
    final response = api.storageControllerRegisterFile(registerStorageFileDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerRegisterFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerStorageFileDto** | [**RegisterStorageFileDto**](RegisterStorageFileDto.md)|  | 

### Return type

[**StorageFileResponseDto**](StorageFileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerRemoveFileMetadata**
> StorageFileResponseDto storageControllerRemoveFileMetadata(id)

Delete storage file metadata by id

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final String id = clx_record_01hv7q6y8e9r0t1y2u3i4o5p; // String | 

try {
    final response = api.storageControllerRemoveFileMetadata(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerRemoveFileMetadata: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**StorageFileResponseDto**](StorageFileResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerRemoveObjects**
> JsonObject storageControllerRemoveObjects(removeStorageObjectDto)

Delete one or more objects from Supabase storage

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();
final RemoveStorageObjectDto removeStorageObjectDto = {"paths":["companions/old-pixel-cat.png"]}; // RemoveStorageObjectDto | 

try {
    final response = api.storageControllerRemoveObjects(removeStorageObjectDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerRemoveObjects: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **removeStorageObjectDto** | [**RemoveStorageObjectDto**](RemoveStorageObjectDto.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **storageControllerUploadAdminFile**
> JsonObject storageControllerUploadAdminFile()

Upload an admin/catalog file through the API

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();

try {
    final response = api.storageControllerUploadAdminFile();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerUploadAdminFile: $e\n');
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

# **storageControllerUploadAvatar**
> JsonObject storageControllerUploadAvatar()

Upload the current user avatar through the API

### Example
```dart
import 'package:relax_api_client/api.dart';

final api = RelaxApiClient().getStorageApi();

try {
    final response = api.storageControllerUploadAvatar();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->storageControllerUploadAvatar: $e\n');
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

