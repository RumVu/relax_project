import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for QueuesApi
void main() {
  final instance = RelaxApiClient().getQueuesApi();

  group(QueuesApi, () {
    // Get Redis-backed queue health and registered queue names
    //
    //Future<JsonObject> queuesControllerHealth({ String deep }) async
    test('test queuesControllerHealth', () async {
      // TODO
    });

  });
}
