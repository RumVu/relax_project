import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for RealtimeApi
void main() {
  final instance = RelaxApiClient().getRealtimeApi();

  group(RealtimeApi, () {
    // Get Socket.IO realtime status and Redis adapter mode
    //
    //Future<JsonObject> realtimeControllerHealth() async
    test('test realtimeControllerHealth', () async {
      // TODO
    });

  });
}
