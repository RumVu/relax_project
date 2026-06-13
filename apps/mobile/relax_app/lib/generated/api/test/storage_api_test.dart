import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for StorageApi
void main() {
  final instance = RelaxApiClient().getStorageApi();

  group(StorageApi, () {
    // Create a signed upload URL for catalog/admin paths
    //
    //Future<JsonObject> storageControllerCreateAdminSignedUploadUrl(CreateSignedUploadUrlDto createSignedUploadUrlDto) async
    test('test storageControllerCreateAdminSignedUploadUrl', () async {
      // TODO
    });

    // Create a signed read URL for an admin/catalog storage object
    //
    //Future<JsonObject> storageControllerCreateAdminSignedUrl(String path, { num expiresIn }) async
    test('test storageControllerCreateAdminSignedUrl', () async {
      // TODO
    });

    // Create a signed Supabase upload URL
    //
    //Future<JsonObject> storageControllerCreateSignedUploadUrl(CreateSignedUploadUrlDto createSignedUploadUrlDto) async
    test('test storageControllerCreateSignedUploadUrl', () async {
      // TODO
    });

    // Create a signed read URL for a storage object
    //
    //Future<JsonObject> storageControllerCreateSignedUrl(String path, { num expiresIn }) async
    test('test storageControllerCreateSignedUrl', () async {
      // TODO
    });

    // List registered storage file metadata
    //
    //Future<BuiltList<StorageFileResponseDto>> storageControllerFindFiles() async
    test('test storageControllerFindFiles', () async {
      // TODO
    });

    // List current user storage file metadata
    //
    //Future<BuiltList<StorageFileResponseDto>> storageControllerFindMyFiles() async
    test('test storageControllerFindMyFiles', () async {
      // TODO
    });

    // Get the public URL for an admin/catalog object
    //
    //Future<JsonObject> storageControllerGetAdminPublicUrl(String path) async
    test('test storageControllerGetAdminPublicUrl', () async {
      // TODO
    });

    // Get storage/CDN path and access strategy
    //
    //Future<JsonObject> storageControllerGetCdnStrategy() async
    test('test storageControllerGetCdnStrategy', () async {
      // TODO
    });

    // Get storage configuration and optional deep connectivity health
    //
    //Future<JsonObject> storageControllerGetHealth({ bool deep }) async
    test('test storageControllerGetHealth', () async {
      // TODO
    });

    // Get upload storage readiness for current user
    //
    //Future<JsonObject> storageControllerGetMyStorageHealth() async
    test('test storageControllerGetMyStorageHealth', () async {
      // TODO
    });

    // Get the public URL for a storage object
    //
    //Future<JsonObject> storageControllerGetPublicUrl(String path) async
    test('test storageControllerGetPublicUrl', () async {
      // TODO
    });

    // Register storage file metadata
    //
    //Future<StorageFileResponseDto> storageControllerRegisterFile(RegisterStorageFileDto registerStorageFileDto) async
    test('test storageControllerRegisterFile', () async {
      // TODO
    });

    // Delete storage file metadata by id
    //
    //Future<StorageFileResponseDto> storageControllerRemoveFileMetadata(String id) async
    test('test storageControllerRemoveFileMetadata', () async {
      // TODO
    });

    // Delete one or more objects from Supabase storage
    //
    //Future<JsonObject> storageControllerRemoveObjects(RemoveStorageObjectDto removeStorageObjectDto) async
    test('test storageControllerRemoveObjects', () async {
      // TODO
    });

    // Upload an admin/catalog file through the API
    //
    //Future<JsonObject> storageControllerUploadAdminFile() async
    test('test storageControllerUploadAdminFile', () async {
      // TODO
    });

    // Upload the current user avatar through the API
    //
    //Future<JsonObject> storageControllerUploadAvatar() async
    test('test storageControllerUploadAvatar', () async {
      // TODO
    });

  });
}
