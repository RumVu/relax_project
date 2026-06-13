import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for FeatureFlagsApi
void main() {
  final instance = RelaxApiClient().getFeatureFlagsApi();

  group(FeatureFlagsApi, () {
    //Future featureFlagsControllerDelete(String key) async
    test('test featureFlagsControllerDelete', () async {
      // TODO
    });

    //Future featureFlagsControllerFindAll() async
    test('test featureFlagsControllerFindAll', () async {
      // TODO
    });

    //Future<JsonObject> featureFlagsControllerFindByKey(String key) async
    test('test featureFlagsControllerFindByKey', () async {
      // TODO
    });

    //Future featureFlagsControllerSeed() async
    test('test featureFlagsControllerSeed', () async {
      // TODO
    });

    //Future<JsonObject> featureFlagsControllerToggle(String key) async
    test('test featureFlagsControllerToggle', () async {
      // TODO
    });

    //Future featureFlagsControllerUpsert(UpsertFeatureFlagDto upsertFeatureFlagDto) async
    test('test featureFlagsControllerUpsert', () async {
      // TODO
    });

  });
}
