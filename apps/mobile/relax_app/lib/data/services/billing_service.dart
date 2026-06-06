import '../../core/api_client.dart';

/// Phản hồi từ POST /billing/me/checkout-session.
class CheckoutSession {
  const CheckoutSession({
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.provider,
    this.checkoutUrl,
    this.qrUrl,
  });

  final String paymentId;
  final int amount;
  final String currency;
  final String provider;
  final String? checkoutUrl; // URL mở trong WebView (SePay / Stripe)
  final String? qrUrl;       // QR fallback nếu provider chưa wire URL

  factory CheckoutSession.fromJson(Map<String, dynamic> j) {
    final pay = (j['payment'] is Map)
        ? Map<String, dynamic>.from(j['payment'] as Map)
        : j;
    return CheckoutSession(
      paymentId: (pay['id'] ?? j['paymentId'] ?? '').toString(),
      amount: (pay['amount'] as num?)?.toInt() ?? 0,
      currency: (pay['currency'] ?? 'VND').toString(),
      provider: (pay['provider'] ?? j['provider'] ?? 'MANUAL').toString(),
      checkoutUrl: (j['checkoutUrl'] ?? pay['checkoutUrl']) as String?,
      qrUrl: (j['qrUrl'] ?? pay['qrUrl']) as String?,
    );
  }
}

/// Gọi /v1/billing/me/* — checkout + confirm.
class BillingService {
  BillingService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Tạo phiên checkout cho plan. Backend trả URL/QR để mở WebView.
  Future<CheckoutSession> createCheckoutSession({
    required String accessToken,
    required String planName,
    String provider = 'MANUAL',
  }) async {
    final body = await _client.postJson(
      '/billing/me/checkout-session',
      <String, Object?>{
        'planName': planName,
        'provider': provider,
      },
      accessToken: accessToken,
    );
    if (body is Map) {
      return CheckoutSession.fromJson(Map<String, dynamic>.from(body));
    }
    throw const ApiException('Backend không trả checkout session.');
  }

  /// Sau khi user thanh toán xong (qua WebView callback), confirm payment.
  Future<void> confirmPayment({
    required String accessToken,
    required String paymentId,
  }) async {
    await _client.postJson(
      '/billing/me/payments/$paymentId/confirm',
      <String, Object?>{},
      accessToken: accessToken,
    );
  }
}
