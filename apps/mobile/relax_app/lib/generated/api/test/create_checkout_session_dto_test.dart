import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';

// tests for CreateCheckoutSessionDto
void main() {
  final instance = CreateCheckoutSessionDtoBuilder();
  // TODO add properties to the builder and call build()

  group(CreateCheckoutSessionDto, () {
    // String planName
    test('to test the property `planName`', () async {
      // TODO
    });

    // Deprecated compatibility field. The backend always prices from SubscriptionTier/fallback plan catalog and ignores client-provided amount.
    // num amount
    test('to test the property `amount`', () async {
      // TODO
    });

    // Deprecated compatibility field. The backend always uses the server-side plan currency.
    // String currency
    test('to test the property `currency`', () async {
      // TODO
    });

    // String provider
    test('to test the property `provider`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // String successUrl
    test('to test the property `successUrl`', () async {
      // TODO
    });

    // String errorUrl
    test('to test the property `errorUrl`', () async {
      // TODO
    });

    // String cancelUrl
    test('to test the property `cancelUrl`', () async {
      // TODO
    });

  });
}
