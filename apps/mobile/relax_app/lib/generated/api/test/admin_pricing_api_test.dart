import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AdminPricingApi
void main() {
  final instance = RelaxApiClient().getAdminPricingApi();

  group(AdminPricingApi, () {
    // Drop the active sale window without touching the regular price.
    //
    //Future adminPricingControllerClearSale(String id) async
    test('test adminPricingControllerClearSale', () async {
      // TODO
    });

    // Create a new tier.
    //
    //Future adminPricingControllerCreate(CreateTierDto createTierDto) async
    test('test adminPricingControllerCreate', () async {
      // TODO
    });

    // Soft-deactivate the tier (sets isActive=false). Hard-delete would orphan past payments.
    //
    //Future adminPricingControllerDeactivate(String id) async
    test('test adminPricingControllerDeactivate', () async {
      // TODO
    });

    // Fetch one tier by id.
    //
    //Future adminPricingControllerFindOne(String id) async
    test('test adminPricingControllerFindOne', () async {
      // TODO
    });

    // List every subscription tier (active + inactive).
    //
    //Future adminPricingControllerList() async
    test('test adminPricingControllerList', () async {
      // TODO
    });

    // Update price, sale, title, display order, or activation flag of a tier.
    //
    //Future adminPricingControllerUpdate(String id, UpdateTierDto updateTierDto) async
    test('test adminPricingControllerUpdate', () async {
      // TODO
    });

  });
}
