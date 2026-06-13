import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for CompanionAssetsApi
void main() {
  final instance = RelaxApiClient().getCompanionAssetsApi();

  group(CompanionAssetsApi, () {
    // Create a companion asset
    //
    //Future<CompanionAssetResponseDto> companionAssetsControllerCreate(CreateCompanionAssetDto createCompanionAssetDto) async
    test('test companionAssetsControllerCreate', () async {
      // TODO
    });

    // List companion assets
    //
    //Future<CompanionAssetPageDto> companionAssetsControllerFindAll({ String q, String category, bool isActive, num skip, num limit }) async
    test('test companionAssetsControllerFindAll', () async {
      // TODO
    });

    // Get the default companion asset
    //
    //Future<CompanionAssetResponseDto> companionAssetsControllerFindDefault() async
    test('test companionAssetsControllerFindDefault', () async {
      // TODO
    });

    // Delete a companion asset
    //
    //Future<CompanionAssetResponseDto> companionAssetsControllerRemove(String id) async
    test('test companionAssetsControllerRemove', () async {
      // TODO
    });

    // Update a companion asset
    //
    //Future<CompanionAssetResponseDto> companionAssetsControllerUpdate(String id, UpdateCompanionAssetDto updateCompanionAssetDto) async
    test('test companionAssetsControllerUpdate', () async {
      // TODO
    });

  });
}
