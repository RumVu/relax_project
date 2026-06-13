import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';

// tests for UpdateTierDto
void main() {
  final instance = UpdateTierDtoBuilder();
  // TODO add properties to the builder and call build()

  group(UpdateTierDto, () {
    // Unique internal code, UPPER_SNAKE only. E.g. CHILL_PLUS, CHILL_PLUS_ANNUAL.
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Display title shown to users. Falls back to name when null.
    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // Marketing copy / description.
    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // List price in the smallest visible unit (e.g. VND).
    // num price
    test('to test the property `price`', () async {
      // TODO
    });

    // Active sale price. Effective when within sale window.
    // num salePrice
    test('to test the property `salePrice`', () async {
      // TODO
    });

    // Short label shown beside the sale price, e.g. \"BLACK FRIDAY -20%\".
    // String saleLabel
    test('to test the property `saleLabel`', () async {
      // TODO
    });

    // ISO datetime when the sale starts.
    // String saleStartsAt
    test('to test the property `saleStartsAt`', () async {
      // TODO
    });

    // ISO datetime when the sale ends.
    // String saleEndsAt
    test('to test the property `saleEndsAt`', () async {
      // TODO
    });

    // ISO 4217 currency. Defaults to VND.
    // String currency
    test('to test the property `currency`', () async {
      // TODO
    });

    // String billingCycle
    test('to test the property `billingCycle`', () async {
      // TODO
    });

    // Display order, low to high.
    // num displayOrder (default value: 0)
    test('to test the property `displayOrder`', () async {
      // TODO
    });

    // bool isActive (default value: true)
    test('to test the property `isActive`', () async {
      // TODO
    });

  });
}
