import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';

// tests for ConfirmPaymentDto
void main() {
  final instance = ConfirmPaymentDtoBuilder();
  // TODO add properties to the builder and call build()

  group(ConfirmPaymentDto, () {
    // Plan the pending payment was created for. The backend re-resolves the plan from SubscriptionTier/fallback catalog and verifies the paid amount matches before activating the subscription.
    // String planName
    test('to test the property `planName`', () async {
      // TODO
    });

  });
}
