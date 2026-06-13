import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AmbientSoundsApi
void main() {
  final instance = RelaxApiClient().getAmbientSoundsApi();

  group(AmbientSoundsApi, () {
    // Create an ambient sound
    //
    //Future<AmbientSoundResponseDto> ambientSoundsControllerCreate(CreateAmbientSoundDto createAmbientSoundDto) async
    test('test ambientSoundsControllerCreate', () async {
      // TODO
    });

    // List ambient sounds
    //
    //Future<AmbientSoundPageDto> ambientSoundsControllerFindAll({ String q, String category, bool isActive, num skip, num limit }) async
    test('test ambientSoundsControllerFindAll', () async {
      // TODO
    });

    // List ambient sounds by category
    //
    //Future<BuiltList<AmbientSoundResponseDto>> ambientSoundsControllerFindByCategory(String category) async
    test('test ambientSoundsControllerFindByCategory', () async {
      // TODO
    });

    // Delete an ambient sound
    //
    //Future<AmbientSoundResponseDto> ambientSoundsControllerRemove(String id) async
    test('test ambientSoundsControllerRemove', () async {
      // TODO
    });

    // Update an ambient sound
    //
    //Future<AmbientSoundResponseDto> ambientSoundsControllerUpdate(String id, UpdateAmbientSoundDto updateAmbientSoundDto) async
    test('test ambientSoundsControllerUpdate', () async {
      // TODO
    });

  });
}
