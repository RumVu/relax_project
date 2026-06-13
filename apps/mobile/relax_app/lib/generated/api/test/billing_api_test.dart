import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for BillingApi
void main() {
  final instance = RelaxApiClient().getBillingApi();

  group(BillingApi, () {
    // Confirm a pending payment and activate the subscription
    //
    //Future<ConfirmPaymentResponseDto> billingControllerConfirmPayment(String id, ConfirmPaymentDto confirmPaymentDto) async
    test('test billingControllerConfirmPayment', () async {
      // TODO
    });

    // Create a checkout session intent
    //
    //Future<CheckoutSessionResponseDto> billingControllerCreateCheckoutSession(CreateCheckoutSessionDto createCheckoutSessionDto) async
    test('test billingControllerCreateCheckoutSession', () async {
      // TODO
    });

    // Get current user billing state
    //
    //Future<BillingMeResponseDto> billingControllerGetMine() async
    test('test billingControllerGetMine', () async {
      // TODO
    });

    // Get current user payment history
    //
    //Future<JsonObject> billingControllerGetMyPayments() async
    test('test billingControllerGetMyPayments', () async {
      // TODO
    });

    // Get a single payment status
    //
    //Future<JsonObject> billingControllerGetPayment(String id) async
    test('test billingControllerGetPayment', () async {
      // TODO
    });

    // List available subscription plans
    //
    //Future<BuiltList<BillingPlanResponseDto>> billingControllerGetPlans() async
    test('test billingControllerGetPlans', () async {
      // TODO
    });

    // Get billing/payment provider status
    //
    //Future<ProviderStatusResponseDto> billingControllerGetProviderStatus() async
    test('test billingControllerGetProviderStatus', () async {
      // TODO
    });

    // SePay webhook payment callback
    //
    //Future<JsonObject> sepayControllerHandleWebhook(String authorization) async
    test('test sepayControllerHandleWebhook', () async {
      // TODO
    });

    // SePay legacy webhook payment callback
    //
    //Future<JsonObject> sepayLegacyControllerHandleWebhook(String authorization) async
    test('test sepayLegacyControllerHandleWebhook', () async {
      // TODO
    });

  });
}
