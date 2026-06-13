import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AnalyticsApi
void main() {
  final instance = RelaxApiClient().getAnalyticsApi();

  group(AnalyticsApi, () {
    // Get analytics response contracts for app charts
    //
    //Future<JsonObject> analyticsControllerGetContracts() async
    test('test analyticsControllerGetContracts', () async {
      // TODO
    });

    // Get current user full analytics overview
    //
    //Future<JsonObject> analyticsControllerGetOverview({ String period, num timezoneOffsetMinutes, String timezone }) async
    test('test analyticsControllerGetOverview', () async {
      // TODO
    });

  });
}
