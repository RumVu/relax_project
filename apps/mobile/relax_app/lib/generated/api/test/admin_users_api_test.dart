import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AdminUsersApi
void main() {
  final instance = RelaxApiClient().getAdminUsersApi();

  group(AdminUsersApi, () {
    // Read a user's current active subscription.
    //
    //Future adminUserPlanControllerGetCurrent(String userId) async
    test('test adminUserPlanControllerGetCurrent', () async {
      // TODO
    });

    // Admin-set the user's plan immediately, without going through payment. Cancels any active subscription and provisions a fresh ACTIVE one for the chosen tier.
    //
    //Future adminUserPlanControllerSetPlan(String userId, SetUserPlanDto setUserPlanDto) async
    test('test adminUserPlanControllerSetPlan', () async {
      // TODO
    });

  });
}
