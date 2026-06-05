import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/api_client.dart';
import '../core/theme.dart';

/// Màn nạp tiền / nâng cấp gói: liệt kê plan từ /billing/plans, hiển thị gói
/// hiện tại từ /billing/me, bấm Nâng cấp → POST checkout-session → mở
/// WebView SePay (form auto-submit qua HTML wrapper).
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _plans = [];
  String _currentPlan = 'FREE';
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/billing/plans'),
        RelaxApi.instance.get('/billing/me'),
      ]);
      final plansData = results[0].data;
      _plans = (plansData is List)
          ? plansData
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
      final sub =
          (results[1].data is Map ? results[1].data['subscription'] : null) as Map?;
      _currentPlan = (sub?['planName'] as String?) ?? 'FREE';
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _start(Map<String, dynamic> plan) async {
    if (plan['name'] == _currentPlan) return;
    setState(() => _starting = true);
    try {
      final res = await RelaxApi.instance.post(
        '/billing/me/checkout-session',
        body: {
          'planName': plan['name'],
          'provider': 'SEPAY',
        },
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final checkout =
            (res.data is Map ? res.data['checkout'] : null) as Map?;
        final url = checkout?['checkoutUrl'] as String?;
        final fields = checkout?['checkoutFormfields'] as Map?;
        if (url != null && fields != null) {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => _CheckoutWebView(
                url: url,
                fields: Map<String, dynamic>.from(fields),
                planTitle: (plan['title'] as String?) ?? plan['name'] as String,
              ),
            ),
          );
          if (!mounted) return;
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: RelaxColors.mint,
              content: Text('Cảm ơn bạn đã nâng cấp 💜'),
            ));
            await _load();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: RelaxColors.coral,
            content: Text('Không lấy được link thanh toán'),
          ));
        }
      } else {
        final msg = (res.data?['message'] as String?) ?? 'Tạo phiên thanh toán lỗi';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: RelaxColors.coral,
          content: Text(msg),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: RelaxColors.coral,
          content: Text(e.toString()),
        ));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nạp thẻ / Nâng cấp',
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : RefreshIndicator(
                color: RelaxColors.violet,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RelaxColors.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: RelaxColors.coral),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(
                                color: RelaxColors.coral, fontSize: 12)),
                      ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [RelaxColors.violet, RelaxColors.plum],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mở khóa Chill Plus 💜',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Phân tích cảm xúc sâu, đổi linh thú theo cung & '
                            'con giáp, mở mọi mode giao diện và nhiều hơn nữa.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._plans.map(_buildPlan),
                    const SizedBox(height: 12),
                    Text(
                      'Thanh toán an toàn qua cổng SePay. Bạn có thể hủy bất '
                      'cứ lúc nào trong Setup.',
                      style: TextStyle(color: context.mutedText, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPlan(Map<String, dynamic> plan) {
    final name = plan['name'] as String;
    final title = (plan['title'] as String?) ?? name;
    final desc = plan['description'] as String?;
    final price = (plan['effectivePrice'] as num?)?.toInt() ??
        (plan['price'] as num?)?.toInt() ??
        0;
    final cur = (plan['currency'] as String?) ?? 'VND';
    final cycle = (plan['billingCycle'] as String?) ?? 'MONTHLY';
    final isCurrent = name == _currentPlan;
    final isPaid = price > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCurrent
            ? RelaxColors.mint.withValues(alpha: 0.08)
            : context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? RelaxColors.mint
              : isPaid
                  ? RelaxColors.violet
                  : context.fieldBorder,
          width: isPaid && !isCurrent ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: context.appText,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: RelaxColors.mint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Đang dùng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          if (desc != null && desc.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(color: context.mutedText, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtPrice(price),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isPaid ? RelaxColors.violet : context.appText,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  cur == 'VND' ? '₫ / ${_cycle(cycle)}' : '$cur / ${_cycle(cycle)}',
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent
                    ? context.surfaceAlt
                    : isPaid
                        ? RelaxColors.violet
                        : RelaxColors.lilac,
                foregroundColor: isCurrent ? context.mutedText : Colors.white,
              ),
              onPressed: (isCurrent || _starting || !isPaid)
                  ? null
                  : () => _start(plan),
              child: _starting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(isCurrent
                      ? 'Bạn đang ở gói này'
                      : isPaid
                          ? 'Nâng cấp ngay'
                          : 'Gói miễn phí'),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtPrice(int v) {
    if (v == 0) return 'Miễn phí';
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _cycle(String c) {
    switch (c.toUpperCase()) {
      case 'ANNUAL':
      case 'YEARLY':
        return 'năm';
      case 'MONTHLY':
        return 'tháng';
      default:
        return c.toLowerCase();
    }
  }
}

/// WebView mở trang SePay với form fields auto-submit. Đóng khi gặp success/
/// error/cancel URL.
class _CheckoutWebView extends StatefulWidget {
  const _CheckoutWebView({
    required this.url,
    required this.fields,
    required this.planTitle,
  });
  final String url;
  final Map<String, dynamic> fields;
  final String planTitle;

  @override
  State<_CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<_CheckoutWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            final u = req.url;
            // Backend gửi success_url / cancel_url / error_url dạng
            // http://localhost:3233/billing?status=... — match qua param "status".
            if (u.contains('status=success')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            if (u.contains('status=cancel') || u.contains('status=error')) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildAutoSubmitHtml());
  }

  String _buildAutoSubmitHtml() {
    final fieldsHtml = widget.fields.entries
        .map((e) =>
            '<input type="hidden" name="${e.key}" value="${_escape(e.value.toString())}" />')
        .join();
    // Auto-submit form to SePay sandbox/production checkout URL.
    return '''
<!DOCTYPE html>
<html><head><meta name="viewport" content="width=device-width,initial-scale=1"/>
<style>body{font-family:system-ui;background:#f5f3ff;display:flex;align-items:center;justify-content:center;min-height:100vh;color:#14122e;margin:0}</style>
</head><body>
<div>Đang chuyển tới trang thanh toán…</div>
<form id="f" method="POST" action="${widget.url}">$fieldsHtml</form>
<script>document.getElementById('f').submit();</script>
</body></html>
''';
  }

  String _escape(String v) =>
      v.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán ${widget.planTitle}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const LinearProgressIndicator(
              color: RelaxColors.violet,
              backgroundColor: Colors.transparent,
              minHeight: 3,
            ),
        ],
      ),
    );
  }
}
