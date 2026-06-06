import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/billing_service.dart';

/// CheckoutScreen — mở WebView SePay/Stripe để user thanh toán.
/// Detect URL callback (`success` / `cancel`) → confirm payment + pop.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.session});
  final CheckoutSession session;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _confirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final url = widget.session.checkoutUrl ?? widget.session.qrUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            final u = request.url.toLowerCase();
            // Mở rộng pattern detection — SePay/Stripe/PayPal đều có thể
            // dùng các convention khác nhau. Match càng nhiều tốt cho user.
            final successPatterns = [
              'status=success',
              'status=succeeded',
              'status=paid',
              'status=completed',
              '/billing?success',
              '/billing/success',
              'payment-success',
              'payment_success',
              'transaction=success',
              '/success?',
            ];
            final cancelPatterns = [
              'status=cancel',
              'status=cancelled',
              'status=canceled',
              'status=failed',
              'payment-cancel',
              'payment_cancel',
              '/cancel?',
              '/failed?',
            ];
            if (successPatterns.any(u.contains)) {
              _onSuccess();
              return NavigationDecision.prevent;
            }
            if (cancelPatterns.any(u.contains)) {
              _onCancel();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    if (url != null && url.isNotEmpty) {
      _controller.loadRequest(Uri.parse(url));
    } else {
      _error = 'Provider chưa trả URL checkout — không thể mở thanh toán.';
      _loading = false;
    }
  }

  Future<void> _onSuccess() async {
    if (_confirming) return;
    setState(() => _confirming = true);
    bool confirmOk = false;
    try {
      final sess = context.sessionOrNull;
      if (sess != null && sess.isLoggedIn) {
        await BillingService().confirmPayment(
          accessToken: sess.accessToken!,
          paymentId: widget.session.paymentId,
        );
        confirmOk = true;
      }
    } catch (e) {
      // Trước đây silent — nếu webhook fail thì payment confirmed ở
      // gateway nhưng backend không biết → user mất tiền không có gói.
      // Log + show toast warn user contact support; vẫn pop true vì
      // payment thực sự success ở gateway.
      debugPrint('[checkout] confirmPayment failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã thanh toán nhưng kích hoạt gói chậm. '
              'Liên hệ hỗ trợ nếu sau 10 phút chưa thấy gói mới.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(confirmOk); // true = backend confirmed
  }

  void _onCancel() {
    Navigator.of(context).pop(false); // false = cancel
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _onCancel,
        ),
        title: const Text('Thanh toán'),
        actions: [
          if (_confirming)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _error != null
          ? _ErrorView(message: _error!, onClose: _onCancel)
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onClose});
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: context.relax.danger,
          ),
          const SizedBox(height: 14),
          Text(
            'Không mở được trang thanh toán',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onClose,
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
