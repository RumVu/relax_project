import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AdminDashboardApi
void main() {
  final instance = RelaxApiClient().getAdminDashboardApi();

  group(AdminDashboardApi, () {
    // Get admin aggregate dashboard metrics for users, billing, retention, engagement, and operations
    //
    //Future adminDashboardControllerGetOverview({ String period, DateTime from, DateTime to, String timezone, num timezoneOffsetMinutes }) async
    test('test adminDashboardControllerGetOverview', () async {
      // TODO
    });

    // Search indexed dashboard/admin content
    //
    //Future adminDashboardControllerSearch({ String q, String entityType, num skip, num limit }) async
    test('test adminDashboardControllerSearch', () async {
      // TODO
    });

  });
}
