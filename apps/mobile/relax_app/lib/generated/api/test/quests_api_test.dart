import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for QuestsApi
void main() {
  final instance = RelaxApiClient().getQuestsApi();

  group(QuestsApi, () {
    // List my active daily quests (auto-seeded + auto-completed).
    //
    //Future<BuiltList<JsonObject>> questsControllerGetMine({ String locale }) async
    test('test questsControllerGetMine', () async {
      // TODO
    });

    // Replace one of my active quests with a different random template I have not seen.
    //
    //Future<JsonObject> questsControllerReroll(String id, { String locale }) async
    test('test questsControllerReroll', () async {
      // TODO
    });

  });
}
