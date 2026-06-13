import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for HealthApi
void main() {
  final instance = RelaxApiClient().getHealthApi();

  group(HealthApi, () {
    // Get API index and exposed module map
    //
    //Future<JsonObject> appControllerGetApiIndex() async
    test('test appControllerGetApiIndex', () async {
      // TODO
    });

    // Get API index alias
    //
    //Future<JsonObject> appControllerGetApiIndexAlias() async
    test('test appControllerGetApiIndexAlias', () async {
      // TODO
    });

    // Get shallow API liveness status
    //
    //Future<JsonObject> appControllerGetHealth({ String deep }) async
    test('test appControllerGetHealth', () async {
      // TODO
    });

    // Get full ops status for admin dashboard
    //
    //Future appControllerGetOps() async
    test('test appControllerGetOps', () async {
      // TODO
    });

    // Get deep API readiness status
    //
    //Future<JsonObject> appControllerGetReady() async
    test('test appControllerGetReady', () async {
      // TODO
    });

  });
}
